---
title: "ITDR Microsoft : ce que la pile détecte, corrèle et permet de répondre"
date: 2026-05-15 09:00:00 +02:00
layout: post
tags: [series:itdr-microsoft, itdr, identity-protection]
categories: [identite, securite]
readtime: true
comments: true
cover-img: "assets/img/banners/banner-itdr.png"
thumbnail-img: "assets/img/posts/series/itdr-microsoft/000/000-thumb.png"
series: ITDR
series_order: 000
sidebar: true
level: présentation
scope:
  - Entra ID
  - Defender XDR
  - Sentinel
  - ITDR
platform: Microsoft Security
---

Cet article sert de **point d'entrée** vers une nouvelle série, dédiée à l'**Identity Threat Detection and Response** dans l'environnement Microsoft.

Elle prolonge directement la série *Conditional Access Framework v4*, qui traitait la décision d'accès. L'ITDR commence là où l'accès conditionnel s'arrête : signaux postérieurs à l'authentification, détection d'anomalies, corrélation cross-pillar, investigation et réponse.

L'objectif n'est pas de présenter chaque produit isolément. C'est de comprendre comment ils s'articulent, ce qu'ils couvrent en pratique, et où s'arrêtent leurs garanties.

## De quoi parle-t-on exactement

L'ITDR est un terme posé par Gartner en 2022, repris depuis par la plupart des éditeurs sécurité. Il désigne l'ensemble des capacités qui permettent de détecter une compromission d'identité, de la corréler avec les autres signaux disponibles, et d'y répondre, qu'elle se manifeste sur un compte, sur une session, sur un token ou sur une application.

Microsoft n'utilise pas systématiquement le sigle ITDR dans sa communication, mais l'ensemble des briques correspondantes existent dans son écosystème depuis plusieurs années : Microsoft Defender for Identity, Microsoft Entra ID Protection, Microsoft Defender for Cloud Apps, Microsoft Defender XDR et Microsoft Sentinel.

Cette série traite ces briques par leur fonction réelle dans une chaîne ITDR, pas par leur marketing produit.

## Pourquoi le sujet émerge maintenant

Le constat est largement partagé sur le terrain : les attaques modernes contre l'identité cherchent moins à casser l'authentification qu'à exploiter une session déjà accordée. Phishing proxy, AiTM, vol de tokens, OAuth consent illicite, abus de service principals. Dans ces scénarios, l'attaquant n'a pas besoin de contourner durablement la MFA. Il hérite d'un accès légitime.

La conséquence pratique est simple. Renforcer la décision d'accès reste indispensable, mais ne suffit plus. Il faut être capable de détecter les écarts de comportement après authentification, d'investiguer rapidement, et de couper les sessions actives avant que l'incident ne se propage.

C'est exactement ce que la pile ITDR Microsoft prétend faire. Cette série regarde dans quelle mesure elle y parvient réellement, et où elle laisse des angles morts.

## À qui s'adresse cette série

La série vise des profils déjà installés dans des environnements Microsoft Entra ID et Microsoft 365 :

- les RSSI et responsables sécurité qui doivent arbitrer entre Defender XDR seul et Defender XDR plus Sentinel ;
- les architectes IAM et sécurité qui conçoivent ou refondent un dispositif de détection identité ;
- les MSP qui exploitent ces outils sur plusieurs tenants et cherchent une grille de lecture commune ;
- les analystes SOC qui prennent en charge des incidents identité et veulent comprendre la mécanique des signaux qu'ils traitent.

Elle part du principe que les notions de base sont acquises : Entra ID, Conditional Access, MFA, journaux de signalisation, alertes Defender. L'objectif n'est pas de présenter chaque produit, mais de poser une lecture opérationnelle de la pile dans son ensemble.

Elle ne s'adresse pas :

- aux environnements en phase de découverte de Microsoft 365 ;
- aux contextes sans gouvernance des identités ni politique de Conditional Access en place ;
- aux lecteurs qui cherchent une configuration universelle ou un script tout-en-un.

## Continuité avec la série Conditional Access Framework

Cette nouvelle série prolonge la précédente, mais en change la posture. La CAF traitait la **prévention** : poser des règles pour réduire les chances qu'un accès illégitime soit accordé. L'ITDR traite la **détection et la réponse** : partir du principe que certaines compromissions passeront, et organiser ce qui se déclenche à ce moment-là.

Les deux séries ne sont pas redondantes. Elles sont complémentaires et reposent sur la même hypothèse, déjà posée dans le 160 de la série CAF : aucun cadre de prévention ne couvre toute la surface d'attaque, et tout dispositif sérieux a besoin d'un volet détection-réponse pour rester cohérent.

## Structure de la série

Seize articles, organisés en cinq blocs.

**Cadre et concepts.** Surface d'attaque identité, panorama des briques Microsoft, modèle de détection signal-alerte-incident.

**Sources de signaux.** Entra ID Protection, Defender for Identity, Defender for Cloud Apps, journaux Entra natifs.

**Corrélation et investigation.** Defender XDR pour l'identité, place de Sentinel, étude de cas bout-en-bout.

**Réponse et automatisation.** Automated Investigation and Response, playbooks Sentinel, runbook de réponse manuelle pour une identité compromise.

**Limites et gouvernance.** Angles morts de la pile, gouvernance opérationnelle et indicateurs de posture.

Comme dans la CAF, chaque article peut être lu indépendamment. L'ordre est pensé pour refléter la progression réelle de compréhension et de mise en œuvre.

## Trois lignes rouges éditoriales

Cette série assume trois positions, posées dès maintenant pour éviter toute ambiguïté dans les articles suivants.

**Pas de complétude prétendue.** La pile ITDR Microsoft est cohérente dans son périmètre. Elle ne couvre pas tout. Les angles morts feront l'objet d'un article dédié, à l'image de ce qui a été fait pour la CAF.

**Pas de confusion ITDR / XDR.** Microsoft Defender XDR n'est pas un produit ITDR au sens strict. C'est une plateforme de corrélation qui ingère, entre autres sources, des signaux d'identité. La nuance est utile, parce qu'elle évite d'attribuer à Defender XDR un rôle qu'il ne joue pas seul.

**Pas de remplacement de la prévention.** Détecter une compromission après authentification n'est pas une stratégie en soi. C'est un complément à un Conditional Access bien posé. Les deux ensemble, pas l'un à la place de l'autre.

## Le rôle de cet article dans la série

Ce premier article n'entre dans aucune mécanique produit. Il sert de point d'ancrage et de référence commune pour les articles plus opérationnels qui suivent.

Chaque brique sera ensuite décortiquée séparément, avec un focus sur ce qu'elle voit, ce qu'elle ne voit pas, et comment elle s'articule avec le reste de la pile. Le contenu reste factuel et professionnel : ni sur-vente, ni dépréciation gratuite.

## Conclusion

L'ITDR Microsoft n'est pas une catégorie de produit, c'est une chaîne fonctionnelle qui s'appuie sur plusieurs briques existantes. Bien comprise, elle prolonge naturellement un dispositif de prévention déjà en place, en particulier celui posé par la série CAF. Mal comprise, elle se transforme en superposition d'outils mal articulés qui produisent du bruit sans apporter de capacité réelle de détection ou de réponse.

Cette série propose une lecture structurée de cette chaîne, brique par brique, avec un point d'attention constant sur le terrain et sur les contextes MSP. La suite démarre la semaine prochaine avec la cartographie de la surface d'attaque identité dans un tenant Microsoft moderne.
