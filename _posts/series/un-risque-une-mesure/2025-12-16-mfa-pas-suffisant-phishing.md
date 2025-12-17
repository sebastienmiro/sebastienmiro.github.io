---
title: "MFA ne veut pas dire sécurité : comprendre pourquoi l’authentification MFA ne suffit plus"
date: 2025-12-16 18:00:00 +01:00
layout: post
tags: [series:un-risque-une-mesure, mfa, entra-id, identité, phishing, token]
categories: [identite, entra-id]
readtime: true
comments: true
cover-img: "assets/img/banners/banner5.png"
thumbnail-img: "assets/img/posts/series/un-risque-une-mesure/2025-12-16-mfa-pas-suffisant-phishing.png"
series: R1M
series_order: 020
sidebar: true
level: concepts
scope:
  - Entra ID
  - MFA
  - Sécurité de l’identité
---

Dire que la MFA ne suffit plus surprend encore beaucoup d'entreprises, de DSI et d'administrateurs.  
Dans Microsoft Entra ID comme dans Microsoft 365, l’authentification multifacteur est devenue un prérequis quasi systématique, au point d’être parfois perçue comme une garantie implicite de sécurité. Lorsqu’elle est activée, elle rassure. Elle coche une case devenue incontournable dans les audits, les recommandations éditeurs et les discours commerciaux. Pour certains, elle marque même une forme de ligne d’arrivée.

Pourtant, lorsque l’on regarde les incidents récents avec un minimum de recul, le récit est souvent le même. Les comptes compromis disposent bien d’une MFA active. Les utilisateurs ont validé leurs demandes sans alerte particulière. Les journaux d’authentification montrent des connexions conformes, sans échec apparent ni contournement visible. Et malgré cela, l’attaquant a pu accéder aux ressources, parfois de manière durable.

Ce décalage crée une incompréhension persistante. Comment un compte protégé par MFA peut-il être compromis sans qu’aucun mécanisme ne semble avoir échoué ? La réponse tient rarement à une faille cryptographique ou à un exploit sophistiqué. Elle tient beaucoup plus souvent à une confusion fondamentale entre ce que protège réellement la MFA et ce qu’on attend implicitement d’elle.

La MFA reste indispensable.  
Mais elle ne protège qu’un moment précis de la chaîne d’authentification.

## Le risque : sécuriser un instant, pas une identité

Le premier risque n’est pas technique. Il est conceptuel.

Assimiler la MFA à une protection globale de l’identité conduit à surestimer le niveau de sécurité réel d’un environnement. On pense avoir sécurisé “l’accès”, alors qu’on n’a sécurisé qu’un instant précis du parcours utilisateur : celui où l’identité est vérifiée avant l’émission des jetons.

Dans les environnements modernes, les attaquants ne cherchent plus seulement à se connecter. Ils cherchent à obtenir quelque chose de réutilisable après la connexion. Ce glissement est essentiel pour comprendre pourquoi la MFA, bien qu’efficace, ne suffit plus à elle seule.

## Ce que la MFA protège réellement — et ce qu’elle ne protège pas

La MFA intervient au moment de l’authentification initiale.  
Elle permet de vérifier que la personne qui présente un identifiant dispose bien d’un facteur supplémentaire, qu’il s’agisse d’une application mobile, d’une clé matérielle, d’un SMS ou d’un facteur biométrique. Dans ce rôle précis, son efficacité n’est plus à démontrer : elle bloque les attaques par mot de passe seul, rend obsolètes les campagnes de credential stuffing basiques et augmente significativement le coût d’entrée pour un attaquant opportuniste.

En revanche, une fois cette étape franchie, la MFA sort du champ de décision. À partir du moment où Entra ID émet un jeton d’accès ou de session, le système ne se demande plus si l’utilisateur a validé une MFA. Il se contente de vérifier si le token présenté est valide.

Cette nuance est rarement explicitée. Elle change pourtant complètement la lecture des attaques modernes.

## Quand la MFA a fonctionné… et que l’attaque réussit quand même

Pendant longtemps, l’objectif d’un attaquant était simple : voler des identifiants pour les utiliser plus tard. La généralisation de la MFA a rendu ce modèle moins rentable. Les attaquants se sont adaptés.

Aujourd’hui, la valeur ne réside plus uniquement dans l’identité déclarative, mais dans les artefacts d’authentification : tokens d’accès, refresh tokens, cookies de session persistants. Une fois en possession de ces éléments, l’attaquant n’a souvent plus besoin de repasser par une phase d’authentification. La MFA a fait son travail. L’accès repose désormais sur la validité du token.

La MFA a donc fonctionné.  
Elle a simplement déplacé la cible.

### MFA fatigue : quand le facteur humain devient le maillon faible

