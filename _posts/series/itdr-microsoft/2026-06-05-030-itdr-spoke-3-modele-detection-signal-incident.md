---
title: "ITDR Microsoft - Du signal à l'incident, modèle de détection"
date: 2026-06-05 09:00:00 +02:00
layout: post
tags: [series:itdr-microsoft, detection, correlation]
categories: [identite, securite]
readtime: true
comments: true
cover-img: "assets/img/banners/banner-itdr.png"
thumbnail-img: "assets/img/posts/series/itdr-microsoft/030/030-thumb.png"
series: ITDR
series_order: 030
sidebar: true
level: concepts
scope:
  - Signaux
  - Alertes
  - Incidents
  - Corrélation
platform: Microsoft Security
---

> Squelette de travail. À développer.

## Intention de l'article

Expliquer comment Microsoft passe d'un signal brut à un incident actionnable. Sortir du flou marketing autour des termes signal, alerte, détection, incident.

## Points à couvrir

- Définitions strictes : signal, détection, alerte, incident.
- Pipeline Defender XDR : ingestion, détection, corrélation, déduplication, incident.
- Sources de signaux côté identité : MDI, EIDP, MDCA, sign-in logs, audit logs.
- Mécanismes de corrélation : graph d'incident, asset graph, lien utilisateur / device / app.
- Niveaux de sévérité, classification, statuts. Comment c'est vraiment utilisé en pratique.
- Faux positifs : volumétrie réelle, mécanismes de tuning, impact opérationnel.

## Conclusion attendue

Le modèle est cohérent mais demande du tuning. Un incident n'est pas une vérité, c'est une hypothèse à investiguer.
