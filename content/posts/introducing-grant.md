---
title: "Introducing Grant"
date: 2020-02-10
draft: false
categories: ["Genealogy"]
tags:
    - grant
    - research
    - tools
    - python
    - qt
series: "Grant"
---

{{< figure src="/grant.png" title="It's only version 0.1!" >}}

There haven't been any posts about genealogy yet and that's not because I've just picked this up, but because it's a hobby that tends to be more sporadic for me. There will be a separate post to introduce my research and what my focus is at the moment, but in summary, I have a fairly good family tree already and currently my work is mainly around documenting individuals with hard evidence[^standesamt]. There have also been some interesting discoveries that no-one else in my family knows of, but again, there will be separate posts for those.

This post is about [Grant]. Grant is not a person, but a program. I like being organized and genealogy requires a good deal of discipline to get it right. I use a stand-alone best-of-breed program to organize my family tree: [Family Historian][family-historian]. It's very good, I like working with it and knowing that it has excellent compliance with the [gedcom] file standard is a big plus.

There is just one things that's missing and that's a way to structure my research. There are of course a lot of productivity apps, todos and believe me, I've tried most of them. The thing they are all missing though is the ability to link to my family tree in some way. Some scenarios that come up for me frequently:

* I need to keep track of which Standesamt I've requested documents from
* Keeping track of which ancestor I need a particular certicicate for
* Find information about an individual when I don't have a name yet

So I could keep writing out the names in a todo app, unable to link a marriage certificate request task to two different individuals. Or I could write my own. Which is what I did.

It's called [Grant] and it's extremely bare-bones at the moment. It is literally just a todo app and has none of the features that I just described, but that's the plan. The application is written in Python3 using Qt5 as a UI framework and I'm extremely pleased with these choices. Development has been a breeze and I've learnt a lot about the language and the framework in the process.

There is a Python library to parse gedcom files and this will be the next major milestone after adding basic searching and filtering capabilities. With gedcom support, research tasks will be linkable to individuals, families, sources, locations, etc in a gedcom file. It will then be possible to query for all tasks that are linked to any of these. Hopefully this will blur the lines between keeping track of my research and where my golden source is for names, dates, flags, etc.

Give it a try and do let me know any feedback you have or what features you think would make you consider using [Grant].

[^standesamt]: Mainly birth/death/marriage records from German Standesamt registrar offices.
[Grant]: https://github.com/pkuehne/grant
[family-historian]: https://www.family-historian.co.uk/
[gedcom]: https://en.wikipedia.org/wiki/GEDCOM
