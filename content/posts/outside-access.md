---
title: Outside Access
date: 2018-09-23
draft: false
categories: [home-network]
tags: 
    - ansible
    - nginx
    - reverse-proxy 
    - raspberry-pi
---

The NUC that I bought a while back has mainly just been used to run a [Plex][plex] server. Lately I've been playing with setting different things up on my Raspberry Pis, including my own [internal DNS][post-internal-dns]. Then I was talking to a colleague of mine about my [Munin][munin] setup and I really wanted to show him what I'm doing. So, perhaps a little radically, I devided to open up access to the outside world

Now, I know what you're saying: "That's _crazy_! No way you can make it secure." and that's partially true. I can't make it 100% secure, but I can make it as secure as I can (tautology alert!).

I grabbed one of the Raspberry PI 3B I hadn't yet coerced into being a playground and I created new ansible roles to setup nginx. The way it works, is relatively straight-forward. The Pi gets a static IP: `192.168.1.10`, to which I route all external traffic on port `80` and `443`. The [internal DNS][post-internal-dns] does the same, matching my internal domain name and re-routing it directly to the Pi, instead of letting it go out into the world wide web.

The nginx setup then gets a separate (but ansible generated) config file for each subdomain I want to make available. Ansible variables are used to set the name of the subdomain and the IP and port to which the domain will eventually proxy. Then we add a clever trick to require basic auth credentials only when coming in from the outside world:

{{< highlight nginx >}}
satisfy any;
allow 192.168.1.0/24;
deny all;

auth_basic "Restricted";
auth_basic_user_file /etc/nginx/.htpasswd;
{{< / highlight >}}

This way we either allow all acccess from inside the local network or else we require Basic Auth.

The next step is to acquire an SSL certificate from [Let's Encrypt][lets-encrypt] which covers all the subdomains. This way the username and password are encrypted in flight and can't be sniffed by middle-men.

[plex]: https://plex.tv/
[lets-encrypt]: https://letsencrypt.org/
[munin]: http://munin-monitoring.org/
[post-internal-dns]: {{< ref my-own-dns >}}
