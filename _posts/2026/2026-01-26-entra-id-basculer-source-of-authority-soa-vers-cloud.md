---
title: "Microsoft Entra ID : basculer le Source of Authority d’un utilisateur vers le cloud"
date: 2026-01-26 07:30:00 +01:00
layout: post
categories: [identite, entra-id]
tags:
  - entra-id
  - source-of-authority
  - hybrid-identity
  - cloud-sync
  - entra-connect
  - identity-lifecycle
  - gouvernance-identite
readtime: true
comments: true
sidebar: true
level: Analyse
platform: Microsoft Entra ID
scope:
  - Microsoft Entra ID
  - Hybrid Identity
  - User Lifecycle
cover-img: "assets/img/posts/2026/01/entra-soa-cloud-cover.png"
thumbnail-img: "assets/img/posts/2026/01/entra-soa-cloud-thumb.png"
---

> Dans un environnement hybride, l’identité utilisateur reste souvent ancrée dans Active Directory.  
> Même lorsque les usages basculent majoritairement vers Microsoft 365, l’AD demeure la **source d’autorité** pour les comptes synchronisés. Cela implique que certaines propriétés, certains cycles de vie et certaines décisions de gouvernance continuent de dépendre d’un annuaire on-prem, parfois sans lien direct avec les usages actuels.

Jusqu’à présent, ce modèle imposait une contrainte structurelle :  
un utilisateur synchronisé depuis Active Directory restait lié à cet annuaire. Faire évoluer cette dépendance nécessitait des opérations lourdes, souvent globales, avec des impacts potentiels sur les accès, les licences et les services associés.

Dans la pratique, l’hybride n’était donc pas toujours une étape transitoire.  
Il devenait fréquemment un état durable, maintenu par contrainte plus que par choix, faute de mécanisme simple et maîtrisé pour faire évoluer la gouvernance de l’identité.

La mise à disposition du basculement du **Source of Authority au niveau de l’objet utilisateur** s’inscrit dans ce contexte. Elle ne concerne pas la synchronisation en elle-même, mais la capacité à redéfinir, de manière ciblée, **où l’identité est effectivement pilotée**.

Ce changement ouvre la voie à une gestion plus progressive de l’hybride, traitée comme un état évolutif plutôt que comme une dépendance figée.

## Le Source of Authority dans Entra ID

Dans Microsoft Entra ID, le *Source of Authority* désigne l’emplacement où une identité est effectivement maîtrisée.  
Ce n’est pas un indicateur secondaire. Il détermine où les attributs peuvent être modifiés, quel système fait référence et dans quelle mesure Entra ID peut agir de manière autonome sur un compte utilisateur.

Deux situations coexistent.

Pour un **utilisateur cloud-only**, Entra ID est la source d’autorité.  
Les attributs sont gérés directement dans le cloud, le cycle de vie est piloté par les mécanismes propres à Entra ID, et les règles de gouvernance s’appliquent sans dépendance externe.

Pour un **utilisateur synchronisé depuis Active Directory**, la logique est différente.  
Même si l’utilisateur consomme exclusivement des services cloud, l’Active Directory on-prem reste la référence. Les attributs structurants sont verrouillés côté Entra ID, et toute modification doit être effectuée dans l’annuaire local avant d’être répercutée par la synchronisation.

Cette distinction a des effets concrets :
- certains champs restent en lecture seule dans Entra ID,
- des erreurs apparaissent lors de tentatives de modification directe,
- le cycle de vie utilisateur dépend toujours des processus AD, même lorsque l’AD n’est plus utilisé pour les usages quotidiens.

Le Source of Authority conditionne donc la capacité d’Entra ID à jouer pleinement son rôle de référentiel d’identité et de point de gouvernance des accès.

L’évolution annoncée par Microsoft agit sur ce point précis, en permettant de redéfinir la source d’autorité au niveau de l’objet utilisateur, sans transformation globale de l’environnement.

## Pourquoi le changement du SOA était jusqu’ici complexe

Jusqu’à récemment, le Source of Authority d’un utilisateur synchronisé était difficile à faire évoluer.  
Dans les faits, un compte restait lié à Active Directory tant qu’il existait une synchronisation, même si l’AD n’était plus utilisé comme annuaire opérationnel.

Les options disponibles étaient limitées et rarement satisfaisantes.  
La plus courante consistait à supprimer l’objet synchronisé, puis à le recréer côté cloud. Cette approche impliquait des coupures de service, des risques de désalignement sur les licences, et des effets de bord sur les applications dépendantes de l’identité.

