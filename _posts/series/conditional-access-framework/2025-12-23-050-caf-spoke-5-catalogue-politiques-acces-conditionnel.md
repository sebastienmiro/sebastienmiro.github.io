---
title: "Conditional Access Framework v4 — Catalogue des politiques"
date: 2026-10-08 09:00:00 +01:00
layout: post
tags: [series:conditional-access-framework, conditional-access, design]
categories: [identite, entra-id]
readtime: true
comments: true
cover-img: "assets/img/banners/banner-conditional-access-admins.png"
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

Cet article constitue le **catalogue de référence** des politiques du *Conditional Access Framework v4*.  
Il s’appuie exclusivement sur la nomenclature officielle des politiques (fichiers JSON CAxxx) et en reprend fidèlement la structure.

Ce catalogue n’est ni un guide de configuration, ni une checklist de déploiement.  
Il sert de **point de vérité** pour comprendre :
- quelles politiques composent réellement le framework,
- à quelles personas elles s’appliquent,
- quelles intentions de sécurité elles portent,
- et quels sont leurs prérequis implicites.

Les analyses détaillées feront l’objet d’articles dédiés et seront référencées progressivement depuis ce catalogue.

## CA000–CA006 — Global policies

Ces politiques constituent le **socle transversal** du framework.  
Elles s’appliquent largement, indépendamment des personas, et visent à éliminer les vecteurs de compromission les plus évidents avant toute spécialisation.

| ID | Politique (nom exact) | Persona(s) | Intention | Contrôle principal | Pré-requis réels | Analyse |
|----|----------------------|------------|-----------|--------------------|------------------|---------|
| CA000 | Global-IdentityProtection-AnyApp-AnyPlatform-MFA | Toutes (hors break-glass) | Identity Protection | MFA | MFA activée | ⏳ |
| CA001 | Global-AttackSurfaceReduction-AnyApp-AnyPlatform-BLOCK-CountryWhitelist | Toutes | Attack Surface Reduction | Blocage géographique | Named locations fiables | ⏳ |
| CA002 | Global-IdentityProtection-AnyApp-AnyPlatform-Block-LegacyAuthentication | Toutes | Identity Protection | Block legacy auth | Aucun | ⏳ |
| CA003 | Global-BaseProtection-RegisterOrJoin-AnyPlatform-MFA | Toutes | Base Protection | MFA | MFA + Entra Join | ⏳ |
| CA004 | Global-IdentityProtection-AnyApp-AnyPlatform-AuthenticationFlows | Toutes | Identity Protection | Auth flows | Auth methods configurées | ⏳ |
| CA005 | Global-DataProtection-Office365-AnyPlatform-Unmanaged-AppEnforcedRestrictions-BlockDownload | Toutes | Data Protection | App enforced restrictions | O365, MCAS | ⏳ |
| CA006 | Global-DataProtection-Office365-iOSandAndroid-RequireAppProtection | Toutes | Data Protection | App protection | Intune MAM | ⏳ |

## CA100–CA105 — Admin policies

Ces politiques sont dédiées aux **comptes à privilèges**.  
Elles sortent explicitement les administrateurs du flux standard d’authentification et réduisent leur surface et durée d’exposition.

| ID | Politique (nom exact) | Persona(s) | Intention | Contrôle principal | Pré-requis réels | Analyse |
|----|----------------------|------------|-----------|--------------------|------------------|---------|
| CA100 | Admins-IdentityProtection-AdminPortals-AnyPlatform-MFA | Admins | Identity Protection | MFA | MFA | ⏳ |
| CA101 | Admins-IdentityProtection-AnyApp-AnyPlatform-MFA | Admins | Identity Protection | MFA | MFA | ⏳ |
| CA102 | Admins-IdentityProtection-AllApps-AnyPlatform-SigninFrequency | Admins | Identity Protection | Sign-in frequency | Session controls | ⏳ |
| CA103 | Admins-IdentityProtection-AllApps-AnyPlatform-PersistentBrowser | Admins | Identity Protection | Persistent browser | Session controls | ⏳ |
| CA104 | Admins-IdentityProtection-AllApps-AnyPlatform-ContinuousAccessEvaluation | Admins | Identity Protection | CAE | CAE support | ⏳ |
| CA105 | Admins-IdentityProtection-AnyApp-AnyPlatform-PhishingResistantMFA | Admins | Identity Protection | Phishing-resistant MFA | FIDO2 / CBA | ⏳ |

## CA200–CA210 — Internals (utilisateurs internes)

Ces politiques couvrent les **utilisateurs internes standards**.  
Elles visent à réduire les attaques opportunistes et à introduire des contrôles contextuels sans bloquer les usages quotidiens.

