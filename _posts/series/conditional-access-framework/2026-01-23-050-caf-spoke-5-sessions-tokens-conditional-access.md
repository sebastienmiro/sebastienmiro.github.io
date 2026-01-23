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

## Ce que cet article couvre réellement

Cet article ne vise pas à démontrer que la MFA est insuffisante.  [Ce point est déjà largement documenté dans un de mes articles.](https://blog.sebastienmiro.fr/identite/entra-id/entra-id-session-persistante-sign-in-frequency/)

L’objectif est plus précis : **comprendre comment le Conditional Access Framework v4 traite concrètement la session et les tokens**, et pourquoi ces mécanismes arrivent à ce stade du framework.

Les politiques abordées ici n’introduisent pas de nouveaux concepts.  
Elles organisent, positionnent et combinent des leviers déjà existants dans Entra ID.

## Session, token, cookie : le périmètre réel de l’accès conditionnel

L’accès conditionnel ne s’applique pas à un utilisateur au sens abstrait.  
Il agit sur des objets techniques précis :
- tokens d’accès,
- tokens de rafraîchissement,
- cookies de session.

Une authentification réussie entraîne l’émission de tokens. Tant qu’ils restent valides, l’accès est accordé, même si le contexte évolue.

Le CAF v4 part de cette réalité technique.  
Il ne cherche pas à empêcher l’émission des tokens, mais à **encadrer leur durée de validité, leur persistance et les conditions dans lesquelles ils restent acceptés**.

## Sign-in frequency : encadrer la durée de validité d’une session

Les politiques **CA102**, **CA202** et **CA402** introduisent un contrôle explicite sur la durée pendant laquelle une session peut rester valide sans nouvelle authentification.

Le framework applique ce levier différemment selon les personas :
- pour les comptes à privilèges, la session doit être courte et régulièrement réévaluée ;
- pour les utilisateurs standards, la durée est modulée selon le type de poste et son niveau de maîtrise.

Ces politiques ne détectent pas une compromission.  
Elles limitent simplement la période pendant laquelle un accès reste exploitable sans interaction supplémentaire.

## Persistent browser : contrôler la persistance implicite

Les politiques **CA103**, **CA206** et **CA403** adressent un point souvent sous-estimé : la persistance des sessions navigateur.

Une session persistante prolonge mécaniquement la validité des tokens, parfois bien au-delà de ce que l’utilisateur perçoit.

Dans le CAF v4 :
- la persistance est explicitement évitée pour les comptes à privilèges ;
- elle peut être tolérée pour les utilisateurs standards, mais uniquement dans des contextes maîtrisés.

Ces règles ne sont pas accessoires.  
Elles conditionnent directement l’impact d’un vol de session, en particulier dans les scénarios de phishing par proxy.

## Continuous Access Evaluation : remettre en cause une session existante

La **Continuous Access Evaluation** (politiques **CA104** et **CA209**) permet de remettre en cause une session **après** son établissement.

Concrètement, une session peut être invalidée en fonction de signaux tels que :
- une évolution du risque utilisateur,
- une modification de l’état du compte,
- ou certains événements de sécurité.

Le framework intègre la CAE comme un mécanisme complémentaire, sans en faire une garantie absolue.  
Elle ne couvre pas tous les cas et n’est pas instantanée dans toutes les situations, mais elle réduit l’écart entre détection et prise d’effet.

## Phishing-resistant MFA : agir au moment de l’émission du token

La politique **CA105** se concentre sur la phase d’authentification des comptes à fort impact.

Même avec une MFA classique, un attaquant peut obtenir un token valide s’il est capable de relayer l’authentification. Le CAF v4 réserve donc les méthodes de MFA résistantes au phishing aux comptes à privilèges.

Cette politique ne protège pas la session une fois le token émis.  
Elle vise uniquement à réduire la probabilité qu’un token exploitable soit obtenu dès l’origine.

## Ce que ces politiques apportent, et ce qu’elles n’apportent pas

Les politiques de session et de tokens ne remplacent :
- ni la détection,
- ni la réponse à incident,
- ni la supervision des usages.

Elles n’empêchent pas toutes les compromissions.  
Elles limitent la durée, la persistance et la réutilisation des accès accordés.

Dans le CAF v4, ces mécanismes sont positionnés comme des **réducteurs d’impact**, pas comme des contrôles préventifs universels.

## Pourquoi ces politiques arrivent à ce stade du framework

Ces leviers sont efficaces, mais sensibles.

Déployés sans cadre, ils entraînent rapidement :
- des déconnexions fréquentes,
- de l’incompréhension côté utilisateurs,
- et des contournements.

C’est pour cette raison que le CAF v4 les positionne après :
- la définition des personas,
- le socle commun,
- et la séparation claire entre utilisateurs standards et comptes à privilèges.

Ils ne constituent pas un point de départ, mais un **niveau d’affinement**.

## Conclusion

Le Conditional Access Framework v4 ne redéfinit pas la gestion des sessions et des tokens.  
Il les place explicitement dans un ensemble cohérent de politiques, avec un périmètre et un ordre d’application clairs.

Les politiques **CA102, CA103, CA104, CA105, CA202, CA206 et CA209** n’introduisent pas de nouveaux mécanismes.  
Elles structurent des contrôles existants pour limiter des situations bien connues sur le terrain : des accès valides trop longtemps et insuffisamment remis en cause.

Dans les articles suivants, le framework sera analysé avec la même approche pour les politiques liées aux appareils, sans les présenter comme des garanties en soi, mais comme des signaux dont l’efficacité dépend entièrement de leur positionnement global.
