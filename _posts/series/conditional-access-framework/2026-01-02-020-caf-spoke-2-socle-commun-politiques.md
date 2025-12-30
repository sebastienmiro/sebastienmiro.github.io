---
title: "Conditional Access Framework v4 — Le socle commun de politiques"
date: 2026-01-02 09:00:00 +01:00
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

## Pourquoi le framework définit un socle commun

Après avoir posé les personas, le Conditional Access Framework v4 introduit un ensemble de politiques transverses, souvent désignées comme le *socle commun*. Ce choix n’est pas organisationnel. Il est avant tout technique.

Dans de nombreux environnements, l’accès conditionnel est construit presque exclusivement par exception : une règle pour les administrateurs, une autre pour les invités, une autre encore pour un cas métier particulier. Ce fonctionnement donne l’illusion de la maîtrise, mais il repose sur une hypothèse fragile : que tout ce qui n’est pas explicitement couvert est acceptable par défaut.

Le framework prend le problème dans l’autre sens. Avant de spécialiser les règles par persona, il définit ce qui doit s’appliquer **presque partout**, indépendamment du profil de l’identité. Ce socle n’a pas vocation à tout couvrir. Il vise à traiter ce qui ne devrait jamais dépendre d’un oubli ou d’un cas particulier.

## Ce que couvre réellement le socle commun

Le socle commun regroupe des politiques qui répondent à une même logique : réduire le bruit et supprimer les angles morts les plus grossiers avant toute différenciation des usages.

On y retrouve notamment :
- l’élimination des méthodes d’authentification legacy ;
- l’imposition d’un socle d’authentification moderne cohérent ;
- des conditions d’accès globales qui servent de garde-fou.

Ces règles ne cherchent pas à être fines. Elles cherchent à être **incontournables lorsque rien d’autre ne s’applique**.

Dans le Conditional Access Framework v4, le socle n’est pas pensé comme une “baseline de sécurité” au sens marketing du terme. Il joue plutôt le rôle d’une **ligne de flottaison** : en dessous, le risque devient trop élevé pour que les politiques plus spécifiques puissent réellement compenser.

## Pourquoi ce socle est souvent mal déployé

Sur le terrain, ce socle est soit déployé trop tard, soit mal positionné.

Dans certains environnements, on commence par créer des règles ciblées, puis on ajoute un socle global pour “compléter”. Le résultat est souvent contre-productif : les règles globales entrent en conflit avec des exceptions existantes, ce qui conduit à multiplier les exclusions et à fragiliser l’ensemble.

À l’inverse, d’autres déploient un socle très strict sans avoir clarifié les personas ni préparé les usages. Le résultat est immédiat : blocages, contournements, et pression pour assouplir les règles sans réelle compréhension de leur rôle.

Le framework est pourtant clair dans son intention : **le socle doit précéder la spécialisation**, pas l’inverse.

## Le socle commun n’est pas un “one size fits all”

Même s’il est transversal, le socle commun n’a pas vocation à s’appliquer aveuglément à toutes les identités.

Certains comptes — en particulier les comptes de secours ou certaines identités techniques — doivent en être explicitement exclus. Non pas parce qu’ils seraient moins sensibles, mais parce que leur rôle est différent.

Le framework ne cherche pas à supprimer les exceptions. Il cherche à les rendre **visibles, intentionnelles et compréhensibles**.

Une exclusion pensée et documentée fait partie du cadre.  
Une exclusion ajoutée en urgence pour “faire passer” une règle est déjà un signal de dérive.

## Ce que le socle ne cherche volontairement pas à faire

Le socle commun ne règle pas la question des privilèges. Il ne corrige pas un modèle d’accès trop permissif. Il ne remplace pas une gouvernance des identités ou des rôles.

Il ne protège pas non plus contre des attaques ciblées, ni contre l’exploitation fine d’une session compromise. Ces sujets relèvent des blocs spécialisés du framework.

Son rôle est plus modeste, mais essentiel : **éviter qu’un oubli ou un angle mort ne devienne une compromission triviale**.

C’est aussi pour cette raison que le framework v4 reste volontairement sobre sur ce socle. Trop de granularité à ce stade rendrait l’ensemble plus fragile, pas plus sûr.

## Le socle comme fondation implicite du reste du framework

Toutes les politiques qui suivent — qu’elles concernent les utilisateurs standards, les comptes à privilèges, les invités ou les workloads — reposent implicitement sur ce socle commun.

Lorsqu’il est correctement posé, il simplifie la lecture des règles spécialisées et limite le besoin d’exceptions. Lorsqu’il est absent ou mal conçu, chaque nouvelle politique devient une tentative de compensation, avec un risque croissant d’incohérence.

C’est précisément parce qu’il est discret que le socle est critique.

## Conclusion

Le socle commun de politiques est probablement la partie la moins visible du Conditional Access Framework v4, mais aussi l’une des plus structurantes.

Il n’est ni exhaustif, ni spectaculaire.  
Il structure le modèle, et protège contre l’oubli.

Bien positionné, il prépare le terrain pour les politiques spécialisées sans se substituer à elles. Mal compris, il devient une source de friction permanente.

Dans la suite de la série, les politiques destinées aux utilisateurs standards et aux comptes à privilèges s’appuieront directement sur ce socle, qui conditionne leur efficacité réelle.
