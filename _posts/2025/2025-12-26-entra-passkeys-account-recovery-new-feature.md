---
title: "Passkeys et récupération de compte : quand la gestion du cycle de vie de l’identité devient centrale"
date: 2025-12-29 06:30:00 +01:00
layout: post
categories: [analyse, technique]
tags: [entra-id, passkeys, mfa, recuperation-compte, identite, gouvernance]
readtime: true
comments: true
cover-img: "assets/img/banners/banner-architecture-best-practices.png"
thumbnail-img: "assets/img/posts/2025/12/2025-12-26-entra-passkeys-account-recovery-new-feature.png"
featured: false
sidebar: true
level: Analyse
scope:
  - Entra ID
  - Passkeys
  - Récupération de compte
platform: Microsoft Entra ID
---

Microsoft a récemment annoncé l’arrivée des **passkeys synchronisées** et de nouveaux mécanismes de **récupération de compte à haut niveau d’assurance** dans Entra ID.  
La documentation décrit précisément comment activer ces fonctionnalités, mais l’annonce mérite une lecture plus large.

Ce que Microsoft met sur la table ne concerne pas uniquement FIDO2 ou l’ergonomie de l’authentification.  
C’est une évolution explicite de la manière dont est pensée la **gestion du cycle de vie complet de l’identité**, y compris dans ses moments de rupture.

## Passkeys : le problème n’est plus vraiment l’authentification

Sur le plan technique, l’intérêt des passkeys est clair.  
La MFA classique (push, OTP, SMS) est devenue à la fois pénible pour les utilisateurs et insuffisante face aux attaques *Adversary-in-the-Middle*. Les passkeys synchronisées apportent un meilleur compromis entre résistance au phishing et expérience utilisateur.

Mais ce déplacement du mécanisme d’authentification entraîne aussi un déplacement du point de confiance.  
Avec des clés synchronisées dans Authenticator, le terminal mobile devient le **coffre-fort de l’identité**. La sécurité ne repose plus uniquement sur Entra ID, mais aussi sur l’état du poste, la gestion MDM, la conformité Intune et, plus largement, la maturité opérationnelle de l’environnement.

Les passkeys améliorent l’entrée dans le système.  
Elles ne disent encore rien de ce qui se passe quand cette entrée devient impossible.

![Passkey improve sign-in success](/assets/img/posts/2025/12/2025-12-29-passkeys-sign-in-success.png)

## Quand la récupération devient un acte d’identité à part entière

C’est sur ce point que l’annonce est réellement structurante.

Microsoft introduit un mécanisme de récupération de compte reposant sur une **vérification d’identité forte**, s’appuyant sur des fournisseurs externes de vérification d’identité intégrés à l’écosystème Entra.  
En cas de perte du facteur principal (téléphone, authenticator), l’utilisateur ne se contente plus de déclarer un incident : il doit **prouver qui il est**.

La récupération repose alors sur des éléments hors du système d’information :
- documents officiels (CNI, passeport),
- vérifications biométriques (Face Check),
- contrôles effectués par des tiers spécialisés.

En cas de succès, Entra ID permet la délivrance d’un **Temporary Access Pass** ou le ré-enrôlement direct de nouvelles méthodes d’authentification.

La récupération n’est plus un contournement de la sécurité.  
Elle devient un **processus d’identité à haut niveau d’assurance**, aligné — en théorie — avec les exigences de l’authentification initiale.

![Recovery mode configuration in Entra ID](/assets/img/posts/2025/12/2025-12-29-entra-account-ownership-verification.png)

## Une identité qui dépasse clairement le périmètre du SI

Cette évolution a des implications architecturales majeures.

L’identité d’entreprise n’est plus uniquement fondée sur des preuves internes (mot de passe, MFA, device). Elle s’appuie désormais sur une **chaîne de confiance élargie**, intégrant des acteurs externes, des données sensibles et des processus proches de ceux de l’identité civile.

Microsoft ne se positionne plus uniquement comme Identity Provider, mais comme **orchestrateur d’identité**, capable de coordonner authentification, vérification documentaire, biométrie et récupération.

