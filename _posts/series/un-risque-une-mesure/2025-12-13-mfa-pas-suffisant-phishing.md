---
title: "MFA ne veut pas dire sécurité : comprendre les limites de la MFA dans Entra ID"
date: 2025-12-14 18:00:00 +01:00
layout: post
tags: [series:un-risque-une-mesure, mfa, phishing]
categories: [identite, entra-id]
readtime: true
comments: true
cover-img: "assets/img/banners/banner3.png"
thumbnail-img: "assets/img/posts/series/un-risque-une-mesure/2025-12-13-mfa-pas-suffisant-phishing.png"
series: R1M
series_order: 010
sidebar: true
level: concepts
scope:
  - Entra ID
  - MFA
---
Cette affirmation peut surprendre, tant l’authentification multifacteur est devenue un prérequis incontournable dans Microsoft Entra ID et Microsoft 365.  
Et pourtant, dans de nombreux incidents récents, **la MFA était bien activée… et n’a pas empêché la compromission**.

La MFA est indispensable.  
Mais **elle n’est plus suffisante à elle seule**.

## Le risque

⚠️ **Considérer la MFA comme une protection complète contre la compromission de comptes conduit à une fausse perception du niveau de sécurité.**

Dans les environnements modernes :
- les attaquants ne cherchent plus seulement à voler un mot de passe,
- ils ciblent l’authentification, la session, puis le token.

La MFA ne protège qu’une étape du processus.

## Rappel : ce que protège réellement la MFA

La MFA intervient **au moment de l’authentification**.  
Elle permet de vérifier que l’utilisateur qui saisit ses identifiants dispose bien d’un facteur supplémentaire (application, clé, SMS, biométrie…).

Ce qu’elle fait bien :
- bloquer les attaques par mot de passe seul,
- augmenter considérablement le coût des attaques basiques,
- réduire l’impact des fuites de mots de passe.

Ce qu’elle **ne fait pas** :
- protéger les sessions déjà établies,
- empêcher le vol ou le rejeu de tokens,
- garantir que l’utilisateur est bien à l’origine de la validation MFA.

## Pourquoi les attaquants ont changé de stratégie

Avec la généralisation de la MFA, le modèle d’attaque a évolué.

Aujourd’hui, l’objectif n’est plus forcément :
> *“se connecter à la place de l’utilisateur”*

mais plutôt :
> *“obtenir un artefact d’authentification réutilisable”*

En pratique :
- token d’accès,
- refresh token,
- session persistante dans un navigateur.

Une fois ce token obtenu, **la MFA n’est plus sollicitée**.

## Les principaux vecteurs de contournement observés

### 1. MFA Fatigue (MFA Bombing)

L’attaquant :
- connaît le mot de passe,
- déclenche volontairement une rafale de demandes MFA,
- mise sur l’erreur humaine.

Dans les environnements peu sensibilisés, il suffit parfois :
- d’un clic machinal,
- d’un moment d’inattention,
- d’un utilisateur sous pression.

La MFA est validée… par la victime elle-même.

### 2. Reverse proxy et phishing moderne (AiTM)

Dans une attaque AiTM typique, décrite par Microsoft, le déroulé est le suivant :

1. L’utilisateur est redirigé vers un site de phishing jouant le rôle de proxy
2. Ce site relaie la page de connexion Microsoft officielle
3. L’utilisateur saisit ses identifiants
4. La demande MFA est transmise en temps réel
5. L’utilisateur valide légitimement la MFA
6. Entra ID émet un token de session
7. Le token est intercepté par l’attaquant

À ce stade :
- aucune alerte MFA n’a été contournée,
- aucune faiblesse cryptographique n’a été exploitée,
- **le modèle de confiance a simplement été abusé**.

Microsoft insiste sur un point clé :  
> *dans une attaque AiTM, la MFA fonctionne exactement comme prévu.*

Le problème n’est donc pas l’authentification, mais **la réutilisabilité du token hors de son contexte d’émission**.

### 3. Vol de session et rejeu de tokens

Une fois la session établie :
- malware,
- navigateur compromis,
- extension malveillante,
- accès local à la machine,

peuvent permettre d’extraire des tokens encore valides.

Ces tokens peuvent être :
- rejoués depuis un autre contexte,
- utilisés sans nouvelle authentification,
- persistants sur plusieurs heures ou jours.

La MFA n’est plus sollicitée.

### 4. MFA faible ou mal configurée

Toutes les MFA ne se valent pas :
- SMS,
- notifications push simples,
- absence de contrôle de contexte.

Dans certains cas, la MFA est réduite à une formalité, facile à détourner ou à abuser.

## Le point commun à tous ces scénarios

Dans chaque cas :
- l’authentification a bien eu lieu,
- la MFA a été validée,
- **le problème se situe après l’authentification**.

👉 Le vrai enjeu n’est plus uniquement *qui s’authentifie*,  
mais **ce qui est utilisé après l’authentification** :
- session,
- token,
- contexte d’accès.

## Le changement de paradigme côté Microsoft Entra

Microsoft ne positionne plus la MFA comme un contrôle suffisant à elle seule.

