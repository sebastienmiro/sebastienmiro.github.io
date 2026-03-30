---
title: "External MFA dans Microsoft Entra ID : ce que change la GA pour votre stratégie d'accès conditionnel"
date: 2026-03-30 07:30:00 +01:00
layout: post
categories: [securite, entra-id]
tags:
  - entra-id
  - external-mfa
  - conditional-access
  - mfa
  - oidc
  - zero-trust
  - authentication-methods
readtime: true
comments: true
sidebar: true
level: Analyse
platform: Microsoft Entra ID
scope:
  - Microsoft Entra ID
  - Conditional Access
  - MFA
cover-img: "assets/img/banners/banner2.png"
thumbnail-img: "assets/img/posts/2026/20260331-thumb.png"
---

## Pourquoi cet article hors série

Le 25 mars 2026, Microsoft a annoncé la disponibilité générale (GA) de l'External MFA dans Microsoft Entra ID. Cette fonctionnalité, anciennement connue sous le nom d'External Authentication Methods (EAM), permet d'intégrer des fournisseurs MFA tiers directement dans le flux d'authentification Entra ID.

Pour toute organisation qui travaille avec le Conditional Access Framework, cette annonce a des implications concrètes. Elle ouvre de nouvelles possibilités d'architecture MFA, mais introduit aussi des limitations qu'il faut connaître avant de modifier ses politiques.

## Le problème que résout External MFA

Jusqu'à présent, les organisations qui souhaitaient utiliser un fournisseur MFA tiers avec Entra ID avaient deux options, toutes deux imparfaites.

La première consistait à utiliser les Custom Controls de Conditional Access. Ce mécanisme redirige l'utilisateur vers un service externe pendant l'évaluation de la politique, puis récupère un signal "oui/non". Il ne repose pas sur OIDC, ne produit pas de claim MFA exploitable par Entra ID et ne satisfait pas les politiques Conditional Access qui exigent "Require multifactor authentication". C'est une impasse technique déguisée en solution.

La seconde option reposait sur la fédération via AD FS, où le fournisseur MFA tiers s'intégrait directement à l'IdP fédéré. Fonctionnel, mais dépendant d'une infrastructure on-premises que Microsoft pousse les organisations à abandonner.

External MFA propose une troisième voie : une intégration standardisée sur OIDC, où le fournisseur tiers devient une méthode d'authentification native dans Entra ID. Le MFA externe satisfait pleinement l'exigence "Require multifactor authentication" dans Conditional Access.

## Comment fonctionne External MFA

Le fonctionnement repose sur le standard OpenID Connect et sur le flux implicite OIDC. Voici la séquence complète :

1. L'utilisateur tente d'accéder à une application protégée par Entra ID et s'authentifie avec un premier facteur (mot de passe, par exemple).

2. Entra ID évalue les politiques Conditional Access applicables et détermine qu'un second facteur est requis.

3. L'utilisateur choisit la méthode MFA externe parmi les méthodes disponibles.

4. Entra ID redirige le navigateur vers l'URL du fournisseur MFA externe (découverte via l'endpoint OIDC Discovery). La requête inclut un paramètre `id_token_hint` qui contient les informations sur l'utilisateur et le tenant.

5. Le fournisseur externe valide le token, vérifie qu'il provient bien d'un tenant Microsoft, puis procède à l'authentification de l'utilisateur avec la méthode de son choix (push, biométrie, clé matérielle, etc.).

6. Le fournisseur externe redirige l'utilisateur vers Entra ID avec un `id_token` valide contenant les claims requis, notamment le type de facteur utilisé (possession, connaissance ou inhérence).

7. Entra ID valide la signature du token, vérifie les claims, et s'assure que le type du second facteur complète bien le type du premier. Si tout est conforme, l'exigence MFA est satisfaite.

Le point essentiel : chaque authentification, même via un fournisseur externe, passe par l'évaluation complète des politiques Entra ID, y compris l'évaluation des risques en temps réel et les contrôles Conditional Access.

## Ce qu'il faut pour configurer External MFA

La configuration dans le portail Entra ID nécessite trois éléments fournis par le fournisseur MFA tiers :

