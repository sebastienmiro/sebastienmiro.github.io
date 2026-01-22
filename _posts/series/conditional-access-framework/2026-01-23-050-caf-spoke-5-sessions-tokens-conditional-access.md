---
title: "Conditional Access Framework v4 - Session et tokens : là où la MFA ne suffit plus"
date: 2026-01-22 19:00:00 +01:00
layout: post
tags: [series:conditional-access-framework, session, token]
categories: [identite, entra-id]
readtime: true
comments: true
cover-img: "assets/img/banners/banner-conditional-access.png"
thumbnail-img: "assets/img/posts/series/conditional-access-framework/050/050-thumb.png"
series: Conditional Access Framework
series_order: 050
sidebar: true
level: concepts
scope:
  - Entra ID
  - Sessions
  - Tokens
  - Conditional Access
platform: Microsoft Entra
---

## Pourquoi la MFA ne suffit plus à elle seule

Pendant longtemps, la sécurité des accès s’est concentrée sur l’authentification.  
Mot de passe, puis MFA, puis MFA renforcée. Une fois cette étape franchie, l’accès était considéré comme légitime jusqu’à la fin naturelle de la session.

Dans la pratique, ce raisonnement ne tient plus.  
Une authentification réussie n’épuise pas le risque. Elle ouvre une session, émet des tokens, et accorde une confiance qui peut durer bien au-delà du contexte initial.

Le Conditional Access Framework v4 part de ce constat : **le problème principal n’est pas l’authentification, mais ce qui se passe après**.  
Durée de session, persistance, réutilisation des tokens et capacité à remettre en cause un accès déjà accordé deviennent des sujets centraux.

## Session, token, cookie : ce que l’accès conditionnel contrôle réellement

Avant d’aborder les politiques, il faut clarifier un point souvent mal compris.

L’accès conditionnel ne protège pas un utilisateur au sens abstrait.  
Il agit sur des éléments techniques précis : des tokens d’accès, des tokens de rafraîchissement et des cookies de session, chacun avec ses propres règles de validité.

Une fois les tokens émis, l’accès reste possible tant qu’ils sont acceptés, même si :
- l’utilisateur change de contexte,
- le niveau de risque évolue,
- ou que le poste utilisé n’est plus le même.

Les attaques actuelles exploitent précisément ce décalage entre le moment de l’authentification et la durée réelle de validité de la session.

Le framework v4 ne cherche pas à empêcher l’émission des tokens.  
Il cherche à **en limiter la durée, la portée et les conditions de réutilisation**.

## Sign-in frequency : limiter la durée d’un accès valide

Les politiques **CA102**, **CA202** et **CA402** introduisent ou renforcent le contrôle de la fréquence de connexion.

Leur objectif est simple : éviter qu’une session reste exploitable trop longtemps sans réauthentification.

Pour les comptes à privilèges, l’enjeu est évident. Une session administrative persistante constitue un point d’entrée critique.  
Pour les utilisateurs standards, l’approche est plus progressive, avec des fréquences adaptées selon le type de poste et son niveau de maîtrise.

Ces politiques ne bloquent pas une attaque en cours.  
Elles **réduisent la durée pendant laquelle un accès volé reste utilisable**, ce qui suffit souvent à casser des scénarios automatisés ou opportunistes.

## Persistent browser : réduire les sessions qui durent sans être visibles

Les politiques **CA103**, **CA206** et **CA403** ciblent un comportement courant : la persistance des sessions dans le navigateur.

Ces sessions, souvent invisibles pour l’utilisateur, prolongent mécaniquement la validité des tokens, parfois pendant plusieurs jours ou semaines.

Le framework v4 recommande une position claire :
- pour les comptes à privilèges, la persistance est un risque à éviter ;
- pour les utilisateurs standards, elle peut être tolérée dans des contextes maîtrisés, mais jamais par défaut.

Ces règles sont souvent sous-estimées.  
Sur le terrain, elles ont un impact direct sur la réduction des attaques par phishing proxy et par réutilisation de session.

## Continuous Access Evaluation : remettre en cause un accès déjà accordé

La **Continuous Access Evaluation** (politiques **CA104** et **CA209**) permet de remettre en cause une session **après** l’authentification.

Concrètement, une session n’est plus considérée comme valide jusqu’à son expiration naturelle. Elle peut être invalidée lorsque certains événements surviennent, comme :
- une évolution du risque utilisateur,
- un changement d’état du compte,
- ou une action administrative critique.

Ce mécanisme ne couvre pas tous les scénarios et n’est pas instantané dans tous les cas.  
Mais il réduit fortement l’écart entre la détection d’un problème et la remise en cause effective de l’accès.

## Phishing-resistant MFA : limiter l’obtention initiale du token

La politique **CA105** se concentre sur un point précis : l’émission du token.

Même avec une MFA classique, un attaquant capable de relayer l’authentification peut obtenir un token valide. Le framework v4 réserve donc les méthodes de MFA résistantes au phishing aux comptes à fort impact, en particulier les comptes à privilèges.

L’objectif n’est pas de généraliser ces méthodes à tous les utilisateurs.  
Il s’agit de réduire la probabilité qu’un attaquant puisse **obtenir un token exploitable dès le départ**.

Cette politique ne protège pas la session une fois le token émis. Elle agit en amont, au moment le plus critique.

## Ce que ces politiques permettent, et leurs limites

Les politiques liées aux sessions et aux tokens ne rendent pas un environnement invulnérable.  
Elles ne remplacent ni la détection, ni la réponse à incident, ni la supervision des usages.

En revanche, elles modifient les conditions d’exploitation :
- un token volé est valide moins longtemps,
- une session est plus facilement remise en cause,
- et l’accès devient plus dépendant du contexte réel.

Le framework v4 formalise cette approche sans promesse excessive.  
Il ne supprime pas les attaques, il en **réduit la portée et la durée**.

## Pourquoi ces politiques arrivent après les personas et le socle

Ces contrôles sont efficaces, mais sensibles.

Déployés trop tôt ou sans cadre, ils génèrent rapidement :
- des déconnexions fréquentes,
- de l’incompréhension côté utilisateurs,
- et des tentatives de contournement.

C’est pour cette raison que le framework les positionne après :
- la définition des personas,
- la mise en place du socle commun,
- et la séparation claire entre utilisateurs standards et comptes à privilèges.

Ce séquencement conditionne leur acceptation et leur efficacité réelle.

## Conclusion

Dans le Conditional Access Framework v4, la session et les tokens ne sont pas des effets secondaires de l’authentification. Ils sont traités comme des éléments à contrôler explicitement.

Les politiques **CA102, CA103, CA104, CA105, CA202, CA206 et CA209** ne cherchent pas à tout bloquer. Elles visent à limiter ce qui cause encore une grande partie des incidents terrain : des accès valides trop longtemps, peu remis en question, et exploitables bien après l’authentification initiale.

Le framework ne propose pas une approche nouvelle par principe.  
Il formalise des mécanismes déjà connus, mais souvent mal positionnés ou mal combinés dans les déploiements réels.

Dans la suite de la série, les politiques liées aux appareils seront abordées avec la même logique : non pas comme des garanties de sécurité, mais comme des signaux, utiles uniquement lorsqu’ils sont correctement intégrés dans l’ensemble du framework.
