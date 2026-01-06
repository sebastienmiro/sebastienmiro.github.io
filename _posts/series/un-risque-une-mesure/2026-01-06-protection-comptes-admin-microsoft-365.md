---
title: "Comptes à privilèges : pourquoi les protéger comme les autres ne suffit pas"
date: 2026-01-06 08:00:00 +01:00
layout: post
tags: [series:un-risque-une-mesure, entra-id, privileged-access, pim, just-in-time, tiering-model]
categories: [identite, entra-id]
readtime: true
comments: true
cover-img: "assets/img/banners/banner1.png"
thumbnail-img: "assets/img/posts/series/un-risque-une-mesure/2026-01-06-entra-id-privileged-accounts.png"
series: R1M
series_order: 050
sidebar: true
level: sécurité opérationnelle
scope:
  - Entra ID
  - Privileged Identity Management (PIM)
  - Modèle de Tiering
  - Sécurité de l’identité
---

> 💡 **Un compte à privilèges n’est pas un utilisateur avec plus de droits.
> 
> C’est un point de contrôle critique pour l’ensemble du tenant.**

Dans Microsoft 365, la protection des comptes à privilèges commence — et s’arrête souvent — au moment de l’authentification : MFA généralisée, parfois renforcée pour les administrateurs, éventuellement couplée à une exigence de conformité du poste. Sur le papier, le dispositif semble solide.

Pourtant, cette approche repose sur une hypothèse fragile : qu’un compte à privilèges serait avant tout un utilisateur « comme les autres », simplement doté de droits supplémentaires.  
Dans les faits, ce n’est pas le cas.

Un compte à privilèges n’est pas seulement un compte utilisateur puissant. C’est un point de contrôle capable de modifier les règles de sécurité, d’altérer les mécanismes de défense et, dans certains cas, de rendre invisibles les actions qui suivent. Le risque ne tient donc pas uniquement à *la manière dont l’administrateur se connecte*, mais à *la permanence de son pouvoir*.

## Le risque structurel : l’accès permanent

Dans beaucoup de tenants, le modèle dominant reste celui de l’accès permanent, ou *standing access*.  
Un administrateur global, Exchange ou Security détient ses privilèges en continu, indépendamment de l’usage réel qu’il en fait.

Qu’il soit en train d’exécuter une opération critique un mardi matin, de consulter ses mails personnels à la pause déjeuner, en déplacement à l’étranger ou simplement inactif le week-end, le niveau de privilège reste strictement identique. Le rôle est attaché à l’identité de manière statique.

![Microsoft 365 - Standing access](/assets/img/posts/series/un-risque-une-mesure/2026-01-06-microsoft-admins-standing-privileges.png)

Dans un environnement cloud, cette situation est particulièrement problématique.  
Si ce compte est compromis — par phishing, vol de token ou malware sur le poste — l’attaquant n’a pas besoin d’escalader quoi que ce soit. Il hérite immédiatement de l’intégralité des privilèges. La compromission d’une identité devient mécaniquement une compromission du tenant.

La surface d’attaque n’est plus technique, elle est temporelle : tant que le privilège existe, il peut être exploité.

## Une hygiène d’architecture souvent négligée : séparer les identités

Avant même de parler d’outils, la première mesure est architecturale.  
Elle consiste à accepter un principe simple : **une même identité ne peut pas être à la fois exposée et privilégiée**.

Ce principe, bien connu dans les modèles de *tiering* hérités d’Active Directory, reste parfaitement valide dans le cloud.

Le compte de productivité — celui utilisé pour Teams, Outlook, le web et les outils collaboratifs — est, par nature, fortement exposé. Il reçoit des mails externes, navigue sur Internet et constitue une cible idéale pour le phishing. Lui confier des rôles d’administration revient à étendre cette surface d’attaque à l’ensemble du système.

À l’inverse, le compte d’administration doit être pensé comme un outil d’exploitation, pas comme une identité du quotidien.
Il est distinct du compte de productivité, idéalement cloud-only et non synchronisé depuis l’Active Directory local, afin d’éviter toute propagation de compromission depuis l’on-premise. Il n’a pas vocation à être utilisé comme un compte de messagerie classique. 
Idéalement, les alertes et notifications de sécurité devraient être centralisées via des canaux dédiés (DL sécurité, SIEM, ITSM), afin de réduire la surface d’attaque liée au phishing. Dans la pratique, l’objectif reste le même : limiter au maximum les usages non strictement nécessaires.

À ces deux catégories s’ajoutent les comptes dits *brise-glace*. Leur rôle n’est pas opérationnel, mais résilient. Ils existent pour les situations de crise absolue : erreur de configuration bloquant tout le tenant, incident majeur... Leur protection repose moins sur l’automatisation que sur des mesures organisationnelles strictes : mots de passe complexes conservés hors ligne, exclusion explicite des politiques d’accès conditionnel et surveillance renforcée de chaque authentification.

## Le cœur du problème : la permanence du privilège

Même avec une séparation correcte des comptes, le problème principal demeure tant que le privilège est permanent.  
Un administrateur qui détient ses droits 24 heures sur 24 reste une cible à haute valeur, même lorsqu’il n’administre rien.

C’est précisément ce point que Microsoft adresse avec **Microsoft Entra Privileged Identity Management (PIM)**.

