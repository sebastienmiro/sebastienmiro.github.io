---
title: "Sécurité de l’identité : le rôle critique des tokens d’accès dans Microsoft Entra ID"
date: 2025-12-23 05:30:00 +01:00
layout: post
tags: [series:un-risque-une-mesure, entra-id, identité, mfa, tokens, token-protection, sécurité]
categories: [identite, entra-id]
readtime: true
comments: true
cover-img: "assets/img/banners/banner1.png"
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

> L’authentification multifacteur est aujourd’hui un prérequis dans Microsoft Entra ID et Microsoft 365. Dans beaucoup d'environnements, son déploiement marque implicitement la fin du sujet “authentification” : le contrôle est en place, le risque est considéré comme couvert.

Les incidents récents montrent pourtant un décalage persistant entre cette perception et la réalité opérationnelle. Les comptes compromis disposent fréquemment d’une MFA active, les validations sont légitimes et les journaux d’authentification ne révèlent aucune anomalie évidente.

La MFA fonctionne.
Mais elle ne couvre pas l’ensemble du problème que l’on cherche à résoudre.

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
L’objectif n’est plus, dans la majorité des cas, de se connecter durablement *à la place* de l’utilisateur, mais d’obtenir ce qui permet de **se passer de l’authentification par la suite**.

Dans des architectures modernes comme Microsoft Entra ID, l’authentification n’est qu’une étape initiale. Une fois validée, le service émet des artefacts — des jetons — qui matérialisent la confiance accordée. Ce sont ces jetons qui sont ensuite présentés aux applications, aux API et aux services pour accéder aux ressources, parfois pendant plusieurs heures, parfois plus longtemps encore.

Pour un attaquant, cette confiance peut prendre différentes formes. Il peut s’agir d’un *access token* permettant d’appeler directement une API, d’un *refresh token* capable de générer de nouveaux jetons sans repasser par une authentification interactive, ou, côté utilisateur, d’une session persistante conservée dans le navigateur et reposant elle-même sur ces jetons.

Dans tous les cas, le principe est identique : **l’accès ne repose plus sur l’authentification, mais sur la validité d’un jeton déjà émis**.

Une fois cet élément récupéré, la MFA ne sera plus sollicitée tant que le jeton reste valide. Elle a rempli son rôle au moment du login, mais elle n’intervient plus dans la suite du parcours d’accès.  
C’est cette dissociation entre authentification et usage des tokens qui explique pourquoi des attaques peuvent réussir alors même que la MFA est activée et correctement configurée.

## Attaques Adversary-in-the-Middle : quand la MFA fonctionne… et l’attaque aussi

Les attaques de type Adversary-in-the-Middle (AiTM), largement documentées par Microsoft, illustrent parfaitement cette dérive.

Le scénario est désormais bien connu : l’utilisateur est redirigé vers un site de phishing qui joue le rôle de proxy. La page de connexion affichée est légitime. Les identifiants sont saisis, la MFA est validée, et Entra ID émet un token de session parfaitement valide.

![Flux AiTM et interception de tokens](https://www.microsoft.com/en-us/security/blog/wp-content/uploads/2022/07/Figure1-overview-of-aitm-phishing.png)


Du point de vue d’Entra ID, tout s’est déroulé normalement.  
La MFA n’a pas été contournée. Elle a été satisfaite.

Le problème n’est donc pas l’authentification, mais **la capacité du token à être rejoué hors de son contexte d’émission**.

## Sessions, cookies et tokens : le périmètre réel de l’attaque

Le raisonnement ne s’arrête pas à l’authentification initiale.  
Une fois la session établie, l’accès aux ressources repose essentiellement sur des éléments persistants stockés côté client : cookies de session, access tokens, refresh tokens, selon les applications et les flux utilisés.

Dans ce contexte, un attaquant n’a pas nécessairement besoin de rejouer une authentification complète. Un poste compromis, une extension de navigateur malveillante ou un accès local à la machine peuvent suffire à extraire des artefacts encore valides, sans interaction avec l’utilisateur et sans déclencher de nouveau contrôle MFA.

Ces éléments peuvent ensuite être présentés depuis un autre environnement, tant qu’ils respectent leurs critères de validité. Du point de vue d’Entra ID, il ne s’agit pas d’une nouvelle connexion, mais de la continuité d’une session déjà autorisée.

La compromission ne dépend alors plus de l’identité de l’utilisateur ni de sa capacité à résister à une tentative de phishing. Elle repose sur la valeur intrinsèque du token et sur sa capacité à être utilisé hors de son contexte d’émission.

C’est précisément cette réalité opérationnelle qui a conduit Microsoft à faire évoluer son modèle de protection des sessions, en introduisant des mécanismes visant à limiter la réutilisabilité des tokens et à remettre le contexte au centre des décisions d’accès.

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

## Ce que perçoit réellement l’utilisateur

Dans les scénarios pleinement compatibles, l’activation de Token Protection est invisible pour l’utilisateur.  
L’authentification se déroule normalement, les applications fonctionnent comme avant, et aucun changement notable n’est perçu.

En revanche, lorsque certains prérequis ne sont pas respectés, l’utilisateur peut se retrouver face à un message d’erreur après une authentification pourtant réussie. L’accès est alors bloqué non pas parce que l’identité est invalide, mais parce que le contexte d’utilisation du token ne répond pas aux exigences de sécurité.

Ce comportement est souvent le premier symptôme visible d’un écart structurel : des postes enrôlés selon des méthodes anciennes, des applications reposant sur des flux non pris en charge, ou des usages qui n’avaient jamais été remis en question tant qu’ils continuaient à fonctionner.

Token Protection ne crée pas ces problèmes.  
Elle les rend visibles.

## Token Protection comme révélateur de cohérence

Token Protection agit moins comme une barrière supplémentaire que comme un révélateur de cohérence globale.  
Elle met en lumière les différences entre le modèle de sécurité attendu — appareils à jour, authentification intégrée, flux supportés — et la réalité opérationnelle du tenant.

Des postes Windows correctement enregistrés, des applications compatibles et des méthodes d’authentification modernes passent sans friction.  
À l’inverse, les environnements hétérogènes, les déploiements historiques ou les usages reposant sur des compromis se retrouvent immédiatement exposés.

En ce sens, Token Protection force une clarification : soit l’environnement est aligné avec le modèle de sécurité  d’Entra ID, soit il ne l’est pas, et l’accès est remis en question.

## Une brique, pas une solution autonome

Token Protection ne remplace ni la MFA, ni l’accès conditionnel, ni la supervision des connexions.  
Elle s’inscrit dans une approche plus large où la sécurité de l’identité ne se limite plus à l’authentification initiale, mais s’étend à la manière dont les tokens sont émis, utilisés et réutilisables dans le temps.

Le véritable changement de paradigme est là :  
le périmètre de défense ne se situe plus uniquement au moment du login, mais dans la capacité à contrôler la valeur opérationnelle d’un token après son émission.

---