Un **Application ID** correspondant à l'application multitenant du fournisseur. L'administrateur doit accorder le consentement admin pour cette application dans son tenant, afin que le fournisseur puisse accéder aux informations utilisateur nécessaires pendant l'authentification.

Un **Client ID**, identifiant utilisé par le fournisseur pour identifier Entra ID comme demandeur d'authentification. Cette valeur peut être identique à l'Application ID selon le fournisseur.

Un **Discovery URL**, l'endpoint OIDC Discovery du fournisseur, qui doit se terminer par `/.well-known/openid-configuration` et être accessible en HTTPS.

La configuration se fait via **Entra ID > Authentication methods > Add External MFA**. Une fois la méthode créée, elle apparaît aux côtés des méthodes natives (Microsoft Authenticator, clés FIDO2, etc.) dans l'interface d'administration. L'administrateur peut ensuite cibler des groupes d'utilisateurs spécifiques, avec inclusion et exclusion.

Le rôle minimum requis est **Privileged Role Administrator** pour accorder le consentement admin. Sans ce rôle, la méthode peut être enregistrée mais pas activée.

## Fournisseurs compatibles

Plusieurs fournisseurs proposent déjà une intégration External MFA :

- **Cisco Duo** fait partie des premiers partenaires. L'intégration supporte le Universal Prompt, les passkeys, et prend en charge les utilisateurs invités et cross-tenant.

- **HYPR** a collaboré étroitement avec Microsoft dès la preview en mai 2024. Son intégration propose une authentification passwordless et phishing-resistant via FIDO2.

- **CyberArk Identity** propose une intégration où la redirection OIDC permet de combiner le premier facteur Microsoft avec un challenge CyberArk.

- **WatchGuard AuthPoint** sera disponible comme fournisseur External MFA à partir d'avril 2026. L'intégration supporte le push, les TOTP, la vérification par QR code et les passkeys FIDO2.

Tout fournisseur capable d'implémenter les trois endpoints OIDC requis (Discovery, Authorization, Token) peut techniquement s'intégrer. Microsoft met à disposition une équipe CxE ISV pour accompagner les éditeurs dans le développement de leur intégration.

## Impact sur le Conditional Access Framework

C'est ici que les choses deviennent intéressantes pour les architectes Conditional Access.

### Ce qui fonctionne

External MFA satisfait le grant control **"Require multifactor authentication"** dans les politiques Conditional Access. Concrètement, si votre politique CA001 exige le MFA pour tous les utilisateurs, un utilisateur qui s'authentifie via Duo ou HYPR en tant que second facteur satisfait cette exigence.

L'intégration avec les contrôles de session fonctionne également : fréquence de connexion, durée de session, et réévaluation continue s'appliquent normalement.

Microsoft recommande d'ailleurs de calibrer soigneusement la fréquence de réauthentification. Une fréquence trop élevée dégrade l'expérience utilisateur et peut paradoxalement augmenter le risque de phishing en habituant les utilisateurs à approuver des prompts sans les examiner.

### Ce qui ne fonctionne pas (encore)

**External MFA n'est pas compatible avec les Authentication Strengths.** C'est la limitation la plus significative. Les politiques Conditional Access qui utilisent le grant control "Require authentication strength" (y compris le built-in "MFA strength") ne sont pas satisfaites par une méthode MFA externe.

En pratique, cela signifie que si vous avez des politiques qui exigent une "Phishing-resistant MFA strength" ou une custom authentication strength, External MFA ne les satisfera pas. Vous devez utiliser uniquement le grant "Require multifactor authentication" classique.

Cette limitation est particulièrement importante dans le contexte du CAF v4, où l'on tend à utiliser les Authentication Strengths pour imposer des méthodes résistantes au phishing sur les ressources critiques.

### Ce qui doit être migré

Les Custom Controls seront dépréciés le **30 septembre 2026**. Les configurations existantes continueront de fonctionner pendant la période de transition, mais Microsoft recommande de commencer la migration dès maintenant.

