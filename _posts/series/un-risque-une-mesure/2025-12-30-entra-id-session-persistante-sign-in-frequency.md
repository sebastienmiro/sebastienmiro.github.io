---
title: "Sessions persistantes : Quand l’accès ne s’arrête jamais vraiment"
date: 2025-12-30 08:00:00 +01:00
layout: post
tags: [series:un-risque-une-mesure, entra-id, sessions, conditional-access, token-theft, cae]
categories: [identite, entra-id]
readtime: true
comments: true
cover-img: "assets/img/banners/banner2.png"
thumbnail-img: "assets/img/posts/series/un-risque-une-mesure/2025-12-30-entra-id-session-persistante-sign-in-frequency.png"
series: R1M
series_order: 040
sidebar: true
level: sécurité opérationnelle
scope:
  - Entra ID
  - Conditional Access
  - Token Theft
  - Continuous Access Evaluation
---

> 💡 **Une session ouverte, c’est une confiance accordée. Le problème, ce n’est pas qu’on l’accorde… c’est qu’on oublie souvent de la reprendre.**

Dans beaucoup d’environnements Microsoft Entra ID, l’authentification est solidement verrouillée. MFA généralisée, méthodes modernes (FIDO2), accès conditionnel en place, parfois même Token Protection activée. Sur le papier, tout est là.

Et pourtant, dans les incidents réels, l’attaquant n’a souvent rien à casser. Il n’a pas besoin de contourner la MFA, ni de rejouer un mot de passe. Il arrive après. Dans une session déjà ouverte. Encore valide. Toujours acceptée.

La sécurité de l’identité ne s’arrête pas au login. Elle commence souvent là où on cesse de regarder.

![Session lifetime](/assets/img/posts/series/un-risque-une-mesure/2025-12-30-token-duration-timeline.png)

## Le risque : confondre authentification réussie et accès légitime durable

L’erreur est subtile, mais répandue. Une fois l’utilisateur authentifié, on considère implicitement que l’accès reste légitime tant que le token n’a pas expiré. Cette logique est héritée de modèles anciens, pensés pour des réseaux fermés, des postes fixes et des menaces peu mobiles.

Dans le cloud, ce raisonnement ne tient plus.

Une session est une **délégation de confiance dans le temps**. Elle autorise l’accès sans redemander de preuve, parfois pendant des heures, parfois pendant des jours (jusqu'à 90 jours par défaut pour le *Rolling Window* d'un Refresh Token). Tant que le token est valide, Entra ID ne remet pas automatiquement en question la légitimité de l’accès, sauf mécanismes explicitement configurés.

C’est là que se loge le risque.

## Ce qu’est réellement une session dans Entra ID

Lorsqu’un utilisateur s’authentifie, Entra ID ne valide pas chaque action. Il émet des jetons — access tokens, refresh tokens, PRT — qui servent de laissez-passer. Ces jetons portent une durée de vie, souvent généreuse, et sont acceptés tant qu’ils respectent leurs critères de validité.

Une fois la session établie, la MFA n’est plus sollicitée.
Le système ne se demande plus *qui* est l’utilisateur, mais uniquement *si le token présenté est valide*.

C’est un choix d’architecture pensé pour le SSO et la résilience. Et comme tout choix d’architecture, il a des conséquences. Derrière cette continuité d’accès se trouvent des mécanismes largement transparents pour l’utilisateur, comme les tokens de session et le Primary Refresh Token (PRT), qui permettent à Entra ID de renouveler l’accès sans redemander d’authentification tant que certaines conditions sont remplies.

## Pourquoi les attaquants adorent les sessions longues

Dans les attaques modernes (notamment via *Infostealers* ou *Adversary-in-the-Middle*), l’objectif n’est plus nécessairement d’entrer par la force. C’est de **rester**.

Une session persistante permet à un attaquant :
- de naviguer librement dans Microsoft 365,
- de créer des règles de persistance (règles de boîte de réception, applications OAuth),
- d’accéder aux données sans bruit,
- parfois même de survivre à un changement de mot de passe si les mécanismes de révocation ne sont pas instantanés.

Dans ce contexte, une session de 14 ou 30 jours n’est pas un confort utilisateur. C’est une fenêtre d’opportunité pour l’attaquant.

## Le faux sentiment de contrôle

Beaucoup d’organisations ont le sentiment de maîtriser ce risque. Après tout, les tokens expirent. Les utilisateurs se reconnectent. Les mots de passe changent.

En réalité, la durée de vie des sessions est rarement interrogée. Les paramètres par défaut sont conservés, les contrôles de session sont absents ou mal compris, et l’accès conditionnel est utilisé principalement comme un filtre d’entrée ("Gatekeeper") plutôt que comme un contrôleur continu.

Le raisonnement est souvent le suivant : *"Si l’utilisateur est authentifié, c’est qu’il est légitime."*
C’est précisément ce postulat que les attaques exploitent.

Une session ouverte peut devenir problématique dans de nombreux scénarios : un poste compromis après authentification, un jeton extrait depuis un navigateur, un accès depuis un pays inhabituel, une élévation de privilèges, ou simplement un compte révoqué trop tard. Sans mécanisme de remise en question, Entra ID continue d’accepter la session. Le contexte a changé, mais la confiance, elle, reste intacte.

