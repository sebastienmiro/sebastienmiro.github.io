---
title: "Sessions persistantes : gouverner l’accès après l’authentification (Sign-in Frequency & Continuous Access Evauation)"
date: 2025-12-30 07:00:00 +01:00
layout: post
tags: [series:un-risque-une-mesure, entra-id, sessions, conditional-access, sign-in-frequency, cae]
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
  - Sessions
  - Continuous Access Evaluation
---

> 💡 **Une session ouverte, c’est une confiance accordée. Le problème, ce n’est pas qu’on l’accorde… c’est qu’on oublie souvent de la reprendre.**

Lorsqu’un utilisateur s’authentifie dans Microsoft 365, l’accès aux ressources ne repose pas sur une vérification continue de son identité. Une fois l’authentification réussie, une session est établie et des jetons sont émis afin de permettre l’accès aux services sans nouvelle sollicitation explicite de l’utilisateur.

Ce fonctionnement est volontaire. Il vise à assurer la continuité d’accès et l’expérience utilisateur. Il repose toutefois sur une hypothèse implicite : tant que la session est valide, l’accès reste légitime.

Dans les faits, cette hypothèse n’est pas toujours vérifiée. Le contexte dans lequel une session a été ouverte peut évoluer sans que l’accès soit remis en question : changement de poste, compromission ultérieure, élévation de privilèges ou signal de risque apparu après l’authentification.

La sécurité de l’identité ne se limite donc pas au moment de l’authentification. Elle dépend également de la manière dont la validité des sessions est définie, contrôlée et remise en cause dans le temps.

![Session lifetime](/assets/img/posts/series/un-risque-une-mesure/2025-12-30-token-duration-timeline.png)

## Le risque : confondre authentification réussie et accès légitime durable

L’erreur est subtile. Une fois l’utilisateur authentifié, l’accès est implicitement considéré comme légitime tant que les jetons associés à la session restent valides. Cette logique est héritée de modèles conçus pour des environnements plus statiques.

Dans des environnements cloud fortement exposés, cette hypothèse devient insuffisante dès lors que le contexte peut évoluer après l’authentification.

Une session est une **délégation de confiance dans le temps**. Elle autorise l’accès sans redemander de preuve, parfois pendant des heures, parfois pendant des jours (jusqu'à 90 jours par défaut pour le *Rolling Window* d'un Refresh Token). Tant que le token reste valide, l’accès n’est généralement pas remis en question, sauf si un événement de sécurité ou une politique explicite déclenche une réévaluation (CAE, Identity Protection, révocation de session, etc.).

C’est là que se loge le risque.

## Ce qu’est réellement une session dans Entra ID

Lorsqu’un utilisateur s’authentifie, Entra ID ne valide pas chaque action. Il émet des jetons — access tokens, refresh tokens, PRT — qui servent de laissez-passer. Ces jetons portent une durée de vie, souvent généreuse, et sont acceptés tant qu’ils respectent leurs critères de validité.

Une fois la session établie, la MFA n’est plus sollicitée.
Le système ne se demande plus *qui* est l’utilisateur, mais uniquement *si le token présenté est valide*.

C’est un choix d’architecture pensé pour le SSO et la résilience. Et comme tout choix d’architecture, il a des conséquences. Derrière cette continuité d’accès se trouvent des mécanismes largement transparents pour l’utilisateur, comme les tokens de session et le Primary Refresh Token (PRT), qui permettent à Entra ID de renouveler l’accès sans redemander d’authentification tant que certaines conditions sont remplies.

## Pourquoi les attaquants adorent les sessions longues
Dans plusieurs scénarios (vol de jetons via infostealers, attaques de type Adversary-in-the-Middle), l’objectif n’est pas nécessairement de contourner l’authentification, mais d’exploiter une session déjà établie.

Une session persistante permet notamment :
- l’accès aux ressources Microsoft 365 sans nouvelle authentification,
- la mise en place de mécanismes de persistance (règles de messagerie, consentements OAuth),
- l’accès aux données sans génération de signaux d’authentification.

Dans ce contexte, des sessions valides sur plusieurs jours ou semaines augmentent mécaniquement la surface temporelle d’exploitation.

Ce risque est particulièrement marqué sur des postes non maîtrisés, des navigateurs non durcis, ou en présence d’infostealers : le token n’est alors pas compromis au moment du login, mais dans un second temps.

