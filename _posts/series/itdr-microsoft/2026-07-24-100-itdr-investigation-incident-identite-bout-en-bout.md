---
title: "ITDR Microsoft - Investigation d'un incident identité de bout en bout"
date: 2026-07-24 09:00:00 +02:00
layout: post
tags: [series:itdr-microsoft, investigation, incident-response]
categories: [identite, securite]
readtime: true
comments: true
cover-img: "assets/img/banners/banner-itdr.png"
thumbnail-img: "assets/img/posts/series/itdr-microsoft/100/100-thumb.png"
series: ITDR
series_order: 100
sidebar: true
level: opérationnel
scope:
  - Investigation
  - Incident
  - Hunting
platform: Microsoft Security
---

> Squelette de travail. À développer.

## Intention de l'article

Cas concret bout en bout, à partir d'un signal initial jusqu'à la qualification de l'incident, en utilisant les outils présentés dans les articles précédents.

## Points à couvrir

- Scénario retenu : compromission par AiTM avec vol de token, suivie d'un OAuth consent illicite. Cas réaliste et couvert par la pile.
- Étape 1 : signal initial dans Defender XDR (alerte EIDP atypical sign-in).
- Étape 2 : analyse de la timeline utilisateur. Sign-in non-interactive suspects, géolocalisation, agent inhabituel.
- Étape 3 : corrélation avec MDCA. Détection d'une session anormale.
- Étape 4 : pivot vers le device. Action suspecte ou pas, ce que dit MDE le cas échéant.
- Étape 5 : Advanced hunting. Identification d'une app OAuth nouvellement consentie avec scopes élevés.
- Étape 6 : qualification. Compromission confirmée, périmètre de l'incident.
- Décisions à prendre avant la phase de réponse traitée dans le 130.

## Format

L'article peut s'appuyer sur des captures écran neutralisées ou des extraits KQL anonymisés.
