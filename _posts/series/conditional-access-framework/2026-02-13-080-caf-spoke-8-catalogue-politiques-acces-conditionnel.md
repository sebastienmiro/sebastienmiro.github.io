---
title: "Conditional Access Framework v2026.1 - Catalogue des politiques"
date: 2026-02-30 09:00:00 +01:00
layout: post
tags: [series:conditional-access-framework, conditional-access, design]
categories: [identite, entra-id]
readtime: true
comments: true
cover-img: "assets/img/banners/banner-conditional-access.png"
thumbnail-img: "assets/img/posts/series/conditional-access-framework/050/050-thumb.png"
series: CA
series_order: 050
sidebar: true
level: référence
scope:
  - Entra ID
  - Conditional Access
  - Catalogue de politiques
platform: Microsoft Entra
---

## Rôle de cet article

Cet article constitue le **catalogue de référence** des politiques du *Conditional Access Framework*, dans sa version **2026.2.1** publiée par Joey Verlinden le 13 février 2026.

Ce catalogue n'est ni un guide de configuration, ni une checklist de déploiement. Il sert de **point de vérité** pour comprendre :

- quelles politiques composent réellement le framework,
- à quelles personas elles s'appliquent,
- quelles intentions de sécurité elles portent,
- et quels sont leurs prérequis implicites.

Les analyses détaillées font l'objet d'articles dédiés, référencés progressivement depuis ce catalogue.

> Le framework complet, avec les politiques exportables et les instructions d'import, est disponible sur le [GitHub de Joey Verlinden](https://github.com/j0eyv/ConditionalAccessBaseline).

---

## Changelog v2026.2.1

Deux modifications notables dans cette version :

**CA501 — nouvelle politique** : une politique *template* pour les agents à haut risque est intégrée au framework. Elle crée par la même occasion une nouvelle persona : **Agents**.

**CA005 — mise à jour** : le contrôle *Require approved client app* est remplacé par *RequireAppProtection*. Ce changement fait suite à la **dépréciation de "Require approved client app" par Microsoft en mars 2026**. Les tenants qui utilisaient encore l'ancien contrôle doivent migrer vers `RequireAppProtection` pour maintenir la couverture de protection des données sur les appareils non gérés.

---

## Personas

Le framework structure ses politiques autour de cinq personas distinctes. Chacune représente un profil d'identité avec ses propres exigences de sécurité.

**Global** regroupe les politiques transversales qui s'appliquent à toutes les identités, ou qui couvrent des scénarios non rattachables à une persona unique. C'est le socle commun du framework.

**Admins** couvre toute identité non-invitée — synchronisée ou cloud — disposant d'un rôle d'administration Microsoft 365 ou Azure AD (Exchange, MDCA, Defender for Endpoint, Compliance, etc.). Les comptes invités avec des rôles admin relèvent de la persona Guests, pas de celle-ci.

**Internals** désigne les utilisateurs disposant d'un compte AD synchronisé, employés de l'organisation, occupant un rôle utilisateur standard.

**Guests** regroupe tous les comptes invités Azure AD (B2B) ayant été invités dans le tenant.

**Agents** — persona introduite en v2026.2.1 — couvre les ressources agentiques gérables via Conditional Access.

---

## CA000–CA006 — Global policies

Ces politiques constituent le **socle transversal** du framework. Elles s'appliquent indépendamment des personas et visent à éliminer les vecteurs de compromission les plus évidents avant toute spécialisation par profil.

| ID | Politique (nom exact) | Persona(s) | Intention | Contrôle principal | Pré-requis | Analyse |
|----|-----------------------|------------|-----------|-------------------|------------|---------|
| CA000 | Global-IdentityProtection-AnyApp-AnyPlatform-MFA | Toutes (hors break-glass) | Identity Protection | MFA | MFA activée | ⏳ |
| CA001 | Global-AttackSurfaceReduction-AnyApp-AnyPlatform-BLOCK-CountryWhitelist | Toutes | Attack Surface Reduction | Blocage géographique | Named location `ALLOWED COUNTRIES` configurée | ⏳ |
| CA002 | Global-IdentityProtection-AnyApp-AnyPlatform-Block-LegacyAuthentication | Toutes | Identity Protection | Block legacy auth | Aucun | ⏳ |
| CA003 | Global-BaseProtection-RegisterOrJoin-AnyPlatform-MFA | Toutes | Base Protection | MFA | MFA + désactivation du paramètre natif d'enregistrement d'appareils | ⏳ |
| CA004 | Global-IdentityProtection-AnyApp-AnyPlatform-AuthenticationFlows | Toutes | Identity Protection | Blocage des transferts de flux d'auth (device code flow) | Fonctionnalité en preview | ⏳ |
| CA005 | Global-DataProtection-Office365-AnyPlatform-Unmanaged-**RequireAppProtection** | Toutes | Data Protection | App Protection Policies (Intune MAM) | Intune MAM, appareils non gérés | ⏳ |
| CA006 | Global-DataProtection-Office365-iOSandAndroid-RequireAppProtection | Toutes | Data Protection | App protection iOS/Android | Intune MAM | ⏳ |

