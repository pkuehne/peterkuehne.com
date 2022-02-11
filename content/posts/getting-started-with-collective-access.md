---
title: "Getting Started With Collective Access"
date: 2020-03-15T18:55:54Z
draft: false
toc: true
categories: ["Genealogy"]
tags:
    - docker
    - archive
    - ansible
    - ldap
series: ""
---

## Background

There comes a point when just having a shoebox under your bed with all your important documents and files is no longer viable.[^1] This is especially true if you have some kind of hobby, like genealogy, which tends to explode in the amount papers you need to keep track of. At this point, I've filled two folders with about 100 documents worth of family history research and I don't expect that to stop anytime soon. So I needed something to make the process of running this small archive easier. Luckily, there is an open source software for everything, so I hit on [CollectiveAccess][ca]

## Introduction

From their own website:

> CollectiveAccess is software for describing all manner of things, and allows you to create catalogues that closely conform to your needs without custom programming.

It is software that's used by galleries, museums and archives to manage their inventory and to display it to the public. There is a demo site available that is a good playground for trying it out.

At first look it is perhaps a little complex and not at all beginner friendly. CA assumes that you already know how archiving works and that you have a scheme in mind. Because it is so broadly applicable it is quite generic in many aspects, which also makes it hard for a beginner to get any guidance on how to use it.

I can't claim to have all the answers, but I'll show how I use it, which will hopefully help others.

## Installation

Docker is still my preferred way to set up any new software, but there is a lack of good (maintained) images around. So I forked the best one I could find and enhanced it a bit. I put the result back on [docker].

The Readme.md is a good starting point for setting up a mysql docker container (don't forget to map a host drive for backup). The collectiveaccess image can then be started with:

    docker run 
        -–link ca_mysql:mysql
        -p 8080:80
        -e DB_USER=user
        -e DB_PW=pw
        -e DB_NAME=collective
        -e DISPLAY_NAME="My Archive"        # optional
        -e ADMIN_EMAIL=admin@my-archive.tld # optional
        -e SMTP_SERVER=mail.my-archive.tld  # optional
        -v /var/ca/conf:/var/www/providence/app/conf
        -v /var/ca/media:/var/www/providence/media/
        pkuehne/collectiveaccess:1.0

The display name is what will be shown as the title all over the site. The previous image didn't allow you to change this, leading it to say "My first CollectiveAccess System" everywhere. Now you can make it reflect your personal preference.

Note that the `conf` directory must be empty so that the relevant config files are created there. The `media` folder will store all the uploaded media that's associated with your objects.

Once the containers have started, you're ready to go! Just go to where you can access the container from your browser and append `/providence`. This will let you set up the database with your preferred schema (more on that in a moment!)

## Providence vs Pawtucket

Providence is the essentially the backend, where you create and manage all your data. Pawtucket is the public-facing version of your data. You can choose to keep certain objects private and only expose a limited set of data to the wider world. Pawtucket works as soon as the database is set up, but needs further configuration to be truly useful, which I will cover in a later post.

## The basics

When creating the database you are asked for the schema which you want to follow for laying out your data. This is only a kind of pre-configuration and can all be changed later on through the web interface. I went with "ISAD(G)" since it seemed the most universal and most of the others are geared towards films, art or digital media.

Now that Providence is up and running and you're logged in as the administrator, its time to get our bearings. Hover over the "New" menu to see all the things we can create in CA. We'll cover them in a slightly different order so we can build on previous concepts.

### Objects

This is the bread-and-butter of your inventory. At the lowest level, you have `Items`, which are the actual physical letters, photos, certificates, etc that you want to archive. The levels above are the hierarchies you can create to keep things organized. Keep in mind that these also represent objects, but at a higher level.

Fonds are the top-level objects. They represent everything that has originated from a particular person or organization. A fonds could be Pablo Picasso or Enron. You can record the extent of the collection, notes, descriptions, etc to describe what is encompassed by this fonds, be generic, this is a high-level view. My Family History fonds says:

> Certificates, photos, letters and assorted physical items from the Kuehne family history.

Below fonds, you can create sub-fonds, series, sub-series and files to organize things a bit. I have a sub-fonds for civil registration documents, one for memorabilia, one for photos, etc. Within that you can have a series for death certificate, birth certificates, etc. You can skip parts of the hierarchy or leave it out completely.

### Accession

Accessions represent how the Objects came into your possession. You might have received items for multiple different fonds in the same bequest, gift, purchase or donation. This helps keep track of what came to you in what way. An accession does not say anything about the hierarchy or structure of your inventory, or the provenance.

### Collection

Collections essentially run orthogonal to Objects and their hierarchies. Let's say you have a fonds for books and one for films. You can create a collection of "books made into movies" that includes objects from both fonds. Collections generally denote that some items are related, but not necessarily from the same origin. If you consider a fonds as originating from a person, you can have collection of painting objects, which contains objects from multiple artists fonds.

### Storage Location

This is an important one. One thing is to label all your objects with their Object ID (or Accession Number), quite another to then find it.

First you'll want to set up a hierarchy for your building. I have the main house and the garage as separate buildings, then the second floor in the house where my office is and the loft, where we keep a bunch of things. I find that [Really Useful Boxes][reallyuseful] are aptly named. I slap a sticker on them with a number in big felt-tip pen and then record this as a Storag Location below the building/floor where I keep it. The object then goes inside (with a sticker of its own listing the Object Identifier) and this is recorded on the Object's details.

Now you can see what's inside each box without opening it and you can quickly find where you've put an item without having to open all the boxes.

### Entity

A person or company that you want to associate with an object. It could be the people who sent/received a letter, the person a song is about or all the people in a given photograph. It could also be the registry office from which you received a given document.

### Place

Similar to Entity, this is a place that has a meaning within an Object. It could be the place a photograph was taken or described in a letter.

### Event

Again, similar to Entity and Place. It could be an exhibition of a collection or a memorable event that triggered the creation of various objects.

### Loans

Probably the least useful unless you're constantly lending things to people and want to keep track of who has what.

## Summary

There is **lots** more to talk about when it comes to CollectiveAccess, but that's for another time. Hopefully, this post has given you an insight into how to get started with CollectiveAccess, what the various terms mean and how to put order into your genealogy research.

[ca]: https://collectiveaccess.org/
[docker]: https://hub.docker.com/r/pkuehne/collectiveaccess
[reallyuseful]: http://www.reallyusefulproducts.co.uk/uk/
[^1]: Or like me you just want to make your own life more difficult.
