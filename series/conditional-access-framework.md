---
layout: page
title: Conditional Access Framework
sidebar: true
series: Conditional Access Framework
permalink: /series/conditional-access-framework/
tags: [series:conditional-access-framework]

---

## Conditional Access Framework — série d’articles

Cette série est dédiée à l’analyse et au déploiement opérationnel du **Conditional Access Framework v4** de Joey Verlinden.

Elle ne cherche pas à lister des règles ni à proposer une configuration universelle.  
L’objectif est de **comprendre la logique réelle du framework** : pourquoi il est structuré par blocs, comment les politiques s’articulent entre elles, et dans quel ordre elles prennent sens sur le terrain.

Les articles suivent volontairement une progression logique :
- du cadre général vers l’opérationnel,
- des concepts vers l’implémentation,
- du global vers le spécifique.

Chaque billet peut être lu indépendamment, mais l’ensemble forme un **parcours cohérent**, pensé pour des environnements Microsoft Entra ID réels, en particulier en contexte MSP.

---

## Parcours de lecture

{% assign posts = site.posts | where: "series", "CA" | sort: "series_order" %}
<ul>
{% for post in posts %}
  <li>
    <a href="{{ post.url }}">{{ post.title }}</a>
  </li>
{% endfor %}
</ul>