> **Note CA005** : le nom de la politique a évolué en v2026.2.1. L'ancien contrôle *Require approved client app* est déprécié par Microsoft depuis mars 2026 ; il est remplacé par *RequireAppProtection*. Le nom officiel de la politique dans le framework est désormais `Global-DataProtection-Office365-AnyPlatform-Unmanaged-RequireAppProtection`.

> **Note CA006** : selon le GitHub de référence, cette politique sera prochainement modifiée ou supprimée en raison d'un chevauchement avec CA005.

---

## CA100–CA105 — Admin policies

Ces politiques sont exclusivement dédiées aux **comptes à privilèges**. Elles sortent les administrateurs du flux d'authentification standard et réduisent leur surface et durée d'exposition.

| ID | Politique (nom exact) | Persona(s) | Intention | Contrôle principal | Pré-requis | Analyse |
|----|-----------------------|------------|-----------|-------------------|------------|---------|
| CA100 | Admins-IdentityProtection-AdminPortals-AnyPlatform-MFA | Admins | Identity Protection | MFA sur portails admin | MFA | ⏳ |
| CA101 | Admins-IdentityProtection-AnyApp-AnyPlatform-MFA | Admins | Identity Protection | MFA toutes apps | MFA | ⏳ |
| CA102 | Admins-IdentityProtection-AllApps-AnyPlatform-SigninFrequency | Admins | Identity Protection | Fréquence de reconnexion (12h max) | Session controls | ⏳ |
| CA103 | Admins-IdentityProtection-AllApps-AnyPlatform-PersistentBrowser | Admins | Identity Protection | Désactivation des sessions persistantes | Session controls | ⏳ |
| CA104 | Admins-IdentityProtection-AllApps-AnyPlatform-ContinuousAccessEvaluation | Admins | Identity Protection | CAE (réévaluation en quasi-temps réel) | Pas de mode Report-only — ON/OFF uniquement | ⏳ |
| CA105 | Admins-IdentityProtection-AnyApp-AnyPlatform-PhishingResistantMFA | Admins | Identity Protection | MFA phishing-resistant | FIDO2 / CBA | ⏳ |

---

## CA200–CA210 — Internals

Ces politiques couvrent les **utilisateurs internes standards**. Elles visent à réduire les attaques opportunistes et à introduire des contrôles contextuels sans bloquer les usages quotidiens.

| ID | Politique (nom exact) | Persona(s) | Intention | Contrôle principal | Pré-requis | Analyse |
|----|-----------------------|------------|-----------|-------------------|------------|---------|
| CA200 | Internals-IdentityProtection-AnyApp-AnyPlatform-MFA | Internals | Identity Protection | MFA | MFA | ⏳ |
| CA201 | Internals-IdentityProtection-AnyApp-AnyPlatform-BLOCK-HighRiskUser | Internals | Identity Protection | Blocage user risk élevé | Entra ID Protection | ⏳ |
| CA202 | Internals-IdentityProtection-AllApps-WindowsMacOS-SigninFrequency-UnmanagedDevices | Internals | Identity Protection | Fréquence de reconnexion (12h) sur appareils non gérés | Détection de conformité appareil | ⏳ |
| CA203 | Internals-AppProtection-MicrosoftIntuneEnrollment-AnyPlatform-MFA | Internals | App Protection | MFA à l'enrôlement Intune | Intune (attention : incompatible Autopilot v2 sans exclusion) | ⏳ |
| CA204 | Internals-AttackSurfaceReduction-AllApps-AnyPlatform-BlockUnknownPlatforms | Internals | Attack Surface Reduction | Blocage plateformes inconnues | Détection de plateforme | ⏳ |
| CA205 | Internals-BaseProtection-AnyApp-Windows-CompliantorAADHJ | Internals | Base Protection | Conformité ou Hybrid Join (Windows) | Intune / Entra Hybrid Join | ⏳ |
| CA206 | Internals-IdentityProtection-AllApps-AnyPlatform-PersistentBrowser | Internals | Identity Protection | Sessions non persistantes (appareils non gérés) | Session controls | ⏳ |
| CA207 | Internals-AttackSurfaceReduction-SelectedApps-AnyPlatform-BLOCK | Internals | Attack Surface Reduction | Blocage d'applications spécifiques | Ciblage applicatif | ⏳ |
| CA208 | Internals-BaseProtection-AnyApp-MacOS-Compliant | Internals | Base Protection | Conformité appareil macOS | Intune | ⏳ |
| CA209 | Internals-IdentityProtection-AllApps-AnyPlatform-ContinuousAccessEvaluation | Internals | Identity Protection | CAE | Pas de mode Report-only — ON/OFF uniquement | ⏳ |
| CA210 | Internals-IdentityProtection-AnyApp-AnyPlatform-BLOCK-HighRiskSignIn | Internals | Identity Protection | Blocage sign-in risk élevé | Entra ID Protection | ⏳ |

