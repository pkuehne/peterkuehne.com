---
title: "Automating This Blog"
date: 2020-01-04T15:50:09Z
draft: true
categories: ["Technology"]
tags:
    - hugo
    - blog
series: [""]
---

The most annoying thing about having a website or blog for me has always been in writing content for it. Getting stuff published is a close second though. So when I wanted to revive this blog and actually have a proper web presence for once, I resolved that it should be as easy as possible to do it. 

So first thing I did was to put this blog up as a Github repo so that I could access it from anywhere. Particularly as I tend to move between Raspberry Pis, WSL, the NUC and my laptop when developing code or doing anything else command line. So in case anything dies accidentally, I wantedt to have a safe central storage.

The other thing was not to have to deal with the building/publishing side of things. In the past, I've put all that stuff in a script, which works great, but now that I'm serving the content out of a secured S3 bucket, it's a bit more of a pain. You need to install the `aws-cli`, create users, log them in, etc. If I want to do a quick publish from some new computer, I would have to go through the whole process again.

Instead, I wanted to use Continuous Delivery, just like the CI/CD systems at work, that continuously build apps and deploy them. I wanted the same for my website. In the past, I've used [Travis][travis] to do the build, but now Github has its own inbuilt CI/CD system, called [Github Actions][github-actions]. Now all I need was a tutorial to get me started and then I found [this][tutorial] on [dev.to][dev-to].
