---
title: "Security Defaults vs. Conditional Access : le faux sentiment de sécurité"
date: 2025-12-12 11:30:00 +01:00
layout: post
tags: [series:un-risque-une-mesure, conditional-access, security-defaults]
categories: [identite, entra-id]
readtime: true
comments: true
cover-img: "assets/img/banners/banner4.png"
thumbnail-img: "assets/img/posts/series/un-risque-une-mesure/2025-12-12-security-defaults-vs-conditional-access.png"
series: R1M
series_order: 010
sidebar: true
level: concepts
scope:
  - Entra ID
  - Conditional Access
  - Généralités
featured: true
featured_reason: "Base indispensable à comprendre avant d'aller plus loin."
---

💡 **Activer l’accès conditionnel sans planification, c’est un peu comme retirer les airbags pour installer un ABS.**  

Analogie bagnolistique mise à part, activer l’accès conditionnel dans Microsoft Entra ID est souvent vécu comme un passage obligé vers une sécurité plus mature. On quitte un mécanisme par défaut, jugé simpliste, pour entrer dans un modèle plus fin, plus contextualisé, plus conforme aux discours actuels autour du Zero Trust. Dans beaucoup d’organisations, cette bascule est présentée comme une amélioration presque mécanique du niveau de protection : l’accès conditionnel serait, par nature, supérieur aux Security Defaults.

Ce raisonnement est compréhensible. Il est aussi dangereux.

L’accès conditionnel n’est pas une couche de sécurité supplémentaire venant s’ajouter à un socle existant. C’est un changement complet de modèle, avec des effets immédiats sur ce qui protège réellement un tenant Microsoft 365. Le problème n’est pas tant ce que l’on gagne en activant l’accès conditionnel, mais ce que l’on enlève — parfois sans s’en rendre compte.

![Entra Admin Center - Security Defaults](/assets/img/posts/security-defaults-entra-admin-center.png)

Dans les environnements analysés après incident, le constat est souvent le même : l’accès conditionnel est bien activé, plusieurs politiques existent, certaines sont même avancées, et pourtant le niveau de protection global est inférieur à ce qu’il était auparavant. Non pas parce que l’outil serait défaillant, mais parce que la transition entre deux modèles de sécurité a été abordée comme un simple paramétrage, et non comme une décision structurante.

> Ce n’est pas un problème de configuration.  
> C’est un problème de compréhension.

## Ce que font réellement les Security Defaults

Les Security Defaults souffrent d’une image assez ingrate. Ils sont peu flexibles, peu visibles, et ne donnent pas l’impression de « travailler ». Ils ne proposent ni exceptions fines, ni conditions complexes, ni arbitrages contextuels. Pour beaucoup, ils ressemblent davantage à une béquille temporaire qu’à un véritable mécanisme de sécurité.

Pourtant, leur rôle n’a jamais été de proposer un modèle optimal. Il est de garantir un minimum cohérent.

Les Security Defaults imposent une authentification multifacteur généralisée, renforcent les exigences sur les comptes administrateurs et bloquent les protocoles d’authentification hérités, sans dépendre d’un découpage par groupes, d’une logique d’exception ou d’une expertise particulière. Ils s’appliquent globalement, de manière prévisible, et surtout difficile à affaiblir par inadvertance.

> Leur force n’est pas technique.  
> Elle est organisationnelle.

Tant qu’ils sont actifs, il est compliqué d’introduire une régression majeure sans en être conscient. On peut trouver leur approche brutale, mais elle a une vertu essentielle : elle empêche une organisation de se raconter une histoire rassurante sur son propre niveau de sécurité. Les règles sont simples, visibles, et difficiles à contourner sans décision explicite.

## Le basculement silencieux vers l’accès conditionnel

C’est ici que se situe le point de rupture, et il est rarement mis en avant lors des projets de déploiement.

Dès qu’une première politique d’accès conditionnel est créée, les Security Defaults sont désactivés dans leur intégralité. Il n’existe pas de mode hybride, pas de coexistence progressive, pas de filet de sécurité conservé en arrière-plan. Le socle disparaît immédiatement.

À partir de ce moment, le tenant ne bénéficie plus d’aucune protection implicite fournie par Microsoft. Tout repose désormais sur les politiques définies par l’organisation, avec leurs périmètres, leurs exclusions, leurs priorités et, surtout, leurs angles morts. Ce qui n’a pas été explicitement reconstruit n’existe plus. Ce qui a été oublié n’est plus protégé.

Et c’est rarement aussi maîtrisé qu’on l’imagine.