---

## CA300–CA301 — Service accounts

Ces politiques couvrent les **identités non humaines**. L'objectif est de limiter leur exposition sans tenter d'appliquer des contrôles pensés pour des authentifications interactives.

| ID | Politique (nom exact) | Persona(s) | Intention | Contrôle principal | Pré-requis | Analyse |
|----|-----------------------|------------|-----------|-------------------|------------|---------|
| CA300 | ServiceAccounts-IdentityProtection-AnyApp-AnyPlatform-MFA | Service accounts | Identity Protection | MFA | MFA supportée | ⏳ |
| CA301 | ServiceAccounts-AttackSurfaceReduction-AllApps-AnyPlatform-BlockUntrustedLocations | Service accounts | Attack Surface Reduction | Blocage des localisations non approuvées | Named location `ALLOWED COUNTRIES - SERVICE ACCOUNTS` | ⏳ |

---

## CA400–CA404 — Guest users

Ces politiques traitent les **identités externes et invités**, avec un niveau de confiance initial volontairement plus faible et des périmètres applicatifs restreints.

| ID | Politique (nom exact) | Persona(s) | Intention | Contrôle principal | Pré-requis | Analyse |
|----|-----------------------|------------|-----------|-------------------|------------|---------|
| CA400 | GuestUsers-IdentityProtection-AnyApp-AnyPlatform-MFA | Guests | Identity Protection | MFA | B2B MFA | ⏳ |
| CA401 | GuestUsers-AttackSurfaceReduction-AllApps-AnyPlatform-BlockNonGuestAppAccess | Guests | Attack Surface Reduction | Blocage de toutes les apps hors exceptions | Ciblage applicatif | ⏳ |
| CA402 | GuestUsers-IdentityProtection-AllApps-AnyPlatform-SigninFrequency | Guests | Identity Protection | Fréquence de reconnexion (12h) | Session controls | ⏳ |
| CA403 | GuestUsers-IdentityProtection-AllApps-AnyPlatform-PersistentBrowser | Guests | Identity Protection | Sessions non persistantes | Session controls | ⏳ |
| CA404 | GuestUsers-AttackSurfaceReduction-SelectedApps-AnyPlatform-BLOCK | Guests | Attack Surface Reduction | Blocage d'applications spécifiques | Ciblage applicatif | ⏳ |

---

## CA500–CA501 — Agents *(nouveau — v2026.2.1)*

Nouvelle persona introduite dans la version 2026.2.1 pour couvrir les **identités agentiques** — ressources d'agents gérables via Conditional Access. Elle ne contient pour l'instant qu'une seule politique.

| ID | Politique (nom exact) | Persona(s) | Intention | Contrôle principal | Pré-requis | Analyse |
|----|-----------------------|------------|-----------|-------------------|------------|---------|
| CA501 | Agents-IdentityProtection-AnyApp-AnyPlatform-BLOCK-HighRiskAgent | Agents | Identity Protection | Blocage des agents à haut risque | Entra ID Protection (workload identities) | ⏳ |

---

## Utilisation du catalogue

Ce catalogue est une **cartographie du framework**, pas une liste de politiques à activer immédiatement.

Toutes les politiques ne sont ni simultanées, ni universelles. L'**ordre de déploiement**, les **exclusions** (notamment le groupe break-glass) et les **dépendances** entre politiques sont déterminants pour un déploiement sécurisé.

Quelques points d'attention transversaux :

- Avant tout déploiement, désactivez les *Security Defaults* dans le tenant.
- Vérifiez que l'application **Microsoft Intune Enrollment** (`d4ebce55-015a-49b5-a083-c84d1797ae8c`) existe dans le tenant — elle est requise par CA203, CA205 et CA208.
- CA104 et CA209 (Continuous Access Evaluation) ne supportent pas le mode *Report-only* : elles doivent être activées directement en mode ON ou OFF.
- Activez les politiques **une par une**, en commençant par le mode *Report-only* lorsque c'est possible.

Les articles suivants entreront dans le détail des politiques par groupe et par persona. Ce catalogue servira de point d'ancrage à l'ensemble de la série.