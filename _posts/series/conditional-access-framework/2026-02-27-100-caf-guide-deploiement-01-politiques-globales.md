---
title: "Conditional Access Framework v2026.2.1 - CA000 à CA006 : le socle global"
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

## Rôle du socle global

Les politiques CA000 à CA006 ne sont pas les plus visibles du framework, mais elles en conditionnent toute la cohérence. Elles remplissent en pratique le rôle autrefois assuré par Security Defaults, avec une granularité et une lisibilité nettement supérieures.

Trois fonctions distinctes :

**Protection minimale homogène.** Elles éliminent les faiblesses évidentes et garantissent que certains invariants de sécurité sont respectés sur l'ensemble du tenant, indépendamment des personas.

**Filet de sécurité.** Tant qu'aucune politique plus spécialisée ne s'applique à une identité ou à un contexte donné, ce sont ces règles qui prennent la décision.

**Mise en retrait volontaire.** C'est un point fondamental du framework : le socle est conçu pour s'effacer dès qu'une politique plus ciblée existe. Cette mise en retrait n'est pas implicite - elle est organisée explicitement par des exclusions.

Le socle global est un point d'entrée, pas un point d'arrivée.

## Logique d'inclusion et d'exclusion

Les politiques CA000-CA006 ciblent un périmètre large, mais jamais indistinct.

L'inclusion repose sur des groupes génériques représentant les utilisateurs standards (APP_Microsoft365_E5 ou équivalents). Ces groupes définissent un périmètre d'usage attendu, pas un niveau de privilège.

Les exclusions jouent un rôle central. Elles ne sont ni des exceptions ponctuelles ni des contournements : ce sont des mécanismes de routage entre politiques. On les retrouve systématiquement sur trois catégories d'identités :

- les comptes de secours (break-glass), pour garantir une capacité de récupération indépendante du framework ;
- les comptes de service et identités non interactives, qui ne suivent pas les flux utilisateurs classiques ;
- les périmètres couverts par des blocs spécialisés (Admins, Internals, Guests), dès lors qu'une politique dédiée existe.

Cette approche garantit qu'une identité est évaluée par la politique la plus pertinente et évite les superpositions involontaires entre règles globales et règles spécialisées.

## CA000 - Global Identity Protection - MFA

CA000 impose une exigence MFA de base sur tous les accès relevant du périmètre global. Son objectif n'est pas d'imposer la méthode la plus forte possible, mais d'éviter qu'un accès interactif significatif repose uniquement sur un facteur faible.

Elle agit comme un garde-fou tant qu'aucune politique plus ciblée ne s'applique. Les blocs Admins (CA100-CA105), Internals (CA200-CA210) et Guests (CA400-CA404) imposent leurs propres exigences MFA, souvent plus strictes. Les identités relevant de ces blocs sont explicitement exclues de CA000 : elles seront évaluées par des règles adaptées à leur niveau de risque.

CA000 couvre donc en pratique les identités qui n'entrent dans aucun autre bloc - un périmètre résiduel, mais pas négligeable.

![CA000-Global-IdentityProtection-AnyApp-AnyPlatform-MFA](/assets/img/posts/conditional-access-framework/CA000-Global-IdentityProtection-AnyApp-AnyPlatform-MFA.png)

## CA001 - Global Attack Surface Reduction - Country Whitelist

CA001 bloque tous les accès en provenance de pays non listés dans la named location `ALLOWED COUNTRIES`. Par défaut dans le framework de référence, seuls la Belgique, le Luxembourg et les Pays-Bas sont autorisés - à adapter impérativement selon le contexte de l'organisation.

Cette règle repose sur des hypothèses opérationnelles fortes. Elle réduit efficacement la surface d'attaque opportuniste - la majorité des tentatives de credential stuffing et de password spray proviennent de plages IP hors zone de confiance - mais elle ne constitue pas une protection absolue. Des VPN, des proxys ou des infrastructures cloud peuvent contourner ce filtre géographique.

Les exclusions permettent de préserver les flux qui ne peuvent pas être contraints géographiquement : certains comptes techniques, flux d'automatisation ou usages spécifiques à des entités internationales.

![CA001-Global-AttackSurfaceReduction-AnyApp-AnyPlatform-BLOCK-CountryWhitelist](/assets/img/posts/conditional-access-framework/CA001-Global-AttackSurfaceReduction-AnyApp-AnyPlatform-BLOCK-CountryWhitelist.png)