L’accès conditionnel donne une impression de contrôle. Les écrans sont remplis, les options sont cochées, les politiques existent. Visuellement, le tenant « fait plus sécurisé ». Techniquement, c’est beaucoup moins évident.

## Le faux sentiment de renforcement

Sur le terrain, les situations se ressemblent souvent. Une ou deux politiques sont créées pour répondre à un besoin précis — forcer la MFA, bloquer certains pays, sécuriser un accès distant. Des exclusions sont ajoutées pour éviter les blocages. Le périmètre est limité aux utilisateurs standards. Les administrateurs sont traités à part, parfois repoussés à plus tard.

> Sur le papier, tout est sous contrôle.  
> Dans Entra ID, beaucoup moins.

Lorsque l’on analyse réellement le tenant, on retrouve des utilisateurs hors périmètre parce qu’ils ne font pas partie du bon groupe, des protocoles legacy encore autorisés faute de règle explicite, des comptes administrateurs exclus « temporairement », des invités totalement absents du modèle, ou encore des politiques empilées sans vision d’ensemble.

Pris individuellement, chaque point semble anodin. Pris ensemble, ils constituent une surface d’attaque élargie. Dans ce type de configuration, il n’est pas rare que les Security Defaults aient offert une protection plus homogène que l’accès conditionnel tel qu’il est déployé.

## Ce que l’on observe réellement en audit

Les constats les plus problématiques sont rarement spectaculaires. Ils sont discrets, presque banals, et passent souvent sous les radars tant qu’aucun incident ne survient.

> Un utilisateur sans MFA parce qu’il n’appartient pas au bon groupe.  
> Un compte administrateur exclu pour « éviter un blocage ».  
> Une application héritée jamais intégrée au modèle.  
> Une politique créée pour un besoin ponctuel, jamais revue.

Dans ces situations, l’accès conditionnel n’a pas échoué. Il a fait exactement ce qu’on lui a demandé. C’est le modèle qui était incomplet.

## Concevoir avant de configurer

L’accès conditionnel n’est pas un mécanisme de protection autonome. Il ne protège rien par défaut, n’impose aucun minimum et ne garantit aucune cohérence globale. Il fournit un framework de décision, et laisse à l’organisation la responsabilité de définir ce qui doit être protégé, comment, et jusqu’où.

Avant d’écrire la moindre politique, une question simple devrait être posée : à partir de quel moment considère-t-on que le tenant est réellement protégé ?

La première étape n’est pas l’optimisation.  
C’est la reconstruction explicite du socle.

Cela implique de rétablir sans ambiguïté ce que les Security Defaults assuraient implicitement : une couverture MFA globale, des exigences renforcées pour les rôles à privilèges, le blocage explicite de l’authentification héritée, et une gestion claire des exceptions. Chaque protection doit être visible, compréhensible et vérifiable dans Entra ID.

## Baselines et cohérence dans le temps

Chercher à tout concevoir seul est rarement une bonne idée. Des baselines existent précisément pour éviter les angles morts et maintenir une cohérence lorsque le nombre de politiques augmente.

La Conditional Access Baseline proposée par Joey Verlinden est un exemple d’approche structurée : politiques atomiques, objectifs clairs, séparation des responsabilités et lisibilité dans le temps. L’objectif n’est pas d’y adhérer aveuglément, mais de disposer d’un cadre permettant de raisonner sur l’ensemble du modèle plutôt que sur des règles isolées.

![Joey Verlinden - Conditional Access Baseline](/assets/img/posts/joeyv-conditional-access-baseline.png)

🔗 Référence :  (https://github.com/j0eyv/ConditionalAccessBaseline)

## Tester fait partie de la sécurité

En accès conditionnel, le test n’est pas une étape annexe. C’est une mesure de sécurité à part entière. Une politique doit être observée dans les journaux, confrontée aux scénarios réels et évaluée sur des comptes pilotes avant tout déploiement global.

Ce qui « ne bloque pas » n’est pas nécessairement ce qui protège.

## Derrière la technique, la gouvernance

Activer l’accès conditionnel n’est pas un simple réglage technique. C’est une décision de gouvernance de l’identité. Elle suppose des règles documentées, des responsabilités clairement identifiées et des revues régulières.

Sans ce cadre, l’accès conditionnel devient une dette technique. Et, le jour où un incident survient, un angle mort difficile à expliquer.

---

Cet article n’a pas vocation à convaincre et n'engage que moi. Il sert de point de déaprt à cette série.

Sans cette compréhension, les mécanismes plus avancés abordés dans la suite de la série reposent sur un socle fragile.
