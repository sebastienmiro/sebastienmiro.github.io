---
title: "Conditional Access Framework v4 — CA000 à CA006 : le socle global"
date: 2026-02-27 09:00:00 +01:00
layout: post
tags: [series:conditional-access-framework, deploiement, baseline]
categories: [identite, entra-id]
readtime: true
comments: true
cover-img: "assets/img/banners/banner-conditional-access.png"
thumbnail-img: "assets/img/posts/series/conditional-access-framework/100/100-thumb.png"
series: CA
series_order: 100
sidebar: true
level: technique
scope:
  - Entra ID
  - Politiques globales
  - Déploiement
platform: Microsoft Entra
---

## Conditional Access Framework v4 — CA000 à CA006 : le socle global

Les politiques CA000 à CA006 constituent le socle global du Conditional Access Framework v4. Elles ne sont ni les plus visibles ni les plus spectaculaires, mais elles conditionnent tout le reste. Sans ce socle, les blocs plus spécialisés reposent sur des hypothèses fragiles et des comportements implicites.

Leur rôle n’est pas de tout sécuriser, mais d’établir un niveau de protection de base cohérent, explicite et maîtrisé. Elles remplissent en pratique le rôle autrefois assuré par Security Defaults, avec une granularité et une lisibilité nettement supérieures.

## Rôle du socle global dans le framework

Le socle global remplit trois fonctions distinctes.

Il fournit d’abord une protection minimale homogène sur l’ensemble du tenant. Il élimine les faiblesses évidentes et garantit que certains invariants de sécurité sont respectés dès l’entrée.

Il agit ensuite comme un filet de sécurité. Tant qu’aucune politique plus spécialisée ne s’applique à une identité ou à un contexte donné, ce sont les règles CA000–CA006 qui prennent la décision.

Enfin, et c’est un point fondamental du framework v4, ce socle est conçu pour s’effacer volontairement dès qu’une politique plus ciblée existe. Cette mise en retrait n’est pas implicite : elle est organisée explicitement par des exclusions.

Le socle global n’est donc pas un ensemble de règles omniprésentes. C’est un point d’entrée, pas un point d’arrivée.

## Logique d’inclusion et d’exclusion

Les politiques CA000–CA006 ciblent un périmètre large, mais jamais indistinct.

L’inclusion repose sur des groupes génériques représentant les utilisateurs standards, comme APP_Microsoft365_E5 ou leurs équivalents de test. Ces groupes définissent un périmètre d’usage attendu, pas un niveau de privilège ni une garantie de sécurité.

Les exclusions jouent un rôle central dans le fonctionnement du socle. Elles ne sont ni des exceptions ponctuelles ni des contournements, mais des mécanismes de routage entre politiques.

On retrouve systématiquement dans les exclusions :

- les comptes de secours (break-glass), afin de garantir une capacité de récupération indépendante de l’accès conditionnel ;
- les comptes de service et identités non interactives, qui ne suivent pas les flux utilisateurs classiques ;
- les périmètres couverts par des blocs spécialisés (Admins, Internals, Guests), dès lors qu’une politique dédiée existe.

Cette approche garantit qu’une identité est évaluée par la politique la plus pertinente, et évite les superpositions involontaires entre règles globales et règles spécialisées.

## CA000 — Global Identity Protection — MFA

CA000 impose une exigence MFA de base sur les accès relevant du périmètre global.

Son objectif n’est pas d’imposer la MFA la plus forte possible, mais d’éviter qu’un accès interactif significatif repose uniquement sur un facteur faible. Elle agit comme un garde-fou tant qu’aucune politique plus ciblée ne s’applique.

Elle exclut explicitement les périmètres couverts par les blocs Admins, Internals, Guests et Service Accounts. Cette exclusion n’est pas une faiblesse : elle garantit que ces identités seront évaluées par des règles plus adaptées à leur niveau de risque.

![CA000-Global-IdentityProtection-AnyApp-AnyPlatform-MFA](/assets/img/posts/conditional-access-framework/CA000-Global-IdentityProtection-AnyApp-AnyPlatform-MFA.png)

## CA001 — Global Attack Surface Reduction — Country Whitelist

CA001 vise à réduire la surface d’attaque en limitant les accès à des zones géographiques connues.

Ce type de règle repose sur des hypothèses opérationnelles fortes et ne peut jamais être universel. Positionnée dans le socle global, elle agit comme un filtre large, sans prétendre couvrir tous les cas.

