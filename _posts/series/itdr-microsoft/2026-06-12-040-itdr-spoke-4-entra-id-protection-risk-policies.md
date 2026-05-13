---
title: "ITDR Microsoft - Entra ID Protection en pratique"
date: 2026-06-12 09:00:00 +02:00
layout: post
tags: [series:itdr-microsoft, entra-id-protection, risk-policies]
categories: [identite, securite]
readtime: true
comments: true
cover-img: "assets/img/banners/banner-itdr.png"
thumbnail-img: "assets/img/posts/series/itdr-microsoft/040/040-thumb.png"
series: ITDR
series_order: 040
sidebar: true
level: technique
scope:
  - Entra ID Protection
  - Risk policies
  - Sign-in risk
  - User risk
platform: Microsoft Entra
---

> Squelette de travail. À développer.

## Intention de l'article

Présenter Entra ID Protection sous l'angle ITDR : ce qui se détecte vraiment, comment c'est exploité dans les politiques, et où ça s'arrête.

## Points à couvrir

- Différence user risk vs sign-in risk. Granularité réelle.
- Types de détections : anonymous IP, atypical travel, malware-linked IP, leaked credentials, password spray, suspicious sign-in, etc.
- Détections offline vs near-real-time. Délai d'élévation du risque.
- Risk policies : block, force password change, MFA, integration via Conditional Access.
- Migration depuis EIDP policies historiques vers CA risk-based policies.
- Pré-requis licence : Entra ID P2 sur les comptes monitorés.
- Limites : comptes non synchronisés, comptes B2B, comptes service principal exclus.

## Liens à intégrer

- Article CAF 050 sur sessions et tokens.
- Article CAF 110 sur les comptes à privilèges, qui doivent rester sur des politiques explicites plutôt que risk-based.
