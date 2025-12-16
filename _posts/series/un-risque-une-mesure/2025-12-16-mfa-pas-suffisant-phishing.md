---
title: "MFA ne veut pas dire sécurité : comprendre pourquoi l’authentification MFA ne suffit plus"
date: 2025-12-16 18:00:00 +01:00
layout: post
tags: [series:un-risque-une-mesure, mfa, entra-id, identité, phishing, token]
categories: [identite, entra-id]
readtime: true
comments: true
cover-img: "assets/img/banners/banner5.png"
thumbnail-img: "assets/img/posts/series/un-risque-une-mesure/2025-12-13-mfa-pas-suffisant-phishing.png"
series: R1M
series_order: 020
sidebar: true
level: concepts
scope:
  - Entra ID
  - MFA
  - Sécurité de l’identité
---

Dire que la MFA ne suffit plus surprend encore beaucoup d'entreprises.  
Dans Microsoft Entra ID comme dans Microsoft 365, l’authentification multifacteur est devenue un prérequis quasi systématique. Elle est souvent présentée comme une garantie de sécurité, parfois même comme une ligne d’arrivée.

Dans les faits, une part significative des incidents récents raconte une autre histoire : les comptes compromis ont une MFA active, les utilisateurs valident leurs demandes et les journaux montrent des authentifications conformes. Pourtant, l’attaquant a pu accéder aux ressources.

La MFA reste indispensable, oui, mais elle ne protège qu’une partie du de la chaîne d'authentification.

## Le risque : confondre authentification et sécurité de l’identité

Le premier risque n’est pas technique, il est conceptuel.  
Considérer la MFA comme une protection globale conduit à une surestimation du niveau de sécurité réel. On pense avoir sécurisé l’identité, alors qu’on n’a sécurisé qu’un instant précis du parcours d’accès.

Dans les environnements modernes, les attaquants ne cherchent plus seulement à se connecter. Ils cherchent à obtenir quelque chose de réutilisable après la connexion. Ce glissement est fondamental.

## Ce que la MFA fait réellement — et ce qu’elle ne fait pas

La MFA intervient à un moment très précis : l’authentification initiale.  
Elle permet de vérifier que la personne qui présente un identifiant dispose bien d’un facteur supplémentaire, qu’il s’agisse d’une application mobile, d’une clé matérielle, d’un SMS ou d’un facteur biométrique.

Dans ce rôle, son efficacité est largement démontrée. Elle bloque les attaques reposant uniquement sur des mots de passe compromis, rend obsolètes les campagnes de credential stuffing basiques et augmente fortement le coût d’entrée pour un attaquant opportuniste.

En revanche, une fois l’authentification validée, la MFA sort du champ de décision.  
À partir du moment où Entra ID émet un jeton d’accès ou de session, le système ne se demande plus si l’utilisateur a validé une MFA. Il se demande uniquement si le token présenté est valide.

Cette nuance est rarement explicitée. Elle change pourtant complètement la lecture des attaques modernes.

## Pourquoi le modèle d’attaque a évolué

Pendant longtemps, l’objectif d’un attaquant était simple : voler des identifiants pour les utiliser plus tard.  
La généralisation de la MFA a rendu ce modèle moins rentable. Les attaquants se sont adaptés.

Aujourd’hui, l’objectif n’est plus seulement l’identité déclarative, mais les artefacts d’authentification. Tokens d’accès, refresh tokens, cookies de session persistants ont une valeur opérationnelle immédiate. Une fois en possession de l’attaquant, ils permettent d’accéder aux ressources sans repasser par l’authentification.

La MFA a fonctionné.  
Elle a simplement déplacé la cible.

## Quand la MFA fonctionne… et que l’attaque réussit quand même

### MFA fatigue : l’erreur humaine exploitée

La MFA fatigue repose sur un principe simple : exploiter le facteur humain.  
L’attaquant déclenche une rafale de demandes MFA jusqu’à obtenir une validation, souvent par automatisme, pression ou incompréhension.

Techniquement, rien n’est cassé.  
Cryptographiquement, tout est conforme.  
Organisationnellement, le contrôle est fragile.

La MFA fonctionne. Elle est simplement validée par la mauvaise personne.

### AiTM : l’authentification parfaitement légitime

Les attaques Adversary-in-the-Middle (AiTM) représentent aujourd’hui le cœur du phishing moderne. Microsoft les documente abondamment, notamment via ses équipes Entra et Defender.