| ID | Politique (nom exact) | Persona(s) | Intention | Contrôle principal | Pré-requis réels | Analyse |
|----|----------------------|------------|-----------|--------------------|------------------|---------|
| CA200 | Internals-IdentityProtection-AnyApp-AnyPlatform-MFA | Internals | Identity Protection | MFA | MFA | ⏳ |
| CA201 | Internals-IdentityProtection-AnyApp-AnyPlatform-BLOCK-HighRiskUser | Internals | Identity Protection | Block | Identity Protection | ⏳ |
| CA202 | Internals-IdentityProtection-AllApps-WindowsMacOS-SigninFrequency-UnmanagedDevices | Internals | Identity Protection | Sign-in frequency | Device detection | ⏳ |
| CA203 | Internals-AppProtection-MicrosoftIntuneEnrollment-AnyPlatform-MFA | Internals | App Protection | MFA | Intune | ⏳ |
| CA204 | Internals-AttackSurfaceReduction-AllApps-AnyPlatform-BlockUnknownPlatforms | Internals | ASR | Block | Platform detection | ⏳ |
| CA205 | Internals-BaseProtection-AnyApp-Windows-CompliantorAADHJ | Internals | Base Protection | Device compliance | Intune / AADJ | ⏳ |
| CA206 | Internals-IdentityProtection-AllApps-AnyPlatform-PersistentBrowser | Internals | Identity Protection | Persistent browser | Session controls | ⏳ |
| CA207 | Internals-AttackSurfaceReduction-SelectedApps-AnyPlatform-BLOCK | Internals | ASR | Block | App scoping | ⏳ |
| CA208 | Internals-BaseProtection-AnyApp-MacOS-Compliant | Internals | Base Protection | Device compliance | Intune | ⏳ |
| CA209 | Internals-IdentityProtection-AllApps-AnyPlatform-ContinuousAccessEvaluation | Internals | Identity Protection | CAE | CAE support | ⏳ |
| CA210 | Internals-IdentityProtection-AnyApp-AnyPlatform-BLOCK-HighRiskSignIn | Internals | Identity Protection | Block | Identity Protection | ⏳ |

## CA300–CA301 — Service accounts / workloads

Ces politiques couvrent les **identités non humaines**.  
Leur objectif principal est de limiter l’exposition sans tenter d’appliquer des contrôles pensés pour des utilisateurs interactifs.

| ID | Politique (nom exact) | Persona(s) | Intention | Contrôle principal | Pré-requis réels | Analyse |
|----|----------------------|------------|-----------|--------------------|------------------|---------|
| CA300 | ServiceAccounts-IdentityProtection-AnyApp-AnyPlatform-MFA | Service accounts | Identity Protection | MFA | MFA supportée | ⏳ |
| CA301 | ServiceAccounts-AttackSurfaceReduction-AllApps-AnyPlatform-BlockUntrustedLocations | Service accounts | ASR | Block | Named locations | ⏳ |

## CA400–CA404 — Guest users

Ces politiques traitent les **identités externes et invités**, avec un niveau de confiance initial volontairement plus faible et des périmètres applicatifs restreints.

| ID | Politique (nom exact) | Persona(s) | Intention | Contrôle principal | Pré-requis réels | Analyse |
|----|----------------------|------------|-----------|--------------------|------------------|---------|
| CA400 | GuestUsers-IdentityProtection-AnyApp-AnyPlatform-MFA | Guests | Identity Protection | MFA | B2B MFA | ⏳ |
| CA401 | GuestUsers-AttackSurfaceReduction-AllApps-AnyPlatform-BlockNonGuestAppAccess | Guests | ASR | Block | App scoping | ⏳ |
| CA402 | GuestUsers-IdentityProtection-AllApps-AnyPlatform-SigninFrequency | Guests | Identity Protection | Sign-in frequency | Session controls | ⏳ |
| CA403 | GuestUsers-IdentityProtection-AllApps-AnyPlatform-PersistentBrowser | Guests | Identity Protection | Persistent browser | Session controls | ⏳ |
| CA404 | GuestUsers-AttackSurfaceReduction-SelectedApps-AnyPlatform-BLOCK | Guests | ASR | Block | App scoping | ⏳ |

## Utilisation du catalogue

Ce catalogue doit être lu comme une **cartographie du framework**, pas comme une liste de choses à activer.  
Toutes les politiques ne sont ni simultanées, ni universelles. Leur **ordre de déploiement**, leurs **exclusions** et leurs **dépendances** sont déterminants.

Les articles suivants entreront dans le détail :
- des politiques de **session et tokens**,
- des politiques **admins critiques**,
- puis du **guide de déploiement synthétique**.

Ce catalogue servira de point d’ancrage à l’ensemble.
