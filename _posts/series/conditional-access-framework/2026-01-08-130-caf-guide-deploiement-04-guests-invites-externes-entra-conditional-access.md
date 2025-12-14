---
title: "Conditional Access Framework v4 — CA400 à CA404 : invités et identités externes"
date: 2026-10-08 09:00:00 +01:00
layout: post
tags: [series:conditional-access-framework, utilisateurs-externes, conditional-access]
categories: [identite, entra-id]
readtime: true
comments: true
cover-img: "assets/img/banners/banner-conditional-access.png"
thumbnail-img: "assets/img/posts/series/conditional-access-framework/130/130-thumb.png"
series: CA
series_order: 130
sidebar: true
level: technique
scope:
  - Entra ID
  - Identités externes
  - Guests
platform: Microsoft Entra
---
## Conditional Access Framework v4 — CA400 à CA404 : invités et identités externes

Les politiques CA400 à CA404 traitent les invités et identités externes. Ce bloc répond à une réalité simple : ces identités n’appartiennent pas à l’organisation, ne suivent pas ses standards techniques, et échappent en grande partie à sa gouvernance.

Le framework ne cherche pas à intégrer ces identités dans le modèle interne. Il les considère comme structurellement moins maîtrisées et adapte les contrôles en conséquence. Le but n’est pas de tout bloquer, mais de limiter strictement ce que ces accès permettent réellement.

## Rôle du bloc Guests dans le framework

Le bloc CA400–CA404 a un rôle de confinement.

Il ne vise ni la productivité maximale, ni l’intégration fluide des usages. Il cherche à garantir que les accès invités restent :
- limités dans le temps,
- restreints en périmètre,
- facilement révoquables,
- et peu persistants.

Contrairement aux utilisateurs internes, les invités ne constituent pas un socle à partir duquel construire d’autres contrôles. Ils représentent un risque à contenir, pas un usage à optimiser.

## Logique d’inclusion et d’exclusion

L’inclusion repose sur les mécanismes natifs d’Entra ID permettant d’identifier les invités et utilisateurs externes.

Les exclusions sont volontairement rares et ciblées.

On retrouve principalement :
- les comptes de secours (break-glass), exclus de toutes les politiques ;
- certaines identités techniques lorsqu’un usage externe spécifique le justifie.

Les invités sont explicitement exclus des politiques globales et internes. Ils sont traités par un bloc dédié afin d’éviter toute ambiguïté dans les décisions d’accès.

## CA400 — Guest Users — Identity Protection — MFA

CA400 impose une exigence MFA pour les utilisateurs invités.

Cette règle établit un minimum de protection face aux risques les plus courants, notamment les compromissions de comptes externes faiblement protégés. Elle ne présume pas de la qualité des mécanismes MFA utilisés par l’organisation d’origine.

L’objectif est de poser une barrière d’entrée claire, sans chercher à aligner les invités sur le niveau de protection des utilisateurs internes.

![CA000](/assets/img/posts/conditional-access-framework/)

## CA401 — Guest Users — Attack Surface Reduction — Block Non-Guest App Access

CA401 empêche les invités d’accéder à des applications qui ne leur sont pas explicitement destinées.

Cette règle réduit le risque de dérive fonctionnelle, où un compte invité finit par accéder à des ressources internes par accumulation de permissions. Elle matérialise une séparation stricte entre usages internes et usages externes.

![CA000](/assets/img/posts/conditional-access-framework/)

## CA402 — Guest Users — Identity Protection — Sign-in Frequency

CA402 impose une fréquence de réauthentification plus élevée pour les invités.

Les sessions longues représentent un risque accru pour des identités externes, souvent utilisées depuis des environnements non maîtrisés. Cette règle limite la durée de validité des sessions et réduit l’impact d’un accès compromis.

La contrainte est assumée. Le confort d’usage n’est pas la priorité pour ce type d’identité.

![CA000](/assets/img/posts/conditional-access-framework/)

## CA403 — Guest Users — Identity Protection — Persistent Browser

CA403 limite l’utilisation des sessions persistantes pour les invités.

Elle vise à empêcher l’ancrage durable d’une session externe sur un poste ou un navigateur non contrôlé. Cette règle complète CA402 en réduisant la surface d’exposition temporelle.

![CA000](/assets/img/posts/conditional-access-framework/)

## CA404 — Guest Users — Attack Surface Reduction — Selected Apps — Block

CA404 bloque l’accès à certaines applications pour les invités lorsque les conditions ne sont pas réunies.

Cette règle permet de protéger des applications sensibles sans bloquer l’ensemble des usages externes. Elle introduit une segmentation fine entre collaboration nécessaire et exposition excessive.

![CA000](/assets/img/posts/conditional-access-framework/)

## Ce que le bloc Guests ne fait volontairement pas

Les politiques CA400–CA404 ne cherchent pas à sécuriser les environnements externes ni à garantir l’identité réelle des invités.

Elles ne remplacent pas les processus de gouvernance des invitations, la revue des accès ou la gestion du cycle de vie des identités externes. Elles partent du principe que ces identités sont moins fiables par nature et limitent leurs effets.

## Conclusion

Le bloc CA400–CA404 ne vise pas à intégrer les invités dans le modèle interne, mais à les maintenir à distance contrôlée.

Sa valeur réside dans sa sobriété : peu de règles, mais des limites claires. Bien appliqué, ce bloc empêche que les identités externes deviennent un point d’entrée durable ou silencieux dans l’environnement.
