---
layout: page
title: ITDR Microsoft
sidebar: true
series: ITDR
permalink: /series/itdr-microsoft/
tags: [series:itdr-microsoft]

---

## ITDR Microsoft, série d'articles

Cette série traite de l'**Identity Threat Detection and Response** dans l'environnement Microsoft : Entra ID Protection, Defender for Identity, Defender for Cloud Apps, Defender XDR et Sentinel.

Elle prolonge la série *Conditional Access Framework*, qui traitait la décision d'accès. L'ITDR commence là où l'accès conditionnel s'arrête : signaux après authentification, détection d'anomalies, corrélation cross-pillar, investigation et réponse.

L'objectif n'est pas de présenter chaque produit isolément, mais de montrer comment ils s'articulent, ce qu'ils couvrent réellement et ce qu'ils ne couvrent pas. Le contenu reste factuel, sans posture commerciale, et assume les limites structurelles de la pile.

La série suit la même logique de progression que la CAF :
- du cadre général vers l'opérationnel,
- des concepts vers l'implémentation,
- du global vers le spécifique.

Chaque article peut être lu indépendamment, mais l'ensemble forme un parcours cohérent, pensé pour des environnements Microsoft Entra ID et Microsoft 365 réels, avec un point d'attention particulier pour les contextes MSP.

---

## Parcours de lecture

{% assign posts = site.posts | where: "series", "ITDR" | sort: "series_order" %}
<ul>
{% for post in posts %}
  <li>
    <a href="{{ post.url }}">{{ post.title }}</a>
  </li>
{% endfor %}
</ul>
