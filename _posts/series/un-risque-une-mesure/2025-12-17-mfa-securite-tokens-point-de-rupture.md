---
title: "MFA ≠ sécurité : pourquoi les tokens sont devenus le vrai point de rupture"
date: 2025-12-17 11:30:00 +01:00
layout: post
tags: [series:un-risque-une-mesure, mfa, token]
categories: [identite, entra-id]
readtime: true
comments: true
cover-img: "assets/img/banners/bannertoken-theft.png"
thumbnail-img: "assets/img/posts/2025/12/17/92e02190-fa01-4431-b156-d406a80b1d60.png"
series: R1M
series_order: 020
sidebar: true
level: concepts
scope:
  - Entra ID
  - MFA
---

Pendant des années, l’authentification multifacteur a été présentée comme une finalité.  
Une fois activée, le sujet semblait réglé. Dans beaucoup de tenants Microsoft 365, cette vision a conduit à un raccourci dangereux : *la MFA est en place, donc le compte est protégé*.

Les incidents récents racontent pourtant une autre histoire.  
Les comptes compromis avaient une MFA active. Les utilisateurs validaient les demandes. Les paramètres semblaient conformes. Et malgré cela, l’attaquant accédait aux ressources.

Le problème n’est pas la MFA.  
Le problème est ce qu’elle ne couvre pas.

## La MFA protège l’authentification, pas la session

Dans Microsoft Entra ID, la MFA intervient uniquement **au moment de l’authentification initiale**.  
Elle permet de vérifier l’identité de l’utilisateur avant l’émission des jetons d’accès.

Une fois cette étape franchie :
- Entra ID émet des tokens (access token, refresh token, Primary Refresh Token),
- la MFA n’est plus sollicitée,
- les accès ultérieurs reposent exclusivement sur ces jetons.

Autrement dit :
- la MFA protège l’entrée,
- elle ne protège ni la session,
- ni la durée d’accès,
- ni la réutilisation des tokens.

C’est précisément ce décalage qui explique l’évolution des attaques.

## Le vrai actif aujourd’hui : un token valide

Avec la généralisation de la MFA, les attaquants ont adapté leur stratégie.  
Le mot de passe n’est plus la cible principale. Ce qui a réellement de la valeur, c’est **un token valide émis par Entra ID**.

Tant qu’un token est accepté :
- aucune nouvelle authentification n’est requise,
- la MFA n’est pas réévaluée,
- l’accès est considéré comme légitime.

Les attaques de type *Adversary-in-the-Middle (AiTM)* illustrent parfaitement ce modèle.  
L’utilisateur se connecte sur une page qui paraît légitime, saisit ses identifiants, valide sa MFA. Du point de vue d’Entra ID, tout est conforme. La MFA est satisfaite, un token est émis.

La seule différence — invisible pour l’utilisateur — est qu’un proxy malveillant intercepte ce token en temps réel et peut ensuite le rejouer depuis un autre environnement.

Dans ce scénario :
- la MFA n’est pas contournée,
- elle est utilisée,
- et le token reste exploitable hors de son contexte d’émission.

Le même raisonnement s’applique aux vols de session, aux malwares ou aux extensions de navigateur.  
Une fois le token extrait, l’attaquant n’a plus besoin ni du mot de passe, ni de la MFA.

Le point de rupture n’est donc plus l’authentification.  
C’est **la réutilisabilité des tokens**.

## Token Protection : ce que Microsoft cherche réellement à bloquer

Token Protection est un **contrôle de session de l’accès conditionnel** conçu pour réduire les attaques par rejeu de token.

Le principe est strictement défini par Microsoft :  
**seuls des tokens liés cryptographiquement à l’appareil d’origine doivent être acceptés par Entra ID**.

Lorsque qu’un appareil Windows 10 ou ultérieur est enregistré dans Microsoft Entra ID :
- un **Primary Refresh Token (PRT)** est émis,
- ce PRT est **cryptographiquement lié à l’appareil**,
- ce lien empêche l’utilisation du token depuis un autre contexte.

Avec Token Protection activée :
- Entra ID valide que les applications utilisent bien des tokens liés à l’appareil,
- tout token non lié (ou issu d’un contexte non supporté) est rejeté.

L’objectif n’est pas d’empêcher le vol de token — ce serait illusoire —  
mais de **supprimer toute valeur opérationnelle à un token volé**.

![Entra Admin Center - Conditional Access Overview](/assets/img/posts/2025/12/17/conditional-access-central-policy-engine-zero-trust.png)
---

# Implémentation technique dans Microsoft Entra ID

La seconde partie de l’article est volontairement plus opérationnelle.  
Token Protection n’est pas un paramètre global du tenant, mais un **contrôle ciblé intégré à l’accès conditionnel**.

## Où se configure Token Protection

La configuration s’effectue dans le portail Microsoft Entra ID, sous :

**Sécurité → Accès conditionnel**

