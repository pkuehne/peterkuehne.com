---
title: "Adding a Schema to LDAP"
date: 2020-01-17
draft: false
categories: ["home-network"]
tags:
    - ldap
    - docker
series: []
---

I've had an LDAP setup for a quite a while[^1], but I've never really used it. Sure, I could set up my [Dokuwiki][dokuwiki] to get the logins and groups from LDAP and that's kind of what it's for, but that wasn't enough. I wanted to use LDAP as a central configuration/setup/inventory management system. Configure my mail server to lookup email addresses there, assign port numbers and hosts for my services from there, etc.

And then I failed at the first hurdle. My LDAP setup didn't come with a schema for all the mail attributes I wanted. Sure the `mail` attribute was there, but I also wanted to specify `mailenable` to be able to turn mail access on/off. Also aliases and mailing lists. So I went looking for how to extend the schema of an LDAP server and boy did it take a lot of research[^2]. I actually abandoned it for a while and only picked it up again by chance the other day.

## Here's how I did it

I managed to find a [schema file][schema-file] with the exact attributes I was looking for in the [osixia/docker-openldap][osixia] github repo. However, you can't simply add the schema file to the server. It must be converted to `ldif` format first. There are plenty of blog posts online that explain how to do this, but I wanted something that just does it for me.

Which I found right [here][schema2ldif]. It's a script that will take a schema file and then spit out the relevant ldif for you. Properly formatted and everything. I had to modify the script a little bit to take the name of the schema file from the command line, but it was as simple as changing

<!-- markdownlint-disable -->
{{< highlight bash >}}
SCHEMAS='dhcp.schema'
# To this
SCHEMAS=$1
{{< /highlight >}}
<!-- markdownlint-restore -->

The major downside was that I needed to do this inside the LDAP docker container. So a quick `docker exec -i -t ldap /bin/bash` and I was in. I `curl`ed the script, modified it and ran the schema file through it[^3]. Then I tried to modify the schema by calling `ldapmodify`.

It didn't work. Apparently the `admin` user of the LDAP directory is different to the `admin` user of the config/schema. Since I didn't know that user's password, I had to create it. I looked up how to create the relevant ldif file:

<!-- markdownlint-disable -->
{{< highlight cfg >}}
dn: olcDatabase={0}config,cn=config
changetype: modify
replace: olcRootPW
olcRootPW: foobar123
{{< /highlight >}}
<!-- markdownlint-restore -->

I then called 'ldapmodify' and after that I could use the `cn=admin,cn=config` user to run `ldapadd` on my `mail.ldif`.

Once that was all done, I quick out of the docker container, restarted it and and hey presto, I can now add lots of `mail` related attributes.

![LDAP mail](/ldap-mail.png)

[dokuwiki]: https://www.dokuwiki.org
[schema-file]: https://github.com/osixia/docker-openldap/blob/stable/image/service/slapd/assets/config/bootstrap/schema/mmc/mail.schema
[osixia]: https://github.com/osixia/docker-openldap/
[schema2ldif]: https://gist.githubusercontent.com/markllama/8816768/raw/71078641bd14371bffb07e8fdc1215aaf1ea0075/schema2ldif.sh
[^1]: According to my commit history, since 2018-10-24
[^2]: Read: Google and StackExchange
[^3]: I feel that I should create a stand-alone docker container for this.