Le modèle de sécurité promu par Entra ID repose désormais sur trois piliers :

- une authentification forte,
- des tokens protégés et contextualisés,
- une évaluation continue de l’accès.

Dans cette logique :
- la MFA protège l’entrée,
- la protection des tokens limite la valeur d’une compromission,
- l’évaluation continue permet de réagir **après** l’authentification.

C’est une rupture avec les modèles historiques basés uniquement sur l’identité déclarative.

## La mesure : penser en termes de chaîne de confiance

Pour renforcer réellement la sécurité, il faut raisonner sur l’ensemble de la chaîne :

> **Authentification → Token → Session → Contexte**

### 1. Lier les tokens au contexte : Token Protection

Microsoft introduit la **Token Protection** précisément pour répondre aux attaques AiTM.

L’objectif n’est pas d’empêcher le vol de token — ce qui est irréaliste —  
mais de **rendre le token inutilisable hors de son contexte d’émission**.

Concrètement, le token peut être lié :
- à l’appareil,
- à la session,
- à certaines caractéristiques du client.

Ainsi :
- un token intercepté via un reverse proxy,
- ou extrait depuis une machine compromise,
- ne pourra pas être rejoué depuis un autre environnement.

Microsoft est très clair sur ce point :
> *un token volé doit perdre toute valeur opérationnelle.*

C’est un changement majeur dans la manière de penser la sécurité des identités.

### 2. Utiliser une MFA résistante au phishing

Toutes les MFA ne sont pas équivalentes face aux attaques modernes.

Les MFA dites résistantes au phishing reposent sur :
- des clés matérielles,
- des méthodes liées à l’origine de la requête,
- une impossibilité technique de rejouer la validation ailleurs.

Elles empêchent :
- les reverse proxies,
- la validation MFA hors contexte légitime.

## Pourquoi Microsoft insiste sur la MFA résistante au phishing

Dans ses recommandations, Microsoft distingue explicitement :
- la MFA classique,
- la MFA résistante au phishing.

Les méthodes résistantes au phishing ont un point commun :
- elles lient la validation MFA à l’origine réelle de la requête,
- elles empêchent techniquement une validation via un proxy intermédiaire.

Dans un scénario AiTM :
- la MFA classique peut être validée à l’insu de l’utilisateur,
- la MFA résistante au phishing bloque la chaîne d’attaque dès l’origine.

Ce n’est pas un durcissement cosmétique, mais une **rupture fonctionnelle** face aux attaques modernes.

### 3. Réduire la surface d’attaque liée au MFA bombing

Limiter les notifications MFA permet :
- de réduire la fatigue utilisateur,
- de rendre les attaques plus visibles,
- de renforcer la vigilance.

Mais surtout, cela doit s’accompagner d’un message clair :
> **une demande MFA inattendue doit toujours être refusée.**

### 4. Exploiter les signaux de risque

Entra ID fournit des signaux précieux :
- impossible travel,
- sign-in risk,
- user risk,
- anomalies comportementales.

Ces signaux permettent :
- de déclencher des contrôles supplémentaires,
- de bloquer automatiquement certaines connexions,
- de sortir d’une logique purement statique.

## Gouvernance et sensibilisation : le facteur souvent négligé

Aucune mesure technique ne compensera :
- une incompréhension des utilisateurs,
- une absence de message clair,
- un discours contradictoire.

La MFA doit être expliquée comme :
- un **contrôle actif**,  
- qui nécessite une action consciente,
- et non comme une validation automatique.

## Ce que cet article ne dit pas explicitement (mais que Microsoft confirme)

Microsoft ne dit pas que la MFA est obsolète.  
Microsoft dit que **la MFA seule ne correspond plus au modèle de menace actuel**.

Le message sous-jacent est clair :
- l’identité ne s’arrête pas à l’authentification,
- le token est devenu l’actif critique,
- le contexte d’accès est désormais un signal de sécurité à part entière.

Ne pas intégrer ces dimensions, c’est défendre un modèle déjà dépassé.

## Ce que Microsoft appelle réellement une attaque AiTM

Microsoft qualifie les attaques modernes de phishing de type **Adversary-in-the-Middle (AiTM)**.

Le principe est fondamentalement différent du phishing classique :

- l’attaquant ne cherche pas à collecter des identifiants pour plus tard,
- il s’interpose **en temps réel** entre l’utilisateur et le service légitime,
- il relaie la page de connexion officielle,
- il intercepte **les identifiants, la MFA et surtout les tokens émis après authentification**.

Du point de vue d’Entra ID :
- l’authentification est valide,
- la MFA est correctement satisfaite,
- le token est légitime.

C’est précisément ce qui rend ces attaques si efficaces.

## À retenir

- La MFA est indispensable, mais insuffisante seule
- Les attaques modernes ciblent les tokens et les sessions
- Une MFA validée peut profiter à l’attaquant
- La résilience repose sur :
  - l’authentification,
  - la protection des tokens,
  - le contexte d’accès
- La sécurité de l’identité est une chaîne, pas un bouton

---

La MFA reste indispensable. Elle n’est simplement plus la fin de l’histoire.
