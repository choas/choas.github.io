---
layout:  post
title:   Jekyll — Twitter Cards and Open Graph
date:    2020-05-26 22:21 +0200
image:   treasure-map-1850653_1280.jpg
credit:  https://pixabay.com/de/photos/schatzkarte-navigation-karte-1850653/
tags:    jekyll twitter-cards
excerpt: Twitter cards display additional information to the tweet message, such as pictures, videos, audio and download links. This makes the tweet more eye catching than a text-only tweet.
---

> The Open Graph protocol enables any web page to become a rich object in a social graph. — [The Open Graph protocol]

My tweets to the previous blog posts looked a bit like Twitter with 144 characters — some text and a link - just sad. After @jasoncaston retweeted my [C64 BASIC on iOS tweet], his tweet looked good. The difference was that he just added an image to it. I also added a picture to my next blog post. It looked good, but not like the other tweets. Why?

So, I simply took a look at a website and found something in the header of the HTML page with `twitter:image`. Then there are more with `twitter:` and also `og:`. I searched the internet and found __Twitter Cards and Open Graph__. Fun 🥳 fact: A colleague talked about it the next day.

## Jekyll Header

Somehow I had thought that Jekyll already has that. Maybe I just used the wrong Jekyll template. But it is no problem to extend it. Jekyll offers several ways to access configuration values and parameters from the blog post. Now I just had to find a template with a best practice example. I found the blog post [How to make your Jekyll site show up on social] and a link to Twitters [Optimize Tweets with Cards] page. The subchapter [Twitter Cards and Open Graph] explains that Twitter can also handle the Open Graph meta elements and that it is just enough to set one image element.

I have inserted the following in head.html page:

```html
<meta name="twitter:card" content="summary_large_image" />
<meta name="twitter:creator" content="@choas" />
{% if page.image %}<meta property="og:image" content="{{site.url}}/images/{{page.image}}" />{% endif %}
<meta property="og:title"
  content="{% if page.title %}{{ page.title | strip_html | strip_newlines | truncate: 160 }}{% else %}{{ site.title }}{% endif %}">
<meta property="og:description"
  content="{% if page.excerpt %}{{ page.excerpt | strip_html | strip_newlines | truncate: 160 }}{% else %}{{ site.description }}{% endif %}">
<meta property="og:url"
  content="{{ page.url | replace:'index.html','' | prepend: site.baseurl | prepend: site.url }}" />
<meta property="og:site_name" content="{{ site.title }}" />
```

Except for the `twitter:creator` entry everything can be copied. It is now even possible to add an `excerpt` for the Twitter Cards or Open Graph in the blog post. Otherwise the first 160 characters of the blog post are used for the description.

## Summary

I have already tested the [head.html adaptions] an older tweet. Now I'm pushing the blog post and will test this again with another tweet.

I don't have Facebook, maybe someone will test it and answer me with a screenshot of this [tweet]?

[The Open Graph protocol]: https://ogp.me/
[C64 BASIC on iOS tweet]: https://twitter.com/jasoncaston/status/1264124593616424962
[How to make your Jekyll site show up on social]: http://aramzs.github.io/jekyll/social-media/2015/11/11/be-social-with-jekyll.html
[Twitter Cards and Open Graph]: https://developer.twitter.com/en/docs/tweets/optimize-with-cards/guides/getting-started#twitter-cards-and-open-graph
[Optimize Tweets with Cards]: https://developer.twitter.com/en/docs/tweets/optimize-with-cards/guides/getting-started
[head.html adaptions]: https://github.com/choas/choas.github.io/commit/66462ece41f128df8fbd344792cfc2510d0d5b44
[tweet]: https://twitter.com/choas/status/1265383243504857098
