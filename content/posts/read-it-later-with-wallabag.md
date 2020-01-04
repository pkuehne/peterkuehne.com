---
title: "Read It Later With Wallabag"
description: "A brief look at running Wallabag as a self-hosted alternative to Instapaper or Pocket"
date: 2018-10-26T21:59:02+01:00
draft: true
categories:
  - home-network
tags:
  - ansible
  - wallabag
  - self-hosted
---

Many people use read-it-later software like Instapaper or Pocket in order to "clip" articles from the web and sync them to a mobile device, so that they can (as the name implies) read them during, say, their commute.

I began to use [Instapaper][instapaper] for a slightly different reason. While doing research on various things, like my `Ansible` setup, how to configure `dnsmasq`, I would come across a lot of interesting material that I wanted to keep. Rather than just bookmarking it, I would save it to Instapaper, categorize and tag it and then retrieve it when I came around again to those projects.

Then in early 2018, the European Union went live with their General Data Protection Regulation and Instapaper went _offline_ for several months, not allowing me access to the site. I was livid. Fortunately, they allowed me to download my content and I went straight to their competitor: [Pocket][pocket]. It offered essentially the same functionality, with a web-clipper Chrome Extension, tagging content and making available on my phone. Yet it didn't seem to have the same issue as Instapaper and was fully live during the whole GDPR go-live

So I was set, but something was nagging me. I had gone down the path of self-hosting as much of my data as I could, so that I wouldn't be at the mercy of some corporation shutting me down, with no way to get at my stuff. Yet that was exactly what had happened to me! While Pocket was still live, who knows what would happen down the line? They could be acquired and shut down, or worse, start feeding my content into some ML algorithm and then target me with ads...

So I went on a hunt for a self-hosted alternative. The mother of all references for self-hosting aficionados is [this github page][kickball]. It has several dozen alternatives for any tool you can think of. I hit on [Wallabag][wallabag] and I thought it was perfect. It had everything I needed:

- It was self-hosted
- It had a web-clipper
- It had an Android app
- It runs in a docker container
- It integrates with RSS readers

So I went about setting it up on my system. Luckily, I already had Docker installed on my _Intel NUC_ which runs all my apps. I created a new Ansible role for it, pulled a recent Docker image off the Hub and ran it. Just worked.

[instapaper]: https://www.instapaper.com/
[pocket]: https://getpocket.com/
[kickball]: https://github.com/Kickball/awesome-selfhosted
[wallabag]: https://wallabag.org/