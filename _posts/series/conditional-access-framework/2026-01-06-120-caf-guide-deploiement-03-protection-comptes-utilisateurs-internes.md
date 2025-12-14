---
title: "Conditional Access Framework v4 — CA200 à CA210 : utilisateurs internes"
date: 2025-12-28 09:00:00 +01:00
layout: post
tags: [series:conditional-access-framework, utilisateurs, deploiement]
categories: [identite, entra-id]
readtime: true
comments: true
cover-img: "assets/img/banners/banner-conditional-access.png"
thumbnail-img: "assets/img/posts/series/conditional-access-framework/120/120-thumb.png"
series: CA
series_order: 120
sidebar: true
level: technique
scope:
  - Entra ID
  - Utilisateurs internes
  - Déploiement
platform: Microsoft Entra
---
## Conditional Access Framework v4 — CA200 à CA210 : utilisateurs internes

Les politiques CA200 à CA210 couvrent les utilisateurs internes standards. Ce bloc représente le cœur opérationnel du Conditional Access Framework v4, car il traite les identités les plus nombreuses, les plus actives et, paradoxalement, les plus exposées.

Contrairement au socle global, ces politiques ne servent pas uniquement de filet de sécurité. Elles définissent le comportement attendu des utilisateurs internes dans un environnement maîtrisé, en combinant exigences d’authentification, gestion de la session et signaux techniques.

## Rôle du bloc Internals dans le framework

Le bloc CA200–CA210 a pour objectif de protéger les usages quotidiens sans les assimiler à des usages à privilèges.

Il se situe volontairement entre deux extrêmes :
- le socle global, qui couvre large mais reste minimal ;
- le bloc administrateurs, qui impose des contraintes fortes et non négociables.

Les politiques Internals sont donc conçues pour être réellement appliquées, pas simplement théoriques. Elles traduisent un compromis assumé entre sécurité, continuité d’activité et expérience utilisateur.

## Logique d’inclusion et d’exclusion

L’inclusion repose sur des groupes représentant explicitement les utilisateurs internes standards. Ces groupes correspondent à un périmètre d’usage, pas à un niveau de confiance.

Les exclusions sont structurantes et systématiques.

On retrouve notamment :
- les comptes de secours (break-glass) ;
- les comptes à privilèges, traités exclusivement par le bloc CA100–CA105 ;
- les comptes de service et identités non interactives ;
- les invités et identités externes, couverts par le bloc CA400.

Cette logique garantit que les utilisateurs internes ne sont ni surprotégés par des règles administratives, ni insuffisamment couverts par le seul socle global.

## CA200 — Internals Identity Protection — MFA

CA200 impose une exigence MFA pour les utilisateurs internes.

Cette règle constitue le point d’entrée du bloc Internals. Elle ne vise pas à imposer les mécanismes MFA les plus contraignants, mais à garantir qu’aucun accès interactif significatif ne repose sur un facteur unique.

Elle prend le relais de CA000 dès lors que l’identité correspond à un utilisateur interne standard.

![CA000](/assets/img/posts/conditional-access-framework/)

## CA201 — Internals Identity Protection — Block High-Risk User

CA201 bloque les accès lorsque l’identité est évaluée comme présentant un risque élevé.

Cette règle introduit une logique de réaction face à des signaux de compromission avérés ou probables. Contrairement aux exigences MFA, elle ne cherche pas à compenser le risque, mais à interrompre le flux.

Elle matérialise une frontière claire : au-delà d’un certain niveau de risque, l’accès n’est plus acceptable.

![CA000](/assets/img/posts/conditional-access-framework/)

## CA202 — Internals Identity Protection — Sign-in Frequency (Unmanaged Devices)

CA202 impose une fréquence de réauthentification renforcée lorsque l’accès s’effectue depuis des devices non maîtrisés.

Cette règle reconnaît explicitement que tous les accès internes ne se font pas depuis des environnements de confiance. Elle limite la durée de validité des sessions dans ces contextes sans bloquer systématiquement l’accès.

C’est une mesure de réduction de l’impact, pas une affirmation de confiance.

![CA000](/assets/img/posts/conditional-access-framework/)