D’autres scénarios reposaient sur des manipulations plus fines, mais restaient lourds à maintenir :
- bascules globales plutôt qu’individuelles,
- dépendances fortes aux outils de synchronisation,
- absence de contrôle granulaire au niveau utilisateur.

Dans la pratique, ces contraintes freinaient les trajectoires de sortie progressive d’Active Directory.  
L’hybride devenait un état durable, non par choix, mais parce que le coût et le risque associés à une modification du SOA étaient jugés trop élevés.

Ce contexte explique pourquoi la possibilité de modifier le Source of Authority au niveau de l’objet utilisateur constitue une évolution notable. Elle répond à une difficulté ancienne, liée moins à la synchronisation elle-même qu’à l’absence de mécanisme maîtrisé pour faire évoluer la gouvernance de l’identité dans le temps.

## Ce que Microsoft annonce concrètement

En janvier 2026, Microsoft a annoncé la disponibilité générale de la possibilité de **modifier le Source of Authority d’un utilisateur au niveau objet** dans Microsoft Entra ID.

Concrètement, cette évolution permet de prendre un utilisateur synchronisé depuis Active Directory et de le basculer vers un mode **cloud-managed**, sans suppression ni recréation du compte. L’utilisateur cesse alors d’être piloté par l’annuaire on-prem et se comporte, du point de vue d’Entra ID, comme un compte natif cloud.

Cette capacité est prise en charge par :
- **Microsoft Entra Connect Sync**,
- **Microsoft Entra Cloud Sync**.

Le basculement s’effectue **utilisateur par utilisateur**, sans impact automatique sur les autres comptes synchronisés. Il devient ainsi possible d’opérer une transition progressive, ciblée, et réversible à l’échelle du tenant.

Après conversion :
- l’utilisateur n’est plus dépendant de la synchronisation AD pour ses attributs,
- les modifications s’effectuent directement dans Entra ID,
- le comportement du compte s’aligne sur celui d’un utilisateur cloud-only.

Cette évolution ne modifie pas le fonctionnement global de la synchronisation.  
Elle introduit un mécanisme supplémentaire, permettant de dissocier certains objets utilisateurs de leur origine on-prem, sans remettre en cause l’architecture hybride existante.

Microsoft positionne cette fonctionnalité comme un levier pour réduire progressivement la dépendance à Active Directory, tout en limitant les ruptures fonctionnelles et les impacts sur les usages quotidiens.

## Ce que change la conversion du SOA côté Entra ID

Une fois le Source of Authority d’un utilisateur basculé vers le cloud, le comportement du compte évolue de manière visible dans Entra ID.  
Le changement ne concerne pas uniquement l’origine de la synchronisation, mais la manière dont l’identité peut être administrée et gouvernée.

Les attributs auparavant verrouillés deviennent modifiables directement dans Entra ID.  
Les mises à jour ne dépendent plus d’un retour vers Active Directory, ni d’un cycle de synchronisation. Cela simplifie les opérations courantes liées au cycle de vie de l’identité, comme les changements de propriétés, les corrections ou les ajustements de gouvernance.

Du point de vue fonctionnel, l’utilisateur se comporte comme un compte cloud-only :
- les règles d’accès conditionnel s’appliquent sans distinction,
- la gestion des méthodes d’authentification est entièrement pilotée côté Entra,
- les mécanismes de gouvernance et d’audit s’appuient sur une source unique.

Ce basculement ne supprime toutefois pas l’objet correspondant dans Active Directory.  
L’utilisateur peut toujours exister côté on-prem, mais il n’est plus considéré comme la référence pour Entra ID. Cette dissociation permet de conserver certains usages hérités tout en transférant la gouvernance effective vers le cloud.

Il est important de noter que la conversion du SOA ne traite pas automatiquement les dépendances périphériques :
- groupes gérés on-prem,
- applications s’appuyant directement sur Active Directory,
- processus RH ou IAM encore liés à l’annuaire local.

Le changement porte sur l’autorité de l’identité, pas sur l’ensemble de son écosystème.

## Cas d’usage concrets

La possibilité de basculer le Source of Authority au niveau de l’utilisateur ouvre plusieurs scénarios qui étaient jusque-là difficiles à traiter proprement.

