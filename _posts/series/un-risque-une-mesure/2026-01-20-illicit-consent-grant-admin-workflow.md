---
title: "Le clic qui contourne la MFA : comprendre le Consent Phishing"
date: 2026-01-20 08:00:00 +01:00
layout: post
tags: [series:un-risque-une-mesure, entra-id, security, oauth, consent-framework]
categories: [securite, entra-id]
readtime: true
comments: true
cover-img: "assets/img/banners/banner-phishing.png"
thumbnail-img: "assets/img/posts/series/un-risque-une-mesure/2026-01-19-consent-phishing.png"
series: R1M
series_order: 070
sidebar: true
level: concepts
scope:
  - Entra ID
  - OAuth 2.0
  - Application Governance
---

Nous avons passé des années à expliquer aux utilisateurs qu’il ne fallait jamais communiquer son mot de passe.  
La plupart ont intégré le message. Les attaquants aussi.

Aujourd’hui, de nombreuses compromissions ne passent plus par le vol d’identifiants, ni même par le contournement de la MFA. Elles reposent sur un mécanisme parfaitement légitime, documenté et encouragé par les plateformes cloud : **le consentement OAuth**.

Le *Consent Phishing* ne cherche pas à casser l’authentification. Il l’utilise exactement comme prévu.

## Le risque : quand l’authentification fonctionne

Dans un scénario de phishing classique, l’utilisateur est redirigé vers une fausse page de connexion.  
S’il est vigilant, ou s’il utilise une MFA résistante au phishing, l’attaque échoue.

Avec le consent phishing, le déroulé est différent.

![Entra ID - Illicit consent workflow](/assets/img/posts/series/un-risque-une-mesure/2026-01-19-illicit-consent-grant.png)

L’utilisateur reçoit un lien vers une application présentée comme légitime : outil collaboratif, mise à jour Office, connecteur métier.  
Il clique, arrive sur **la vraie page Microsoft**, s’authentifie normalement et valide sa MFA sans anomalie.

C’est seulement après cette étape qu’apparaît l’écran de consentement standard :  
*l’application souhaite accéder à votre profil, vos fichiers ou vos emails*.

Lorsque l’utilisateur accepte, il ne donne ni son mot de passe, ni son second facteur.  
Il **délègue des permissions**.

À partir de cet instant, une application tierce est autorisée dans le tenant, avec les droits accordés. Elle peut obtenir des access tokens et des refresh tokens, et accéder aux données sans interaction utilisateur supplémentaire.

Pour Entra ID, tout est conforme.  
L’utilisateur s’est authentifié et a explicitement consenti.

## Pourquoi la MFA ne protège pas contre ce scénario

Ce point est essentiel à comprendre.

La MFA protège l’authentification de l’utilisateur.  
Elle ne protège pas la **délégation de droits OAuth**.

Dans un consent phishing, il n’y a pas d’usurpation d’identité. Il y a une **autorisation volontaire**, obtenue par tromperie, mais techniquement valide. La MFA est satisfaite, car l’utilisateur est bien à l’origine de l’action.

C’est ce qui rend ce type d’attaque particulièrement efficace et difficile à détecter par les mécanismes classiques :  
pas d’échec de connexion, pas de signal de risque évident, pas d’anomalie géographique.

## Les conséquences concrètes

Une application malveillante consentie peut, selon les permissions accordées :

- lire les emails et les pièces jointes,
- accéder aux fichiers OneDrive et SharePoint,
- maintenir un accès durable via des refresh tokens,
- survivre à un changement de mot de passe utilisateur.

Dans de nombreux environnements, la révocation du consentement n’est pas automatisée et passe inaperçue. L’attaquant n’a plus besoin de revenir : l’accès persiste tant que l’application reste autorisée.

## Pourquoi bloquer tout le consentement utilisateur n’est pas une réponse viable

La réaction instinctive consiste souvent à désactiver complètement le consentement utilisateur.  
D’un point de vue sécurité, la mesure est efficace. D’un point de vue opérationnel, elle est rarement tenable.

De nombreux outils SaaS légitimes reposent sur OAuth et nécessitent un consentement initial.  
Tout bloquer revient à déplacer la friction vers le support, à multiplier les demandes d’exception et, dans certains cas, à encourager le contournement par des solutions non maîtrisées.

Le vrai enjeu n’est pas d’empêcher tout consentement.  
Il est de **distinguer ce qui peut être accepté sans risque majeur de ce qui doit être contrôlé**.

## La mesure : filtrer la confiance plutôt que l’interdire

Microsoft fournit un cadre précis pour réduire drastiquement le risque de consent phishing sans bloquer les usages légitimes.

L’approche repose sur deux principes complémentaires :
- limiter le consentement utilisateur aux applications dignes de confiance,
- imposer un contrôle administratif pour tout le reste.

### Filtrer par éditeur vérifié et permissions à faible impact

La première brique consiste à autoriser le consentement utilisateur **uniquement** lorsque l’application répond à des critères stricts :
- l’éditeur est **vérifié** par Microsoft,
- les permissions demandées sont classées comme **faible impact**.

Cela permet de bloquer automatiquement :
- les applications créées par des attaquants,
- les éditeurs anonymes,
- les demandes d’accès aux emails, fichiers ou données sensibles.

🔗[Configure user consent settings](https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/configure-user-consent)

🔗[Verified publisher status](https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/verified-publisher)

🔗[Permission classifications](https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/configure-permission-classifications)

### Mettre en place un workflow d’approbation administrateur

Lorsque le consentement utilisateur est bloqué, il est essentiel de proposer une alternative encadrée.

Le **Admin Consent Workflow** permet à l’utilisateur de demander une approbation, avec justification, sans avoir à comprendre les implications techniques des permissions demandées.  
La décision est déplacée vers des profils capables d’évaluer le risque.

🔗[Configure the admin consent workflow](https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/configure-admin-consent-workflow)

Ce mécanisme permet :
- de conserver la traçabilité des décisions,
- d’éviter les exceptions sauvages,
- de répartir la charge sans la concentrer sur un seul Global Admin.

![Entra ID - Admin approval workflow](/assets/img/posts/series/un-risque-une-mesure/2026-01-19-illicit-consent.png)

## Traiter l’existant : le consent phishing d’hier est encore actif aujourd’hui

La configuration protège les consentements futurs.  
Elle ne corrige pas ceux déjà accordés.

Un travail de revue est indispensable dans **Enterprise Applications** :
- identifier les applications avec des noms génériques ou trompeurs,
- vérifier les éditeurs non vérifiés,
- analyser les permissions applicatives étendues.

Sur ce point, Microsoft Defender for Cloud Apps apporte des signaux particulièrement utiles pour détecter les applications à risque ou trompeuses.

🔗[Investigate OAuth apps](https://learn.microsoft.com/en-us/defender-cloud-apps/investigate-apps)

## Ce que révèle le consent phishing

Le consent phishing met en lumière un point souvent sous-estimé :  
la sécurité de l’identité ne se limite pas à l’authentification.

Tant que des utilisateurs peuvent déléguer, seuls, des accès techniques qu’ils ne sont pas en mesure d’évaluer, la MFA ne suffit pas. Le problème n’est pas l’erreur humaine, mais l’absence de cadre.

Le consentement OAuth est un mécanisme puissant.  
Sans gouvernance explicite, il devient un angle mort.

Dans le prochain article, nous aborderons un autre détournement du modèle OAuth : **les permissions applicatives accordées sans temporalité**, et pourquoi leur gouvernance est souvent plus critique encore que celle des identités humaines.
