---
title: My Own DNS
date: 2018-04-07
draft: false
categories: ["Home Network"]
tags: 
    - ansible
    - dns
    - raspberry-pi
---

I've been meaning to do this for ages now and today I found the time to do it right. I installed [dnsmasq][dnsmasq] on a spare Raspberry Pi to do three things:

1. Provide nice name resolution on my servers (i.e. `*foo*.peterkuehne.com`)
2. Log all DNS queries (for stats, etc, not for actual monitoring)
3. Cache DNS lookups and make browsing a few milliseconds faster

As far as I can see right now, this all works great. It took me a while to get the DNS IP set up properly on my Windows machine, but after some restarting, even that worked.

Already I'm seeing a bunch of requests from random places, like my NAS trying to find some NXDOMAIN for a service that Netgear seems to have shut down a while ago, but never removed the requests for. I can't stop the requests, but I can at least reduce the outbound traffic to my upstream nameservers.

[dnsmasq]: http://www.thekelleys.org.uk/dnsmasq/doc.html
