---
title: "Sessions persistantes : quand l’accès ne s’arrête jamais vraiment"
date: 2025-12-30 11:00:00 +01:00
layout: post
tags: [series:un-risque-une-mesure, entra-id, sessions, conditional-access, token]
categories: [identite, entra-id]
readtime: true
comments: true
cover-img: "assets/img/banners/banner2.png"
thumbnail-img: "assets/img/posts/series/un-risque-une-mesure/2025-12-30-entra-id-session-persistante-sign-in-frequency.png"
series: R1M
series_order: 040
sidebar: true
level: concepts
scope:
  - Entra ID
  - Sessions
  - Conditional Access
  - Sécurité de l’identité
---

💡 **Une session ouverte, c’est une confiance accordée.  
Le problème, ce n’est pas qu’on l’accorde… c’est qu’on oublie souvent de la reprendre.**

Dans beaucoup d’environnements Microsoft Entra ID, l’authentification est solidement verrouillée. MFA généralisée, méthodes modernes, accès conditionnel en place, parfois même Token Protection activée. Sur le papier, tout est là.

Et pourtant, dans les incidents réels, l’attaquant n’a souvent rien à casser. Il n’a pas besoin de contourner la MFA, ni de rejouer un mot de passe. Il arrive après. Dans une session déjà ouverte. Encore valide. Toujours acceptée.

La sécurité de l’identité ne s’arrête pas au login. Elle commence souvent là où on cesse de regarder.

## Le risque : confondre authentification réussie et accès légitime durable

L’erreur est subtile, mais répandue. Une fois l’utilisateur authentifié, on considère implicitement que l’accès reste légitime tant que le token n’a pas expiré. Cette logique est héritée de modèles anciens, pensés pour des réseaux fermés, des postes fixes et des menaces peu mobiles.

Dans le cloud, ce raisonnement ne tient plus.

Une session est une **délégation de confiance dans le temps**. Elle autorise l’accès sans redemander de preuve, parfois pendant des heures, parfois pendant des jours. Tant que le token est valide, Entra ID ne remet pas en question la légitimité de l’accès, même si le contexte a radicalement changé.

C’est là que se loge le risque.

## Ce qu’est réellement une session dans Entra ID

Lorsqu’un utilisateur s’authentifie, Entra ID ne valide pas chaque action. Il émet des jetons — access tokens, refresh tokens — qui servent de laissez-passer. Ces jetons portent une durée de vie, souvent généreuse, et sont acceptés tant qu’ils respectent leurs critères de validité.

Une fois la session établie, la MFA n’est plus sollicitée.  
Le système ne se demande plus *qui* est l’utilisateur, mais uniquement *si le token présenté est valide*.

C’est un choix d’architecture. Et comme tout choix d’architecture, il a des conséquences.

Derrière cette continuité d’accès se trouvent des mécanismes largement transparents pour l’utilisateur, comme les tokens de session et le Primary Refresh Token (PRT), qui permettent à Entra ID de renouveler l’accès sans redemander d’authentification tant que certaines conditions sont remplies.

## Pourquoi les attaquants adorent les sessions longues

Dans les attaques modernes, l’objectif n’est plus nécessairement d’entrer. C’est de **rester**.

Une session persistante permet :
- de naviguer librement dans Microsoft 365,
- de créer des règles de persistance,
- d’accéder aux données sans bruit,
- parfois même de survivre à un changement de mot de passe.

Dans ce contexte, une session de 14 ou 30 jours n’est pas un confort utilisateur. C’est une fenêtre d’opportunité.

## Le faux sentiment de contrôle

Beaucoup d’organisations ont le sentiment de maîtriser ce risque. Après tout, les tokens expirent. Les utilisateurs se reconnectent. Les mots de passe changent.

En réalité, la durée de vie des sessions est rarement interrogée. Les paramètres par défaut sont conservés, les contrôles de session sont absents ou mal compris, et l’accès conditionnel est utilisé principalement comme un filtre d’entrée.

Le raisonnement est souvent le suivant :  
*“Si l’utilisateur est authentifié, c’est qu’il est légitime.”*

C’est précisément ce postulat que les attaques exploitent.

## Quand une session devient dangereuse

Une session ouverte peut devenir problématique dans de nombreux scénarios :  
un poste compromis après authentification, un jeton extrait depuis un navigateur, un accès depuis un pays inhabituel, une élévation de privilèges, ou simplement un compte révoqué trop tard.

Sans mécanisme de remise en question, Entra ID continue d’accepter la session. Le contexte a changé, mais la confiance, elle, reste intacte.

## La mesure : reprendre le contrôle des sessions

La réponse ne consiste pas à raccourcir arbitrairement toutes les sessions. Elle consiste à **conditionner la durée de la confiance** et à la réévaluer en continu.

Microsoft fournit plusieurs leviers, souvent mal compris ou sous-utilisés.

## Sign-in Frequency : limiter la durée de confiance

Le paramètre *Sign-in Frequency* permet d’imposer une réauthentification après un certain temps, indépendamment de la validité du token. C’est un outil simple, mais structurant.

Il ne remet pas en cause chaque requête. Il impose une borne temporelle claire : passé ce délai, l’utilisateur devra prouver à nouveau son identité.

Mal utilisé, il dégrade l’expérience utilisateur.  
Bien ciblé, il réduit drastiquement la fenêtre d’exploitation d’une session compromise.

![Conditional Access – Sign-in Frequency](/assets/img/posts/2025/12/conditional-access-signin-frequency.png)

🔗 Documentation Microsoft :  
https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-session-controls

## Continuous Access Evaluation : remettre le contexte au centre

La *Continuous Access Evaluation* (CAE) marque un changement plus profond. Elle permet à Entra ID de réévaluer une session **après l’authentification**, en fonction d’événements de sécurité.

Changement de mot de passe, révocation de compte, modification de privilèges, signal de risque élevé : la session peut être invalidée sans attendre son expiration naturelle.

Ce n’est plus une sécurité statique. C’est une sécurité réactive.

![Continuous Access Evaluation overview](/assets/img/posts/2025/12/continuous-access-evaluation.png)

🔗 Documentation Microsoft :  
https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-continuous-access-evaluation

## Les limites à connaître

Tous les clients ne supportent pas CAE. Tous les scénarios ne sont pas couverts. Et surtout, CAE ne remplace pas une stratégie de session cohérente.

C’est un filet supplémentaire, pas une excuse pour laisser des sessions ouvertes indéfiniment.

## Gouvernance : la durée de confiance est un choix

La gestion des sessions n’est pas qu’un sujet technique. C’est un choix de gouvernance.  
Quelle durée de confiance est acceptable ?  
Quels contextes justifient une réauthentification ?  
Quels signaux doivent invalider un accès ?

Ces questions doivent être posées explicitement. Sans réponse claire, la configuration devient arbitraire. Et l’arbitraire est l’ennemi de la sécurité.

## Ce qu’on observe sur le terrain

Dans de nombreux tenants, Token Protection est activée, la MFA est robuste, mais les sessions durent toujours plusieurs semaines. L’attaquant n’a plus besoin de voler un token. Il lui suffit d’arriver pendant la fenêtre de validité.

La sécurité est solide à l’entrée. Elle est laxiste dans la durée.

## À retenir

Une session est une délégation de confiance.  
Une confiance sans limite temporelle devient un risque.  
La MFA protège l’entrée, pas la durée.  
La sécurité de l’identité se joue aussi après l’authentification.  

Dans le prochain épisode, nous aborderons un autre angle souvent négligé : **les comptes à privilèges**, et pourquoi les protéger “comme les autres” est rarement suffisant.
