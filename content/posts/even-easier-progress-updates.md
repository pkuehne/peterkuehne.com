---
title: "Even Easier Progress Updates"
date: 2022-02-23T19:50:58Z
draft: false
categories: ["Technology"]
tags:
    - hugo
    - blog
series: ""
---

I knew I couldn't stay away from the automation bug for much longer. So I spent a good day or so familiarising myself with Hugo's [Templating] and how [Data Templates] work. With a bit of trial error and a lot of squinting at syntax errors, I've managed to come up with a fairly good system.

Firstly, I extended the syntax in the `params` section of the `config.yaml`. You can now eschew the `max` and `now` keys and instead provide a `file`:

<!-- markdownlint-disable -->
{{< highlight yaml >}}
params:
  progress:
    - title: "Painting Challenge"
      max: 142
      now: 89
    - title: "Other Challenge"
      file: other_challenge
{{< / highlight >}}
<!-- markdownlint-restore-->

The `get_progress_data` partial then reads that data file (in yaml format) and extracts a list of items[^items]. Each item has a `count` and a `done` field. If they are missing, they are assumed to be 1 and 0 respectively. The items are added to the relevant total and returned. The shortcodes themselves stayed the same, but the data now comes from the data file instead of having to explicitly update the config file.

The other enhancement I made was to create another shortcode to list out the items in the data file and style them depending on whether the item is done or not. I also made it so that if an item is in progress[^progress]
it shows the number in brackets behind it. The code is a bit convoluted, so I won't reproduce it here. You can see it in the github repo. The shortcode is called `list_progress_items`. I think this will be the last I do on this. The idea is to focus more on the painting and the blogging, rather than making the blogging software progressively more complicated!

[templating]: https://gohugo.io/templates/introduction/
[data templates]: https://gohugo.io/templates/data-templates/
[^items]: Such as a list of miniatures to paint
[^progress]: i.e. the `count` and `done` are unequal and more than 1 and 0 respectively.
