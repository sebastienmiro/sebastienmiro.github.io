---
title: "Conditional Access Framework v4 — Session & tokens : ce que le framework protège réellement"
date: 2026-04-03 09:00:00 +01:00
layout: post
tags: [series:conditional-access-framework, token-protection, session]
categories: [identite, entra-id]
readtime: true
comments: true
cover-img: "assets/img/banners/banner-conditional-access.png"
thumbnail-img: "assets/img/posts/series/conditional-access-framework/150/150-thumb.png"
series: CA
series_order: 150
sidebar: true
level: technique
scope:
  - Entra ID
  - Sessions
  - Token protection
platform: Microsoft Entra
---

## Conditional Access Framework v4 — Session & tokens : ce que le framework protège réellement

Le Conditional Access Framework v4 marque une rupture nette avec les approches historiques de l’accès conditionnel. Cette rupture ne se situe pas dans l’authentification elle-même, mais dans ce qui vient après.

Les attaques modernes ne cherchent plus prioritairement à casser l’authentification. Elles cherchent à exploiter une session valide. Phishing proxy, attaques de type AiTM, vol et réutilisation de tokens : dans ces scénarios, l’attaquant n’a pas besoin de contourner durablement la MFA. Il lui suffit d’hériter d’un accès déjà accordé.

C’est précisément à cet endroit que le framework v4 apporte sa contribution la plus significative.

## De l’authentification à la session : un changement de perspective

Pendant longtemps, l’accès conditionnel a été pensé comme un mécanisme de filtrage à l’entrée. Une fois l’utilisateur authentifié, la session était implicitement considérée comme fiable jusqu’à son expiration.

Le framework v4 abandonne cette hypothèse. Il considère la session comme un objet de sécurité à part entière, soumis à des contraintes, des réévaluations et des limites explicites.

Ce changement de perspective est fondamental. Il ne cherche pas à empêcher toutes les compromissions, mais à limiter ce qu’une compromission permet réellement de faire dans le temps.

## Ce que le framework sait faire sur la session

Le Conditional Access Framework v4 agit sur plusieurs dimensions de la session.

Il peut d’abord limiter sa durée effective. Les politiques de fréquence de connexion et de persistance du navigateur réduisent la fenêtre pendant laquelle un accès compromis reste exploitable.

Il peut ensuite réévaluer la session en cours. Grâce à l’évaluation continue de l’accès, un changement de contexte — élévation de risque, révocation, modification de l’état du device — peut invalider une session sans attendre une nouvelle authentification.

Enfin, il peut conditionner l’usage de la session à des contraintes techniques. Le contexte device, le type de plateforme ou l’état de conformité influencent directement ce que la session permet ou non.

Ces mécanismes ne rendent pas la session inviolable. Ils la rendent plus fragile face à l’exploitation prolongée.

## Ce que le framework ne protège pas

Il est essentiel de poser clairement les limites.

Le Conditional Access Framework ne protège pas les tokens contre tous les scénarios de vol. Un token valide, utilisé dans un contexte encore considéré comme acceptable, peut rester exploitable pendant une période donnée.

Le framework ne voit pas non plus ce qui se passe à l’intérieur de la session applicative. Une fois l’accès accordé, les actions réalisées dans l’application dépendent de ses propres contrôles, pas de l’accès conditionnel.

Enfin, le framework ne remplace ni la détection ni la réponse. Il réduit la surface et la durée d’exploitation, mais il ne détecte pas activement un comportement malveillant sophistiqué.

## Pourquoi les politiques de session arrivent après les blocs d’identité

Dans l’ordre de déploiement, les politiques liées à la session et aux tokens ne doivent jamais être activées en premier.

Ces règles modifient des comportements existants. Elles provoquent des réauthentifications plus fréquentes, des pertes de session perçues comme des anomalies et des ruptures d’usage visibles.

Les activer sans avoir stabilisé :
- les périmètres d’identité,
- les exclusions par personas,
- les usages applicatifs,

revient à introduire des effets difficiles à attribuer et à expliquer.

Le framework suppose que l’identité est déjà correctement cadrée avant d’agir sur la session.

## La logique des exclusions appliquée à la session

Les politiques de session ne s’appliquent pas indistinctement.

Elles excluent systématiquement certains périmètres :
- les comptes de secours ;
- les flux techniques non interactifs ;
- les identités traitées par des règles plus strictes ou spécifiques.

Cette logique garantit que la session est évaluée par la politique la plus pertinente, et évite qu’une contrainte pensée pour un usage standard ne s’applique à un contexte critique ou atypique.

## Ce que le framework cherche réellement à obtenir

L’objectif n’est pas d’empêcher toute exploitation de session. Cet objectif est irréaliste dans des environnements ouverts et interconnectés.

Le framework cherche à :
- réduire la durée d’exploitation ;
- augmenter la dépendance au contexte ;
- multiplier les points de rupture pour l’attaquant.

Une session volée devient plus courte, plus instable et plus difficile à réutiliser de manière fiable.

## Conclusion

Le Conditional Access Framework v4 ne transforme pas l’accès conditionnel en mécanisme de détection avancée. Il ne promet pas l’inviolabilité des sessions ni la protection absolue des tokens.

Il apporte en revanche une réponse pragmatique à une réalité actuelle : l’authentification n’est plus le point de rupture principal, la session l’est devenue.

En traitant la session comme un objet de sécurité à part entière, le framework réduit l’impact des compromissions inévitables et replace l’accès conditionnel à sa juste place : un contrôle de frontière évolué, mais jamais autosuffisant.