## Microsoft Entra PIM : transformer le privilège en événement

Privileged Identity Management ne cherche pas à “renforcer” l’authentification existante. Son apport est ailleurs. Il agit sur la nature même du privilège et sur la manière dont celui-ci est exercé dans le temps.

Dans un modèle basé sur PIM, un administrateur n’est plus détenteur permanent d’un rôle. Il y est éligible. Par défaut, son compte ne dispose d’aucun droit d’administration actif. Il peut s’authentifier, accéder aux portails, mais il n’a pas la capacité d’agir tant qu’il n’a pas explicitement demandé une élévation.

Lorsqu’une action administrative est nécessaire, cette élévation doit être formulée comme une intention claire : activer un rôle précis, pour une durée limitée, avec une justification. Cette demande déclenche alors un contrôle renforcé — typiquement une authentification forte — indépendamment du fait que l’utilisateur se soit déjà connecté auparavant. Le privilège n’est accordé que dans ce cadre strict, et pour un temps borné.

À l’issue de cette période, le rôle est retiré automatiquement, sans action manuelle. Le compte revient à son état initial, dépourvu de tout privilège actif.

Ce changement n’est pas cosmétique. Il modifie profondément le modèle de risque. Le privilège cesse d’être un état permanent attaché à une identité ; il devient un événement ponctuel, traçable et réversible.

D’un point de vue défensif, l’effet est immédiat. Un attaquant qui compromet un compte administrateur en dehors d’une fenêtre d’activation ne récupère aucun pouvoir exploitable. Pour aller plus loin, il lui faudrait initier une élévation, franchir un contrôle MFA supplémentaire et générer des événements d’audit explicites — autant de signaux qui transforment une compromission silencieuse en tentative détectable.

## Durcir l’activation : authentification et poste

Le Just-In-Time réduit la fenêtre d’exposition, mais il ne supprime pas le risque pendant la période d’activation.  
C’est pourquoi PIM doit être combiné à des exigences d’accès spécifiques pour les rôles sensibles.

Sur le plan de l’authentification, Microsoft recommande explicitement l’usage de méthodes résistantes au phishing pour les rôles critiques : clés FIDO2 ou Windows Hello for Business. Les notifications push ou les codes SMS, acceptables pour des utilisateurs standards, ne sont plus adaptées à des comptes capables de modifier les règles du tenant.

Sur le plan du poste, l’administration depuis un environnement non maîtrisé constitue un risque majeur. Les politiques d’accès conditionnel doivent imposer un appareil conforme, géré par Intune, voire une station dédiée à l’administration dans les environnements les plus sensibles. Administrer depuis un poste utilisé pour la messagerie ou la navigation web revient à mélanger deux surfaces d’attaque incompatibles.

## Gouvernance : contrôler la légitimité dans le temps
La dernière dimension, souvent négligée, est celle de la gouvernance.
Dans les grands environnements, le risque prend souvent la forme d’une accumulation progressive des droits : un administrateur change d’équipe, conserve ses anciens rôles et en acquiert de nouveaux, sans remise en question formelle. Dans les PME, la situation est différente, mais pas moins risquée.

On y observe fréquemment des comptes administrateurs laissés à l’abandon, des rôles attribués “temporairement” qui deviennent permanents, ou des utilisateurs qui ne sont ni administrateurs de métier ni formés aux enjeux de sécurité, mais qui se retrouvent avec des privilèges étendus — parfois même des rôles de type Global Administrator. Non par malveillance, mais à la suite de décisions prises dans l’urgence, de contraintes de temps ou simplement faute de cadre clair pour attribuer, limiter et retirer ces droits.

Dans ces contextes, le problème n’est pas tant la sophistication des attaques que la banalisation du privilège.

Les revues d’accès intégrées à PIM permettent précisément de remettre de l’ordre dans cette réalité. À intervalle régulier, chaque rôle éligible doit être explicitement reconfirmé, soit par l’administrateur concerné, soit par son responsable. En l’absence de validation, l’éligibilité est retirée automatiquement.

Ce mécanisme introduit une discipline là où il n’y en avait pas. Il oblige à se poser une question simple, mais rarement formulée : cette personne a-t-elle encore besoin de ce privilège aujourd’hui ? La gestion des comptes à privilèges cesse alors d’être une accumulation historique pour devenir un processus vivant, aligné sur l’organisation réelle — qu’elle soit grande, petite ou très peu structurée.

## En filigrane : un changement de mentalité

Protéger les comptes à privilèges ne consiste pas à empiler des contrôles autour d’un modèle inchangé.  
Cela implique de reconnaître que le privilège est, en soi, un risque systémique.

Tant que l’administration reste un état permanent, chaque compromission d’identité porte en elle le potentiel d’un incident majeur.  
Le modèle Just-In-Time, rendu opérationnel par PIM, associé à une séparation stricte des identités et à un durcissement contextuel de l’accès, constitue aujourd’hui la seule réponse structurelle cohérente face aux menaces modernes.

Dans le prochain épisode, nous quitterons le monde des utilisateurs humains pour nous intéresser à des identités plus discrètes, mais tout aussi critiques : **les identités applicatives et les comptes de service**, souvent dotés de privilèges permanents sans véritable supervision.
