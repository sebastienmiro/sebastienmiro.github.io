---
title: "ITDR Microsoft - Defender for Cloud Apps côté identité"
date: 2026-06-26 09:00:00 +02:00
layout: post
tags: [series:itdr-microsoft, defender-for-cloud-apps, session-control, oauth]
categories: [identite, securite]
readtime: true
comments: true
cover-img: "assets/img/banners/banner-itdr.png"
thumbnail-img: "assets/img/posts/series/itdr-microsoft/060/060-thumb.png"
series: ITDR
series_order: 060
sidebar: true
level: technique
scope:
  - Defender for Cloud Apps
  - Session control
  - OAuth governance
platform: Microsoft Security
---

> Squelette de travail. À développer.

## Intention de l'article

Cadrer MDCA strictement sur son apport ITDR identitaire, sans déborder sur le volet SaaS shadow IT ou DLP qui mériterait une autre série.

## Points à couvrir

- Session policies via reverse proxy : ce que ça permet réellement de bloquer après authentification.
- Détections d'anomalies comportementales identité : impossible travel, activité depuis IP suspecte, exfiltration de masse, partage anormal.
- App governance : surveillance des consentements OAuth, applications à privilèges élevés, détection d'applications malveillantes.
- Intégration Conditional Access App Control.
- Pré-requis licence et activation : licences MDCA, EID P1, configuration des proxies.
- Limites : compatibilité applicative restreinte sur certaines apps, latence, scénarios mobiles partiellement couverts.

## Liens à intégrer

- Article 130 réponse manuelle, isoler une identité, où MDCA permet de couper les sessions actives.
