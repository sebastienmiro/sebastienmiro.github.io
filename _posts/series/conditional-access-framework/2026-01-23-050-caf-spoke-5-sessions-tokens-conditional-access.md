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

Cet article n’a pas pour objectif de démontrer que la MFA serait insuffisante en soi.  
Ce point a déjà été traité en détail dans un autre article, à travers l’analyse des sessions persistantes et des mécanismes de Sign-in Frequency.

L’objectif est plus circonscrit : **comprendre comment le Conditional Access Framework v4 traite concrètement la session et les tokens**, et pourquoi ces leviers apparaissent à ce stade précis du framework.

Les politiques abordées ici n’introduisent pas de nouveaux concepts.  
Elles organisent, positionnent et combinent des mécanismes déjà disponibles dans Entra ID, afin de répondre à des scénarios d’incident largement observés sur le terrain.

## Session, token, cookie : le périmètre réel de l’accès conditionnel

L’accès conditionnel ne s’applique pas à un utilisateur au sens abstrait.  
Il agit sur des objets techniques bien définis : des tokens d’accès, des tokens de rafraîchissement et des cookies de session, chacun avec son propre cycle de vie et ses conditions de validité.

Une authentification réussie entraîne l’émission de tokens. Tant que ces tokens restent valides et acceptés par les services, l’accès est autorisé, même si le contexte initial a évolué entre-temps. C’est précisément cette dissociation entre l’instant de l’authentification et la durée réelle de validité de la session qui est exploitée dans de nombreux scénarios d’attaque.

Le Conditional Access Framework v4 part de cette réalité technique.  
Il ne cherche pas à empêcher l’émission des tokens, mais à **encadrer leur durée de validité, leur persistance et les conditions dans lesquelles ils restent exploitables**.

## Sign-in frequency : encadrer la durée d’un accès valide

Les politiques **CA102**, **CA202** et **CA402** introduisent un contrôle explicite sur la durée pendant laquelle une session peut rester valide sans nouvelle authentification.

Le framework applique ce levier de manière différenciée selon les personas. Pour les comptes à privilèges, la logique est directe : une session administrative persistante constitue une surface d’attaque importante et doit être régulièrement réévaluée. Pour les utilisateurs standards, l’approche est plus progressive, avec des durées ajustées en fonction du type de poste et de son niveau de maîtrise.

Ces politiques ne détectent pas une compromission et ne bloquent pas une attaque en cours.  
Elles visent à limiter la période pendant laquelle un accès compromis reste exploitable sans interaction supplémentaire, ce qui suffit souvent à réduire l’efficacité de scénarios opportunistes ou automatisés.

## Persistent browser : maîtriser la persistance implicite des sessions

Les politiques **CA103**, **CA206** et **CA403** adressent un point fréquemment sous-estimé : la persistance des sessions dans le navigateur.

Une session persistante prolonge mécaniquement la validité des tokens, parfois sur plusieurs jours, sans que l’utilisateur n’ait conscience qu’un accès reste actif. Ce comportement, anodin en apparence, joue un rôle central dans les scénarios de vol de session et de phishing par proxy.

Dans le CAF v4, la position est explicite.  
La persistance est évitée pour les comptes à privilèges, car elle introduit un risque disproportionné par rapport au gain fonctionnel. Pour les utilisateurs standards, elle peut être tolérée dans des contextes maîtrisés, mais jamais comme comportement par défaut.

Ces règles ne sont pas accessoires.  
Elles conditionnent directement l’impact réel d’un vol de session.

## Continuous Access Evaluation : remettre en cause une session existante

La **Continuous Access Evaluation** (politiques **CA104** et **CA209**) permet de remettre en cause une session après son établissement, en fonction de signaux apparus postérieurement à l’authentification.

Concrètement, une session n’est plus considérée comme valide jusqu’à son expiration naturelle. Elle peut être invalidée en réponse à des événements tels qu’une évolution du risque utilisateur, une modification de l’état du compte ou certaines actions de sécurité.

Le framework intègre la CAE comme un mécanisme complémentaire, sans en faire une garantie absolue. Elle ne couvre pas tous les scénarios et n’est pas instantanée dans toutes les situations, mais elle réduit l’écart entre la détection d’un problème et la remise en cause effective de l’accès.

## Phishing-resistant MFA : agir au moment de l’émission du token

La politique **CA105** se concentre sur la phase d’authentification des comptes à fort impact.

Même avec une MFA classique, un attaquant capable de relayer l’authentification peut obtenir un token valide. Le CAF v4 réserve donc les méthodes de MFA résistantes au phishing aux comptes à privilèges, là où l’impact justifie la contrainte.

Cette politique ne protège pas la session une fois le token émis.  
Elle vise uniquement à réduire la probabilité qu’un token exploitable soit obtenu dès l’origine.

## Ce que ces politiques permettent, et leurs limites

Les politiques liées aux sessions et aux tokens ne rendent pas un environnement invulnérable.  
Elles ne remplacent ni la détection, ni la réponse à incident, ni la supervision des usages.

En revanche, elles modifient les conditions d’exploitation. Un token volé reste valide moins longtemps, une session est plus facilement remise en cause et l’accès devient plus dépendant du contexte réel.

Dans le CAF v4, ces mécanismes sont positionnés comme des **réducteurs d’impact**, pas comme des contrôles préventifs universels.

## Pourquoi ces politiques arrivent à ce stade du framework

Ces leviers sont efficaces, mais sensibles.  
Déployés sans cadre préalable, ils génèrent rapidement des effets de bord : déconnexions fréquentes, incompréhension côté utilisateurs et tentatives de contournement.

C’est pour cette raison que le CAF v4 les positionne après la définition des personas, la mise en place du socle commun et la séparation claire entre utilisateurs standards et comptes à privilèges. Ils ne constituent pas un point de départ, mais un **niveau d’affinement**, destiné à traiter des risques déjà identifiés.

## Conclusion

Le Conditional Access Framework v4 ne redéfinit pas la gestion des sessions et des tokens.  
Il les positionne explicitement dans un ensemble cohérent de politiques, avec un périmètre et un ordre d’application clairs.

Les politiques **CA102, CA103, CA104, CA105, CA202, CA206 et CA209** n’introduisent pas de nouveaux mécanismes. Elles structurent des contrôles existants pour limiter des situations bien connues sur le terrain : des accès valides trop longtemps et insuffisamment remis en cause.

Dans la suite de la série, les politiques liées aux appareils seront analysées avec la même approche, non pas comme des garanties de sécurité, mais comme des signaux dont l’efficacité dépend entièrement de leur positionnement dans l’ensemble du framework.
