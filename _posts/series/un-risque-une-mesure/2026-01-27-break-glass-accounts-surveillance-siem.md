---
title: "S’enfermer dehors : le risque du lockout et la stratégie brise-glace"
date: 2026-01-26 21:08:00 +01:00
layout: post
tags: [series:un-risque-une-mesure, entra-id, break-glass, emergency-access, sentinel, monitoring]
categories: [identite, entra-id]
readtime: true
comments: true
cover-img: "assets/img/posts/series/un-risque-une-mesure/2026-01-26-break-glass-fail-oups-la-boulette.png"
thumbnail-img: "assets/img/posts/series/un-risque-une-mesure/2026-01-27-break-glass-accounts-surveillance-siem.png"
series: R1M
series_order: 080
sidebar: true
level: sécurité opérationnelle
scope:
  - Entra ID
  - Comptes d'urgence
  - Monitoring SIEM
  - Résilience
---

> 💡 **En sécurité, la disponibilité est une propriété de sécurité à part entière.**  
> Une architecture qui empêche toute reprise de contrôle en situation de crise ne renforce pas la sécurité, elle la fragilise.

Dans Microsoft Entra ID, nous empilons volontairement des mécanismes de protection de plus en plus stricts. Accès conditionnel, MFA résistante au phishing, authentification forte, conformité des postes, PIM, Token Protection. Cette approche est saine et nécessaire.

Mais elle introduit un risque rarement traité frontalement : celui de s’exclure soi-même du tenant au moment où l’accès est le plus critique.

Une erreur de configuration, une dépendance technique indisponible ou une panne de service peuvent suffire à rendre l’administration impossible. Non pas parce qu’un attaquant a pris la main, mais parce que plus personne ne peut intervenir.

## Le risque : le lockout administratif

Le risque ici n’est pas l’intrusion, mais l’exclusion.

Dans un modèle centré sur l’identité, l’accès aux fonctions d’administration dépend d’un enchaînement de services et de contrôles. Si l’un d’eux devient indisponible ou mal configuré, l’accès peut être bloqué pour tous les administrateurs simultanément.

Les scénarios sont connus et documentés :
- une politique d’accès conditionnel mal ciblée qui bloque tous les utilisateurs, administrateurs inclus,
- une dépendance forte à un service MFA temporairement indisponible,
- une fédération (ADFS, fournisseur tiers) compromise ou hors service,
- un durcissement excessif appliqué sans compte de secours.

Dans ces situations, Microsoft impose une procédure de récupération externe, lourde et volontairement lente. C’est normal du point de vue de la sécurité globale, mais incompatible avec une gestion de crise opérationnelle.

## Le paradoxe de la sécurité moderne

Plus un environnement est durci, plus il devient dépendant de ses mécanismes de protection.

Chaque couche ajoutée renforce la posture globale, mais augmente aussi le nombre de points de défaillance possibles. MFA, conformité du poste, réseau, identité fédérée, clés matérielles. Chacun de ces éléments est un atout en temps normal, et un risque en situation exceptionnelle.

Sans stratégie explicite de reprise d’accès, l’architecture Zero Trust peut se transformer en point de blocage total.

## La mesure : créer une identité réellement indépendante

La réponse ne consiste pas à créer “un compte admin de plus”.  
Elle consiste à concevoir une identité qui reste accessible quand tout le reste échoue.

Un compte brise-glace n’est pas un compte opérationnel. C’est un mécanisme de résilience. Il doit pouvoir fonctionner indépendamment de l’architecture standard du tenant.

### Architecture du compte brise-glace

Un compte brise-glace respecte quelques principes stricts :

- **Cloud-only** : jamais synchronisé depuis l’Active Directory on-premise.
- **Domaine `onmicrosoft.com`** : aucune dépendance au DNS ou à la fédération.
- **Deux comptes** : pour éviter un point de défaillance unique, sans multiplier les accès sensibles.
- **Rôle Global Administrator permanent** : aucun recours à PIM. Si PIM est indisponible, le compte doit rester utilisable.