> 🟡 Ce qu’il faut garder en tête concernant le “vol de token”
> Le risque lié aux sessions persistantes n’implique pas que tout token volé soit automatiquement exploitable, ni que l’attaque soit triviale à réaliser.
> Dans la plupart des cas, la réutilisation d’un token reste fortement dépendante du contexte (type d’application, posture du poste, mécanismes de contrôle actifs, support CAE / Token Protection, etc.).
> Dans les environnements bien configurés, ce risque n’est pas à considérer comme une faille structurelle, mais plutôt comme un vecteur d’opportunité dans des situations où la surface d’exposition n’a pas été suffisamment cadrée.
> L’enjeu n’est donc pas d’alarmer, mais d’encadrer la durée et les conditions de confiance afin de réduire l’impact potentiel d’une session compromise.

## Le faux sentiment de contrôle

Dans de nombreux cas, la maîtrise du risque repose principalement sur les contrôles d’authentification. Les tokens expirent, les mots de passe changent, et les utilisateurs se reconnectent.

En revanche, la durée de validité effective des sessions et les mécanismes de remise en question après authentification sont rarement analysés de manière explicite.

Le raisonnement est souvent le suivant : *"Si l’utilisateur est authentifié, c’est qu’il est légitime."*
C’est précisément ce postulat que les attaques exploitent.

Une session ouverte peut devenir problématique dans de nombreux scénarios : un poste compromis après authentification, un jeton extrait depuis un navigateur, un accès depuis un pays inhabituel, une élévation de privilèges, ou simplement un compte révoqué trop tard. Sans mécanisme de remise en question, Entra ID continue d’accepter la session. Le contexte a changé, mais la confiance, elle, reste intacte.

## La mesure : reprendre le contrôle des sessions

La réponse ne consiste pas à raccourcir arbitrairement toutes les sessions (ce qui frustrerait les utilisateurs). Elle consiste à **conditionner la durée de la confiance** et à la réévaluer en continu.

Microsoft fournit plusieurs leviers complémentaires, souvent mal compris ou sous-utilisés.

### 1. Sign-in Frequency : limiter la durée de confiance

Le paramètre *Sign-in Frequency* (SIF) permet d’imposer une réauthentification après un certain temps, indépendamment de la validité du token ou de l'activité de l'utilisateur. C’est un outil simple, mais structurant.

Il ne remet pas en cause chaque requête. Il impose une borne temporelle claire : passé ce délai (ex: 7 jours), l’utilisateur devra prouver à nouveau son identité.

Une configuration trop agressive peut entraîner des sollicitations fréquentes de l’utilisateur. Une configuration ciblée permet en revanche de réduire la fenêtre d’exploitation sans impact disproportionné.

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

![Continuous Access Evaluation overview](/assets/img/posts/series/un-risque-une-mesure/2025-12-30-continuous-access-evaluation-session-controls.png)