La stratégie de migration recommandée par Microsoft est la suivante : créer un jeu parallèle de politiques Conditional Access utilisant "Require multifactor authentication" au lieu du Custom Control, tester avec un sous-ensemble d'utilisateurs, puis basculer progressivement.

## Cas d'usage concrets

### Fusions et acquisitions

Lors d'un rapprochement entre deux organisations, chacune peut avoir son propre fournisseur MFA. External MFA permet de maintenir le fournisseur existant tout en centralisant la gestion des identités dans Entra ID. Les utilisateurs conservent leur expérience MFA habituelle pendant la période de transition.

### Conformité réglementaire

Certains secteurs (banque, santé, défense) imposent l'utilisation de solutions MFA spécifiques, certifiées ou auditées. External MFA permet de répondre à ces exigences sans abandonner Entra ID comme plan de contrôle identitaire.

### Environnements hétérogènes

Les organisations qui exploitent des environnements mixtes (Microsoft et non-Microsoft) peuvent vouloir un fournisseur MFA unique pour tous leurs systèmes. External MFA permet d'utiliser ce même fournisseur pour les ressources protégées par Entra ID, garantissant une expérience utilisateur cohérente.

### Authentification passwordless cross-platform

Les méthodes natives d'Entra ID fonctionnent très bien dans un écosystème Windows, mais peuvent être limitées dans des environnements multi-OS. Un fournisseur externe comme HYPR permet d'étendre l'authentification passwordless et phishing-resistant à l'ensemble du parc, quel que soit le système d'exploitation.

## Points de vigilance

### Enregistrement utilisateur

Lors de la première utilisation, les utilisateurs passent par un assistant d'enregistrement qui les guide vers le fournisseur MFA externe. Si l'authentification auprès du fournisseur réussit, la méthode est enregistrée dans les Security Info de l'utilisateur. Les administrateurs peuvent également pré-enregistrer les utilisateurs, ce qui leur évite cette étape.

### Windows 10 non supporté

External MFA ne fonctionne pas pendant le processus de configuration initiale (OOBE) de Windows 10. Microsoft ne prévoit pas d'étendre le support à Windows 10, le système étant en fin de vie. Pour utiliser External MFA lors de la configuration d'un appareil, il faut Windows 11.

### Coexistence des politiques

Si votre tenant est en cours de migration des méthodes d'authentification legacy vers la nouvelle politique unifiée, attention aux interactions. Si Microsoft Authenticator ou d'autres méthodes restent actives dans les politiques legacy, elles apparaîtront aux utilisateurs en plus de la méthode externe. Pour limiter les options à la seule méthode externe, il faut finaliser la migration vers la politique d'authentification unifiée d'Entra ID.

### Licence requise

L'utilisation d'External MFA nécessite au minimum une licence **Microsoft Entra ID P1**. C'est une exigence Microsoft, indépendante du fournisseur MFA tiers choisi.

## Ce que cela signifie pour le CAF v4

Dans le cadre du Conditional Access Framework v4, External MFA s'intègre naturellement dans les politiques de base qui utilisent le grant "Require multifactor authentication". Les sept politiques CA000 à CA006 restent pleinement compatibles.

En revanche, pour les politiques avancées qui s'appuient sur les Authentication Strengths pour exiger du MFA phishing-resistant, External MFA ne peut pas (encore) être utilisé comme méthode qualifiante. Cela reste une limitation significative pour les organisations qui veulent à la fois un fournisseur MFA tiers et une posture phishing-resistant imposée par Conditional Access.

La recommandation pour le moment : utiliser External MFA là où le grant "Require MFA" suffit, et conserver les méthodes natives (passkeys, Windows Hello for Business, clés FIDO2) pour les politiques qui exigent une Authentication Strength spécifique.

## Pour aller plus loin

- [Annonce officielle Microsoft](https://techcommunity.microsoft.com/blog/microsoft-entra-blog/external-mfa-in-microsoft-entra-id-is-now-generally-available/4488926)
- [Guide de configuration step-by-step](https://learn.microsoft.com/en-us/entra/identity/authentication/how-to-authentication-external-method-manage)
- [Référence technique du provider OIDC](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-external-method-provider)