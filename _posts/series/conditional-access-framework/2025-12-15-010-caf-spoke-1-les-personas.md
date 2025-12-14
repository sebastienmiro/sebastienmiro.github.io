---
title: "Conditional Access Framework v4 — Les personas comme point de départ"
date: 2026-10-08 09:00:00 +01:00
layout: post
tags: [series:conditional-access-framework, conditional-access, gouvernance]
categories: [identite, entra-id]
readtime: true
comments: true
cover-img: "assets/img/banners/banner-conditional-access.png"
thumbnail-img: "assets/img/posts/series/conditional-access-framework/010/010-thumbnail.png"
series: CA
series_order: 010
sidebar: true
level: concepts
scope:
  - Entra ID
  - Conditional Access
  - Personas
platform: Microsoft Entra
---

L’une des forces du Conditional Access Framework v4 est de ne pas commencer par des règles.  
Il commence par des **personas**.

Ce choix peut sembler anodin, mais il est structurant. Dans la plupart des environnements, l’accès conditionnel est historiquement construit à l’envers : on crée une règle pour répondre à un problème ponctuel, puis une autre, puis une troisième. Avec le temps, on se retrouve avec un empilement de politiques difficiles à lire, à maintenir et à expliquer.

Le framework prend le problème à la racine. Avant de parler de conditions, de contrôles ou de paramètres, il pose une question simple : **qui est en train de se connecter ?** Et surtout : **dans quel contexte de risque cette identité s’inscrit-elle ?**

Les personas ne sont donc pas une abstraction théorique. Elles sont le mécanisme qui permet d’éviter que toutes les identités soient traitées de la même manière.

## Une persona n’est pas un rôle, ni un groupe métier

Il est important de lever un malentendu fréquent.  
Dans le cadre du Conditional Access Framework, une persona n’est ni un rôle RH, ni un groupe fonctionnel, ni une classification métier.

Une persona représente un **profil de risque et d’exposition**, du point de vue de l’identité et de l’accès. Elle répond à des questions très concrètes :  
- Quel est l’impact si ce compte est compromis ?  
- À quelle fréquence est-il utilisé ?  
- Dans quels contextes techniques s’authentifie-t-il ?  
- Peut-on accepter une friction plus élevée à l’authentification ?

C’est pour cette raison que le framework raisonne en personas techniques, et non en utilisateurs au sens organisationnel. Une même personne peut d’ailleurs appartenir à plusieurs personas, selon les comptes qu’elle utilise.

## Les grandes familles de personas du framework

Le framework distingue plusieurs grandes catégories d’identités, chacune justifiant des politiques d’accès conditionnel différentes. Cette segmentation n’est pas décorative : elle conditionne directement la structure et l’ordre de déploiement des règles.

### Utilisateurs standards

C’est la persona la plus large, et souvent celle par laquelle on commence à tort.  
Elle regroupe les comptes utilisés au quotidien pour accéder aux applications, à la messagerie, aux outils collaboratifs.

Le framework considère ces identités comme **exposées par nature**, mais avec un impact généralement contenu. L’objectif n’est pas de bloquer toute tentative d’accès, mais de limiter les scénarios de compromission simples et répétables, tout en conservant une expérience utilisateur acceptable.

Les politiques associées à cette persona constituent une base, mais ne doivent jamais être considérées comme suffisantes pour d’autres types de comptes.

### Comptes à privilèges et administrateurs

Le framework isole très clairement les comptes à privilèges des utilisateurs standards. Ce point est fondamental.

Un compte administrateur n’est pas simplement un utilisateur avec plus de droits. C’est une **surface d’attaque critique**, avec un impact potentiellement systémique en cas de compromission. Le framework en tire une conséquence directe : ces comptes doivent sortir du flux normal d’authentification.

Cela se traduit par des exigences plus fortes, des restrictions supplémentaires sur le device et le contexte d’accès, et une tolérance beaucoup plus faible au risque. Cette séparation conceptuelle évite une erreur encore trop fréquente : appliquer les mêmes règles à tous, en se disant que “ça ira bien”.

### Comptes de secours (break-glass)

Le framework traite explicitement les comptes de secours comme une persona à part entière. Ce n’est pas un détail.

Ces comptes n’existent pas pour être sécurisés comme les autres, mais pour **rester accessibles dans des scénarios de défaillance**. Leur traitement nécessite donc un équilibre délicat entre disponibilité et exposition.

Le framework ne cherche pas à les intégrer dans les flux classiques de règles, mais à les isoler clairement, avec des politiques spécifiques et très maîtrisées. Les mélanger avec d’autres personas est l’une des erreurs les plus coûteuses que l’on puisse faire en accès conditionnel.

### Identités non humaines et workloads

Les identités applicatives, comptes de service et workloads ne se comportent pas comme des utilisateurs humains. Elles n’utilisent pas de MFA, n’interagissent pas avec des devices, et sont souvent invisibles pour les équipes tant qu’un incident ne survient pas.

Le framework les considère comme une catégorie distincte, avec des règles et des attentes différentes. L’objectif n’est pas de leur appliquer des contrôles inadaptés, mais de **ne pas les oublier**, ce qui est un risque fréquent lorsque l’accès conditionnel est pensé uniquement pour des utilisateurs interactifs.

### Invités et identités externes

Enfin, le framework isole les identités externes, invités et partenaires. Leur niveau de confiance initial est par définition plus faible, et leur contexte d’authentification plus difficile à maîtriser.

Les regrouper dans une persona dédiée permet d’appliquer des politiques cohérentes, sans affaiblir les règles destinées aux utilisateurs internes, ni créer des exceptions permanentes.

## Pourquoi les personas conditionnent l’ordre de déploiement

Un point souvent sous-estimé est que les personas ne servent pas uniquement à organiser les règles. Elles dictent aussi **l’ordre logique dans lequel ces règles doivent être mises en place**.

Le framework incite implicitement à commencer par :
- les comptes critiques,
- puis les scénarios transverses,
- avant d’élargir aux usages quotidiens.

Cette approche réduit fortement les effets de bord, les blocages accidentels et la tentation de multiplier les exclusions. Elle explique aussi pourquoi un déploiement “tout en même temps” aboutit souvent à un accès conditionnel illisible et fragile.

## Ce que les personas ne font pas

Les personas ne remplacent ni la gouvernance des droits, ni la gestion des rôles, ni la classification métier. Elles ne disent rien de ce que l’utilisateur est autorisé à faire, mais uniquement **dans quelles conditions il peut accéder**.

C’est précisément cette séparation des responsabilités qui rend le framework lisible. L’accès conditionnel décide de l’entrée. Le reste relève d’autres mécanismes.

## Conclusion

Le Conditional Access Framework v4 commence par les personas parce qu’il s’agit du seul moyen réaliste d’éviter une approche uniforme et inefficace de l’accès conditionnel. En distinguant clairement les profils de risque, le framework permet de construire des politiques cohérentes, compréhensibles et déployables dans le temps.

Comprendre les personas n’est pas un prérequis théorique. C’est la condition nécessaire pour que toutes les règles qui suivent aient un sens.

Dans les articles suivants, chaque groupe de politiques sera analysé à travers ce prisme, en commençant par le socle commun qui s’applique à plusieurs de ces personas.
