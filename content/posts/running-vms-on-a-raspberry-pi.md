---
title: "Running VMs on a Raspberry Pi 4"
date: 2021-01-09T20:44:16Z
draft: false
categories: ["home-network"]
tags:
    - raspberry-pi
    - esxi
series: []
---

This Christmas brought a brand new 8Gb Raspberry Pi 4[^cooler]. I was very excited, the processing power and memory are insane for such a tiny single-board computer! I dind't just want to turn it into any other raspberry pi server[^plenty]. I wanted to do something special. Then I came across a YouTube video[^algo] that gave me the winning idea: Turn my Raspberry Pi into a Virtual Machine host!

{{< youtube 6aLyZisehCU >}}

I've linked the video above, so you can watch it for yourself. The instructions are very clear and easy to follow. It did take me a few days to actually get everything set up. So rather than copying all the steps here, I'll write a little about what problems I encountered[^easy]

First thing that I had trouble with was the need to set things up via a direct console, rather than `ssh`. I ended up having to buy a small USB keyboard and an hdmi switch so that I could get through the installation. At one point you need to spam ESC in order to get into the Raspberry Pi's BIOS. You obviously can't do that over `ssh`. 

This is where a bunch of issues came in. I prepped the USB drive and SD card. Booted up the Pi and ... didn't get a BIOS menu. I spammed ESC like my life depended on it, but nothing happened. I thought it was the keyboard I'd bought. The caps lock light didn't turn on when I toggled it, so I thought maybe it didn't get enough power. So I searched online[^whatelse] and found that the Pi can't power all USB devices and needs an external powered USB hub. So I bought that[^easy]. When it came, I plugged everything in again, spammed the ESC key and... nothing happened. The caps lock key didn't turn on still and I was ready to send it all back and call failure. 

I tried one more thing, which I thought was quite cool. This is a bit of a side-road[^later]. I wanted to build a control panel for a game I play. Just simple stuff, have a bunch of buttons, which then send key combinations to the game. It's surprisingly easy to do with a specific type of Arduino and about ten lines of code. I had rigged up a prototype for testing and quickly rewrote its code to send ESC when I pressed a breadboard button. I hooked that up and the Pi had no issues powering the Arduino, but even then I didn't get a BIOS menu. So I figured, something must be wrong.

I went through the process of creating the SD card again. I assumed that this is the most error prone part of the whole endeavour. I reflashed everything and tried again. It still didn't work, but at least this time I got a different screen before nothing happened. So I knew that something is wrong with the SD card / contents. So I deleted all the zip files, re-downloaded, re-unpacked them and the prepared the SD card according to instructions. 

It worked! My little USB keyboard flawlessly sent ESC and brought up the BIOS. Everything after was a breeze. ESXI installed without issue and ten minutes later I had my first VM running on the Raspberry Pi!

I assumed that I would only be able to run a couple of VMs on the Pi and sure enough, Ubuntu takes a fair amount of RAM to run (even without a GUI). So I went in search of another, smaller distro and ended up with Alpine. It's tiny, much easier to configure with Ansible. So by my calculations I can run a good eight Alpine VMs on the Raspberry Pi 4, depending on the load in the VM.

One of the VMs is my new DNS server and it's already performing better than the existing one, which has a dedicated Raspberry Pi 2!

[^cooler]: and the whole package with fans, case, stand-offs, etc!
[^plenty]: I already have four others from various generations.
[^algo]: Thank the Algorithm Gods.
[^easy]: Nothing's ever easy.
[^whatelse]: What else could you do? Read the `man` pages? Pffft, sod that :wink:
[^later]: I'll probably put together another post a little later.