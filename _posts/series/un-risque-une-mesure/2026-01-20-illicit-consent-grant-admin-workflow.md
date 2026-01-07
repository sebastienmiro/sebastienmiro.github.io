---
title: "Le clic qui contourne le MFA : Le Consent Phishing"
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

> 💡 **Le constat :** Nous avons martelé à nos utilisateurs de ne jamais donner leur mot de passe. Les attaquants se sont adaptés : ils ne demandent plus le mot de passe, ils demandent la **permission**. C'est le "Consentement Illicite" (Illicit Consent Grant), une technique qui rend le MFA inopérant.

Aujourd'hui, la compromission de compte ne passe plus nécessairement par le vol d'identifiants. Le **Consent Phishing** est particulièrement dangereux car il détourne les mécanismes de confiance de Microsoft pour piéger l'utilisateur.

## Le Risque : L'utilisateur devient complice malgré lui

Dans un phishing classique, l'utilisateur atterrit sur une fausse page de connexion. S'il est vigilant ou équipé d'une clé de sécurité, l'attaque échoue.

![Entra ID - Illicit consent workflow](/assets/img/posts/series/un-risque-une-mesure/2026-01-19-illicit-consent-grant.png)

Ici, le scénario est différent. L'utilisateur reçoit un lien vers une application (souvent déguisée en outil légitime). Il s'authentifie sur la véritable page Microsoft, avec son certificat valide, et valide son MFA avec succès.
C'est alors que le piège se referme : une fenêtre standard lui demande : *"L'application 'Upgrade Office 365' souhaite accéder à vos emails et vos contacts. Accepter ?"*

L'utilisateur clique sur "Accepter". À cet instant :
1.  Une **application tierce malveillante** est autorisée dans votre tenant.
2.  L'attaquant récupère un jeton d'accès (Access Token) et un jeton de rafraîchissement (Refresh Token).
3.  Il obtient un accès durable à la boîte mail, sans jamais avoir connu le mot de passe.

Pour le système, l'accès est légitime : l'utilisateur s'est authentifié et a explicitement validé la demande.

### Pourquoi c'est critique
* **Invisibilité :** Pas d'échec de connexion, pas d'alerte classique "Impossible travel".
* **Persistance :** Changer le mot de passe ne révoque pas toujours les droits de l'application (selon la configuration de révocation des tokens).
* **Crédibilité :** L'attaque utilise l'infrastructure officielle de Microsoft.

## La Mesure : Filtrer la confiance (Verified Publishers)

Le réflexe immédiat serait de bloquer tout consentement utilisateur (`Do not allow user consent`). C'est techniquement robuste, mais cela paralyse les usages métiers : plus aucune connexion possible à des outils SaaS légitimes (Adobe, Trello, outils RH) sans ticket au support. Le Shadow IT risque alors d'exploser.

La bonne posture consiste à **filtrer la confiance** et **déléguer le contrôle**.

### 1. La configuration "Filtre"
Plutôt que de tout interdire, configurez la politique de consentement pour autoriser les utilisateurs à valider seuls une demande **uniquement si** deux conditions sont réunies :
* L'application provient d'un **Éditeur Vérifié** (Verified Publisher) par Microsoft (identité certifiée via le Microsoft Partner Network).
* ET les permissions demandées sont "à faible impact" (ex: connexion simple `openid`, lecture du profil de base).

Toute demande sortant de ce cadre (éditeur inconnu ou demande d'accès aux fichiers/mails) sera bloquée.

### 2. Le Filet de Sécurité : Admin Consent Workflow
Lorsque le consentement est bloqué, l'utilisateur ne doit pas être dans une impasse. Activez le **flux de demande d'approbation administrateur**.

* **Côté utilisateur :** Une fenêtre indique *"L'approbation d'un administrateur est requise"*. Il peut saisir une justification.
* **Côté Admin :** Vous recevez la demande dans le portail Entra. Vous vérifiez la réputation de l'application et l'approuvez pour le demandeur (ou pour toute l'organisation).

## Mise en œuvre

Dans **Entra ID > Enterprise applications > Consent and permissions** :

1.  **User consent settings :** Cochez *"Allow user consent for apps from verified publishers, for selected permissions"*.
2.  **Permission classifications :** Définissez explicitement les permissions à faible risque (Low impact).
3.  **Admin consent settings :** Activez le workflow et désignez des réviseurs (équipe Sécurité ou Helpdesk niveau 2). Ne laissez pas cette tâche au seul Global Admin.

![Entra ID - Admin approval workflow](/assets/img/posts/series/un-risque-une-mesure/2026-01-19-illicit-consent.png)

## Le nettoyage

Cette mesure protège l'avenir. Pour l'existant, une analyse s'impose.
Filtrez vos applications d'entreprise (**Enterprise Applications**) pour identifier celles qui ont des noms génériques ("App", "Test", "Upgrade"), des éditeurs non vérifiés, et des permissions critiques (Read Mail, Read Files).

*Note :* Les alertes **Defender for Cloud Apps** ("Misleading publisher name", "App with suspicious permissions") sont ici très efficaces pour automatiser cette détection.

## Conclusion

L'Admin Consent Workflow est le compromis nécessaire entre verrouillage total et permissivité dangereuse. Il ne s'agit pas d'empêcher les utilisateurs de travailler, mais de leur retirer la responsabilité de valider des accès techniques qu'ils ne sont pas en mesure d'évaluer.

Ne laissez pas vos utilisateurs décider seuls qui a le droit d'exfiltrer les données de l'entreprise.