Les exclusions permettent de préserver les flux qui ne peuvent pas être contraints géographiquement, notamment certains comptes techniques ou usages spécifiques.

![CA001-Global-AttackSurfaceReduction-AnyApp-AnyPlatform-BLOCK-CountryWhitelist](/assets/img/posts/conditional-access-framework/CA001-Global-AttackSurfaceReduction-AnyApp-AnyPlatform-BLOCK-CountryWhitelist.png)

## CA002 — Global Identity Protection — Block Legacy Authentication

CA002 bloque l’authentification legacy.

Cette règle élimine une classe entière d’attaques et constitue un prérequis technique au bon fonctionnement du reste du framework. Sans elle, certaines politiques avancées deviennent inopérantes ou incohérentes.

Son intégration dans le socle garantit que toutes les décisions ultérieures reposent sur des flux modernes.

![CA002-Global-IdentityProtection-AnyApp-AnyPlatform-Block-LegacyAuthentication](/assets/img/posts/conditional-access-framework/CA002-Global-IdentityProtection-AnyApp-AnyPlatform-Block-LegacyAuthentication.png)

## CA003 — Global Base Protection — Register or Join

CA003 protège les opérations d’enregistrement ou de jonction des appareils.

Ces flux sont souvent sous-estimés alors qu’ils constituent un point d’entrée stratégique. La règle vise à s’assurer que seules des identités correctement authentifiées peuvent enregistrer ou rattacher un device à l’environnement.

Elle pose une barrière de base, qui pourra être renforcée par des politiques plus spécifiques.

![CA003-Global-BaseProtection-RegisterOrJoin-AnyPlatform-MFA](/assets/img/posts/conditional-access-framework/CA003-Global-BaseProtection-RegisterOrJoin-AnyPlatform-MFA.png)

## CA004 — Global Identity Protection — Authentication Flows

CA004 couvre des flux d’authentification moins visibles mais sensibles.

Elle permet d’éviter que des chemins secondaires deviennent des angles morts du dispositif de sécurité. Son positionnement dans le socle garantit une couverture homogène de ces flux dès le départ.

![CA004-Global-IdentityProtection-AnyApp-AnyPlatform-AuthenticationFlows](/assets/img/posts/conditional-access-framework/CA004-Global-IdentityProtection-AnyApp-AnyPlatform-AuthenticationFlows.png)

## CA005 — Global Data Protection — Office 365 Unmanaged Devices

CA005 introduit une distinction entre devices maîtrisés et non maîtrisés pour Office 365.

Elle ne vise pas à bloquer systématiquement l’accès, mais à en réduire l’impact lorsque l’environnement n’est pas de confiance, en limitant certaines actions sensibles.

C’est une mesure de réduction de risque, pas un mécanisme de confiance.

![CA005-Global-DataProtection-Office365-AnyPlatform-Unmanaged-AppEnforcedRestrictions-BlockDownload](/assets/img/posts/conditional-access-framework/CA005-Global-DataProtection-Office365-AnyPlatform-Unmanaged-AppEnforcedRestrictions-BlockDownload.png)

## CA006 — Global Data Protection — Mobile App Protection

CA006 étend cette logique aux plateformes mobiles en imposant l’utilisation d’applications protégées lorsque le contexte l’exige.

Elle marque une transition importante : l’accès n’est plus évalué uniquement sur l’identité, mais aussi sur les conditions techniques dans lesquelles il est exercé.

![CA006-Global-DataProtection-Office365-iOSenAndroid-RequireAppProtection](/assets/img/posts/conditional-access-framework/CA006-Global-DataProtection-Office365-iOSenAndroid-RequireAppProtection.png)

## Ce que le socle global ne fait volontairement pas

Les politiques CA000–CA006 ne cherchent pas à gérer finement les sessions longues, à protéger les tokens de manière avancée, ni à traiter les spécificités des comptes à privilèges ou des invités.

Ces sujets sont volontairement laissés aux blocs suivants. Le socle prépare le terrain, il ne remplace pas le reste du framework.

## Conclusion

Le socle global du Conditional Access Framework v4 est indispensable mais non autosuffisant. Il établit une base claire et explicite, sur laquelle les politiques spécialisées peuvent ensuite s’appuyer sans collision.

Sa valeur ne réside pas dans la sévérité de ses contrôles, mais dans sa capacité à structurer l’accès conditionnel de manière lisible et durable. Comprendre cette logique est essentiel pour déployer le framework sans le détourner de son intention initiale.