![Entra Admin Center - Conditional Access Overview](/assets/img/posts/2025/12/17/conditional-access-overview.png)

Token Protection apparaît comme un **Session Control**, au même titre que la fréquence de connexion ou la persistance de session.

## Créer une politique dédiée

Il est fortement recommandé de créer une **politique d’accès conditionnel dédiée**.  
Token Protection agit directement sur les tokens ; il doit être possible d’identifier précisément où ce contrôle est appliqué.

![Conditional Access - Policies Listing](/assets/img/posts/2025/12/17/conditional-access-policies-azure-ad-listing.png)

## Définir les ressources ciblées

Microsoft est explicite : Token Protection ne doit être appliqué **qu’aux ressources supportées**.

Applications recommandées :
- Office 365 Exchange Online
- Office 365 SharePoint Online
- Microsoft Teams Services
- Azure Virtual Desktop
- Windows 365

⚠️ **Il ne faut pas sélectionner le groupe “Office 365”**.  
Ce point constitue une exception documentée par Microsoft et entraîne des blocages non intentionnels.

![Conditional Access - Cloud apps or actions](/assets/img/posts/2025/12/17/conditional-access-cloud-apps-or-actions.png)

## Plateformes et clients : conditions obligatoires

Token Protection repose sur des flux modernes et sur l’intégration avec le broker d’authentification Windows (WAM).

Configuration recommandée :
- **Device platform** : Windows uniquement
- **Client apps** : Mobile apps and desktop clients

⚠️ Laisser le navigateur sélectionné ou ne pas configurer la condition *Client apps* peut bloquer des applications utilisant MSAL.js (par exemple Teams Web).

![Conditional Access - Conditions](/assets/img/posts/2025/12/17/conditional-access-conditions.png)

## Activer Token Protection (Session control)

L’activation se fait dans :
**Access controls → Session**

Option à sélectionner :
> **Require token protection for sign-in sessions**

![Conditional Access - Session Controls](/assets/img/posts/2025/12/17/complete-policy-components-session.png)

Microsoft rappelle explicitement que :
- seuls les appareils et applications supportés fonctionneront,
- les autres seront bloqués.

## Prérequis techniques (à ne pas ignorer)

### Licence
- Microsoft Entra ID P1 minimum.

### Appareils supportés
- Windows 10 ou ultérieur :
  - Entra ID joined
  - Entra ID hybrid joined
  - Entra ID registered
- Windows Server 2019 ou ultérieur (hybrid joined)

### Appareils non supportés (exemples)
- Surface Hub
- Microsoft Teams Rooms (Windows)
- Azure Virtual Desktop Entra joined
- Cloud PCs Entra joined
- Autopilot self-deploying mode
- Enrôlement en masse
- VM Azure avec extension Entra ID

Dans ces cas, Entra ID ne peut pas garantir le binding du token.

## Gestion des exclusions via Device Filters

Microsoft recommande d’exclure explicitement certains scénarios via des filtres d’appareils, par exemple :

- Cloud PC :
  `systemLabels -eq "CloudPC" and trustType -eq "AzureAD"`
- Azure Virtual Desktop :
  `systemLabels -eq "AzureVirtualDesktop" and trustType -eq "AzureAD"`
- Autopilot self-deploying :
  `enrollmentProfileName -eq "Autopilot self-deployment profile"`

Ces exclusions permettent un déploiement progressif sans interruption massive.

## Déploiement recommandé

Microsoft insiste sur une approche incrémentale :
- groupe pilote,
- politique en **Report-only**,
- analyse des logs interactifs et non interactifs,
- bascule progressive en mode *On*.

## Analyse des logs et compréhension des erreurs

Les journaux de connexion Entra ID exposent explicitement l’état du binding.

Champ clé :
**Token Protection – Sign In Session**

Valeurs possibles :
- **Bound** : token correctement lié
- **Unbound** : token non lié

Codes fréquents :
- `1002` : absence d’état appareil Entra ID
- `1003` : type d’enrôlement non supporté
- `1006` : version OS non supportée
- `1008` : client non intégré à WAM

![Sign-in log - Token Protection status](/assets/img/posts/2025/12/17/sign-in-log-sample-unbound-status-code-1002.png)

Ces informations sont indispensables pour distinguer :
- un problème de compatibilité,
- d’une tentative de rejeu de token.

## Expérience utilisateur

Sur un appareil et une application compatibles, **Token Protection est totalement transparent**.

En revanche :
- appareil non enregistré,
- application non supportée,

entraînent un blocage explicite après authentification.

---

## Conclusion

La MFA reste indispensable.  
Elle n’est simplement plus suffisante à elle seule.

Aujourd’hui, la sécurité de l’identité ne se joue plus uniquement à l’authentification, mais sur **ce qui circule après**. Tant que les tokens restent librement rejouables hors de leur contexte, les attaques continueront de fonctionner.

Token Protection n’est pas un durcissement cosmétique.  
C’est une réponse directe à la manière dont les compromissions se produisent réellement.
