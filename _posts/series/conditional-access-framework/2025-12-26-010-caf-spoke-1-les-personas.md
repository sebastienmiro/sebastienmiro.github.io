---
title: "Conditional Access Framework v4 — Les personas comme point de départ"
date: 2025-12-26 08:45:00 +01:00
layout: post
tags: [series:conditional-access-framework, conditional-access, gouvernance]
categories: [identite, entra-id]
readtime: true
comments: true
cover-img: "assets/img/banners/banner-conditional-access.png"
thumbnail-img: "assets/img/posts/series/conditional-access-framework/010/010-thumb.png"
series: Conditional Access Framework
series_order: 010
sidebar: true
level: concepts
scope:
  - Entra ID
  - Conditional Access
  - Personas
platform: Microsoft Entra
---

L’une des forces du Conditional Access Framework v4 est de ne pas commencer par des règles.  
Il commence par des **personas**.

Ce choix peut sembler anodin, mais il est en réalité structurant. Dans beaucoup d’environnements, l’accès conditionnel s’est construit à l’envers : une règle pour un incident, une autre pour une recommandation d’audit, puis une troisième pour “être tranquille”. Au fil du temps, on obtient un empilement de politiques difficiles à lire, difficiles à expliquer, et surtout difficiles à faire évoluer sans risque.

Le framework prend le problème à la racine. Avant de parler de conditions, de contrôles ou de paramètres, il pose une question simple : **qui est en train de se connecter ?** Et, implicitement : **quel est le niveau de risque acceptable pour cette identité-là**.

Les personas ne sont donc pas une abstraction théorique. Elles sont le mécanisme qui permet d’éviter que toutes les identités soient traitées comme si elles présentaient le même niveau d’exposition.

## Un persona n’est pas un rôle, ni un groupe métier

Il est important de lever un malentendu fréquent.

Dans le cadre du Conditional Access Framework, un persona n’est ni un rôle RH, ni un groupe fonctionnel, ni une classification organisationnelle.  
Un persona représente un **profil de risque et d’exposition**, vu uniquement sous l’angle de l’identité et de l’accès.

Il répond à des questions très concrètes :
- Quel est l’impact si ce compte est compromis ?
- À quelle fréquence est-il utilisé ?
- Dans quels contextes techniques s’authentifie-t-il ?
- Quelle friction peut-on raisonnablement imposer à l’authentification ?

C’est pour cette raison que le framework raisonne en personas techniques. Une même personne peut d’ailleurs appartenir à plusieurs personas selon les comptes qu’elle utilise : un compte standard pour le quotidien, un compte à privilèges pour l’administration, voire un compte de secours qu’elle n’utilise qu’en dernier recours.

## Des identités aux profils de risque fondamentalement différents

![Les personas du framework](/assets/img/posts/2025/12/2025-12-26-caf-v4-personas.png)

Traiter toutes les identités de la même façon revient à nier des différences de risque pourtant évidentes.  
Un compte utilisé dix fois par jour depuis un poste maîtrisé n’a rien à voir avec un compte administrateur, un compte invité ou une identité applicative.

Le framework ne cherche pas à multiplier les catégories, mais à **nommer clairement ces différences**, afin qu’elles se traduisent ensuite par des politiques lisibles et cohérentes.  
C’est pour cette raison qu’il formalise plusieurs personas techniques, chacun correspondant à un niveau d’exposition et d’impact distinct.

Les sections suivantes décrivent ces personas, non pas comme une classification abstraite, mais comme les points d’entrée concrets des décisions d’accès conditionnel.

### Utilisateurs standards

C’est le persona le plus large, et souvent celle par laquelle on commence… parfois trop vite.

Elle regroupe les comptes utilisés au quotidien pour accéder à la messagerie, aux applications métiers, aux outils collaboratifs. Le framework considère ces identités comme **exposées par nature**, mais avec un impact *généralement* contenu en cas de compromission.

L’objectif n’est pas de bloquer toute tentative d’accès, mais de réduire les scénarios de compromission simples et répétables, tout en conservant une expérience utilisateur acceptable.

**Exemple terrain**  
Un utilisateur reçoit un e-mail de phishing crédible, clique sur le lien et saisit ses identifiants sur une fausse page. Les identifiants sont compromis.

Avec le CAF v4 correctement déployé :
- une tentative de connexion depuis un pays inhabituel peut être bloquée par défaut ;
- un accès depuis un device non maîtrisé peut être fortement restreint ;
- certaines actions sensibles peuvent être limitées même si la connexion aboutit.

Le framework ne prétend pas empêcher toutes les compromissions, et il ne bloque pas systématiquement un vol de token. En revanche, il **réduit fortement la capacité de l’attaquant à exploiter immédiatement le compte**, ce qui change radicalement l’impact opérationnel de l’incident.

Les politiques associées aux utilisateurs standards constituent une base. Elles ne doivent jamais être utilisées comme référence pour d’autres types de comptes.

### Comptes à privilèges et administrateurs

Le framework isole très clairement les comptes à privilèges des utilisateurs standards, et ce n’est pas négociable.