La MFA fatigue repose sur une logique simple et redoutablement efficace. L’attaquant déclenche une rafale de demandes MFA jusqu’à obtenir une validation, souvent par automatisme, par lassitude ou par pression contextuelle. D’un point de vue technique, rien n’est cassé. Cryptographiquement, tout est conforme. Organisationnellement, le contrôle repose sur un comportement humain fragile.

La MFA est validée par la victime elle-même.  
Et le système considère légitimement que l’accès est autorisé.

### AiTM : une authentification parfaitement légitime

Les attaques de type Adversary-in-the-Middle (AiTM) représentent aujourd’hui le cœur du phishing moderne. Microsoft les documente abondamment, notamment dans ses publications Entra et Defender.

Dans un scénario AiTM, l’attaquant ne cherche pas à imiter grossièrement une page de connexion. Il s’interpose en temps réel entre l’utilisateur et le service légitime. L’utilisateur voit la vraie page Microsoft, saisit ses identifiants, valide sa MFA. Entra ID émet alors un token parfaitement légitime.

![Overview of AiTM phishing](https://www.microsoft.com/en-us/security/blog/wp-content/uploads/2022/07/Figure1-overview-of-aitm-phishing.png)

La différence est invisible pour l’utilisateur : le token est intercepté avant d’arriver à son navigateur et peut ensuite être rejoué depuis un autre environnement. Du point de vue d’Entra ID, tout est conforme. La MFA n’a pas été contournée. Elle a été utilisée exactement comme prévu.

🔗 [TechCommunity - AiTM](https://techcommunity.microsoft.com/blog/microsoft-entra-blog/defeating-adversary-in-the-middle-phishing-attacks/1751777)

### Vol de session et rejeu de tokens

Une fois la session établie, d’autres vecteurs entrent en jeu. Navigateur compromis, extension malveillante, malware local ou accès physique permettent parfois d’extraire des tokens encore valides. Ces tokens peuvent être rejoués pendant plusieurs heures, parfois plusieurs jours, sans que la MFA ne soit à nouveau sollicitée.

Dans tous ces scénarios, le point commun est le même : l’authentification a bien eu lieu, la MFA a été validée, et la compromission intervient après.

## Le véritable actif critique : le token

Ce que montrent ces attaques, ce n’est pas l’obsolescence de la MFA, mais un changement de focalisation. Le véritable actif critique n’est plus uniquement l’identité, mais le token. Et le véritable enjeu n’est plus seulement de savoir qui s’authentifie, mais dans quel contexte et avec quels artefacts l’accès est maintenu.

## Le virage opéré par Microsoft Entra

Microsoft ne présente plus la MFA comme un contrôle autonome. Le modèle de sécurité promu par Entra ID repose désormais sur une chaîne complète : authentification, tokens, sessions, contexte et évaluation continue.

Dans cette approche, la MFA protège l’entrée.  
La sécurité se joue sur ce qui se passe après.

C’est dans cette logique qu’apparaissent la MFA résistante au phishing, la Token Protection, la Continuous Access Evaluation et l’exploitation systématique des signaux de risque.

## Token Protection : réduire la valeur d’un token volé

La Token Protection, intégrée à l’accès conditionnel Entra ID, ne cherche pas à empêcher le vol de token. Microsoft part d’un constat réaliste : dans certains scénarios, le vol est inévitable. L’objectif est différent : rendre le token inutilisable hors de son contexte d’émission.

Un token intercepté via un reverse proxy ou extrait d’un poste compromis perd alors toute valeur opérationnelle s’il est rejoué ailleurs.

![Token Protection – Session Control](https://learn.microsoft.com/fr-fr/entra/identity/conditional-access/media/concept-token-protection/complete-policy-components-session.png)

🔗 [Microsoft Learn - Token Protection](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-token-protection)

## MFA résistante au phishing : une différence fonctionnelle

Toutes les MFA ne se valent pas. Microsoft distingue explicitement les méthodes résistantes au phishing, capables de bloquer techniquement les attaques AiTM. Ces méthodes lient la validation MFA à l’origine réelle de la requête et empêchent toute validation via un proxy intermédiaire.

🔗 [Microsoft Learn - Phishing Resistant MFA](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-phishing-resistant)

## Gouvernance et réalité opérationnelle

Aucune mesure technique ne compense une absence de gouvernance. La MFA doit être comprise comme un contrôle actif, jamais comme une formalité. Une demande MFA inattendue doit être refusée. Les journaux doivent être analysés. Les scénarios doivent être testés.

Sans ce cadre, la MFA devient une illusion de sécurité.

Dans le prochain article, je rentrerai dans le concret : comment mettre en œuvre la Token Protection via l’accès conditionnel dans Entra ID, et surtout ce que cela change réellement en situation d’incident.
