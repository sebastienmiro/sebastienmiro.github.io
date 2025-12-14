---
title: "Security Defaults vs. Conditional Access : le faux sentiment de sécurité"
date: 2025-12-12 11:30:00 +01:00
layout: post
tags: [series:un-risque-une-mesure, conditional-access, security-defaults]
categories: [identite, entra-id]
readtime: true
comments: true
cover-img: "assets/img/banners/banner4.png"
thumbnail-img: "assets/img/posts/1765400671089.jpg"
series: R1M
series_order: 010
sidebar: true
level: concepts
scope:
  - Entra ID
  - Conditional Access
  - Généralités
featured: true
featured_reason: "Base indispensable à comprendre avant d'aller plus loin."
---

💡 **Activer l’accès conditionnel sans planification, c’est un peu comme retirer les airbags pour installer un ABS.**  
On gagne en contrôle, en finesse, en possibilités… mais on supprime au passage une protection passive qui faisait son travail sans poser de questions.

L’accès conditionnel (Conditional Access) est souvent présenté comme le mécanisme de sécurité “avancé” de Microsoft Entra ID. Dans les faits, ce n’est pas tant une brique de sécurité qu’un **changement de modèle**, avec des effets immédiats — et parfois invisibles — sur le niveau de protection réel d’un tenant Microsoft 365.

![Entra Admin Center - Security Defaults](/assets/img/posts/security-defaults-entra-admin-center.png)

## Le risque dès l’activation

Le point clé à comprendre est contre-intuitif : **activer l’accès conditionnel sans reconstruire explicitement les protections des Security Defaults peut faire baisser le niveau de sécurité**.

Ce scénario est fréquent. Il revient régulièrement lors d’audits, et parfois après incident. Non pas parce que l’accès conditionnel serait défaillant, mais parce que la transition entre deux modèles de sécurité est mal comprise.

Le problème n’est pas l’outil. Le problème est ce qu’on enlève en l’activant.

## Ce que font réellement les Security Defaults

Les Security Defaults ne sont ni fins, ni élégants, ni personnalisables. Ils n’essaient pas de l’être. Leur rôle est ailleurs : fournir un **socle minimal cohérent**, pensé pour couvrir les scénarios d’attaque les plus courants, sans dépendre d’une expertise avancée.

Concrètement, ils imposent une authentification multifacteur pour les utilisateurs, renforcent les exigences sur les comptes administrateurs, bloquent les protocoles d’authentification hérités et s’appliquent globalement, sans logique d’exception implicite.

Ce modèle a deux qualités souvent sous-estimées. Il est prévisible, et il est difficile à affaiblir par inadvertance.

## Le basculement silencieux vers l’accès conditionnel

C’est ici que se situe le point de rupture.

**Dès qu’au moins une politique d’accès conditionnel est activée, les Security Defaults sont automatiquement désactivés.** Il n’y a pas de mode hybride, pas de transition progressive, pas de filet de sécurité conservé en arrière-plan.

À partir de ce moment, Microsoft ne fournit plus aucun socle implicite. Tout ce qui protège le tenant repose exclusivement sur les politiques d’accès conditionnel définies. Ce qui n’est pas explicitement configuré n’existe tout simplement plus.

Autrement dit, l’accès conditionnel ne complète pas les Security Defaults. Il les remplace.

## Le faux sentiment de sécurité

Dans la pratique, ce basculement crée un sentiment trompeur de renforcement. Visuellement, le tenant “fait plus sécurisé”. Les politiques sont là, les écrans sont remplis, les options sont cochées.

Mais lorsqu’on regarde dans le détail, on retrouve souvent les mêmes situations : quelques politiques créées rapidement, des exclusions larges pour éviter les blocages, un périmètre limité aux utilisateurs standards, des administrateurs traités à part — voire pas du tout — et des scénarios entiers laissés hors champ, comme l’authentification legacy, les comptes de service ou les invités.

Techniquement, le tenant peut alors se retrouver **moins protégé qu’avant**, alors même que l’accès conditionnel est activé.

## Ce que l’on observe sur le terrain

Les exemples sont malheureusement classiques : des utilisateurs sans MFA parce qu’ils ne font pas partie du bon groupe, des protocoles obsolètes toujours autorisés faute de règle explicite, des comptes administrateurs volontairement exclus “temporairement”, des invités complètement hors périmètre ou encore des politiques empilées sans vision d’ensemble.

Dans ce type de configuration, il n’est pas rare que les Security Defaults aient offert une meilleure protection que l’accès conditionnel tel qu’il est déployé.

## L’accès conditionnel n’est pas une protection en soi

C’est un point fondamental, et souvent mal compris.

L’accès conditionnel ne protège rien par défaut. Il n’impose aucun minimum. Il ne garantit aucune cohérence globale. Il fournit un framework : des conditions, des contrôles, et une liberté quasi totale.

Cette liberté est une force. Mais elle implique une responsabilité claire : **concevoir un modèle de sécurité avant d’écrire des règles**.

## La mesure : reconstruire le socle avant d’optimiser

Avant de chercher à affiner, à contextualiser ou à automatiser, l’objectif doit rester simple : **recréer explicitement le niveau de protection offert par les Security Defaults**.

Cela commence par des fondamentaux non négociables. Les comptes brise-glace doivent être exclus de toutes les politiques, mais sécurisés, documentés, surveillés et testés. Ils ne sont pas là pour le confort, mais pour la résilience.

Ensuite, le socle doit être reconstruit sans ambiguïté : MFA pour tous les utilisateurs, exigences renforcées pour les rôles à privilèges, blocage explicite de l’authentification legacy, couverture globale sans dépendance implicite. Chaque protection doit être visible dans Entra ID, vérifiable et explicable à un tiers.

Plutôt que d’inventer un modèle de toutes pièces, il est souvent pertinent de s’appuyer sur une baseline structurée. Celle proposée par Joey Verlinden, par exemple, repose sur des politiques atomiques, lisibles dans le temps et conçues pour évoluer progressivement. L’objectif n’est pas d’être conforme à une baseline, mais d’assurer la cohérence du modèle.

![Joey Verlinden - Conditional Access Baseline](/assets/img/posts/joeyv-conditional-access-baseline.png)

Enfin, toute politique d’accès conditionnel doit être testée. Pas uniquement en mode “ça ne bloque pas”, mais sur les scénarios critiques, via les journaux de connexion, avant un déploiement global. En accès conditionnel, **le test fait partie intégrante de la mesure de sécurité**.

## Derrière la technique, la gouvernance

L’activation de l’accès conditionnel n’est pas un simple réglage technique. C’est une décision de gouvernance de l’identité. Elle suppose des règles documentées, des objectifs clairs, une responsabilité identifiée et des revues régulières.

Sans cela, l’accès conditionnel devient rapidement une dette technique. Et, le jour où un incident survient, un angle mort.

## À retenir

Les Security Defaults offrent un socle minimal mais robuste.  
L’accès conditionnel désactive ce socle sans le remplacer implicitement.  
Toute protection non reconstruite est perdue.  
Avant d’optimiser, il faut d’abord reconstruire.  
La sécurité de l’identité est avant tout une question de gouvernance.

Cet article sert de point d’entrée à la série *1 risque / 1 mesure*.  
Les épisodes suivants iront plus loin, là où ce socle devient indispensable face aux attaques modernes.
