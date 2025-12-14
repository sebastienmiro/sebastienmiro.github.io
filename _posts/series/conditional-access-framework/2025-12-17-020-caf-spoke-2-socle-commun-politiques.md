---
title: "Conditional Access Framework v4 — Le socle commun de politiques"
date: 2026-10-08 09:00:00 +01:00
layout: post
tags: [series:conditional-access-framework, baseline, conditional-access]
categories: [identite, entra-id]
readtime: true
comments: true
cover-img: "assets/img/banners/banner-conditional-access-baseline.png"
thumbnail-img: "assets/img/posts/series/conditional-access-framework/020/020-thumb.png"
series: CA
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

Après avoir posé les personas, le Conditional Access Framework v4 introduit un ensemble de politiques transverses, souvent désignées comme le *socle commun*. Ce choix n’est pas organisationnel, il est technique.

Dans de nombreux environnements, l’accès conditionnel est construit exclusivement par exception : une règle pour les admins, une autre pour les invités, une autre pour un cas métier particulier. Ce fonctionnement donne l’illusion de la maîtrise, mais il repose sur une hypothèse fragile : que tout ce qui n’est pas explicitement traité est acceptable par défaut.

Le framework prend le problème dans l’autre sens. Avant de spécialiser les règles par persona, il définit ce qui doit s’appliquer **presque partout**, indépendamment du profil de l’identité. Ce socle n’est pas là pour être exhaustif, mais pour éliminer les scénarios les plus évidents et les plus reproductibles.

## Ce que couvre réellement le socle commun

Le socle commun regroupe des politiques qui répondent à une même logique : réduire le bruit et supprimer les angles morts les plus grossiers avant toute différenciation des usages.

On y retrouve notamment tout ce qui concerne l’élimination des méthodes d’authentification héritées, l’imposition d’un niveau minimal d’authentification moderne et la définition de conditions d’accès globales cohérentes. Ces règles ne cherchent pas à être fines. Elles cherchent à être **incontournables**.

Dans le framework, ce socle n’est pas pensé comme une “baseline de sécurité” au sens marketing du terme. Il constitue plutôt une **ligne de flottaison** : en dessous, le risque devient trop élevé pour que les politiques plus spécifiques aient un réel impact.

## Pourquoi ce socle est souvent mal déployé

Sur le terrain, ce socle est soit déployé trop tard, soit mal positionné.

Dans certains environnements, on commence par créer des règles ciblées, puis on ajoute un socle global pour “compléter”. Le résultat est souvent contre-productif : les règles globales entrent en conflit avec des exceptions existantes, ce qui conduit à multiplier les exclusions et à fragiliser l’ensemble.

À l’inverse, d’autres déploient un socle très strict sans avoir clarifié les personas ni préparé les usages. Là encore, l’effet est immédiat : blocages, contournements, et pression pour assouplir les règles sans réelle compréhension de leur rôle.

Le framework insiste implicitement sur un point simple : **le socle doit précéder la spécialisation**, pas l’inverse.

## Le socle commun n’est pas un “one size fits all”

Même s’il est transversal, le socle commun n’a pas vocation à s’appliquer aveuglément à toutes les identités.

Certains comptes — en particulier les comptes de secours ou certaines identités techniques — doivent en être explicitement exclus, non pas parce qu’ils sont moins sensibles, mais parce que leur rôle est différent. Le framework ne cherche pas à nier ces exceptions, il cherche à les rendre visibles et intentionnelles.

C’est une distinction importante. Une exclusion pensée et documentée fait partie du cadre. Une exclusion ajoutée en urgence pour “faire passer” une règle en est déjà une dérive.

## Ce que le socle ne cherche volontairement pas à faire

Le socle commun ne règle pas la question des privilèges. Il ne corrige pas un modèle d’accès trop permissif. Il ne remplace pas une gouvernance des identités ou des rôles.

Il ne protège pas non plus contre des attaques ciblées, ni contre l’exploitation fine d’une session compromise. Son rôle est plus modeste, mais essentiel : **nettoyer le terrain** pour que les politiques plus spécifiques aient un effet réel.

C’est pour cette raison que le framework ne multiplie pas les règles dans ce socle. Trop de granularité à ce stade serait contre-productive et rendrait l’ensemble plus fragile.

## Le socle comme fondation du reste du framework

Toutes les politiques qui suivent — qu’elles soient destinées aux utilisateurs standards, aux administrateurs, aux invités ou aux workloads — reposent implicitement sur ce socle commun.

Lorsqu’il est correctement posé, il simplifie la lecture des règles spécialisées et limite le besoin d’exceptions. Lorsqu’il est absent ou mal conçu, chaque nouvelle politique devient une tentative de compensation, avec un risque croissant d’incohérence.

C’est aussi pour cette raison que le framework v4 reste relativement sobre sur ce socle : il doit être **stable dans le temps**, compréhensible et rarement modifié.

## Conclusion

Le socle commun de politiques est probablement la partie la moins visible du Conditional Access Framework v4, mais aussi l’une des plus structurantes. Il ne fait pas tout, et il n’est pas là pour être spectaculaire.

Bien posé, il réduit immédiatement une large part des risques génériques et prépare le terrain pour les politiques plus spécifiques. Mal compris ou mal positionné, il devient une source de friction permanente.

Dans la suite de la série, les politiques destinées aux utilisateurs standards et aux comptes à privilèges s’appuieront directement sur ce socle, qui conditionne leur efficacité réelle.
