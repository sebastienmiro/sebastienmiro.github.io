---
title: "MDE Foundations - Episode 1 : état des lieux et feuille de route"
date: 2025-05-16 08:00:00 +01:00
layout: post
categories: [securite, MDE]
tags:
  - Microsoft Defender for Endpoint
  - Intune
  - MDE Foundations
  - Endpoint Security
  - Windows
readtime: true
comments: true
sidebar: false
level: Intermédiaire
platform: Microsoft Defender for Endpoint
scope: Postes de travail / Serveurs
cover-img: assets/img/posts/2025/05/mde-foundations-ep1-cover.png
thumbnail-img: assets/img/posts/2025/05/mde-foundations-ep1-thumb.png
series: MDE Foundations
series_order: 1
---

Quand on audite la configuration de Microsoft Defender for Endpoint sur un tenant existant, on tombe rarement sur quelque chose de propre. Ce n'est pas une critique des équipes en place : MDE est un produit complexe, sa documentation est dense, et il n'existe pas de configuration de référence officielle prête à l'emploi. Le résultat, c'est que beaucoup de déploiements ont été faits par morceaux, avec des méthodes de gestion qui ne se parlent pas entre elles.

Cet épisode pose le constat et présente la démarche que cette série va suivre.

## Ce que les audits révèlent

Voici les situations que l'on rencontre régulièrement, indépendamment de la taille du tenant ou du secteur d'activité.

**Onboarding orphelin**

Des postes sont onboardés via un script déposé en GPO il y a deux ans. Le script tourne, MDE remonte les machines dans le portail, mais personne ne sait exactement quels postes sont couverts ni si le script est encore distribué aux nouvelles machines. L'inventaire MDE et l'inventaire réel ne correspondent pas.

**Tamper Protection désactivée**

C'est souvent le premier paramètre qu'on vérifie et c'est souvent à Off. La raison invoquée : un outil tiers qui entrait en conflit et qu'on a depuis désinstallé, ou une procédure de déploiement qui n'a jamais été mise à jour.

**Exclusions trop larges**

On trouve des exclusions qui portent sur des dossiers entiers (`C:\Program Files\`, `C:\Windows\Temp\`), parfois héritées d'un ancien antivirus. Ces exclusions restent en place sans réévaluation parce que "ça marche" et personne ne veut toucher à quelque chose qui fonctionne.

**ASR figé en mode Audit**

Les règles Attack Surface Reduction ont été activées en Audit lors d'un projet qui n'a jamais abouti. Elles génèrent des événements que personne ne consulte, et personne n'a eu le mandat de passer en Block. Le mode Audit est devenu la configuration permanente par défaut.

**Méthodes de gestion mixtes**

Sur un même tenant, on trouve des policies déployées via Intune, des configurations appliquées via le portail MDE, des scripts onboarding en GPO et parfois des paramètres locaux modifiés manuellement. Il devient impossible de savoir quelle configuration est effectivement appliquée sur un poste donné sans y aller voir.

**Absence de distinction postes / serveurs**

Les serveurs Windows sont gérés avec les mêmes politiques que les postes de travail, ou pas gérés du tout via MDE. Les serveurs exposent pourtant une surface d'attaque différente et méritent des profils distincts.

## Pourquoi gérer MDE depuis Intune

MDE peut être configuré depuis plusieurs endroits : le portail Microsoft Defender, des GPO, des scripts, ou Intune. Le problème avec la multiplicité des méthodes, c'est qu'elles s'appliquent avec des priorités qui ne sont pas toujours prévisibles, et qu'elles rendent l'audit difficile.

Intune présente plusieurs avantages concrets pour gérer MDE.

La configuration est versionnée et traçable. Chaque policy a un historique de modification avec la date et l'auteur.

Le périmètre d'application est défini par des groupes Entra ID. On peut cibler précisément un sous-ensemble de machines pour un déploiement pilote avant de pousser à l'ensemble du parc.

Les policies Intune s'appliquent aussi aux postes et serveurs onboardés dans MDE sans licence Intune active. Ces machines apparaissent comme "managed by MDE" dans le portail et reçoivent les politiques de sécurité Endpoint Security comme n'importe quel poste Intune-enrolled. C'est un point souvent mal compris : tu n'as pas besoin d'une licence Intune par machine pour bénéficier de la gestion centralisée des politiques de sécurité MDE.

Il reste un cas où Intune ne peut pas tout faire : certains paramètres avancés de MDE ne sont exposés qu'au niveau du portail Defender. On les signalera au cas par cas dans la série.

## Plan de la série MDE Foundations

La série couvre le déploiement complet de MDE sur un tenant, postes de travail et serveurs Windows, avec Intune comme méthode de gestion unique.

**Épisode 1** - État des lieux et feuille de route *(cet article)*

**Épisode 2** - Licences et onboarding : postes de travail

**Épisode 3** - Licences et onboarding : serveurs Windows

**Épisode 4** - Antivirus : configurer Windows Defender correctement

**Épisode 5** - Firewall : profils et règles de base

**Épisode 6** - Attack Surface Reduction : comprendre les règles

**Épisode 7** - Attack Surface Reduction : déploiement progressif

**Épisode 8** - Tamper Protection et verrouillage

**Épisode 9** - Investigation et réponse avec MDE

**Épisode 10** - Le template MDE Foundations : import clés en main avec IntuneManagement

Le dernier épisode fournit un export complet de groupes Entra ID et de policies Intune, importable directement dans ton tenant via un outil dédié. Les épisodes macOS et Linux seront traités séparément, en dehors de cette série.