## CA002 - Global Identity Protection - Block Legacy Authentication

CA002 bloque l'ensemble des protocoles d'authentification dits "legacy", c'est-à-dire ceux qui ne supportent pas l'authentification moderne (Modern Authentication / ADAL/MSAL) et sont donc incapables de satisfaire une exigence MFA.

Les protocoles ciblés incluent notamment :

- **SMTP basique** - utilisé par des clients mail ou des applications pour envoyer des messages sans OAuth ;
- **POP3 et IMAP** - protocoles de récupération de mail sans support MFA natif ;
- **Exchange ActiveSync (EAS)** sur des clients non modernes ;
- **Exchange Web Services (EWS)** dans certaines configurations legacy ;
- **Autodiscover** et **MAPI over HTTP** dans leurs variantes non modernes ;
- les authentifications basiques via **Office 2013** et versions antérieures sans configuration Modern Auth.

L'absence de support MFA sur ces protocoles les rend structurellement vulnérables : une fois des credentials compromis (phishing, fuite de base), un attaquant peut s'authentifier directement sans jamais déclencher de prompt MFA. CA002 élimine cette classe d'attaques entière.

C'est un prérequis technique au bon fonctionnement du reste du framework. Sans CA002, les politiques MFA des autres blocs peuvent être contournées via ces protocoles. Son intégration dans le socle global garantit une couverture universelle, indépendante des personas.

> **Prérequis opérationnel** : avant d'activer CA002, vérifier dans les journaux de connexion Entra ID que des flux legacy sont encore actifs dans l'environnement. Le mode Report-only permet d'identifier les applications ou utilisateurs concernés avant tout blocage.

![CA002-Global-IdentityProtection-AnyApp-AnyPlatform-Block-LegacyAuthentication](/assets/img/posts/conditional-access-framework/CA002-Global-IdentityProtection-AnyApp-AnyPlatform-Block-LegacyAuthentication.png)

## CA003 - Global Base Protection - Register or Join

CA003 protège les opérations d'enregistrement et de jonction d'appareils au tenant Entra ID. Ces flux sont souvent sous-estimés : ils constituent pourtant un point d'entrée stratégique. Un device enregistré dans le tenant peut potentiellement être utilisé pour satisfaire des contrôles de conformité ou de jonction, et influer sur les décisions d'accès conditionnel.

CA003 impose la MFA sur ces opérations pour toutes les identités du périmètre global. Elle agit comme une barrière de base, qui peut être renforcée par des politiques plus spécifiques selon le contexte (Autopilot, BYOD, etc.).

> **Point de configuration à vérifier** : le paramètre natif *Require Multifactor Authentication to register or join devices with Microsoft Entra* (disponible dans `Entra ID > Devices > Device settings`) doit être désactivé avant d'activer CA003. Sans cette désactivation, les deux mécanismes coexistent et peuvent créer des comportements inattendus.

![CA003-Global-BaseProtection-RegisterOrJoin-AnyPlatform-MFA](/assets/img/posts/conditional-access-framework/CA003-Global-BaseProtection-RegisterOrJoin-AnyPlatform-MFA.png)

## CA004 - Global Identity Protection - Authentication Flows

CA004 cible des flux d'authentification secondaires que les autres politiques ne couvrent pas nativement. Elle est actuellement en preview dans Entra ID.

Le principal flux concerné est le **device code flow** (également appelé authentication transfer). Ce mécanisme permet à un utilisateur de s'authentifier sur un appareil en saisissant un code affiché sur un autre appareil - typiquement utilisé pour des téléviseurs connectés, des consoles, ou des appareils sans interface de saisie standard.

Le problème de sécurité est structurel : ce flux peut être détourné via une attaque de type **device code phishing**. Le scénario classique consiste à envoyer à une victime un code d'authentification légitime généré par l'attaquant, qui récupère ensuite le token d'accès une fois le code validé par la victime. L'authentification réussit du point de vue d'Entra ID - c'est une authentification interactive valide - mais le token est immédiatement sous le contrôle de l'attaquant.

CA004 permet de bloquer ou de restreindre ce flux au niveau du tenant, indépendamment de l'application ciblée. Son positionnement dans le socle global garantit une couverture universelle.

> **Statut preview** : cette fonctionnalité est en preview au moment de la rédaction. Vérifier sa disponibilité et son comportement dans votre tenant avant activation. Les fonctionnalités en preview peuvent évoluer sans préavis.