## CA203 — Internals App Protection — Intune Enrollment

CA203 protège les flux d’enrôlement Intune.

L’enrôlement d’un device est un acte structurant, souvent sous-estimé. Cette règle vise à s’assurer que seules des identités correctement authentifiées peuvent initier ce type d’opération.

Elle empêche qu’un enrôlement devienne un vecteur de persistance non contrôlée.

![CA000](/assets/img/posts/conditional-access-framework/)

## CA204 — Internals Attack Surface Reduction — Block Unknown Platforms

CA204 bloque les accès depuis des plateformes non identifiées ou non supportées.

Cette règle réduit la surface d’attaque en empêchant l’exploitation de clients atypiques ou détournés. Elle force l’usage de plateformes connues, sur lesquelles les autres signaux du framework peuvent s’exprimer correctement.

![CA000](/assets/img/posts/conditional-access-framework/)

## CA205 — Internals Base Protection — Windows Compliant or AAD Joined

CA205 introduit une exigence de device maîtrisé pour certains accès depuis Windows.

Cette règle établit une distinction claire entre un poste personnel et un poste intégré à l’environnement. Elle ne garantit pas la sécurité du device, mais elle fournit un signal fort sur son niveau d’intégration.

Elle prépare l’exploitation plus fine du signal device dans les blocs suivants.

![CA000](/assets/img/posts/conditional-access-framework/)

## CA206 — Internals Identity Protection — Persistent Browser

CA206 limite l’usage des sessions persistantes pour les utilisateurs internes.

Cette règle réduit la durée de vie effective des sessions dans le navigateur, en particulier sur des postes partagés ou non maîtrisés. Elle vise à limiter l’exploitation d’un accès légitime au-delà de sa fenêtre d’usage normale.

![CA000](/assets/img/posts/conditional-access-framework/)

## CA207 — Internals Attack Surface Reduction — Selected Apps — Block

CA207 bloque l’accès à certaines applications spécifiques lorsque les conditions ne sont pas réunies.

Cette règle permet de protéger des applications sensibles sans généraliser des contraintes excessives à l’ensemble du tenant. Elle introduit une segmentation applicative ciblée.

![CA000](/assets/img/posts/conditional-access-framework/)

## CA208 — Internals Base Protection — macOS Compliant

CA208 applique une logique équivalente à CA205 pour les environnements macOS.

Elle reconnaît la diversité des postes internes et adapte les exigences de conformité au système utilisé, sans introduire de rupture fonctionnelle.

![CA000](/assets/img/posts/conditional-access-framework/)

## CA209 — Internals Identity Protection — Continuous Access Evaluation

CA209 active l’évaluation continue de l’accès pour les utilisateurs internes.

Cette règle permet de prendre en compte des changements de contexte en cours de session, par exemple une élévation de risque détectée après l’accès initial. Elle réduit la dépendance à l’instant d’authentification.

![CA000](/assets/img/posts/conditional-access-framework/)

## CA210 — Internals Identity Protection — Block High-Risk Sign-in

CA210 bloque les connexions évaluées comme présentant un risque élevé au moment de l’authentification.

Contrairement à CA201, qui se concentre sur l’identité, cette règle agit sur le signal transactionnel. Elle complète le dispositif de protection contre les attaques opportunistes et ciblées.

![CA000](/assets/img/posts/conditional-access-framework/)

## Ce que le bloc Internals ne fait volontairement pas

Les politiques CA200–CA210 ne cherchent pas à traiter les usages administratifs, ni à imposer des contraintes équivalentes à celles des comptes à privilèges.

Elles ne garantissent pas non plus la sécurité intrinsèque des devices ou des applications. Elles fournissent des signaux et des garde-fous, pas des certitudes.

## Conclusion

Le bloc CA200–CA210 constitue le cœur vivant du Conditional Access Framework v4. Il traduit les intentions du framework en contrôles réellement appliqués au quotidien.

Sa valeur réside dans son équilibre : suffisamment strict pour réduire les risques concrets, suffisamment pragmatique pour rester exploitable. C’est sur ce bloc que repose, en pratique, l’efficacité globale du framework.
