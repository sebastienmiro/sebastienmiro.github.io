---
title: "ITDR Microsoft - Automated Investigation and Response"
date: 2026-07-31 09:00:00 +02:00
layout: post
tags: [series:itdr-microsoft, air, automation, response]
categories: [identite, securite]
readtime: true
comments: true
cover-img: "assets/img/banners/banner-itdr.png"
thumbnail-img: "assets/img/posts/series/itdr-microsoft/110/110-thumb.png"
series: ITDR
series_order: 110
sidebar: true
level: technique
scope:
  - AIR
  - Automation
  - Defender XDR
platform: Microsoft Security
---

> Squelette de travail. À développer.

## Intention de l'article

Décortiquer ce que fait vraiment Automated Investigation and Response côté identité, sans surévaluer la promesse d'automatisation totale.

## Points à couvrir

- Périmètre AIR : ce qui est automatisé par défaut, ce qui demande activation, ce qui demande validation humaine.
- Actions de réponse natives côté identité : confirm user compromised, require password change, disable user, revoke sessions.
- Modes : full automation, semi-auto, manual approval.
- Limites : actions à privilèges élevés non automatisées, périmètre AD on-prem partiel, dépendance à la qualité du modèle de détection.
- Risques opérationnels : actions automatisées sur un faux positif, impact business, gestion d'incident en heures non ouvrées.
- Recommandation pratique : démarrer en mode manual approval, élargir progressivement après calibrage.

## Conclusion attendue

L'automatisation est intéressante sur un sous-ensemble bien identifié. Tout passer en automatique est une erreur classique qui transforme un faux positif en incident utilisateur.
