---
title: "Conditional Access Framework v4 — Le socle commun de politiques"
date: 2026-01-02 08:00:00 +01:00
layout: post
tags: [series:conditional-access-framework, baseline, conditional-access]
categories: [identite, entra-id]
readtime: true
comments: true
cover-img: "assets/img/banners/banner-conditional-access.png"
thumbnail-img: "assets/img/posts/series/conditional-access-framework/020/020-thumb.png"
series: Conditional Access Framework
series_order: 020
sidebar: true
level: concepts
scope:
  - Entra ID
  - Conditional Access
  - Politiques globales
platform: Microsoft Entra
---

Après avoir posé les personas, le Conditional Access Framework v4 introduit un ensemble de politiques transverses, souvent regroupées sous le terme de *socle commun*. Ce choix n’est pas organisationnel. Il est avant tout technique.

Dans de nombreux environnements, l’accès conditionnel est construit presque exclusivement par exception : une règle pour les administrateurs, une autre pour les invités, une autre encore pour un besoin ponctuel. Cette approche repose implicitement sur une hypothèse risquée : que tout ce qui n’est pas explicitement couvert est acceptable par défaut.

Le framework adopte une logique inverse. Avant toute spécialisation par persona, il définit un ensemble de règles destinées à s’appliquer **dans la majorité des cas**, indépendamment du profil de l’identité. Ce socle n’a pas vocation à couvrir tous les usages. Il vise à traiter ce qui ne devrait jamais dépendre d’un oubli ou d’un périmètre mal défini.

## Ce que couvre réellement le socle commun

Le socle commun regroupe des politiques qui répondent à une logique simple : éliminer les angles morts évidents avant toute différenciation des usages.

On y retrouve notamment :
- le blocage des méthodes d’authentification legacy ;
- l’imposition d’un socle d’authentification moderne cohérent ;
- des conditions d’accès globales servant de garde-fou transversal.

Ces règles ne cherchent pas à être fines ni adaptées à des cas particuliers. Elles sont conçues pour **s’appliquer lorsque aucune politique plus spécifique ne prend le relais**.

Dans le Conditional Access Framework v4, le socle n’est donc pas une “baseline de sécurité” au sens générique. Il définit un ensemble de conditions minimales, sans lesquelles les politiques spécialisées perdent une partie de leur efficacité.

## Un rôle double : structurer le modèle et couvrir les oublis

Le socle commun remplit deux fonctions distinctes, qui expliquent souvent les malentendus à son sujet.

Sur le plan du modèle, il structure le framework. Il permet d’éviter que chaque bloc de politiques repose sur ses propres hypothèses implicites. Les règles spécialisées s’appuient ainsi sur un socle partagé, ce qui rend l’ensemble plus lisible et plus cohérent.

Sur le plan opérationnel, le socle agit comme un **mécanisme de protection par défaut**. Il intervient lorsque :
- une politique dédiée n’existe pas encore ;
- un périmètre a été oublié ;
- un usage réel n’a pas été anticipé lors de la conception initiale.

Le socle n’est donc pas destiné à piloter les usages nominaux. Il est là pour éviter qu’un accès non prévu ne se fasse sans aucun contrôle.

## Pourquoi ce socle est souvent mal positionné sur le terrain

Dans la pratique, le socle commun est fréquemment introduit au mauvais moment.

Dans certains environnements, il est ajouté tardivement, une fois que de nombreuses règles ciblées existent déjà. Les politiques globales entrent alors en conflit avec des exceptions en place, ce qui conduit à multiplier les exclusions et à fragiliser l’ensemble.

À l’inverse, d’autres déploient un socle très strict sans avoir clarifié les personas ni préparé les usages. Les effets sont immédiats : blocages, contournements et pression pour assouplir les règles sans compréhension claire de leur rôle.

Le framework est pourtant explicite dans sa logique : **le socle doit précéder la spécialisation**, pas l’inverse.

## Un périmètre volontairement large, mais pas aveugle

Même s’il est transversal, le socle commun n’a pas vocation à s’appliquer indistinctement à toutes les identités.

Certains comptes — notamment les comptes de secours ou certaines identités techniques — doivent en être explicitement exclus. Non pas parce qu’ils seraient moins sensibles, mais parce que leur fonction impose des contraintes différentes.

Le framework ne cherche pas à éliminer les exceptions. Il cherche à les rendre **visibles, intentionnelles et justifiées**.

Une exclusion conçue et documentée fait partie du cadre.  
Une exclusion ajoutée en urgence pour contourner un blocage en est déjà une dérive.

## Ce que le socle ne cherche volontairement pas à traiter

Le socle commun ne gère pas les privilèges.  
Il ne corrige pas un modèle d’accès trop permissif.  
Il ne remplace ni la gouvernance des identités, ni la gestion des rôles.

Il ne protège pas non plus contre des attaques ciblées ou l’exploitation avancée d’une session compromise. Ces scénarios relèvent des politiques spécialisées du framework.

Son rôle est volontairement limité : **éviter qu’un oubli structurel ou un périmètre mal défini ne se traduise par un accès trivial**.

C’est aussi pour cette raison que le framework v4 reste sobre sur ce socle. Une granularité excessive à ce niveau rendrait l’ensemble plus fragile, sans bénéfice réel.

## Le socle comme prérequis implicite du reste du framework

Toutes les politiques qui suivent — utilisateurs standards, comptes à privilèges, invités, workloads — reposent implicitement sur ce socle commun.

Lorsqu’il est correctement positionné, il réduit le besoin d’exceptions et simplifie la lecture des règles spécialisées. Lorsqu’il est absent ou mal conçu, chaque nouvelle politique devient une tentative de compensation, avec un risque croissant d’incohérence.

C’est précisément parce qu’il est peu visible que ce socle est structurant.

## Conclusion

Le socle commun de politiques est l’un des éléments les moins spectaculaires du Conditional Access Framework v4, mais aussi l’un des plus déterminants.

Il ne cherche ni à tout couvrir ni à tout contrôler.  
Il structure le modèle et protège contre l’oubli.

Bien positionné, il permet aux politiques spécialisées de fonctionner comme prévu. Mal compris, il devient une source de friction et de contournements.

Dans la suite de la série, les politiques destinées aux utilisateurs standards et aux comptes à privilèges s’appuieront directement sur ce socle, qui conditionne leur efficacité réelle.
