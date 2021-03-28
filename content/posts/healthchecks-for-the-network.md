---
title: "Healthchecks for the Network"
date: 2020-01-11
draft: false
categories: ["home-network"]
tags:
    - healthcheck
    - ansible
series: ""
---

Over the Christmas holidays, we spent a couple of weeks abroad with family. During this time, I still like to have access to my network, both for the self-hosted services I have but also so I can play around with new ideas during the downtime.

Unfortunately, about halfway through our holiday, I lost access. I couldn't tell whether this was because my [DNS Updater][dns-update] script failed to set the correct dynamic WAN IP on my DNS record, or whether the router had locked up, or my servers were down. I was relatively sure that they couldn't be all down, as I lost access to the [VPN][vpn] as well as SSH and they run on separate Raspberry Pis, but without visibility into the network, I couldn't tell[^1].

So I resolved to get some sort of heartbeat put in place to get a signal every few minutes if the server is still alive. I found [healthchecks.io][healthchecks], which did exactly what I wanted. You set up a check with a unique ID and specify both a timeout and a grace period. Then just ping a specific URL with the unique ID and the server is marked as **up**. Otherwise wait the grace period and mark it **down** if still no signal is received.

I of course set all this up with my Ansible playbooks and it couldn't have been easier. I added a new variable for each host in the `host_vars/hostname.yml` file called `healthcheck_id` and then set up the following task:

<!-- markdownlint-disable -->
{{< highlight yaml >}}
tasks:
  - name: Ensure healthcheck script exists
    template:
      src: 'healthcheck.sh'
      dest: '/home/ansible/healthcheck.sh'
      mode: '0755'

  - name: Ensure healthcheck job is added to cron
    cron:
      name: "healthcheck"
      minute: "*/5"
      job: "/home/ansible/healthcheck.sh > /dev/null"

{{< / highlight >}}
<!-- markdownlint-restore-->

The script is very straightforward, but I always prefer calling simple scripts than to have a naked command line argument. The script simple does a curl on the healthcheck.io URL with the relevant id:

<!-- markdownlint-disable -->
{{< highlight bash >}}
#! /bin/bash

curl -fsS --retry 3 https://hc-ping.com/{{ healthcheck_id }} > /dev/null
{{< / highlight >}}
<!-- markdownlint-restore-->

I then integrated this with my [Pushbullet][pushbullet] setup so I get notified as soon as a server is down and when it comes back up again. Additionally, I get these badges, which I can show in my internal dashboards and on this page!

Badge: [![Shield](https://healthchecks.io/badge/f64aa0cc-cc31-4423-a248-ab9721/CK9m-Cbo/servers.svg)](https://healthchecks.io)

Hopefully :point_up: says *up*!!!

[dns-update]: https://hub.docker.com/repository/docker/pkuehne/route53-update
[healthchecks]: https://healthchecks.io/
[vpn]: {{< ref "shutting-out-the-world.md" >}}
[^1]: Yeah, it was the router that needed a restart.