**Premier cas :** les utilisateurs dont les usages sont déjà entièrement cloud.  
Lorsqu’un compte ne dépend plus d’Active Directory pour l’authentification, les applications ou les processus quotidiens, maintenir l’AD comme source d’autorité n’apporte plus de valeur opérationnelle. La conversion du SOA permet alors d’aligner la gouvernance de l’identité sur la réalité des usages.

**Second cas :** les comptes contraints par des attributs hérités d’Active Directory.  
Certaines propriétés verrouillées compliquent la gestion des accès, l’automatisation ou l’application de règles de gouvernance. Le basculement vers un SOA cloud permet de lever ces contraintes sans remettre en cause l’ensemble de la synchronisation.

Ce mécanisme est également pertinent pour des populations spécifiques :
- utilisateurs internes intégrés tardivement dans l’annuaire on-prem,
- comptes issus de regroupements ou de transitions organisationnelles,
- utilisateurs pour lesquels l’AD n’est plus le référentiel pertinent du cycle de vie.

Enfin, la conversion du SOA **peut s’inscrire dans une démarche plus progressive de réduction de la dépendance à Active Directory**. 
Plutôt qu’une bascule globale, il devient possible d’avancer par périmètre, en traitant les identités une à une, selon leur niveau de dépendance réelle à l’annuaire local.

Dans tous les cas, l’intérêt du mécanisme réside dans sa granularité. Il permet d’adapter la trajectoire d’évolution de l’identité sans imposer un changement uniforme à l’ensemble des comptes synchronisés.

## Pré-requis et garde-fous

La conversion du Source of Authority au niveau utilisateur repose sur un environnement préparé.  
Même si l’opération est ciblée et réversible, elle implique un changement réel de gouvernance de l’identité, qui nécessite quelques vérifications en amont.

Du point de vue technique, l’environnement doit répondre aux conditions suivantes :
- utilisation de **Microsoft Entra Connect Sync** ou **Microsoft Entra Cloud Sync**,
- synchronisation fonctionnelle et stable,
- absence d’erreurs bloquantes sur les objets concernés.

Au-delà des prérequis techniques, certains points méritent une attention particulière avant toute conversion.

Les dépendances doivent être identifiées.  
Un utilisateur peut être utilisé indirectement par :
- des groupes gérés côté Active Directory,
- des applications s’appuyant sur des attributs on-prem,
- des processus RH ou IAM qui considèrent encore l’AD comme référence.

La conversion du SOA ne met pas fin à ces dépendances. Elle change la source de vérité pour Entra ID, sans modifier automatiquement les usages ou intégrations existantes.

Il est également recommandé de définir un cadre clair sur les populations éligibles.  
Tous les comptes synchronisés n’ont pas vocation à devenir cloud-managed. La sélection doit se faire en fonction des usages réels, du niveau de dépendance à l’AD et des contraintes de sécurité associées.

Enfin, la traçabilité et le contrôle restent essentiels.  
La conversion du SOA est un acte structurant sur le cycle de vie de l’identité. Elle doit s’inscrire dans un processus documenté, avec des validations explicites et une capacité de retour arrière maîtrisée.

Ces garde-fous permettent d’éviter une lecture trop simpliste de la fonctionnalité, et de l’utiliser comme un levier d’évolution maîtrisé plutôt que comme un raccourci technique.

## Impacts sur la gouvernance de l’identité

La conversion du Source of Authority modifie la manière dont l’identité est gouvernée, bien plus que la manière dont elle est synchronisée.  
En transférant l’autorité vers Entra ID, le point de décision se déplace vers le cloud, là où sont déjà appliquées la majorité des règles d’accès et de sécurité.

Ce changement apporte une cohérence accrue entre :
- la gestion du cycle de vie de l’utilisateur,
- les politiques d’accès conditionnel,
- les méthodes d’authentification,
- et les mécanismes d’audit et de traçabilité.

Lorsque le SOA reste on-prem, certaines décisions sont prises dans Entra ID sans que l’annuaire local n’en ait connaissance, et inversement. La conversion réduit ce décalage en alignant la gouvernance sur le référentiel réellement utilisé pour les accès.

Sur le plan opérationnel, cela simplifie aussi la responsabilité.  
Les équipes qui administrent Entra ID disposent d’une autorité directe sur l’identité, sans dépendre de modifications préalables côté Active Directory. Les ajustements liés aux accès, à l’authentification ou à la conformité peuvent être effectués dans un périmètre unique.