🔗 [Documentation Microsoft associée - Continuous Access Evaluation](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-session#customize-continuous-access-evaluation)

### Les limites à connaître

Tous les clients ne supportent pas CAE (bien que la couverture sur Office, Teams et les navigateurs modernes soit excellente). Tous les scénarios ne sont pas couverts. Et surtout, CAE ne remplace pas une stratégie de session cohérente.

C’est un filet de sécurité supplémentaire, pas une excuse pour laisser des sessions ouvertes indéfiniment.

### Exemples de durée de confiance des sessions dans Entra ID selon le contexte

> ⚠️ **Important — recommandations à adapter au contexte**
>
> Les valeurs proposées ci-dessous sont des repères et doivent être adaptées au contexte.
> Sur des postes **non gérés et non protégés par Intune / MAM**, une réauthentification très fréquente
> (par exemple quotidienne) peut devenir **lourde pour l’utilisateur** et générer de la [**fatigue MFA**](https://blog.sebastienmiro.fr/identite/entra-id/mfa-pas-suffisant-phishing/).
>
> Dans ces situations, la décision doit être prise dans un cadre global de gouvernance des accès
> (segmentation des usages, durcissement navigateur, séparation des comptes, intégration à Intune, etc.),
> plutôt que par un simple raccourcissement des sessions.
>
> 👉 Pour une approche structurée, voir la série d'articles [**Conditional Access Framework v4**](https://blog.sebastienmiro.fr/identite/entra-id/000-conditional-access-framework-analyse-francais-fr/).

| Contexte d’accès | Type de poste | Sensibilité du compte | Sign-in Frequency recommandée | CAE | Logique de sécurité |
|---|---|---:|:---:|:---:|---|
| Utilisateur standard | Poste géré — Entra ID joined / Hybrid joined | Standard | **7 jours** | Oui | Le PRT permet un renouvellement fluide ; bon équilibre sécurité / UX |
| Utilisateur standard | Navigateur sur poste non géré (BYOD / perso) | Standard | **1 jour** | Oui | Réduit la fenêtre d’exploitation en cas d’infostealer ou AiTM |
| Utilisateur standard — mobilité | Mobile géré (MDM/MAM + App Protection) | Standard | **7 à 14 jours** | Oui | Acceptable si l’isolation applicative est correctement mise en œuvre |
| Comptes techniques étendus / IT Ops | Poste géré dédié | Élevée | **1 jour** | Oui | Limite la persistance de session sur des comptes à exposition accrue |
| Comptes administrateurs (Global / Security / Entra / Exchange) | Poste / bastion d’administration dédié | Critique | **8 à 12 heures** | Oui | Administration = activité ponctuelle → confiance courte et située |
| Comptes invités (B2B) | Contexte partenaire non maîtrisé | Variable | **1 jour** | Oui | Contexte hétérogène, principe de prudence |
| Accès à données sensibles / régulées | Poste géré | Standard+ | **1 à 3 jours** | Oui | Ajuster selon contraintes conformité / exigences d’audit |
| Applications non compatibles CAE | Variable | Variable | **≤ 1 jour** | Partiel | La SIF compense partiellement l’absence d’invalidation événementielle |

> 💡 **Ces durées ne remplacent pas les contrôles de sécurité du poste**
>
> Les réglages de session réduisent la durée d’exploitation d’un accès compromis,
> mais ils ne remplacent pas le **durcissement du poste et du navigateur**, l’EDR,
> la détection d’infostealers, la séparation des usages et — lorsque compatible —
> l’utilisation de **Token Protection**.
>
> Dans la majorité des incidents, le risque provient d’une **session navigateur déjà active** ;
> la réduction de durée limite l’impact, elle ne supprime pas la cause.

## Gouvernance : la durée de confiance est un choix

Ces questions doivent être traitées explicitement dans la gouvernance des accès, en tenant compte du contexte organisationnel et des usages réels.
- Quelle durée de confiance est acceptable pour un poste géré ? 
- Quelle durée pour un poste personnel ?
- Quels contextes justifient une réauthentification ?
- Quels signaux doivent invalider un accès ?

Ces questions doivent être posées explicitement. Sans réponse claire, la configuration devient arbitraire. Et l’arbitraire est l’ennemi de la sécurité.

## Ce qu’on observe sur le terrain

Dans de nombreux tenants, la MFA et parfois Token Protection sont en place mais les sessions durent toujours plusieurs semaines, même pour des comptes sensibles. L’attaquant n’a plus besoin de voler un token au moment du login. Il lui suffit d’arriver pendant la fenêtre de validité.

La sécurité est solide à l’entrée. Elle est laxiste dans la durée.

## Ce qu’il faut vérifier concrètement dans son tenant

Sans même modifier une configuration, quelques questions simples permettent d’évaluer le risque. Je vous invite à vérifier ces points dès demain :

- Quelle est la **Sign-in Frequency effective** sur les applications critiques (M365, Azure Portal, Exchange) ? Est-elle configurée ou laissée par défaut ?
- Continuous Access Evaluation (CAE) est-elle **activée** dans vos politiques de session ?
- Existe-t-il des **exceptions CA** (comptes de service, VIP, legacy) qui contournent les contrôles de session ?
- Combien de temps une session reste-t-elle techniquement valide après un changement de mot de passe ? (Faites le test).

Si ces réponses ne sont pas claires, le risque est probablement sous-estimé.

## Conclusion

Une session persistante n’est ni une faiblesse technique, ni une mauvaise pratique en soi. C’est un **choix implicite**, souvent hérité des paramètres par défaut de Microsoft.

Dans Entra ID, de nombreux scénarios de compromission exploitent des accès déjà établis plutôt que des faiblesses d’authentification initiale. Sign-in Frequency et Continuous Access Evaluation ne sont pas des options de confort ou des réglages secondaires. Ce sont des **mécanismes de maîtrise du risque dans le temps**.

Tant que la durée de confiance n’est pas explicitement définie, documentée et revue, la sécurité de l’identité reste incomplète.

---
*Dans le prochain épisode de la série, nous aborderons les comptes à privilèges, où la durée de confiance devient encore plus critique.*
