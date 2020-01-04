---
title: Shutting out the World
date: 2019-07-17
draft: false
categories: [home-network]
tags: 
    - docker 
    - vpn
    - reverse-proxy 
    - raspberry-pi
    - self-hosted
---

I've been running some of my services so that they are accessible from the [outside world][post-outside-world]. Some of this has been for fun (like my [calibre][calibre] setup) and some because I want to keep control of my own data. I've [self-hosted][self-hosted] a quite a few services on my NUC now, including things like Plex and tinytinyrss. Many of them have been exposed to the internet as subdomain, so that I could use them both from within my own network and when I'm out and about. The reverse proxy would ensure that WAN requests (i.e. those from the internet at large) would always require a Basic Auth challenge, whereas within the network would not. I felt that this was pretty secure, particularly since the username/password were only ever sent via https.

That's not to say, I've always been 100% happy with having these services exposed and I've tried to be as [paranoid][post-hardening-reverse-proxy] as possible about securing them via a reverse proxy, running on a separate Raspberry Pi. The `nginx` reverse proxy also had its log files inspected by fail2ban, which would automatically ban IPs if they failed to authenticate twice within 10 minutes.

There were other problems as well though. I couldn't make this work for anything that simply required an address, like IP Camera viewers. Or anything that loaded data over some sort of web-worker tunnel. Requests would often fail and I was forced to leave selected routes unprotected in order for services to run correctly in the outside world.

Then I had a talk with a colleague and they mentioned that a friend of theirs had a similiar setup and that he'd been hacked. The hacker not only messed up all the config, installed a coin miner, but also encrypted a bunch of files to force a ransom.

I admit, I panic'ed a bit and as soon as I got home, I closed all external access via the proxy.

Chance to get hacked now: <1%, but I also could not longer access any of my services anymore.

Cue: [OpenVPN][openvpn]. After some googling, a lot of reading and a couple of failed starts, I settled on installing [PiVPN ][pivpn] on another Raspberry Pi. The setup was very simple actually and there are plenty of good guides out there to help. Within a couple of hours, I had it set up and generated a key for my Android phone to use. I installed the OpenVPN app, opened the `.ovpn` profile and hey presto it worked!

Now I can access my entire network from anywhere in the world, by simply connecting to my VPN. It's still not 100% secure, but far, far more than it was previously.

The other nice side-effect is that now when I browse the web while connected to the VPN, I get automatic adblock as the network traffic is routed over the VPN server and uses my own DNS. Goodbye ads.

[post-outside-world]: {{< ref "outside-access" >}}
[post-hardening-reverse-proxy]:  {{< ref "hardening-the-reverse-proxy" >}}
[self-hosted]: {{< relref "/tags/self-hosted" >}}
[post-network-level-adblock]: {{< ref "network-level-adblock" >}}
[calibre]: https://calibre-ebook.com
[pivpn]: https://www.pivpn.io
[openvpn]: https://openvpn.net
