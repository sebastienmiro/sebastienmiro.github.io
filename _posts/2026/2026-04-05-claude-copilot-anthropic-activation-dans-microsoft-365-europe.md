---
title: "Non, Claude n'est pas activé par défaut dans Copilot en Europe"
date: 2026-04-05 08:00:00 +01:00
layout: post
categories: [Microsoft 365, Copilot]
tags:
  - Copilot
  - Anthropic
  - Claude
  - RGPD
  - EU Data Boundary
  - sous-traitant
readtime: true
comments: true
sidebar: true
level: Intermédiaire
platform: Microsoft 365
scope: Tenant
cover-img: assets/img/banners/IMG_7802.jpeg
thumbnail-img: assets/img/posts/2026/IMG_7801.jpeg
---

Depuis quelques jours, on voit circuler sur LinkedIn des publications affirmant que "Claude va être activé par défaut dans Microsoft 365 Copilot". Certaines recommandent de désactiver la fonctionnalité au plus vite. Le problème, c'est que ces publications omettent un détail important : cette activation par défaut ne concerne pas les tenants européens.

Rétablissons les faits.

## Ce qui s'est réellement passé

En septembre 2025, Microsoft a introduit les modèles Claude d'Anthropic dans Copilot Studio et l'agent Researcher. A cette époque, l'utilisation de Claude nécessitait un opt-in explicite de l'administrateur du tenant, avec acceptation des conditions commerciales propres à Anthropic. Les Product Terms et le DPA de Microsoft ne s'appliquaient pas.

Le 8 décembre 2025, Microsoft a publié la notification MC1193290 annonçant un changement de modèle contractuel. Anthropic devenait un sous-traitant (subprocessor) de Microsoft, opérant désormais sous le DPA Microsoft et les Product Terms. Un nouveau toggle administrateur est apparu dans le Microsoft 365 Admin Center.

Le 7 janvier 2026, ce nouveau modèle est entré en vigueur. Le toggle legacy a été déprécié.

## Activé par défaut, mais pas partout

Voici la répartition par zone géographique du comportement par défaut du toggle Anthropic :

**Tenants commerciaux hors UE/AELE/Royaume-Uni** : toggle activé par défaut (ON). Claude est disponible dans Copilot dès le 7 janvier 2026 sauf si l'administrateur le désactive.

**Tenants UE, AELE et Royaume-Uni** : toggle désactivé par défaut (OFF). L'administrateur Global Admin doit explicitement activer le toggle pour rendre Claude disponible.

**Tenants GCC, GCC High, DoD et clouds souverains** : Claude n'est pas disponible. Aucun toggle n'apparait dans la console.

En clair : si votre tenant est hébergé dans la zone EU Data Boundary, Claude n'est pas activé. Il ne l'a jamais été automatiquement. Les publications LinkedIn qui affirment le contraire sont factuellement incorrectes.

## Pourquoi l'UE est exclue de l'activation par défaut

La raison est technique et contractuelle. Microsoft le dit explicitement dans sa documentation :

> Les modèles Anthropic déployés dans les offres Microsoft sont actuellement exclus de l'EU Data Boundary et, le cas échéant, des engagements de traitement in-country.

Concrètement, lorsque Claude est utilisé dans Copilot, les données quittent l'infrastructure Azure pour être traitées sur l'infrastructure d'Anthropic, principalement aux Etats-Unis. Même si Anthropic opère sous le DPA Microsoft en tant que sous-traitant, le traitement des données se fait en dehors de l'Union européenne.

Pour un tenant européen, activer Claude revient donc à autoriser un transfert de données personnelles vers les Etats-Unis, avec tout ce que cela implique en matière de RGPD.

## Ce que cela implique côté conformité

L'activation de Claude sur un tenant européen implique un transfert de données vers les Etats-Unis via un nouveau sous-traitant. Ce type de changement relève du DPO et du service juridique de l'organisation. Les points à examiner incluent la couverture du transfert par le DPA Microsoft, la mise à jour du registre des traitements, et l'information des personnes concernées. Ce n'est pas au seul administrateur IT de trancher.

Quelques questions à remonter avant d'activer le toggle :

Le transfert hors UE est-il couvert par le DPA Microsoft pour ce sous-traitant ? Le registre des traitements (ROPA) reflète-t-il ce changement de sous-traitance ? Les utilisateurs concernés sont-ils informés du traitement supplémentaire ? Le DPO a-t-il validé l'activation ?

Le statut de sous-traitant de Microsoft ne dispense pas l'organisation cliente de ses obligations en tant que responsable de traitement.

## Où trouver le toggle et comment le gérer

Le toggle se trouve dans le Microsoft 365 Admin Center :

1. Accédez à **Copilot** puis **Settings**
2. Sélectionnez **Data access**
3. Cliquez sur **AI providers operating as Microsoft subprocessors**
4. Le toggle **Anthropic** apparait avec son état actuel

Si votre tenant est en zone UE/AELE/UK, le toggle est sur OFF par défaut. L'activation nécessite le rôle Global Administrator.

Point important : si vous aviez précédemment activé l'ancien toggle (celui qui liait directement aux conditions Anthropic), il a été déprécié. Vous devez réactiver le nouveau toggle sous-traitant si vous souhaitez continuer à utiliser Claude.

## Quelles fonctionnalités dépendent de Claude

Désactiver Claude (ou ne pas l'activer en Europe) a des conséquences fonctionnelles. Plusieurs expériences Copilot s'appuient sur les modèles Anthropic :

L'agent Researcher utilise Claude Opus pour le raisonnement approfondi sur des requêtes complexes. Copilot Studio permet aux créateurs de sélectionner Claude comme modèle pour leurs agents. Agent Mode dans Excel propose Claude Opus comme option pour les taches analytiques. Les agents Word, Excel et PowerPoint du programme Frontier exploitent les modèles Claude pour la création de contenu itérative.

Sans Claude, ces fonctionnalités basculent sur les modèles OpenAI (GPT-4o) ou deviennent indisponibles selon le contexte.

## Ce qu'il faut retenir

Pour les administrateurs de tenants européens, la situation est claire. Claude n'est pas activé par défaut. Aucune action d'urgence n'est nécessaire. Mais si vous envisagez de l'activer, faites-le en lien avec votre DPO et votre service juridique.

Pour les administrateurs hors UE/AELE/UK, Claude est déjà actif sur votre tenant depuis janvier 2026, sauf si vous l'avez désactivé. Vérifiez le toggle dans le M365 Admin Center.

Et pour tout le monde : méfiez-vous des publications LinkedIn qui mélangent les zones géographiques et transforment un changement de sous-traitance en panique RGPD. La documentation Microsoft est publique et accessible. Lisez-la avant de relayer.

## Ressources

- [Anthropic as a subprocessor for Microsoft Online Services - Microsoft Learn](https://learn.microsoft.com/en-us/microsoft-365/copilot/connect-to-ai-subprocessor)
- [EU Data Boundary - Microsoft Learn](https://learn.microsoft.com/en-us/privacy/eudb/eu-data-boundary-learn)
- [Microsoft Data Protection Addendum (DPA)](https://www.microsoft.com/licensing/docs/view/Microsoft-Products-and-Services-Data-Protection-Addendum-DPA)
