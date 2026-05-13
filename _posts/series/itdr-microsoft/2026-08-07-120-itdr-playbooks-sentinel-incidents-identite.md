---
title: "ITDR Microsoft - Playbooks Sentinel pour incidents identité"
date: 2026-08-07 09:00:00 +02:00
layout: post
tags: [series:itdr-microsoft, sentinel, playbooks, soar]
categories: [identite, securite]
readtime: true
comments: true
cover-img: "assets/img/banners/banner-itdr.png"
thumbnail-img: "assets/img/posts/series/itdr-microsoft/120/120-thumb.png"
series: ITDR
series_order: 120
sidebar: true
level: technique
scope:
  - Sentinel
  - Logic Apps
  - SOAR
platform: Microsoft Security
---

> Squelette de travail. À développer.

## Intention de l'article

Présenter une sélection courte de playbooks Sentinel qui ont un intérêt opérationnel réel pour l'ITDR. Éviter le catalogue exhaustif sans valeur.

## Points à couvrir

- Architecture : Sentinel, automation rules, Logic Apps.
- Pré-requis : connecteurs Entra, MDI, MDCA, Defender XDR, intégration avec ITSM (ServiceNow ou équivalent).
- Trois playbooks types à couvrir en détail :
  - Réponse à un sign-in à haut risque confirmé : revoke sessions, force password change, notification équipe.
  - Réponse à une application OAuth suspecte : disable, notification, escalade.
  - Réponse à un compte privilégié compromis : isolation, notification SOC niveau 2, escalade.
- Anti-patterns : actions destructrices non-réversibles, playbooks qui appellent d'autres playbooks en cascade, pas de garde-fou humain sur les actions sensibles.
- Mesure d'efficacité : MTTR, taux de faux positifs, taux d'incidents traités sans intervention.

## Conclusion attendue

Un playbook bien fait fait gagner du temps. Un playbook mal fait crée des incidents là où il n'y en avait pas.