Dans un scénario AiTM, l’attaquant ne cherche pas à imiter grossièrement une page de connexion. Il s’interpose en temps réel entre l’utilisateur et le service légitime. L’utilisateur voit la vraie page Microsoft, saisit ses identifiants, valide sa MFA. Entra ID émet alors un token parfaitement légitime.

![Overview of AiTM phishing](https://www.microsoft.com/en-us/security/blog/wp-content/uploads/2022/07/Figure1-overview-of-aitm-phishing.png)

La différence est invisible pour l’utilisateur : le token est intercepté avant d’arriver à son navigateur et peut ensuite être rejoué depuis un autre environnement.

Du point de vue d’Entra ID :
- l’authentification est valide,
- la MFA est satisfaite,
- aucun mécanisme cryptographique n’est violé.

Microsoft est très clair sur ce point : dans une attaque AiTM, la MFA fonctionne exactement comme prévu.

🔗 Article Microsoft TechCommunity  :
https://techcommunity.microsoft.com/blog/microsoft-entra-blog/defeating-adversary-in-the-middle-phishing-attacks/1751777

### Vol de session et rejeu de tokens

Une fois la session établie, d’autres vecteurs entrent en jeu.  
Navigateur compromis, extension malveillante, malware local ou accès physique permettent parfois d’extraire des tokens encore valides.

Ces tokens peuvent être rejoués depuis un autre contexte pendant plusieurs heures, parfois plusieurs jours. La MFA n’est plus invoquée. Elle a déjà fait son travail.

## Le point commun de tous ces scénarios

Dans tous les cas observés, l’authentification a eu lieu et la MFA a été validée.  
La compromission se produit après.

Le véritable actif critique n’est plus l’identité, mais le token.  
Et le véritable enjeu n’est plus uniquement de savoir qui s’authentifie, mais dans quel contexte et avec quels artefacts.

## Le virage opéré par Microsoft Entra

Microsoft ne présente plus la MFA comme un contrôle autonome.  
Le modèle de sécurité promu par Entra ID repose désormais sur une chaîne complète : authentification, tokens, sessions, contexte et évaluation continue.

Dans cette approche, la MFA protège l’entrée.  
La sécurité repose sur ce qui se passe après.

C’est dans cette logique qu’apparaissent la MFA résistante au phishing, la Token Protection, la Continuous Access Evaluation et l’exploitation systématique des signaux de risque.

## Token Protection : réduire la valeur d’un token volé

La Token Protection, intégrée à l’accès conditionnel Entra ID, ne cherche pas à empêcher le vol de token. Microsoft part d’un constat réaliste : dans certains scénarios, le vol est inévitable.

L’objectif est différent : rendre le token inutilisable hors de son contexte d’émission.

Un token intercepté via un reverse proxy ou extrait d’un poste compromis perd alors toute valeur opérationnelle s’il est rejoué ailleurs.

![Token Protection – Session Control](https://learn.microsoft.com/fr-fr/entra/identity/conditional-access/media/concept-token-protection/complete-policy-components-session.png)

🔗 Documentation Microsoft :
https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-token-protection

## MFA résistante au phishing : une différence fonctionnelle

Toutes les MFA ne se valent pas. Microsoft distingue explicitement les méthodes résistantes au phishing, capables de bloquer techniquement les attaques AiTM.

Ces méthodes lient la validation MFA à l’origine réelle de la requête et empêchent toute validation via un proxy intermédiaire.

🔗 Documentation Microsoft :
https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-phishing-resistant

## Gouvernance et réalité opérationnelle

Aucune mesure technique ne compense une absence de gouvernance.  
La MFA doit être comprise comme un contrôle actif, jamais comme une formalité : une demande MFA inattendue doit être refusée, les journaux doivent être analysés, les scénarios doivent être testés.

Sans ce cadre, la MFA devient une illusion de sécurité.

## À retenir

La MFA reste indispensable, mais elle ne protège qu’à instant du parcours d'authentification : les attaques sur l'identité ciblent les tokens et les sessions.  
La sécurité de l’identité repose donc sur une chaîne complète, pas juste sur une notification dans une application.

Dans le prochain article, je détaillerai comment mettre en place le mécanisme de Token Protection grâce à une politique d'accès conditionnel dans Entra ID. 