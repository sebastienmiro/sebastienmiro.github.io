---
title: "Identités applicatives et non humaines : le piège du privilège permanent (Episode 6)"
date: 2026-01-13 08:00:00 +01:00
layout: post
tags: [series:un-risque-une-mesure, entra-id, workload-identity, app-registrations, conditional-access, governance]
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

> 💡 **Contexte**  
> Dans Microsoft Entra ID, une part croissante des accès n’est plus réalisée par des utilisateurs humains, mais par des identités techniques : applications, automatisations, scripts, services. Ces identités — App Registrations, Service Principals, Managed Identities — ne quittent jamais l’entreprise, ne changent pas de poste et ne prennent pas de congés. Elles s’accumulent.

![Entra ID - App management overview](/assets/img/posts/series/un-risque-une-mesure/2026-01-13-app-management-overview.png)

Dans la plupart des tenants, ces identités sont créées pour répondre à un besoin ponctuel : synchroniser des données, automatiser un traitement, interfacer un outil tiers. L’authentification repose sur des mécanismes techniques — secrets ou certificats — dont la durée de vie est, par construction, limitée.

En revanche, les **permissions applicatives** accordées à ces identités suivent une logique très différente. Elles ne sont ni temporaires, ni réévaluées automatiquement, ni liées à une échéance métier. Une fois accordées, elles restent valides jusqu’à ce qu’un humain décide explicitement de les retirer.

Cette dissociation entre la durée de vie du moyen d’authentification et celle du privilège constitue un risque structurel, souvent sous-estimé, et profondément différent de celui des identités humaines.

## Le risque : des permissions sans horizon temporel

Une identité applicative ne s’authentifie pas de manière interactive.  
Elle ne reçoit pas de notification MFA, ne subit pas de fatigue utilisateur et n’est pas sensible aux contrôles de localisation ou d’anomalies comportementales classiques.

Le piège réside dans une confusion fréquente entre deux notions distinctes :

- l’**authentification**, qui est souvent bien maîtrisée (rotation des secrets, certificats à durée limitée) ;
- l’**autorisation**, qui repose sur des permissions applicatives parfois extrêmement larges (`User.ReadWrite.All`, `Files.Read.All`, `Directory.ReadWrite.All`) et rarement remises en question.

Dans de nombreux environnements, ces permissions sont attribuées lors de la création de l’application, puis simplement oubliées. Le privilège devient durable par défaut, sans lien avec un besoin opérationnel courant. Si l’identité est compromise plusieurs mois ou années plus tard, l’attaquant hérite immédiatement de l’ensemble des capacités accumulées au fil du temps.

### Une détection structurellement plus difficile

À cela s’ajoute une difficulté opérationnelle bien connue des équipes sécurité : les accès applicatifs légitimes ressemblent souvent, dans les journaux, à des accès malveillants. Volumes importants, exécution continue, plages horaires étendues… Les signaux faibles sont rares, et les faux positifs nombreux.

L’absence d’interaction humaine réduit mécaniquement l’efficacité des mécanismes de détection basés sur le comportement utilisateur. Le problème n’est pas l’absence de logs, mais leur interprétation.

## L’illusion de sécurité : rotation et identités managées

Face à ce constat, beaucoup d’équipes se tournent vers les **Managed Identities**, à juste titre. Elles permettent d’éliminer toute gestion manuelle de secrets, de réduire drastiquement les risques de fuite dans le code et de déléguer la rotation à la plateforme.

Sur le plan de l’authentification, le gain est réel.

Mais ce mécanisme ne traite pas le cœur du problème.  
Les permissions applicatives accordées à une identité managée restent, elles aussi, permanentes tant qu’elles ne sont pas explicitement révoquées. Une identité managée trop permissive reste une identité dangereuse, même si son secret est parfaitement protégé.

Réduire le risque d’authentification ne suffit pas lorsque le privilège, lui, reste sans limite temporelle.

## La mesure : gouverner le cycle de vie des identités applicatives

La réponse n’est pas uniquement technique. Elle est organisationnelle et procédurale.  
Il s’agit d’introduire une **gouvernance explicite du privilège applicatif**, alignée sur le cycle de vie réel des usages.

### Niveau 1 : rétablir la responsabilité

Aucune gouvernance n’est possible sans responsable identifié.  
Dans beaucoup de tenants, on trouve des applications sans propriétaire clair, héritées de projets terminés ou créées par des collaborateurs partis depuis longtemps.

La première étape consiste à imposer une règle simple : **toute application doit avoir des propriétaires actifs**. À défaut, elle devient candidate à la désactivation. Cette mesure, basique en apparence, permet déjà de réduire significativement l’angle mort.

### Niveau 2 : recertifier les privilèges dans le temps

Microsoft Entra ID propose, via **Identity Governance**, un mécanisme adapté à ce problème : les **Access Reviews** appliquées aux Service Principals (licences spécifiques requises).

Plutôt que de reposer sur des audits ponctuels, ce mécanisme permet d’instaurer une revue périodique des permissions applicatives. Les propriétaires de l’application doivent confirmer que les accès sont toujours nécessaires. En l’absence de réponse, ou en cas de refus, les permissions sont retirées.

Ce changement est fondamental : la légitimité d’un privilège n’est plus implicite, elle doit être régulièrement réaffirmée.

### Niveau 3 : réduire la portée des permissions

Lorsque le contexte le permet, la réduction de la surface d’exposition passe aussi par le **partitionnement** des accès.  
Des mécanismes comme le *Resource Specific Consent* ou l’usage ciblé des *Administrative Units* permettent de limiter l’impact potentiel d’une compromission, en restreignant le périmètre d’action de l’identité applicative.

