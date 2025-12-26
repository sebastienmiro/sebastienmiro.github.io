---
title: "Identités applicatives et non humaines : le piège du privilège permanent"
date: 2026-01-13 11:00:00 +01:00
layout: post
tags: [series:un-risque-une-mesure, entra-id, workload-identity, app-registrations, conditional-access]
categories: [identite, entra-id]
readtime: true
comments: true
cover-img: "assets/img/banners/banner4.png"
thumbnail-img: "assets/img/posts/series/un-risque-une-mesure/2026-01-13-entra-id-app-registration-scope-management.png"
series: R1M
series_order: 060
sidebar: true
level: concepts
scope:
  - Entra ID
  - Identités applicatives
  - Accès non humain
  - Sécurité de l’identité
---

> 💡 Dans Microsoft Entra ID, les applications et automatisations accèdent aux ressources à l’aide d’identités non humaines, telles que des app registrations, des comptes de service ou des identités de charge de travail. Ces identités sont utilisées pour permettre l’intégration entre services et l’exécution de traitements automatisés.

![Entra ID - App management overview](/assets/img/posts/series/un-risque-une-mesure/2026-01-13-app-management-overview.png)

L’authentification de ces identités repose sur des moyens techniques — secrets, certificats ou identités managées — dont la durée de validité est nécessairement limitée. En revanche, les **permissions applicatives** accordées à ces identités ne sont, par défaut, ni temporaires ni soumises à un mécanisme systématique de remise en question dans le temps.

Cette dissociation entre la durée de vie du moyen d’authentification et celle du privilège constitue un risque spécifique, distinct de celui des identités humaines.

## Le risque : des permissions applicatives sans temporalité fonctionnelle

Une identité applicative ne s’authentifie pas de manière interactive et n’est pas soumise aux contrôles associés aux utilisateurs humains, tels que l’authentification multifacteur ou les signaux liés au poste ou à la localisation.

Les secrets et certificats utilisés pour l’authentification disposent d’une date d’expiration et peuvent être renouvelés ou révoqués. Toutefois, les permissions applicatives associées à l’identité restent valides tant qu’elles ne sont pas explicitement retirées, indépendamment de la rotation des moyens d’authentification.

Dans de nombreux environnements, ces permissions sont attribuées lors de la création de l’application et conservées sans échéance fonctionnelle explicite, même lorsque l’usage réel de l’application évolue ou disparaît.

Le privilège devient alors durable par conception, sans lien direct avec un besoin opérationnel courant.

## Permissions applicatives et portée excessive

Les permissions de type *Application permissions* permettent à une application d’accéder directement aux ressources, sans contexte utilisateur. Elles sont souvent choisies pour simplifier l’implémentation ou couvrir des cas d’usage larges dès la conception.

Une fois accordées, ces permissions sont rarement réduites. Leur maintien est justifié par le bon fonctionnement de l’application, sans analyse régulière de la portée réellement nécessaire.

Dans ce modèle, la rotation des secrets ou des certificats améliore la sécurité de l’authentification, mais ne réduit pas l’étendue ni la durée du privilège. Une compromission ultérieure permettrait toujours d’exploiter l’ensemble des permissions accordées.

## Détection et contrôles limités sur les accès non humains

L’absence d’interaction humaine limite l’applicabilité de nombreux mécanismes de détection utilisés pour les comptes utilisateurs. Les accès applicatifs légitimes et malveillants peuvent présenter des caractéristiques similaires dans les journaux, rendant l’analyse comportementale plus complexe.

Tant que les permissions applicatives restent valides, une identité compromise peut continuer à accéder aux ressources sans générer de signaux évidents de rupture de comportement, en particulier lorsque l’application est utilisée de manière régulière.

Le risque principal ne réside donc pas dans la durée de validité des secrets, mais dans la persistance du privilège associé à l’identité.

## La mesure : gouverner la durée et la portée des permissions applicatives

La réduction du risque passe par la mise en place d’un **cycle de vie explicite des permissions applicatives**, indépendant de celui des moyens d’authentification.

Cela implique notamment :
- l’attribution de permissions strictement nécessaires à l’usage réel de l’application,
- la justification documentée de chaque permission applicative accordée,
- la revue périodique de ces permissions, indépendamment de la rotation des secrets,
- la suppression des permissions devenues inutiles,
- la suppression des identités applicatives obsolètes.

Ces mesures relèvent principalement de la gouvernance et de l’exploitation, et non d’un mécanisme technique unique.

## Identités managées et réduction du risque d’authentification

Lorsque cela est possible, l’utilisation d’identités managées permet de réduire le risque lié à la gestion des secrets et certificats. La plateforme prend en charge l’émission et la rotation des jetons, limitant ainsi l’exposition liée aux moyens d’authentification.

Toutefois, les identités managées ne résolvent pas le problème de fond. Les permissions applicatives accordées à ces identités restent durables tant qu’elles ne sont pas explicitement révoquées. La réduction du risque d’authentification ne doit pas être confondue avec la gouvernance du privilège.

## Accès conditionnel et identités de charge de travail

Certaines fonctionnalités permettent aujourd’hui d’appliquer des politiques d’accès conditionnel aux identités de charge de travail. Ces mécanismes offrent des possibilités de restriction supplémentaires selon des critères définis.

Ils nécessitent toutefois des licences spécifiques (Microsoft Entra ID P1 ou P2 selon les scénarios) et ne couvrent pas l’ensemble des usages applicatifs existants. Ils doivent être considérés comme des mécanismes complémentaires, et non comme une réponse globale à la question de la temporalité des privilèges applicatifs.

## Observations issues du terrain

Dans de nombreux environnements, les identités applicatives sont nombreuses, parfois anciennes, et insuffisamment documentées. Certaines applications ne sont plus utilisées, tandis que leurs permissions restent actives.

La rotation des secrets est souvent en place, mais la revue des permissions applicatives est inexistante ou informelle. Le risque persiste alors indépendamment des mécanismes d’authentification.

## Conclusion

Les identités applicatives et non humaines sont des composants indispensables des environnements Entra ID. Le risque principal associé à ces identités ne réside pas dans la durée de validité des secrets ou des jetons, mais dans la persistance des permissions applicatives accordées.

Tant que ces permissions ne sont pas traitées comme des capacités à gouverner dans le temps — avec une portée définie, une justification explicite et une revue régulière — elles constituent un point de fragilité durable dans la sécurité de l’identité.