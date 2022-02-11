---
title: "Automating This Blog - Part 2"
date: 2020-08-02
draft: false
categories: ["Technology"]
tags:
    - hugo
    - blog
    - docker
series: ""
---

When I started writing this blog, I had put aside a spare Raspberry Pi as kind of "dev" server. A place I could freely install stuff, test out code and run my [Ansible][tag-ansible] playbooks. The main reason to keep this separate from the server which runs all my services was because there was limited disk space on the server[^apt].

One of the biggest challenges was to keep my version of [hugo] up-to-date and to remember not to publish my blog entries with the `draft` switch enabled[^history]. I also wanted to get off the dev server and having to remember which internal IP I need to point at to see the preview.

Then I remembered, I already have my own [domain] setup in my home-network where I could host the preview! All the Docker containers on my server are already connected to a [traefik] container, which takes care of routing the subdomains to the relevant container IPs[^v1]. All I have to do is add a label to a Docker container with the right subdomain and as soon as it starts up, traefik will reverse-proxy that subdomain to the container's exposed IP address.

So I created my own [hugo] Docker container. It's very simple and I'm sure there are plenty of better ways to do it, but this works for me just fine[^latest]:

{{< highlight docker >}}
FROM ubuntu:20.04

ENV HUGO_VERSION=0.74.3
ENV HUGO_BASEURL=http://localhost/
ENV HUGO_ENV=production

RUN apt update && apt install -y \
        curl \
        git \
    && curl -SL https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz \
        -o /tmp/hugo.tar.gz \
    && tar -xzf /tmp/hugo.tar.gz -C /tmp \
    && mv /tmp/hugo /usr/local/bin/ \
    && apt remove curl -y \
    && apt autoremove -y \
    && mkdir -p /src \
    && rm -rf /tmp/*

WORKDIR /src

EXPOSE 1313

ARG HUGO_ENV=production
USER 1000:1000
ENTRYPOINT ["/usr/local/bin/hugo"]
CMD ["serve", "-e ${HUGO_ENV}", "--bind=0.0.0.0", "--appendPort=false"]

{{< /highlight >}}

This will, by default render a production version of my site, excluding drafts, future and expired posts. When creating the container in [Portainer], I can override the `HUGO_ENV` variable to `development` to see drafts, etc. This led me to have two of this container running: One, which I can use for editing and previews and another to see what the finished site will look like before I publish. A kind of dev and beta environment if you will. To make them easier to distinguish (apart from the URI), I also overrode the name of the site in my `development` config file to put **DEV** in front of the name. As long as I remember to check the beta version of the site, I should forget that pesky `draft` switch again!

The final bonus came when I rememberd that the `CMD` section can be completely overriden when creating a container. Since the `hugo` commmand itself is quite useful for scaffolding new posts, etc, I didn't want to miss out on that just because I don't have it installed directly on my server. So I now have a script that can do this, though it's just as simple to do something like this in a script:

<!-- markdownlint-disable -->
{{< highlight bash >}}
#! /bin/bash

docker run --rm -t -v `pwd`:/src pkuehne/hugo $*

{{< /highlight >}}
<!-- markdownlint-restore -->

Call the script `hugo` and you can do things like: `./hugo new post/a-new-post.md` (note the leading `./`).

I'm very happy with this new setup, though upgrading to the latest version of `hugo` has not been without complications. I was about 20 versions behind, which meant that I had to review every single page to make sure it still rendered OK. So if you're subscribing via RSS, apologies for any posts that appear as *new* when they're clearly not!

[tag-ansible]: {{< ref "/tags/ansible" >}}
[hugo]: https://gohugo.io/
[domain]: {{< ref "my-own-dns.md" >}}
[traefik]: https://docs.traefik.io/
[Portainer]: https://www.portainer.io/
[^apt]: And playing around on a server always leads to more `apt` bloat!
[^history]: My git commit history will show you what I mean.
[^v1]: I'm still running v1, don't judge me, the upgrade is far more stressful than my current situation allows :scream:
[^latest]: Correct at time of goint to print, you can see the latest version [here](https://github.com/pkuehne/peterkuehne.com/blob/master/Dockerfile)
