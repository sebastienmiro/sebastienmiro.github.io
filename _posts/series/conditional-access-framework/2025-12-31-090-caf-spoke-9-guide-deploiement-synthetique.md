---
title: "Conditional Access Framework v4 — Guide de déploiement maîtrisé (audit-first)"
date: 2025-12-24 09:00:00 +01:00
layout: post
tags: [series:conditional-access-framework, deploiement, synthese]
categories: [identite, entra-id]
readtime: true
comments: true
cover-img: "assets/img/banners/banner-conditional-access.png"
thumbnail-img: "assets/img/posts/series/conditional-access-framework/090/090-thumb.png"
series: CA
series_order: 090
sidebar: true
level: opérationnel
scope:
  - Entra ID
  - Déploiement
  - Audit
platform: Microsoft Entra
---
## Conditional Access Framework v4 — Guide de déploiement maîtrisé (audit-first)

Déployer l’accès conditionnel n’est jamais une opération neutre. Que l’on parte de *Security Defaults*, d’un tenant avec déjà des politiques d’accès conditionnel, ou d’un déploiement automatisé via un outil tiers, la même réalité s’impose : une mauvaise séquence crée immédiatement des blocages, des angles morts ou une régression de sécurité difficile à corriger a posteriori.

Ce guide ne décrit pas où cliquer dans le portail.  
Il décrit **comment introduire le Conditional Access Framework v4 sans casser l’existant**, en respectant la logique interne du framework et en s’appuyant systématiquement sur une phase d’observation avant toute activation.

### Étape 1 — Audit de l’existant (point de départ obligatoire)

Avant toute modification, il faut comprendre précisément ce qui est déjà en place.

Cela implique au minimum :
- vérifier si *Security Defaults* est actif ;
- recenser toutes les politiques d’accès conditionnel existantes, leur état (On / Audit), leur périmètre réel et leurs exclusions ;
- identifier les méthodes d’authentification réellement utilisables ;
- lister les comptes à privilèges effectivement utilisés ;
- vérifier l’existence et le test récent des comptes de secours.

À ce stade, **on ne touche à rien**.  
On observe, on cartographie, on documente.

Cette étape conditionne tout le reste. Sans elle, le déploiement du framework devient un exercice théorique.

### Étape 2 — Cas n°1 : Security Defaults actif

Si *Security Defaults* est actif, la première erreur serait de le désactiver pour « repartir proprement ».

Security Defaults assure implicitement plusieurs protections critiques. Les supprimer sans équivalent explicite crée immédiatement une fenêtre de vulnérabilité.

La transition correcte se fait en deux temps.

D’abord, on met en place explicitement un socle minimal de politiques d’accès conditionnel couvrant a minima :
- le blocage de l’authentification legacy ;
- une exigence MFA cohérente sur les accès sensibles ;
- la protection des accès administratifs ;
- l’utilisation exclusive de l’authentification moderne.

Ces règles **ne sont pas encore le Conditional Access Framework v4**.  
Elles servent uniquement à garantir qu’aucune protection implicite n’est perdue.

Une fois ce socle validé, *Security Defaults* peut être désactivé.  
Ce n’est qu’à partir de là que le framework peut être introduit.

### Étape 3 — Cas n°2 : accès conditionnel déjà présent

Dans de nombreux tenants, des politiques d’accès conditionnel existent déjà. Elles ont été créées pour répondre à des besoins ponctuels, souvent sans cadre global.

Dans ce cas :
- on ne supprime rien ;
- on ne modifie rien immédiatement ;
- on ne cherche pas à simplifier avant d’avoir observé.

On **déploie l’intégralité du Conditional Access Framework v4 en mode Audit**, par-dessus l’existant.

L’objectif n’est pas de remplacer immédiatement, mais de **poser une grille de lecture cohérente** sur une configuration hétérogène.

### Étape 4 — Pourquoi le framework doit être déployé en totalité, en mode Audit

Le Conditional Access Framework v4 ne fonctionne pas comme une simple liste de règles indépendantes. Il repose sur une logique de spécialisation progressive, dans laquelle les politiques globales servent de socle et cèdent volontairement la place à des politiques plus ciblées.

Cette spécialisation est rendue possible par les exclusions. Elles ne sont pas des exceptions, mais des mécanismes de routage entre politiques.

Déployer seulement une partie du framework en Audit fausse l’analyse, car :
- les recouvrements ne sont pas visibles ;
- les exclusions croisées ne peuvent pas être interprétées correctement ;
- les journaux deviennent difficilement exploitables.

Déployer **l’ensemble du framework en Audit** permet au contraire :
- d’observer quelle politique aurait réellement pris la décision ;
- de comprendre comment les flux sont orientés entre politiques globales et spécialisées ;
- de valider la cohérence des périmètres et des exclusions.

Le mode Audit n’est pas une temporisation.  
C’est **la phase d’ingénierie du déploiement**.

### Étape 5 — Analyse des journaux et des métriques

Une fois le framework entièrement présent en mode Audit, l’analyse peut commencer.

On observe notamment :
- quelles politiques auraient été appliquées ;
- à quels types d’identités ;
- sur quelles applications ;
- dans quels contextes ;
- avec quels effets combinés.

Cette phase permet :
- d’ajuster les périmètres d’inclusion ;
- de valider les exclusions réellement nécessaires ;
- d’identifier les dépendances entre politiques ;
- de détecter les incohérences héritées de l’existant.

Sans cette étape, toute activation repose sur des hypothèses.

### Étape 6 — Passage progressif en mode ON (ordre recommandé)

L’activation ne commence qu’après l’analyse, progressivement et dans un ordre cohérent avec la structure du framework :

1. Les politiques globales (CA000–CA006), qui remplacent explicitement les protections de base
2. Les utilisateurs internes standards (CA200–CA210)
3. Les contrôles de session et de tokens, une fois les flux compris
4. L’exploitation des signaux device
5. Les comptes à privilèges (CA100–CA105)
6. Les invités et identités externes (CA400+)
7. Les comptes de service (CA300+), selon les usages réels

Chaque bascule doit être annoncée, observée et stabilisée avant de passer à la suivante.

### Ce qu’il ne faut pas faire

- Activer un bloc complet sans analyse préalable.
- Supprimer l’existant avant d’avoir observé les interactions.
- Accumuler des exclusions « temporaires » non documentées.
- Interpréter le mode Audit comme une absence de risque.
- Confondre conformité device et sécurité réelle.

Ces erreurs sont rarement techniques.  
Elles sont presque toujours méthodologiques.

### Conclusion

Le Conditional Access Framework v4 ne s’active pas d’un clic.  
Il se **déploie par superposition, observation et substitution progressive**, en respectant la logique interne des politiques et de leurs exclusions.

Quel que soit le point de départ — *Security Defaults*, accès conditionnel partiel ou déploiement automatisé — la règle reste la même :

**audit d’abord, compréhension ensuite, activation en dernier.**
