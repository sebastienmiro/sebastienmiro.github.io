---
title: "ITDR Microsoft - Limites structurelles et angles morts"
date: 2026-08-21 09:00:00 +02:00
layout: post
tags: [series:itdr-microsoft, limites, risques]
categories: [identite, securite]
readtime: true
comments: true
cover-img: "assets/img/banners/banner-itdr.png"
thumbnail-img: "assets/img/posts/series/itdr-microsoft/140/140-thumb.png"
series: ITDR
series_order: 140
sidebar: true
level: concepts
scope:
  - Limites
  - Angles morts
  - Périmètre
platform: Microsoft Security
---

> Squelette de travail. À développer.

## Intention de l'article

Pendant du 160 de la série CAF. Lister les zones que la pile ITDR Microsoft ne couvre pas ou couvre mal, avant de parler gouvernance dans l'article suivant.

## Points à couvrir

- Insider threat : actions légitimes vues comme normales par les détections, périmètre principalement traité par Purview Insider Risk, hors série.
- Identités B2B : visibilité réduite côté tenant invitant, détections partielles.
- Service principals et managed identities : exploitation OAuth, abus de scopes, peu visibles sans hunting actif.
- Comptes break-glass : silencieux par construction, exclus des risk policies. Sujet déjà traité dans la série Un risque, une mesure, à référencer.
- IdP tiers fédérés : signaux côté Entra existent mais incomplets, dépendance forte au tiers (Okta, Ping, ADFS).
- Applications SaaS hors MDCA : pas de session control, détection comportementale limitée.
- Latence de détection : certaines détections en quasi-temps réel, d'autres en différé jusqu'à plusieurs heures. Implication sur les attaques rapides.

## Conclusion attendue

L'ITDR Microsoft est cohérent dans son périmètre. Ses limites ne sont pas des défauts, ce sont des choix d'architecture. Les ignorer mène à une fausse confiance, ce qui est plus dangereux qu'un trou identifié.
