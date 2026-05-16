---
layout: page
title: MDE Foundations Framework
sidebar: true
series: MDE Foundations
permalink: /series/mde-foundations/
tags: [series:mde-foundations]

---

## MDE Foundations Framework - série d’articles

Contenu en cours de rédaction

---

## Parcours de lecture

{% assign posts = site.posts | where: "series", "CA" | sort: "date" %}
<ul>
{% for post in posts %}
  <li>
    <a href="{{ post.url }}">{{ post.title }}</a>
  </li>
{% endfor %}
</ul>
