---
title: "ITDR Microsoft - Defender for Identity, ce qu'il voit et ce qu'il ne voit pas"
date: 2026-06-19 09:00:00 +02:00
layout: post
tags: [series:itdr-microsoft, defender-for-identity, active-directory]
categories: [identite, securite]
readtime: true
comments: true
cover-img: "assets/img/banners/banner-itdr.png"
thumbnail-img: "assets/img/posts/series/itdr-microsoft/050/050-thumb.png"
series: ITDR
series_order: 050
sidebar: true
level: technique
scope:
  - Defender for Identity
  - Active Directory
  - AD CS
  - Entra Connect
platform: Microsoft Security
---

> Squelette de travail. À développer.

## Intention de l'article

Présenter Defender for Identity en mode terrain. Quels capteurs déployer, sur quoi, et avec quel niveau de couverture réel.

## Points à couvrir

- Architecture : capteurs sur DC, sur ADFS, sur AD CS, sur Entra Connect.
- Évolution récente côté identités cloud (capteurs Entra ID).
- Catégories de détections : reconnaissance, credential access, lateral movement, domain dominance, exfiltration.
- Exemples : DCSync, Kerberoasting, Golden Ticket, Skeleton Key, Overpass-the-Hash.
- Pré-requis : comptes de service, captures réseau, configuration des stratégies d'audit AD.
- Intégration avec Defender XDR : comment les détections remontent côté incident.
- Limites : Hash impossible sur certains scénarios sans audit Windows correctement configuré. Faux positifs sur les outils légitimes (scanners de vulnérabilités, Pingcastle).

## Conclusion attendue

Defender for Identity ne remplace pas une politique d'audit AD bien posée. Il complète. Et son déploiement opérationnel est plus exigeant que ce que la documentation laisse penser.
