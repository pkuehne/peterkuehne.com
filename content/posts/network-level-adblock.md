---
title: "Network Level Adblock"
date: 2018-09-27
draft: false
categories: ["home-network"]
tags:
    - dns
    - adblock
    - ansible
series: [""]
---

I've had my own [internal DNS][post-internal-dns] for a while now and it's been working great. I've even pointed my router's DHCP config to hand out the Raspberry Pi's IP address as the network's authoritative DNS Server. 

At the same time I've used [AdBlock Plus][adblock-plus] for a while now in my browser, but I was always unhappy that I couldn't have the same thing on my Pixel as well. Particularly as ads and popups are even more annoying on a small screen when you just want to look something up. (edit: *Adblock Plus has since been release for mobile, but the rest of this still stands*). 

I started looking into [Pi-hole][pi-hole] as a way to do network-level blocking of ads. After reading the documentation and some questions on StackOverflow, it quickly became apparent that Pi-hole is just a souped-up version of my own DNS server, even running `dnsmasq`. I didn't feel like giving up my own DNS server and a whole Raspberry Pi, so went ahead and replicated the setup myself through my trusty Ansible setup.

First thing was to find a source for the adblock domains, etc. I was extremely fortunate to find that someone not only already maintains a list but even has it in `dnsmasq` config notation. So all I had to do was to to download it and then include it in my own config.

{{< highlight yaml >}}
tasks:
  - name: "Download adblock domains"
    become: yes
    get_url:
      url: "https://raw.githubusercontent.com/notracking/hosts-blocklists/master/domains.txt"
      dest: "/etc/adblock_domains.dnsmasq"
      force: yes
  - name: "Download adblock hosts"
    become: yes
    get_url:
      url: "https://raw.githubusercontent.com/notracking/hosts-blocklists/master/hostnames.txt"
      dest: "/etc/adblock_hosts.dnsmasq"
      force: yes
{{< / highlight >}}

Then in the `dnsmasq` config file template I could simply insert the two files as configuration and additional hosts respectively:

{{< highlight cfg >}}
# Adblock
conf-file=/etc/adblock_domains.dnsmasq
addn-hosts=/etc/adblock_hosts.dnsmasq
{{< / highlight >}}

This responds to known adserver domains with an `NXDOMAIN`, meaning that it pretends there is no such domain available to resolve to an IP. Most adserver code fails gracefully if it can't find its domain to server ads from. So in the majority of cases, it just silently doesn't show you any ads.

The other advantage is for my guests, who automatically get ad-free browsing experience when on my wifi. Except Android that is. Apparently, Google always ignores the DHCP provided DNS server and uses its own. Very annoying, but I'm sure there's a way around that too.

[post-internal-dns]: {{< ref my-own-dns >}}
[adblock-plus]: https://adblockplus.org/
[pi-hole]: https://pi-hole.net