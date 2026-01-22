---
title: "Conditional Access Framework v4 — Session et tokens : là où la MFA ne suffit plus"
date: 2026-01-22 19:00:00 +01:00
layout: post
tags: [series:conditional-access-framework, session, token]
categories: [identite, entra-id]
readtime: true
comments: true
cover-img: "assets/img/banners/banner-conditional-access.png"
thumbnail-img: "assets/img/posts/series/conditional-access-framework/060/060-thumb.png"
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

## Pourquoi le framework v4 déplace le centre de gravité

Pendant longtemps, la sécurité de l’identité a été pensée presque exclusivement autour de l’authentification. Mot de passe, puis MFA, puis MFA renforcée. Une fois cette étape franchie, la session héritait d’un niveau de confiance implicite, rarement remis en question.

Le Conditional Access Framework v4 acte un changement clair : **l’authentification n’est plus un point final**, mais un point d’entrée.  
Ce qui devient déterminant, c’est ce qui se passe après : la durée de la session, sa persistance, sa réutilisation et les signaux capables de remettre en cause une confiance déjà accordée.

Les politiques liées à la session et aux tokens constituent le cœur opérationnel du framework v4. Elles expliquent pourquoi une MFA correctement déployée reste insuffisante face aux attaques actuelles.

## Session, token, cookie : remettre les termes à leur place

Avant d’aborder les politiques, il est utile de clarifier un point souvent flou sur le terrain.

L’accès conditionnel ne protège pas un utilisateur abstrait.  
Il agit sur **des artefacts techniques concrets** : des tokens d’accès, des tokens de rafraîchissement et des cookies de session, chacun avec son propre cycle de vie.

Une authentification réussie aboutit à l’émission de tokens. Tant que ces tokens restent valides et acceptés, l’accès est possible, même si le contexte initial a évolué. Les attaques modernes exploitent précisément ce décalage entre l’instant de l’authentification et la durée réelle de confiance accordée à la session.

Le framework v4 ne cherche pas à empêcher l’émission de tokens.  
Il cherche à **en limiter la portée, la durée et la réutilisation**.

## Sign-in frequency : réduire la durée de confiance

Les politiques **CA102**, **CA202** et **CA402** introduisent ou renforcent le contrôle de la fréquence de connexion. Leur objectif n’est pas de gêner l’utilisateur, mais de limiter la durée pendant laquelle une session peut être exploitée sans nouvelle authentification.

Pour les comptes à privilèges, la logique est évidente : une session administrative persistante constitue une surface d’attaque majeure.  
Pour les utilisateurs standards, le framework adopte une approche plus nuancée, en modulant la fréquence selon le type de device et son niveau de maîtrise.

Ces politiques ne bloquent pas une attaque en cours.  
Elles **réduisent la fenêtre d’exploitation**, ce qui suffit souvent à casser des scénarios opportunistes ou automatisés.

## Persistent browser : limiter les sessions oubliées

Les politiques **CA103**, **CA206** et **CA403** traitent un problème très concret : les sessions persistantes dans le navigateur. Ces sessions, souvent invisibles pour l’utilisateur, prolongent artificiellement la validité des tokens.

Le framework v4 recommande de limiter, voire d’interdire, l’usage du navigateur persistant selon les personas.  
Pour les comptes à privilèges, la position est explicite : la persistance est un risque, pas un confort acceptable.  
Pour les utilisateurs standards, elle peut être tolérée dans certains contextes maîtrisés, mais jamais comme comportement par défaut.

Ces règles sont parfois perçues comme secondaires. En pratique, elles jouent un rôle clé dans la réduction de l’impact d’un vol de session, notamment dans les scénarios de phishing proxy.

## Continuous Access Evaluation : remettre en cause la confiance après coup

La **Continuous Access Evaluation** (politiques **CA104** et **CA209**) introduit une rupture conceptuelle importante. Elle permet de remettre en cause une session **après** l’authentification, lorsqu’un signal critique apparaît.

Concrètement, une session n’est plus considérée comme valide jusqu’à son expiration naturelle. Elle peut être invalidée en fonction d’événements tels qu’un changement de risque utilisateur ou une modification de l’état du compte.

Le framework intègre la CAE comme un mécanisme central pour réduire l’écart entre détection et réaction. Ce n’est pas une solution universelle ni instantanée dans tous les cas, mais elle introduit une gestion plus dynamique de la confiance accordée à une session.

## Phishing-resistant MFA : protéger l’émission du token

La politique **CA105** cible un point précis : la phase d’émission du token.

Même avec une MFA classique, un attaquant capable de relayer ou d’intercepter l’authentification peut obtenir un token valide. Le framework v4 positionne donc les méthodes de MFA résistantes au phishing comme une exigence spécifique pour les comptes à privilèges.

L’objectif n’est pas de généraliser ces méthodes à tous les usages, mais de les réserver aux identités dont l’impact justifie la contrainte.  
Cette politique ne protège pas la session une fois le token émis. Elle réduit la probabilité qu’un attaquant puisse **obtenir** ce token en premier lieu.

## Ce que ces politiques font réellement, et ce qu’elles ne font pas

Les politiques de session et de tokens ne rendent pas un environnement invulnérable.  
Elles ne remplacent ni la détection, ni la réponse à incident, ni la supervision des usages.

En revanche, elles modifient profondément les conditions d’exploitation. Là où un vol de token offrait auparavant un accès stable et discret, il devient plus fragile, plus court et plus dépendant du contexte.

Le framework v4 ne promet pas l’élimination des attaques.  
Il vise une **dégradation systématique de leur efficacité**.

## Pourquoi ces politiques arrivent après les personas et les rôles

Ces contrôles sont puissants, mais sensibles.

Mal positionnés, ils génèrent rapidement des effets de bord : déconnexions fréquentes, incompréhension des utilisateurs, tentatives de contournement. C’est pour cette raison que le framework ne les place pas en première ligne.

Ils viennent après :
- la clarification des personas ;
- la mise en place du socle commun ;
- la distinction nette entre utilisateurs standards et comptes à privilèges.

Ce séquencement conditionne leur acceptation et leur efficacité réelle.

## Conclusion

Dans le Conditional Access Framework v4, la session et les tokens ne sont pas des effets secondaires de l’authentification. Ils sont traités comme des objets de sécurité à part entière, avec leur propre logique de contrôle.

Les politiques CA102, CA103, CA104, CA105, CA202, CA206 et CA209 ne cherchent pas à empêcher toutes les attaques. Elles visent à limiter ce qui fait aujourd’hui la majorité des incidents terrain : des accès prolongés, peu remis en question, exploitables bien après l’authentification initiale.

Ce choix n’est ni nouveau ni théorique. Il formalise une réalité opérationnelle déjà connue, mais souvent mal intégrée dans les déploiements d’accès conditionnel.

Dans la suite de la série, les politiques liées aux appareils seront abordées sous le même angle : non pas comme des garanties de sécurité, mais comme des signaux, efficaces uniquement lorsqu’ils sont correctement positionnés dans l’ensemble du framework.