Un compte administrateur n’est pas simplement un utilisateur “avec plus de droits”. C’est une **surface d’attaque critique**, avec un impact critique en cas de compromission. Le framework en tire une conséquence directe : ces comptes doivent sortir du flux normal d’authentification.

Cela se traduit par :
- des exigences d’authentification plus fortes ;
- des contraintes accrues sur l'appareil et le contexte ;
- une tolérance au risque beaucoup plus faible.

**Exemple terrain**  
Un administrateur se connecte depuis son poste personnel en déplacement.  
Dans un modèle uniforme, l’accès passe “comme d’habitude”.  
Avec le framework, le contexte suffit à déclencher des exigences supplémentaires, voire un blocage, sans impacter les utilisateurs standards.

Cette séparation conceptuelle évite une erreur encore fréquente : appliquer les mêmes règles à tout le monde, en espérant que cela suffira.

### Identités non humaines et workloads

Les identités applicatives, comptes de service et workloads ne se comportent pas comme des utilisateurs humains. Elles n’utilisent pas de MFA interactif, n’ont pas de device au sens classique, et sont souvent invisibles jusqu’au jour où quelque chose casse.

Le framework les considère comme une catégorie distincte. L’objectif n’est pas de leur appliquer des contrôles inadaptés, mais de **leur donner un traitement explicite**, cohérent avec leurs usages réels.

**Exemple terrain**  
Un compte de service compromis ne déclenche souvent aucune alerte visible côté utilisateur. Sans règles dédiées, il peut rester exploitable longtemps. Le CAF v4 force au minimum à identifier ces identités et à leur appliquer des décisions d’accès spécifiques, au lieu de les laisser “passer entre les mailles”.

### Invités et identités externes

Enfin, le framework isole les identités externes : invités, partenaires, prestataires. Leur niveau de confiance initial est par définition plus faible, et leur contexte d’authentification plus difficile à maîtriser.

Les regrouper dans un persona dédié permet d’appliquer des politiques cohérentes sans affaiblir celles destinées aux utilisateurs internes, ni multiplier les exceptions permanentes.

## Pourquoi les personas conditionnent l’ordre de déploiement

Les personas ne servent pas uniquement à organiser les règles. Elles dictent aussi **l’ordre logique de mise en œuvre**.

Le framework incite implicitement à commencer par :
- les identités à fort impact,
- les scénarios transverses,
- avant d’élargir aux usages quotidiens.

Cette approche réduit les effets de bord, limite les blocages accidentels et diminue la tentation de créer des exclusions “en urgence”. Elle explique aussi pourquoi un déploiement global et simultané conduit presque toujours à un accès conditionnel fragile et illisible.

## Ce que les personas ne font pas

Les personas ne remplacent ni la gouvernance des droits, ni la gestion des rôles, ni la classification métier. Elles ne disent rien de ce qu’un utilisateur est autorisé à faire.

Elles définissent uniquement **dans quelles conditions l’accès est accordé**.

Cette séparation est volontaire. L’accès conditionnel décide de l’entrée. Le reste relève d’autres mécanismes.

### Le cas particulier des comptes de secours (break-glass)

Le framework traite les comptes de secours comme un cas à part, mais **pas au sens d’un ensemble de politiques dédiées**.

Dans le Conditional Access Framework v4, les comptes break-glass ne sont pas protégés par des règles spécifiques. Ils sont au contraire **explicitement exclus de l’ensemble des politiques d’accès conditionnel**. Ce choix est volontaire et assumé : ces comptes existent avant tout pour **rester accessibles dans des scénarios de défaillance**, y compris lorsque l’accès conditionnel devient lui-même un point de blocage.

Erreur de configuration, déploiement défectueux, panne d’un fournisseur d’identité ou d’un mécanisme d’authentification : dans ces situations, la priorité n’est pas la réduction du risque, mais la capacité à reprendre la main.

Le framework ne cherche donc pas à intégrer les comptes de secours dans les flux classiques de décisions d’accès. Il les **isole par exclusion**, afin qu’aucune règle globale, administrative ou contextuelle ne puisse les rendre inaccessibles par effet de bord.

Ce point est critique sur le terrain. Mélanger des comptes break-glass avec d’autres personas — même “temporairement” — est l’une des erreurs les plus coûteuses que l’on puisse faire en accès conditionnel.

> À noter toutefois : le fait que le framework n’introduise pas de politiques dédiées aux comptes de secours n’empêche pas d’imaginer des évolutions. Dans des environnements matures, le traitement explicite de ces comptes par des règles très ciblées, hors du flux principal, pourrait constituer une amélioration pertinente — à condition de ne jamais compromettre leur fonction première : rester accessibles quand tout le reste échoue.

## Conclusion

Le Conditional Access Framework v4 commence par les personas parce que c’est, à mon sens, le seul moyen d’éviter une approche uniforme et inefficace de l’accès conditionnel. En distinguant clairement les profils de risque, le framework permet de construire des politiques compréhensibles, maintenables et cohérentes dans le temps.

Comprendre les personas n’est pas un prérequis théorique.  
C’est la condition nécessaire pour que toutes les règles qui suivent aient un sens.

Dans les articles suivants, chaque bloc de politiques sera analysé à travers ce prisme, en commençant par le socle commun qui s’applique à plusieurs de ces personas.
