---
title: "Making Progress Updates Easier"
date: 2022-02-19T18:41:46Z
draft: false
categories: ["Technology"]
tags:
    - blog
    - hugo
series: ""
---

Earlier this year, I started to track progress for my painting [challenge]. It's been going well and I've a lot of fun tracking the numbers and seeing them go up. One thing I was keen on though, was to improve the update process. Updating the markdown page for the challenge and calculating the percentage progress by hand, is hardly difficult or time-consuming, but anyone who's read my blog will know that I like automating things. This blog isn't any different and I've been keen to try out some of the more advanced features of [Hugo] as well, particularly [shortcodes]. I started out by creating a shortcode just for the painting challenge, but then realized that in the future, I might want to track multiple things[^track]. That gave me the idea of putting a progress bar on the sidebar menu. Sure enough, my theme, [Mainroad], allows you to create custom widgets for the sidebar.

Putting it all together looks something like this.I moved the relevant datapoints that I would need to update into the `config.yaml` under the `params` section[^github]:

<!-- markdownlint-disable -->
{{< highlight yaml >}}
params:
  progress:
    - title: "Painting Challenge"
      max: 142
      now: 89
    - title: "Other progress"
      max: 100
      now: 10
{{< / highlight >}}
<!-- markdownlint-restore-->

Then I created the `challenge.html` shortcode in the relevant directory[^where].  I gave it a parameter to indicate which item in the list to show, which can be done by using `.Get 0` for the zeroth positional parameter. I then grab the relevant list item by using the `index` function. Compute the total (i.e. the percentage) by multiplying the dividend by `100.0` first[^float]. Then simply use them in the html like so:

<!-- markdownlint-disable -->
{{< highlight html >}}
{{ $index := .Get 0}}
{{ $progress := index .Site.Params.progress $index}}
{{ $total := math.Round (div (mul (index $progress "now") 100.0) (index $progress "max")) }}
<span>
    Completed: {{ index $progress "now" }}/{{ index $progress "max" }} = <b>{{ $total}}%</b>
</span>
{{< / highlight >}}
<!-- markdownlint-restore-->

It can then be embedded in the markdown page:

<!-- markdownlint-disable -->
{{< highlight markdown >}}
Here are the challenge details {{</* challenge 0 */>}}
{{< / highlight >}}
<!-- markdownlint-restore-->

I do something similar for the widget in the sidebar, but here I iterate over all the progress items and render them with a `<meter>` html tag to show a nice progressbar as well as the percentage. The code is a little more involved, but still very manageable:

<!-- markdownlint-disable -->
{{< highlight html >}}
<div class="widget-categories widget">
    <h4 class="widget__title">Progress</h4>
    <div class="widget__content">
        <ul class="widget__list">
            {{ $progress := .Site.Params.progress }}
            {{ range $item := $progress }}
            {{ $total := (math.Round (div (mul (index $item "now") 100.0) (index $item "max")))}}
            <li class="widget__item">
                <span>
                    {{ index $item "name" }}:
                </span>
                <span style="float:right">
                    <meter value="{{$total}}" max="100">{{$total}}%</meter>
                    {{$total}}%
                </span>
            </li>
            {{ end }}
        </ul>
    </div>
</div>
{{< / highlight >}}
<!-- markdownlint-restore-->

The major downside is that I have to do the percentage calculation in two places[^function], but given that it is a very standard and easy formula, I don't feel too bad about it. At least now, I can change the `now` value in one place (the config file) and have it automatically update across the site. I'm absolutely loving the power of shortcodes!

I found it really interesting to delve a bit deeper into what Hugo can do and I'm very impressed. I can already think of a few other ways to leverage it, not just for this site, but other projects too. I know that Hugo can also load information from [data] files and this is the next thing I'll be looking into. If I can put the actual items to track into datafiles and have the `now` and `max` values derived automatically, that would be even better. I could then potentially *generate* the progress pages automatically during build, instead of writing them out. I imagine this would be quite a bit more convoluted though and for now I'm happy to push these changes as they are.

[challenge]: {{< ref "/series/painting-challenge-2022" >}}
[hugo]: https://gohugo.io/
[shortcodes]: https://gohugo.io/templates/shortcode-templates/
[github]: https://github.com/pkuehne/peterkuehne.com
[mainroad]: https://github.com/Vimux/Mainroad
[data]: https://gohugo.io/templates/data-templates/

[^github]: You can see all of this in the [github] repo of course.
[^track]: What books I still need to listen to for example or progress on a particular painting project.
[^where]: `layouts/partials/shortcodes/challenge.html` but double-check the documentation
[^float]: Note the decimal to force the result to be a floating point number rather than doing straight integer division.
[^function]: In a program, I would write a function to refactor of course.