![CA004-Global-IdentityProtection-AnyApp-AnyPlatform-AuthenticationFlows](/assets/img/posts/conditional-access-framework/CA004-Global-IdentityProtection-AnyApp-AnyPlatform-AuthenticationFlows.png)

## CA005 - Global Data Protection - Office 365 Unmanaged Devices

CA005 conditionne l'accès aux données Office 365 selon que l'appareil est géré ou non par l'organisation.

**Mise à jour v2026.2.1 - migration obligatoire.** Le contrôle *Require approved client app* utilisé dans les versions précédentes du framework est déprécié par Microsoft depuis mars 2026. CA005 utilise désormais le contrôle *RequireAppProtection*, qui s'appuie sur les App Protection Policies (APP) définies dans Intune MAM. Si des politiques héritées s'appuient encore sur l'ancien contrôle, elles doivent être migrées : le contrôle déprécié ne sera plus appliqué après la date de retrait.

Le nom officiel de la politique dans le framework est désormais `Global-DataProtection-Office365-AnyPlatform-Unmanaged-RequireAppProtection`.

Sur le fond, CA005 ne bloque pas l'accès depuis les appareils non gérés. Elle impose que cet accès passe par des applications protégées par une App Protection Policy Intune, ce qui permet de contrôler les actions sensibles (copier-coller, téléchargement, transfert vers des applications non gérées) même sur des appareils hors MDM.

C'est une mesure de réduction de risque, pas un mécanisme de confiance totale. Un appareil non géré reste un appareil non géré : CA005 limite l'impact d'un accès depuis un tel appareil, elle ne le sécurise pas.

> **Prérequis** : des App Protection Policies doivent être configurées et déployées dans Intune avant l'activation de CA005. Sans elles, la politique bloquera les accès depuis les appareils non gérés faute d'application conforme disponible.

![CA005-Global-DataProtection-Office365-AnyPlatform-Unmanaged-RequireAppProtection](/assets/img/posts/conditional-access-framework/CA005-Global-DataProtection-Office365-AnyPlatform-Unmanaged-RequireAppProtection.png)

## CA006 - Global Data Protection - Mobile App Protection

CA006 étend la logique de CA005 aux plateformes iOS et Android en imposant des App Protection Policies pour l'accès à Office 365 depuis ces plateformes.

Elle marque une transition importante dans le framework : l'accès n'est plus évalué uniquement sur l'identité, mais aussi sur les conditions techniques dans lesquelles il est exercé. L'application mobile utilisée devient un signal de confiance à part entière.

Les rôles admin sont exclus de CA006 par conception - à condition que le principe d'administration avec des comptes dédiés soit respecté. Si des rôles admin sont attribués à des comptes utilisateurs non dédiés, cette exclusion crée une surface non protégée à corriger en priorité.

> **Note d'évolution.** Selon le GitHub de référence de Joey Verlinden, CA006 sera prochainement modifiée ou supprimée en raison d'un chevauchement fonctionnel croissant avec CA005. Avec RequireAppProtection désormais en place sur CA005, les deux politiques couvrent des scénarios partiellement redondants sur iOS et Android. À surveiller lors des prochaines versions du framework.

![CA006-Global-DataProtection-Office365-iOSenAndroid-RequireAppProtection](/assets/img/posts/conditional-access-framework/CA006-Global-DataProtection-Office365-iOSenAndroid-RequireAppProtection.png)

## Ce que le socle global ne fait pas

CA000-CA006 ne gèrent pas les sessions longues ni les tokens de manière avancée. Elles ne traitent pas les spécificités des comptes à privilèges, des invités, des agents ou des identités non humaines. Elles n'imposent pas de conformité device au-delà des App Protection Policies.

Ces sujets sont volontairement laissés aux blocs spécialisés. Le socle prépare le terrain - il ne remplace pas le reste du framework.

## Conclusion

Le socle global est indispensable mais non autosuffisant. Sa valeur ne réside pas dans la sévérité de ses contrôles, mais dans sa capacité à structurer l'accès conditionnel de manière lisible, explicite et durable.

Conformément à la logique de déploiement progressif du framework, ces politiques s'activent en dernier - après que toutes les personas spécialisées sont en place et correctement exclues. C'est à ce moment seulement que le socle peut jouer son rôle de filet de sécurité sans risque de collision avec les blocs plus ciblés.