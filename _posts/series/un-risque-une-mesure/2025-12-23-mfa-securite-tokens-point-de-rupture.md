---
title: "MFA ≠ sécurité : comprendre pourquoi les tokens sont devenus le vrai point de rupture"
date: 2025-12-23 11:30:00 +01:00
layout: post
tags: [series:un-risque-une-mesure, entra-id, identité, mfa, tokens, token-protection, sécurité]
categories: [identite, entra-id]
readtime: true
comments: true
cover-img: "assets/img/banners/banner-mfa-token-protection.png"
thumbnail-img: "assets/img/posts/series/un-risque-une-mesure/2025-12-23-mfa-securite-tokens-point-de-rupture.png"
series: R1M
series_order: 030
sidebar: true
level: concepts
scope:
  - Entra ID
  - MFA
  - Conditional Access
  - Token Protection
---

Pendant longtemps, l’authentification multifacteur a été présentée comme une ligne d’arrivée.  
Une fois activée, le sujet semblait clos. Dans de nombreux environnements Microsoft 365, cette logique a conduit à une forme de confort opérationnel : la MFA était en place, donc le risque était supposément maîtrisé.

Sur le terrain, les incidents racontent une autre histoire.  
Les comptes compromis disposaient bien d’une MFA active. Les utilisateurs validaient leurs demandes. Les paramètres semblaient cohérents. Et pourtant, l’attaquant était bien là.

Le problème n’est pas la MFA.  
Le problème est ce qu’on attend d’elle.

## Ce que fait réellement une authentification MFA

Dans Microsoft Entra ID, la MFA intervient à un moment précis et limité : **l’authentification initiale**.  
Elle permet de renforcer la preuve d’identité au moment où Entra ID décide d’émettre des jetons d’accès.

Une fois cette étape passée, le modèle change complètement.  
Les accès ultérieurs aux ressources ne reposent plus sur la MFA, mais sur les **tokens** délivrés lors de cette authentification.

C’est un point fondamental :  
> la MFA protège l’entrée, pas ce qui circule ensuite.

Autrement dit, elle ne protège ni la session, ni la durée d’accès, ni la réutilisation des artefacts d’authentification.

## Pourquoi le mot de passe n’est plus la cible principale

Avec la généralisation de la MFA, le modèle d’attaque a évolué.  
L’objectif n’est plus nécessairement de se connecter « à la place » de l’utilisateur, mais d’obtenir **un élément d’authentification réutilisable**.

Dans la pratique, cela prend plusieurs formes :  
un access token, un refresh token, ou une session persistante dans un navigateur.

Une fois ce token obtenu, la MFA ne sera plus sollicitée tant que le jeton reste valide.  
C’est cette réalité qui explique l’efficacité des attaques modernes malgré la MFA.

## Attaques Adversary-in-the-Middle : quand la MFA fonctionne… et l’attaque aussi

Les attaques de type Adversary-in-the-Middle (AiTM), largement documentées par Microsoft, illustrent parfaitement cette dérive.

Le scénario est désormais bien connu : l’utilisateur est redirigé vers un site de phishing qui joue le rôle de proxy. La page de connexion affichée est légitime. Les identifiants sont saisis, la MFA est validée, et Entra ID émet un token de session parfaitement valide.