Ce compte doit être pensé comme un outil de secours, pas comme une identité humaine.

## Authentification : le point de tension assumé

Pour être utilisable lorsque le MFA Azure ou l’accès conditionnel sont défaillants, le compte brise-glace doit être explicitement exclu de ces mécanismes.

Ce choix est volontairement inconfortable. Il va à l’encontre des bonnes pratiques usuelles, mais il répond à un objectif précis : garantir l’accès en situation de crise.

Deux options sont réalistes :
- un mot de passe extrêmement long, aléatoire, stocké physiquement et séparé en plusieurs parties,
- ou une clé matérielle FIDO2, à condition que son usage ne dépende d’aucune politique d’accès conditionnel.

![Breakglass - FIDO2 protected account](/assets/img/posts/series/un-risque-une-mesure/2026-01-26-fido2-break-glass.png)

### Enrôler une clé FIDO2 sur un compte exclu

L’enrôlement se fait en dehors de toute logique d’accès conditionnel, mais nécessite que la méthode FIDO2 soit activée au niveau du tenant.

- **Activation tenant** :  
  *Entra ID > Protection > Authentication methods > Policies > FIDO2 Security Key*

- **Ciblage** :  
  Le compte brise-glace doit être explicitement inclus dans la portée de la méthode.

- **Enrôlement utilisateur** :  
  Via `https://mysignins.microsoft.com/security-info`, une seule fois, en environnement contrôlé.

Le test de connexion est indispensable. Tant que la clé n’a pas été testée dans un navigateur vierge, le compte ne peut pas être considéré comme opérationnel.

## Exclusion explicite de l’accès conditionnel

Le compte brise-glace doit être exclu de toutes les politiques d’accès conditionnel, sans exception.

Pas de filtrage géographique, pas d’exigence de poste conforme, pas de MFA conditionnel. Si une seule politique l’impacte, le compte perd sa raison d’être.

Cette exclusion doit être documentée, visible et régulièrement vérifiée.

## La contrepartie obligatoire : surveillance maximale

Un compte Global Administrator permanent, exclu du MFA et de l’accès conditionnel, constitue une cible critique.

La seule manière acceptable de compenser ce risque est la surveillance en temps réel.

Toute activité sur un compte brise-glace doit être considérée comme un incident de sécurité jusqu’à preuve du contraire.

### Ce qui doit déclencher une alerte critique

- toute tentative de connexion, réussie ou échouée,
- toute modification du compte,
- toute action d’administration réalisée avec ce compte.

![Breakglass login - SOC alert](/assets/img/posts/series/un-risque-une-mesure/2026-01-26-soc-breakglass-account-activity.png)

Ces événements doivent générer une alerte immédiate dans le SIEM, avec un délai de réaction de quelques minutes, pas de quelques heures.

## Gouvernance : tester avant d’en avoir besoin

Un compte d’urgence non testé est un compte inutile.

La recommandation est simple : simuler une crise à intervalles réguliers.

- ouvrir le coffre,
- utiliser le compte,
- vérifier l’accès réel au portail,
- confirmer la réception de l’alerte SOC,
- effectuer une rotation du secret ou de la clé.

Cet exercice doit être documenté. Il fait partie intégrante de la posture de sécurité.

## Conclusion

Les comptes brise-glace ne sont pas une option. Ils sont une assurance.

Ils ne doivent pas être “sécurisés comme les autres”, mais pensés pour fonctionner quand les autres échouent. Leur sécurité repose moins sur l’empilement de contrôles techniques que sur trois principes simples : indépendance, protection physique et surveillance constante.

Le jour où vous serez réellement enfermé dehors, ces comptes ne seront pas un luxe. Ils seront votre seule porte d’entrée.
