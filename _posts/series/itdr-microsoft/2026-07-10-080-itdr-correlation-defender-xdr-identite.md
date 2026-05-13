---
title: "ITDR Microsoft - Defender XDR, corrélation cross-pillar côté identité"
date: 2026-07-10 09:00:00 +02:00
layout: post
tags: [series:itdr-microsoft, defender-xdr, correlation]
categories: [identite, securite]
readtime: true
comments: true
cover-img: "assets/img/banners/banner-itdr.png"
thumbnail-img: "assets/img/posts/series/itdr-microsoft/080/080-thumb.png"
series: ITDR
series_order: 080
sidebar: true
level: technique
scope:
  - Defender XDR
  - Corrélation
  - Investigation
platform: Microsoft Security
---

> Squelette de travail. À développer.

## Intention de l'article

Montrer comment Defender XDR consolide les signaux identité provenant de MDI, EIDP, MDCA et MDE, et où s'arrête la corrélation native.

## Points à couvrir

- Architecture de l'asset graph : utilisateur, device, mailbox, app, identité hybride.
- Mécanismes de corrélation : graph d'incident, lien entre alertes, scoring d'incident.
- Vue Identity dans Defender XDR : timeline, alertes liées, lateral movement paths.
- Advanced hunting : tables IdentityInfo, IdentityLogonEvents, AADSignInEventsBeta, IdentityDirectoryEvents, IdentityQueryEvents.
- Requêtes KQL types pour ITDR : détection de compromission de service principal, suivi d'un attaquant sur identités hybrides.
- Limites : périmètre fermé à la pile Microsoft. Tout ce qui sort (SaaS hors MDCA, IdP tiers) demande Sentinel.

## Conclusion attendue

Defender XDR est efficace dans son périmètre. Le vrai sujet pour un analyste, c'est de savoir quand il suffit et quand il faut aller chercher des signaux ailleurs.