D’un point de vue conceptuel, l’approche est cohérente avec une vision *identity-first*.  
D’un point de vue opérationnel, elle soulève néanmoins des questions très concrètes.

![Entra account recovery mode](/assets/img/posts/2025/12/2025-12-29-entra-account-recovery-mode.png)

---

## Mon regard RSSI : une approche puissante… mais délicate à déployer

C’est probablement ici que le décalage entre la vision et le terrain apparaît le plus nettement.

Mélanger des **accès professionnels** avec des processus de vérification reposant sur des **documents d’identité nationaux** n’est pas anodin. En France notamment, où le déploiement d’Authenticator reste déjà parfois complexe, ajouter une couche de vérification par CNI ou passeport peut rapidement devenir sensible, tant sur le plan culturel que réglementaire.

La question n’est pas uniquement technique. Elle touche :
- à l’acceptabilité par les utilisateurs,
- à la perception de l’intrusion,
- à la gestion des données personnelles,
- et à la responsabilité en cas de litige ou d’erreur.

À cela s’ajoute une réalité plus pragmatique : la récupération devient un **service facturé à l’usage**.  
Chaque incident utilisateur peut désormais avoir un coût mesurable, dépendant de fournisseurs tiers et de volumes difficiles à anticiper.

Enfin, il ne faut pas sous-estimer le risque de surconfiance.  
Une récupération dite “à haut niveau d’assurance” reste un processus probabiliste, dépendant de la qualité des contrôles, des données et des prestataires impliqués. Elle ne dispense ni d’audit, ni de supervision, ni de garde-fous organisationnels.

### Contraintes de licence et de facturation

| Fonctionnalité                         | Prérequis de licence / facturation                         | Remarque terrain |
|--------------------------------------|-------------------------------------------------------------|------------------|
| Passkeys synchronisées               | Inclus pour tous les clients Microsoft Entra ID             | Pas de surcoût spécifique |
| Récupération de compte               | Microsoft Entra ID P1                                       | À réserver aux populations ciblées |
| Face Check (biométrie)               | Add-on à l’usage ou inclus dans Microsoft Entra Suite       | Coût variable selon le volume |
| Vérification de documents officiels  | Facturation à l’acte via Microsoft Security Store           | Dépendance à des fournisseurs tiers |

Le modèle inclut des composantes facturées à l’usage (vérification de documents officiels, et selon le cas Face Check).  
Le coût dépend donc du volume de vérifications réalisées, principalement lié aux scénarios de récupération (perte de facteur, indisponibilité d’accès, réinscription).

## L’identité comme processus continu

Ce que cette annonce met en lumière, au-delà des passkeys, c’est un changement de paradigme.

L’identité n’est plus seulement un point d’entrée à sécuriser.  
C’est un **processus continu**, qui inclut :
- l’accès initial,
- l’usage quotidien,
- l’incident,
- la récupération,
- et la réinscription.

Les passkeys sont visibles et séduisantes.  
La récupération de compte l’est beaucoup moins.

Pourtant, c’est souvent dans ces moments de rupture que se mesure la solidité réelle d’une architecture d’identité.

## Ressources

- 🔗 [Microsoft Entra Blog - Synced passkeys and high assurance account recovery](https://techcommunity.microsoft.com/blog/microsoft-entra-blog/synced-passkeys-and-high-assurance-account-recovery/3627343)
- 🔗 [Microsoft Entra News and Insights | Microsoft Security Blog](https://www.microsoft.com/en-us/security/blog/products/microsoft-entra/)
- ⁠🔗 [⁠Microsoft Entra blog | Tech Community](https://techcommunity.microsoft.com/t5/microsoft-entra-blog/bg-p/Identity)
- 🔗 [⁠Microsoft Entra documentation | Microsoft Learn](https://learn.microsoft.com/en-us/entra/)
- 🔗 [Microsoft Entra discussions | Microsoft Community](https://techcommunity.microsoft.com/t5/microsoft-entra/bd-p/Azure-Active-Directory)
