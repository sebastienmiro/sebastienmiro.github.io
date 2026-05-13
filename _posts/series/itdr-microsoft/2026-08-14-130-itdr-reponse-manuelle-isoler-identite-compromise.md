---
title: "ITDR Microsoft - Réponse manuelle, isoler une identité compromise"
date: 2026-08-14 09:00:00 +02:00
layout: post
tags: [series:itdr-microsoft, incident-response, runbook]
categories: [identite, securite]
readtime: true
comments: true
cover-img: "assets/img/banners/banner-itdr.png"
thumbnail-img: "assets/img/posts/series/itdr-microsoft/130/130-thumb.png"
series: ITDR
series_order: 130
sidebar: true
level: opérationnel
scope:
  - Réponse incident
  - Containment
  - Forensic
platform: Microsoft Security
---

> Squelette de travail. À développer.

## Intention de l'article

Runbook opérationnel pour isoler une identité compromise quand l'automatisation ne s'applique pas. Pour les comptes à privilèges et les cas complexes.

## Points à couvrir

- Phase 1, containment immédiat : disable user, revoke refresh tokens, revoke MDCA sessions, block Conditional Access.
- Phase 2, perte d'accès : reset password, retirer MFA methods, retirer Authentication Methods enregistrées, supprimer FIDO2 / Passkeys / TOTP.
- Phase 3, identité hybride : action côté AD on-prem si compte synchronisé, suspension Entra Connect si nécessaire.
- Phase 4, app et OAuth : révocation des consentements applicatifs, désactivation de service principals créés ou modifiés.
- Phase 5, forensic préliminaire : extraction sign-in logs, audit logs, alerts associés, sauvegarde avant rotation.
- Phase 6, retour utilisateur : nouvelle identité ou réactivation contrôlée. Critères pour choisir.
- Documentation interne : ce qui doit absolument être tracé pour audit et post-mortem.

## Format suggéré

Checklist actionnable en plus du contenu rédigé. Possibilité d'ajouter un script PowerShell d'aide en annexe.
