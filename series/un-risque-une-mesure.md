---
layout: page
title: Série "Un risque, une mesure"
sidebar: true
series: R1M
permalink: /series/un-risque-une-mesure/
tags: [series:un-risque-une-mesure]

---

## Un risque, une mesure — série d’articles

Cette série est dédiée à l’analyse concrète et opérationnelle des risques de sécurité, suivie d’une mesure de remédiation ciblée.

Elle ne cherche pas à couvrir l’ensemble du spectre cyber, ni à proposer des checklists génériques.
L’objectif est de faire le lien explicite entre un scénario de risque réel et une réponse de sécurité adaptée, en tenant compte des contraintes techniques, organisationnelles et opérationnelles.

Chaque article repose sur un principe simple :

- partir d’un risque identifiable (attaque, mauvaise configuration, usage détourné),
- analyser ce qui pose réellement problème,
- proposer une mesure précise, contextualisée et justifiée.

Les billets sont volontairement indépendants les uns des autres.
Ils peuvent être lus isolément, mais l’ensemble constitue une bibliothèque de cas concrets, ancrée majoritairement dans des environnements Microsoft (Entra ID, Microsoft 365, PowerShell, messagerie), avec une logique transposable au-delà des outils.

---

## Parcours de lecture

{% assign posts = site.posts | where: "series", "R1M" | sort: "date" %}
<ul>
{% for post in posts %}
  <li>
    <a href="{{ post.url }}">{{ post.title }}</a>
  </li>
{% endfor %}
</ul>