## La mesure : reprendre le contrôle des sessions

La réponse ne consiste pas à raccourcir arbitrairement toutes les sessions (ce qui frustrerait les utilisateurs). Elle consiste à **conditionner la durée de la confiance** et à la réévaluer en continu.

Microsoft fournit plusieurs leviers complémentaires, souvent mal compris ou sous-utilisés.

### 1. Sign-in Frequency : limiter la durée de confiance

Le paramètre *Sign-in Frequency* (SIF) permet d’imposer une réauthentification après un certain temps, indépendamment de la validité du token ou de l'activité de l'utilisateur. C’est un outil simple, mais structurant.

Il ne remet pas en cause chaque requête. Il impose une borne temporelle claire : passé ce délai (ex: 7 jours), l’utilisateur devra prouver à nouveau son identité.

Mal utilisé (trop court), il dégrade l’expérience utilisateur.
Bien ciblé, il réduit drastiquement la fenêtre d’exploitation d’une session compromise.

![Conditional Access – Sign-in Frequency](/assets/img/posts/series/un-risque-une-mesure/2025-12-30-conditional-access-session.png)

🔗 [Documentation Microsoft associée - Sign-In frequency](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-session#sign-in-frequency)

### 2. Continuous Access Evaluation : remettre le contexte au centre

La *Continuous Access Evaluation* (CAE) marque un changement plus profond. Elle permet à Entra ID de réévaluer une session **après l’authentification**, quasiment en temps réel, en fonction d’événements de sécurité critiques.

Si l'un des événements suivants survient, la session peut être invalidée immédiatement sans attendre son expiration naturelle :
* Changement ou réinitialisation de mot de passe.
* Révocation explicite du compte.
* Modification de privilèges.
* Détection d'un risque utilisateur élevé (Identity Protection).
* Changement de localisation réseau (pour certaines configurations).

Ce n’est plus une sécurité statique basée sur un minuteur. C’est une sécurité réactive basée sur l'événement.

![Continuous Access Evaluation overview](/assets/img/posts/series/un-risque-une-mesure/2025-12-30continuous-access-evaluation-session-controls.png)

🔗 [Documentation Microsoft associée - Continuous Access Evaluation](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-session#customize-continuous-access-evaluation)

### Les limites à connaître

Tous les clients ne supportent pas CAE (bien que la couverture sur Office, Teams et les navigateurs modernes soit excellente). Tous les scénarios ne sont pas couverts. Et surtout, CAE ne remplace pas une stratégie de session cohérente (SIF).

C’est un filet de sécurité supplémentaire, pas une excuse pour laisser des sessions ouvertes indéfiniment.

## Gouvernance : la durée de confiance est un choix

La gestion des sessions n’est pas qu’un sujet technique. C’est un choix de gouvernance.
* Quelle durée de confiance est acceptable pour un poste géré ? (ex: 14 jours)
* Quelle durée pour un poste personnel ? (ex: 1 heure ou bloqué)
* Quels contextes justifient une réauthentification ?
* Quels signaux doivent invalider un accès ?

Ces questions doivent être posées explicitement. Sans réponse claire, la configuration devient arbitraire. Et l’arbitraire est l’ennemi de la sécurité.

## Ce qu’on observe sur le terrain

Dans de nombreux tenants, Token Protection est activée, la MFA est robuste, mais les sessions durent toujours plusieurs semaines, même pour des comptes sensibles. L’attaquant n’a plus besoin de voler un token au moment du login. Il lui suffit d’arriver pendant la fenêtre de validité.

La sécurité est solide à l’entrée. Elle est laxiste dans la durée.

## Ce qu’il faut vérifier concrètement dans son tenant

Sans même modifier une configuration, quelques questions simples permettent d’évaluer le risque. Je vous invite à vérifier ces points dès demain :

- [ ] Quelle est la **Sign-in Frequency effective** sur les applications critiques (M365, Azure Portal, Exchange) ? Est-elle configurée ou laissée par défaut ?
- [ ] Continuous Access Evaluation (CAE) est-elle **activée** dans vos politiques de session ?
- [ ] Existe-t-il des **exceptions CA** (comptes de service, VIP, legacy) qui contournent les contrôles de session ?
- [ ] Combien de temps une session reste-t-elle techniquement valide après un changement de mot de passe ? (Faites le test).

Si ces réponses ne sont pas claires, le risque est probablement sous-estimé.

## Conclusion

Une session persistante n’est ni une faiblesse technique, ni une mauvaise pratique en soi. C’est un **choix implicite**, souvent hérité des paramètres par défaut de Microsoft.

Dans Entra ID, la majorité des compromis modernes ne résultent pas d’une authentification faible, mais d’une **confiance prolongée non remise en question**. MFA et accès conditionnel renforcent l’entrée. Ils ne gouvernent pas, à eux seuls, la durée de validité d’un accès.

Sign-in Frequency et Continuous Access Evaluation ne sont pas des options de confort ou des réglages secondaires. Ce sont des **mécanismes de maîtrise du risque dans le temps**.

Tant que la durée de confiance n’est pas explicitement définie, documentée et revue, la sécurité de l’identité reste incomplète.

---
*Dans le prochain épisode de la série, nous aborderons les comptes à privilèges, où la durée de confiance devient encore plus critique.*