![Flux AiTM et interception de tokens](https://www.microsoft.com/en-us/security/blog/wp-content/uploads/2022/07/Figure1-overview-of-aitm-phishing.png)


Du point de vue d’Entra ID, tout s’est déroulé normalement.  
La MFA n’a pas été contournée. Elle a été satisfaite.

Le problème n’est donc pas l’authentification, mais **la capacité du token à être rejoué hors de son contexte d’émission**.

## Sessions, cookies et tokens : le vrai périmètre d’attaque

Le même raisonnement s’applique aux vols de session.  
Une fois la session établie, un malware, une extension de navigateur malveillante ou un accès local à la machine peuvent permettre d’extraire des tokens encore valides.

Ces tokens peuvent ensuite être rejoués depuis un autre environnement, sans déclencher de nouvelle MFA.  
Dans ce modèle, la compromission ne dépend plus de l’utilisateur, mais de la valeur du token lui-même.

C’est précisément ce point qui a conduit Microsoft à revoir la manière dont les sessions sont protégées.

## Token Protection : lier le jeton à son contexte

Token Protection est un **contrôle de session d’accès conditionnel** dont l’objectif est clair : réduire l’impact des attaques par rejeu de token.

Concrètement, Entra ID tente de s’assurer que seuls des **tokens liés cryptographiquement à un appareil** (comme les Primary Refresh Tokens) puissent être utilisés pour accéder aux ressources protégées.

Lorsqu’un appareil Windows 10 ou ultérieur est correctement enregistré dans Entra ID, un PRT est émis et lié à cet appareil.  
Même si un attaquant parvient à intercepter ce token, il ne pourra pas être utilisé depuis un autre contexte.

Ce mécanisme ne cherche pas à empêcher le vol du token, mais à **le rendre inutilisable** hors de son environnement d’origine.

## Où Token Protection s’intègre dans Entra ID

Token Protection ne s’active pas comme une option globale.  
Il s’intègre directement dans le moteur d’accès conditionnel.

![Entra Admin Center – Conditional Access overview](/assets/img/posts/2025/12/23/conditional-access-overview.png)

La logique est cohérente : il s’agit d’un contrôle de session, soumis aux mêmes règles de ciblage, d’exclusion et de test que les autres politiques CA.

## Création d’une politique dédiée

Dans la pratique, Token Protection mérite une politique dédiée.  
Il s’agit d’un contrôle structurant, avec des impacts visibles en cas d’incompatibilité.

![Création d’une politique d’accès conditionnel](/assets/img/posts/2025/12/23/conditional-access-policies-azure-ad-listing.png)

Une convention de nommage explicite permet d’identifier immédiatement le rôle de cette politique lors des analyses d’incident.

## Ciblage : utilisateurs, plateformes et applications

Token Protection n’est pas universelle.  
Microsoft en limite volontairement le périmètre afin de garantir un modèle d’authentification cohérent.

### Appareils supportés

Seuls certains types d’appareils sont compatibles :
- Windows 10 ou ultérieur, Microsoft Entra joined, hybrid joined ou registered
- Windows Server 2019 ou ultérieur, hybrid Entra joined

Les environnements plus atypiques (Azure Virtual Desktop Entra joined, Autopilot self-deploying, bulk enrollment, etc.) ne sont pas supportés.

Lorsque ces appareils sont inclus dans le périmètre, l’accès est bloqué.  
Ce comportement n’est pas un bug : il révèle une incompatibilité structurelle avec le modèle de protection des tokens.

### Applications et ressources

Token Protection s’applique uniquement à des applications compatibles, notamment :
- Exchange Online
- SharePoint Online
- Microsoft Teams
- Azure Virtual Desktop
- Windows 365

Certaines applications ou modules PowerShell restent explicitement non supportés. Leur blocage est un indicateur clair de dépendances legacy encore actives dans l’environnement.

## Activation du contrôle de session

L’activation se fait dans la section **Session** des contrôles d’accès.

![Activation de Token Protection](/assets/img/posts/2025/12/23/complete-policy-components-session.png)

Le message affiché est explicite : seules les combinaisons appareil / application supportées fonctionneront. Les autres seront bloquées.

## Déploiement progressif et mode Report-only

Microsoft recommande explicitement un déploiement progressif.  
Le mode Report-only permet d’identifier les incompatibilités avant toute mise en production.

Cette phase est essentielle pour observer les impacts réels sans perturber les utilisateurs.

## Lecture des journaux : comprendre ce qui est bloqué

Une fois la politique active, les journaux de connexion deviennent la source principale d’analyse.

![Sign-in log – Token Protection Unbound](/assets/img/posts/2025/12/23/sign-in-log-sample-unbound-status-code-1002.png)

Le champ **Token Protection – Sign In Session** indique si la requête était liée (Bound) ou non (Unbound).  
Les codes de statut associés permettent d’identifier précisément la cause du blocage :
- 1002 : absence d’état d’appareil Entra ID
- 1003 : type d’enregistrement non supporté
- 1006 : version d’OS incompatible
- 1008 : client non intégré au broker WAM

Ces informations permettent d’orienter rapidement les actions correctives.

## Ce que voit réellement l’utilisateur

Dans les scénarios compatibles, l’utilisateur ne perçoit aucun changement.  
Dans les autres cas, un message d’erreur apparaît après l’authentification, indiquant que l’accès est bloqué par une exigence de sécurité.

Ce comportement est souvent le premier signal visible d’une dette technique jusque-là ignorée.

## Gouvernance implicite de Token Protection

Token Protection agit comme un révélateur.  
Elle met en évidence les écarts entre le modèle de sécurité souhaité et la réalité des postes, des applications et des usages.

Elle ne remplace ni la MFA, ni l’accès conditionnel, ni la supervision.  
Elle s’inscrit dans une approche où la valeur du token devient le véritable périmètre de défense.

---

