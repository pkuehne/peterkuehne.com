---
title: "Capturing Restic Stats"
date: 2020-08-09
draft: false
categories: ["home-network"]
tags:
    - restic
    - backup
    - influxdb
series: ""
---

## Backup a sec

A while back I wrote a post about [restic], which is a great backup solution for incremental, encrypted backups. I played around with it for a bit, created an Ansible playbook to install it on my machines and made it simple to use by only having to add an entry to a file. Since then I've not used it again[^tried]. Like most backup solutions, it just sort of sat there and didn't do much. 

Then I recently had a scare when my NUC started acting up after I'd upgraded to Ubuntu 18.04[^20]. So had a look at what configuration files or directories I definitely wanted to keep and added them to the `sources.lst` file, which drives what `restic` backs up. It worked, I even tried to do a restore and that all seemed to be OK. Then I wanted to take a look about how much data `restic` was actually backing up each time it ran. Granted, it is an incremental backup, but if enough changed, that could still be a lot of data.

So I did what anyone would do: pull the stats into a new `influxdb` database to build a `Grafana` dashboard.

## Check your health

But first things first: How do we know the backup succeeded each night? Nothing worse than trying to recover a backup only to discover that the cron job has been failing for the past few months.

So I extended the script I had originally with a healthcheck ping. You go to [healthchecks.io], set up an account and create an ID. You can then ping that ID with a simple GET request via `curl` and `healthchecks.io` knows all is good. So how do you know that the ping failed to be run? You set a timeout within which the ping should occur. So I've set mine up to happen every 24h plus ten minutes (to give it time to complete the backup). If a ping takes longer than that to arrive, somethings wrong and `healthchecks.io` will send me an e-mail (or a Pushover notification) to say the check has failed. The whole thing looks like this in the script:

<!-- markdownlint-disable -->
{{< highlight bash >}}
echo "$(date) - Running healthcheck ping"
curl -sS --retry 3 https://hc-ping.com/hex-uuid-string > /dev/null
{{< /highlight >}}
<!-- markdownlint-restore-->

The echo is there because the scripts output is redirected to a logfile, so I can see how long the run took, etc. Cron doesn't have a good way to see script output otherwise.

## Getting the stats

First thing to do is to actually capture the metrics. `restic` actually has a whole subcommand to do just that. It prints out the stats in a number of formats, but the easiest to parse is probably json. It also distinguishes between all-time stats and latest.

<!-- markdownlint-disable -->
{{< highlight bash >}}
/usr/local/bin/restic -r $REPO stats latest --host $HOSTNAME --json > /tmp/restic_stats_latest
/usr/local/bin/restic -r $REPO stats        --host $HOSTNAME --json > /tmp/restic_stats_all
{{< /highlight >}}
<!-- markdownlint-restore-->

Depending on how you've set up your restic, the repo name could be an `S3` bucket or a directory on your NAS. Take a look at the origin [restic] article for more information.

Next, we need to parse the stats to be able to load individual metrics into our `influxdb` database. We'll use `jq` for this, which can easily parse `json` files and extract individual keys:

<!-- markdownlint-disable -->
{{< highlight bash >}}
STAT_LATEST_TOTAL_FILES=$(jq '.total_file_count' /tmp/restic_stats_latest)
STAT_LATEST_TOTAL_SIZE=$(jq '.total_size' /tmp/restic_stats_latest)
STAT_ALL_TOTAL_FILES=$(jq '.total_file_count' /tmp/restic_stats_all)
STAT_ALL_TOTAL_SIZE=$(jq '.total_size' /tmp/restic_stats_all)
{{< /highlight >}}
<!-- markdownlint-restore-->

We are only extracting a subset of the stats available here, the number of files changed and the total size uploaded, but this can be easily extended to capture everything that `restic` reports in the stat command.

## An influx of data
I wrote a while back about how to setup [influxdb] (and related services) via `Ansible`, so this assumes that has already been done. To be fair, with plenty of docker images around it's not particularly difficult.

It's a good idea to ensure the database exists before you start writing to it. Of course you can just create it once and assume you don't just delete it. One the other hand it's just one more request to make and should essentially be a no-op.

<!-- markdownlint-disable -->
{{< highlight bash >}}
curl -i -XPOST "192.168.1.xxx:8086/query" --data-urlencode 'q=CREATE DATABASE IF NOT EXISTS "restic"'
{{< /highlight >}}
<!-- markdownlint-restore-->

This will ensure the database is there. Now, adding new measurements is extremely easy by simply using `curl` like so:

<!-- markdownlint-disable -->
{{< highlight bash >}}
INFLUXDB_ENDPOINT="192.168.1.xxx:8086/write?db=restic"
curl -sS -XPOST "$INFLUXDB_ENDPOINT" --data-binary "latest,host=$HOSTNAME,repo=$REPO total_file_count=$STAT_LATEST_TOTAL_FILES" > /dev/null
curl -sS -XPOST "$INFLUXDB_ENDPOINT" --data-binary "latest,host=$HOSTNAME,repo=$REPO total_size=$STAT_LATEST_TOTAL_SIZE" > /dev/null
curl -sS -XPOST "$INFLUXDB_ENDPOINT" --data-binary "all,host=$HOSTNAME,repo=$REPO total_file_count=$STAT_ALL_TOTAL_FILES" > /dev/null
curl -sS -XPOST "$INFLUXDB_ENDPOINT" --data-binary "all,host=$HOSTNAME,repo=$REPO total_size=$STAT_ALL_TOTAL_SIZE" > /dev/null
{{< /highlight >}}
<!-- markdownlint-restore-->

The format takes a little getting used to the first time you look at it. Basically everything before the first space are the tags that will be applied to the measurement. In our case whether it's for "all" or "latest", which host the measurement was taken and which repo it was uploaded to. You could add many more tags here, but this will allow you to see measurements per host for the latest `restic` run. After the space comes the actual measurement with field name equals value.

The whole query has to be binary encoded and sent as a `POST` request. That's it. I recommend playing around with it in a script first to get a feel for what tags you want, how they'll appear in Grafana, etc.

That's already it, if all goes well and there are no errors, the data should be available in Grafana as soon as the first backup completes.

[restic]: {{< ref "backup-as-a-service-using-restic" >}}
[influxdb]: {{< ref "collecting-all-the-data" >}}
[^tried]: Let alone have its restore capability tested!
[^20]: Yes, yes, I know that 20.04 is out already...