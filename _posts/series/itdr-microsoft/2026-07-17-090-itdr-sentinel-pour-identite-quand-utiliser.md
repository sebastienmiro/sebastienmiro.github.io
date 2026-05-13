---
title: "ITDR Microsoft - Sentinel pour l'identité, quand l'utiliser"
date: 2026-07-17 09:00:00 +02:00
layout: post
tags: [series:itdr-microsoft, sentinel, siem, soar]
categories: [identite, securite]
readtime: true
comments: true
cover-img: "assets/img/banners/banner-itdr.png"
thumbnail-img: "assets/img/posts/series/itdr-microsoft/090/090-thumb.png"
series: ITDR
series_order: 090
sidebar: true
level: technique
scope:
  - Sentinel
  - SIEM
  - Identité
platform: Microsoft Security
---

> Squelette de travail. À développer.

## Intention de l'article

Trancher une question récurrente : faut-il Sentinel par-dessus Defender XDR pour l'ITDR. La réponse est nuancée et dépend de quelques critères.

## Points à couvrir

- Recouvrement entre Defender XDR et Sentinel côté identité.
- Cas où Defender XDR suffit : périmètre 100% Microsoft, équipe SOC réduite, pas de besoin de rétention longue.
- Cas où Sentinel devient nécessaire : sources tierces (IdP, SaaS, on-prem hors AD), conservation au-delà de 6 mois, analytique avancée, SOAR.
- Connecteurs Sentinel pour ITDR : Entra ID, MDI, MDCA, Defender XDR, AD, MFA logs.
- Modèle de coût : ingestion par GB, retention, automation rules.
- Patterns de détection identité non couverts par Defender XDR : analyse comportementale sur longue période, détection multi-tenant pour MSP.

## Conclusion attendue

Sentinel n'est pas une obligation. Il devient pertinent quand on a un besoin opérationnel précis qui dépasse Defender XDR. À justifier sur des critères mesurables, pas sur une posture défensive.