Ce n’est pas toujours possible, mais lorsque ça l’est, le gain est considérable.

## Complément défensif : accès conditionnel pour identités de charge de travail

En complément de la gouvernance, Microsoft permet désormais d’appliquer des politiques d’accès conditionnel aux **Workload Identities**. Cela ne réduit pas les permissions accordées, mais limite les contextes dans lesquels elles peuvent être exploitées.

Restreindre l’usage d’un Service Principal à des plages IP connues ou à des environnements maîtrisés permet de contenir l’impact d’un token volé et d’ajouter une barrière supplémentaire à l’exploitation.

## Mise en œuvre pratique : par où commencer ?

La difficulté avec les identités applicatives n’est pas tant le manque d’outils que le manque de priorisation. Vouloir tout traiter d’un coup conduit souvent à l’inaction. À l’inverse, quelques actions ciblées permettent rapidement de reprendre le contrôle.

La première étape consiste à **objectiver le périmètre**. Microsoft recommande explicitement de commencer par identifier les applications utilisant des *Application Permissions*, en particulier sur Microsoft Graph, car ce sont elles qui disposent d’un accès autonome et potentiellement global au tenant.  
🔗 [Documentation Microsoft – Permissions et consentement](https://learn.microsoft.com/en-us/entra/identity-platform/permissions-consent-overview)

Une fois cet inventaire établi, l’attention doit se porter sur les permissions les plus larges, notamment celles se terminant par `*.All`. Microsoft souligne que ces permissions doivent être considérées comme équivalentes à des privilèges élevés, et justifiées uniquement lorsqu’aucune alternative plus restrictive n’est possible.  
🔗 [Microsoft Graph – Application permissions reference](https://learn.microsoft.com/en-us/graph/permissions-reference)

Dans un second temps, un **nettoyage basique mais efficace** s’impose : suppression des secrets expirés depuis longtemps, désactivation des Service Principals inactifs, et identification des applications sans propriétaire actif. Microsoft insiste sur ce point : une application sans owner clairement identifié est, par définition, une dette de sécurité.  
🔗 [Documentation Microsoft – App ownership and lifecycle](https://learn.microsoft.com/en-us/entra/identity-platform/app-objects-and-service-principals)

Une fois ce socle assaini, la mise en place de **revues d’accès** permet d’introduire une gouvernance dans la durée. Les Access Reviews appliquées aux Service Principals déplacent la responsabilité vers les équipes métiers ou techniques réellement consommatrices de l’application, conformément aux recommandations Microsoft en matière d’Identity Governance.  
🔗 [Documentation Microsoft – Access reviews for applications](https://learn.microsoft.com/en-us/entra/id-governance/access-reviews-application-access)

Enfin, lorsque le contexte le permet, Microsoft encourage à réduire la portée des accès via des mécanismes comme le *Resource Specific Consent*, afin d’éviter les permissions globales lorsque le besoin est localisé.  
🔗 [Documentation Microsoft – Resource-specific consent](https://learn.microsoft.com/en-us/microsoftteams/platform/graph-api/rsc/resource-specific-consent)

## Lecture croisée : recommandations Microsoft et usages réels

La documentation Microsoft sur les identités applicatives est globalement claire sur un point :  
les permissions applicatives doivent être limitées, justifiées et régulièrement revues.

Sur le papier, le modèle est sain. Dans la réalité, l’écart se creuse vite.

Côté Microsoft, les recommandations reposent sur quelques principes structurants :
- chaque application doit avoir un **propriétaire identifié** ;
- les permissions doivent suivre le **principe du moindre privilège** ;
- les accès applicatifs doivent être **revus périodiquement**, via Identity Governance ;
- les secrets et certificats doivent être **rotés automatiquement** ou gérés par la plateforme.

Ces principes sont documentés, cohérents, et techniquement atteignables dans Entra ID.

Dans les environnements que l’on observe au quotidien, la situation est souvent différente.  
Non par négligence volontaire, mais par accumulation progressive de décisions pragmatiques.

Les applications sont créées pour répondre à un besoin ponctuel — intégration métier, automatisation, script d’administration — puis laissées en place.  
Les permissions accordées “pour que ça marche” ne sont jamais réévaluées.  
Les propriétaires initiaux changent de rôle ou quittent l’entreprise.  
Et l’identité applicative continue d’exister, silencieusement, avec exactement les mêmes droits.

Le point de friction n’est donc pas la technologie, mais le **cycle de vie**.  
Microsoft fournit les mécanismes de gouvernance, mais ceux-ci ne sont jamais activés par défaut.  
Sans processus explicite, la sécurité des identités non humaines repose entièrement sur la mémoire collective — ce qui, en pratique, ne tient pas dans le temps.

C’est précisément là que se situe l’enjeu réel :  
non pas “sécuriser une application”, mais accepter que **toute permission applicative est un privilège durable tant qu’elle n’est pas explicitement remise en question**.

## Conclusion

Les identités applicatives sont devenues indispensables au fonctionnement des environnements Microsoft 365. Le risque principal qu’elles introduisent ne réside pas dans la gestion des secrets, mais dans la **persistance silencieuse des permissions**.

Tant que ces privilèges ne sont pas considérés comme des capacités à gouverner dans le temps — avec une justification, une portée et une remise en question régulière — ils constituent un point de fragilité durable, souvent invisible, mais parfaitement exploitable.
