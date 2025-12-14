---
title: "Conditional Access Framework v4 — Session et tokens : le vrai point de rupture"
date: 2025-12-24 09:00:00 +01:00
layout: post
tags: [series:conditional-access-framework, session, token]
categories: [identite, entra-id]
readtime: true
comments: true
cover-img: "assets/img/banners/banner-conditional-access-admins.png"
thumbnail-img: "assets/img/posts/series/conditional-access-framework/060/060-thumb.png"
series: CA
series_order: 060
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

Le Conditional Access Framework v4 acte un changement fondamental : **l’authentification n’est plus le point final**, mais seulement l’entrée. Ce qui compte réellement, c’est ce qui se passe après : la durée de la session, sa réutilisation, son détournement éventuel, et les signaux capables de la remettre en cause.

Les politiques liées à la session et aux tokens constituent le cœur du framework v4. Elles expliquent à elles seules pourquoi une MFA “correctement déployée” ne suffit plus face aux attaques actuelles.

## Session, token, cookie : remettre les termes à leur place

Avant d’entrer dans les politiques, il est important de clarifier un point souvent flou sur le terrain.  
L’accès conditionnel ne protège pas un utilisateur abstrait, mais **des artefacts techniques bien précis** : des tokens, des cookies de session, et leur cycle de vie.

Une authentification réussie aboutit à l’émission de tokens. Tant que ces tokens sont valides et acceptés, l’accès est possible, même si le contexte initial a changé. Les attaques modernes exploitent précisément ce décalage entre l’instant de l’authentification et la durée réelle de la session.

Le framework v4 ne cherche pas à empêcher l’émission de tokens. Il cherche à **en réduire la portée, la durée et la réutilisabilité**.

## Sign-in frequency : réduire la durée de confiance

Les politiques **CA102**, **CA202** et **CA402** introduisent ou renforcent le contrôle de la fréquence de connexion. Leur objectif n’est pas de gêner l’utilisateur, mais de limiter la durée pendant laquelle une session peut être exploitée sans nouvelle authentification.

Pour les comptes à privilèges, cette logique est évidente : une session administrative persistante est une surface d’attaque majeure. Pour les utilisateurs standards, le framework adopte une approche plus nuancée, en modulant la fréquence selon le type de device ou son niveau de maîtrise.

Ces politiques ne bloquent pas une attaque en cours. Elles **réduisent la fenêtre d’opportunité**, ce qui est souvent suffisant pour casser les scénarios automatisés ou opportunistes.

## Persistent browser : limiter les sessions “oubliées”

Les politiques **CA103**, **CA206** et **CA403** ciblent un problème très concret : les sessions persistantes dans le navigateur. Ces sessions, souvent invisibles pour l’utilisateur, prolongent artificiellement la durée de validité des tokens.

Le framework v4 recommande de limiter, voire d’interdire, l’usage du *persistent browser* selon les personas. Pour les comptes à privilèges, la position est claire : la persistance est un risque, pas un confort acceptable. Pour les utilisateurs standards, elle peut être tolérée dans certains contextes maîtrisés, mais jamais par défaut.

Ces règles sont souvent perçues comme secondaires. En réalité, elles sont déterminantes pour réduire l’impact d’un vol de session, notamment dans les scénarios de phishing proxy.

## Continuous Access Evaluation : casser la confiance implicite

La **Continuous Access Evaluation** (politiques **CA104** et **CA209**) introduit une rupture conceptuelle majeure. Elle permet de remettre en cause une session **après** l’authentification, lorsque certains signaux critiques apparaissent.

Concrètement, cela signifie qu’une session n’est plus considérée comme valide jusqu’à son expiration naturelle. Elle peut être invalidée en fonction d’événements comme un changement de risque utilisateur ou une modification de l’état du compte.

Le framework intègre la CAE comme un mécanisme clé pour réduire l’écart entre détection et réaction. Ce n’est pas une solution universelle, ni instantanée dans tous les cas, mais c’est un pas décisif vers une gestion plus dynamique de la session.

## Phishing-resistant MFA : protéger l’émission du token

La politique **CA105** cible un point précis mais critique : la phase d’émission du token.  
Même avec une MFA classique, un attaquant capable d’intercepter ou de relayer l’authentification peut obtenir un token valide.

Le framework v4 positionne les méthodes de MFA résistantes au phishing comme une exigence spécifique pour les comptes à privilèges. L’objectif n’est pas de généraliser ces méthodes à tous les usages, mais de les réserver là où le risque et l’impact justifient la contrainte.

Cette politique ne protège pas la session une fois le token émis. Elle réduit fortement la probabilité qu’un attaquant puisse **obtenir** ce token en premier lieu.

## Ce que ces politiques font réellement, et ce qu’elles ne font pas

Les politiques de session et de tokens ne rendent pas un environnement invulnérable.  
Elles ne remplacent ni la détection, ni la réponse à incident, ni la supervision des usages.

En revanche, elles changent profondément l’économie des attaques. Là où un vol de token pouvait auparavant offrir un accès stable et discret, il devient plus fragile, plus court, et plus dépendant du contexte.

Le framework v4 assume pleinement cette approche. Il ne promet pas l’élimination des attaques, mais **leur dégradation systématique**.

## Pourquoi ces politiques arrivent après les personas et les rôles

Ces contrôles sont puissants, mais aussi sensibles.  
Mal positionnés, ils génèrent rapidement des effets de bord : déconnexions fréquentes, incompréhension des utilisateurs, contournements.

C’est pour cette raison que le framework ne les place pas en première ligne. Ils viennent après :
- la clarification des personas,
- la mise en place du socle commun,
- la distinction nette entre utilisateurs standards et comptes à privilèges.

Ce séquencement est essentiel pour que ces politiques soient acceptées et comprises.

## Conclusion

Le Conditional Access Framework v4 marque une rupture claire : la sécurité de l’identité ne s’arrête plus à l’authentification. La session et les tokens deviennent des objets de sécurité à part entière.

Les politiques **CA102, CA103, CA104, CA105, CA202, CA206, CA209** traduisent cette évolution de manière concrète. Elles ne bloquent pas toutes les attaques, mais elles réduisent drastiquement leur portée et leur durée.

C’est précisément à ce niveau que le framework v4 se distingue des approches plus anciennes, et justifie une lecture attentive, loin des slogans du type “MFA = sécurité”.

Dans le prochain article, la série abordera les **politiques liées aux devices**, souvent perçues comme simples, mais largement surinterprétées sur le terrain.