Cette évolution ne supprime pas les besoins de coordination avec les processus existants.  
Elle impose au contraire de clarifier où se situent les responsabilités : ce qui relève encore de l’AD, et ce qui est désormais piloté exclusivement par Entra ID.

Le basculement du SOA agit ainsi comme un marqueur.  
Il matérialise le passage d’une identité héritée, pilotée par contrainte, vers une identité gouvernée là où les contrôles sont effectivement appliqués.

## Limites et points de vigilance

La conversion du Source of Authority n’est pas un mécanisme universel.  
Elle répond à des cas précis et ne supprime pas l’ensemble des contraintes liées à un environnement hybride.

Le premier point de vigilance concerne les dépendances persistantes à Active Directory.  
Même après basculement du SOA, certains usages peuvent rester liés à l’annuaire on-prem :
- groupes de sécurité ou de distribution gérés côté AD,
- applications s’appuyant directement sur LDAP ou Kerberos,
- processus d’habilitation ou de sortie encore construits autour de l’AD.

Dans ces scénarios, le changement de source d’autorité ne suffit pas à lui seul. Il doit être accompagné d’une revue des dépendances applicatives et des processus existants.

Un autre point d’attention porte sur la cohérence des cycles de vie.  
Si une partie des identités est gouvernée côté Entra ID et une autre côté Active Directory, le risque de désalignement augmente. Sans cadre clair, des décisions contradictoires peuvent apparaître entre les deux référentiels.

La conversion du SOA ne constitue pas non plus une solution de sortie complète d’Active Directory.  
Elle permet une évolution progressive, mais ne traite pas les besoins liés à l’authentification on-prem, aux postes joints au domaine ou aux applications héritées.

Enfin, ce mécanisme suppose une maturité minimale en matière de gouvernance de l’identité.  
Basculer la source d’autorité vers le cloud sans règles explicites sur la gestion des comptes, des accès et des exceptions revient à déplacer la complexité, sans la réduire.

Ces limites ne remettent pas en cause l’intérêt de la fonctionnalité, mais rappellent qu’elle s’inscrit dans une trajectoire d’évolution, et non dans une logique de simplification immédiate.

## Lecture globale de la trajectoire Microsoft Entra

La possibilité de basculer le Source of Authority au niveau de l’utilisateur s’inscrit dans une évolution continue de Microsoft Entra ID, orientée vers une gouvernance de l’identité de plus en plus centrée sur le cloud.

Cette annonce ne constitue pas une rupture isolée. Elle s’aligne avec d’autres évolutions récentes :
- la montée en puissance de **Entra Cloud Sync** comme alternative plus souple à Entra Connect Sync,
- le renforcement des capacités de gouvernance et de cycle de vie directement dans Entra ID,
- la centralité accrue de l’identité cloud dans les mécanismes d’accès conditionnel et de sécurité.

Ce que Microsoft met en place n’est pas une sortie brutale de l’hybride, mais un modèle plus modulable.  
L’hybride n’est plus traité comme un état figé, mais comme une configuration ajustable, dans laquelle certaines identités peuvent évoluer plus vite que d’autres.

La conversion du SOA au niveau objet va dans ce sens.  
Elle permet d’avancer par étapes, sans imposer une transformation globale immédiate, tout en donnant davantage de cohérence aux environnements déjà largement orientés vers Microsoft 365.

Cette approche confirme une tendance de fond : Entra ID n’est plus seulement un point de synchronisation ou d’authentification, mais un référentiel d’identité à part entière, destiné à porter la gouvernance principale, même dans des contextes hybrides durables.

## Ressources

- **Vue d’ensemble du Source of Authority dans Microsoft Entra ID**  
  [User source of authority overview](https://learn.microsoft.com/en-us/entra/identity/hybrid/user-source-of-authority-overview)

- **Configurer la conversion du Source of Authority pour un utilisateur**  
  [How to configure user source of authority](https://learn.microsoft.com/en-us/entra/identity/hybrid/how-to-user-source-of-authority-configure)

- **Préparer l’environnement avant la conversion du Source of Authority**  
  [Prepare your environment for user source of authority](https://learn.microsoft.com/en-us/entra/identity/hybrid/prepare-user-source-of-authority-environment)

- **Microsoft Entra – Releases and announcements**  
  [What’s new in Microsoft Entra](https://learn.microsoft.com/en-us/entra/fundamentals/whats-new)
