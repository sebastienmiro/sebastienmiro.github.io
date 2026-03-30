---
title: "Conditional Access Framework - CA100 à CA105 : comptes à privilèges"
date: 2026-03-06 09:00:00 +01:00
layout: post
tags: [series:conditional-access-framework, privileged-access, deploiement]
categories: [identite, entra-id]
readtime: true
comments: true
cover-img: "assets/img/banners/banner-conditional-access.png"
thumbnail-img: "assets/img/posts/series/conditional-access-framework/110/110-thumb.png"
series: CA
series_order: 110
sidebar: true
level: technique
scope:
  - Entra ID
  - Comptes à privilèges
  - Déploiement
platform: Microsoft Entra
---

## Un changement de logique, pas un durcissement

Les politiques CA100 à CA105 ne sont pas une version renforcée du socle global. Elles en sortent volontairement. À partir de ce bloc, le framework considère que certains comptes ne doivent plus suivre le flux normal des utilisateurs - ni en termes de méthodes d'authentification, ni en termes de durée de session, ni en termes de réactivité aux signaux de risque.

Les comptes à privilèges concentrent un risque disproportionné. Leur compromission a un impact immédiat et transversal sur l'ensemble du tenant. Le framework ne cherche pas à les protéger "un peu plus" : il les isole dans un modèle de contrôle dédié.

## Rôle du bloc Admins dans le framework

Le bloc CA100-CA105 est conçu pour être la règle finale appliquée aux comptes concernés. Contrairement au socle global, ces politiques ne s'effacent pas au profit d'autres règles plus spécifiques. Elles sont le terminus.

Les comptes administrateurs sont explicitement exclus des politiques globales et des blocs Internals, Guests et Service Accounts. Ils ne doivent jamais être évalués par des règles pensées pour des usages non privilégiés.

Les exclusions jouent ici un rôle inverse de celui du socle : elles n'ont pas pour fonction de céder la place à une politique plus ciblée, mais d'isoler strictement le périmètre administrateur. Les seules exclusions systématiques sont les comptes break-glass, exclus de l'ensemble du framework sans exception.

## Périmètre et définition des comptes à privilèges

Dans le contexte du framework, un compte admin est toute identité non invitée - synchronisée ou cloud - portant un rôle d'administration Microsoft 365 ou Azure AD : Global Administrator, Privileged Role Administrator, Exchange Administrator, Security Administrator, MDCA, Defender for Endpoint, Compliance, etc.

Les comptes invités avec des rôles admin relèvent de la persona Guests, pas de ce bloc.

Un point opérationnel critique : le framework part du principe que les rôles administratifs sont portés par des comptes dédiés, distincts des comptes utilisateurs du quotidien. Si ce n'est pas le cas dans votre environnement, les politiques CA100-CA105 s'appliqueront également aux usages non administratifs de ces comptes - ce qui crée des contraintes opérationnelles fortes et souvent imprévisibles. La séparation des comptes admin n'est pas une recommandation de confort, c'est un prérequis au bon fonctionnement de ce bloc.

## CA100 - Admins Identity Protection - Admin Portals - MFA

CA100 impose la MFA sur l'accès aux portails d'administration : portail Entra ID, centre d'administration Microsoft 365, et autres interfaces administratives.

C'est le premier niveau de séparation visible entre un compte utilisateur et un compte à privilèges. Un accès administratif sans MFA n'est pas une configuration sous-optimale : c'est une configuration inacceptable.

CA100 cible spécifiquement les portails admin plutôt que l'ensemble des applications. CA101 prend le relais pour les autres contextes.

![CA100-Admins-IdentityProtection-AdminPortals-AnyPlatform-MFA](/assets/img/posts/conditional-access-framework/)

## CA101 - Admins Identity Protection - Any App - MFA

CA101 étend l'exigence MFA à l'ensemble des applications accessibles par les comptes à privilèges.

L'objectif est d'éviter qu'une application secondaire, moins surveillée, devienne un point d'entrée vers des privilèges élevés. Un compte administrateur est administrateur partout, pas uniquement dans les portails dédiés. La MFA doit donc s'appliquer sans exception, quel que soit le contexte d'accès.

CA100 et CA101 se complètent : CA100 cible les portails admin explicitement, CA101 couvre le reste. Ensemble, ils garantissent qu'aucun accès d'un compte à privilèges ne repose sur un facteur unique.

![CA101-Admins-IdentityProtection-AnyApp-AnyPlatform-MFA](/assets/img/posts/conditional-access-framework/)

## CA102 - Admins Identity Protection - Sign-in Frequency

CA102 limite la durée de vie des sessions pour les comptes à privilèges. Le framework de référence fixe cette fréquence à **12 heures maximum** : au-delà, une réauthentification est exigée.

Ce choix mérite une explication. La persistance des sessions est un vecteur d'exploitation souvent sous-estimé. Un token volé ou une session ouverte sur un poste compromis reste exploitable pendant toute la durée de validité de la session. Réduire cette fenêtre à 12 heures limite mécaniquement l'impact d'une compromission non détectée immédiatement.

12 heures représente un compromis opérationnel raisonnable : suffisamment court pour réduire le risque, suffisamment long pour ne pas interrompre une journée de travail normale. Certaines organisations vont plus loin (4 ou 8 heures) pour les rôles les plus sensibles comme Global Administrator ou Privileged Role Administrator.

> **Point d'attention opérationnel.** Certaines organisations assignent des rôles élevés à leurs comptes principaux (non dédiés), ce qui entraîne des réauthentifications fréquentes sur tous les usages quotidiens. C'est le signe d'un problème de gouvernance des rôles à corriger, pas une raison d'assouplir CA102.

![CA102-Admins-IdentityProtection-AllApps-AnyPlatform-SigninFrequency](/assets/img/posts/conditional-access-framework/)

## CA103 - Admins Identity Protection - Persistent Browser

CA103 désactive les sessions persistantes dans le navigateur pour les comptes à privilèges.

Une session persistante permet à un navigateur de maintenir un état authentifié entre les fermetures de session. Pour un compte utilisateur standard, c'est du confort. Pour un compte administrateur, c'est une surface d'exposition inutile : un poste non verrouillé, un navigateur ouvert, et l'accès aux portails admin est immédiat sans nouvelle authentification.

CA103 complète CA102 sur un axe différent. CA102 agit sur la durée de vie des tokens ; CA103 agit sur l'ancrage de la session dans le navigateur. Les deux ensemble réduisent significativement la fenêtre d'exploitation d'un accès administratif compromis ou abandonné.

![CA103-Admins-IdentityProtection-AllApps-AnyPlatform-PersistentBrowser](/assets/img/posts/conditional-access-framework/)

## CA104 - Admins Identity Protection - Continuous Access Evaluation

CA104 active le Continuous Access Evaluation (CAE) pour les comptes à privilèges.

### Comment fonctionne CAE

Dans le modèle standard d'authentification OAuth, un access token a une durée de vie fixe - généralement 60 à 75 minutes. Pendant ce laps de temps, même si le contexte change (compte désactivé, mot de passe réinitialisé, signal de risque détecté), le token reste valide et exploitable. L'application ne réévalue pas l'accès avant l'expiration.

CAE rompt avec ce modèle. Il introduit un canal de communication entre Entra ID et les applications compatibles (Exchange Online, SharePoint Online, Teams, Graph API...) permettant à Entra ID d'envoyer des événements critiques en temps quasi réel. Lorsqu'un événement est détecté - révocation de session, changement de mot de passe, désactivation du compte, signal de risque élevé - l'application est notifiée et peut forcer une réévaluation immédiate plutôt d'attendre l'expiration du token.

En pratique, CAE réduit la fenêtre de validité d'un token compromis de 60 minutes à quelques secondes ou minutes selon les applications.

### Contrainte de déploiement

> **CA104 ne peut pas être créée en mode Report-only.** Les modes supportés sont exclusivement ON et OFF. Cette contrainte est documentée par Microsoft et s'applique également à CA209 (CAE pour les Internals). Lors du déploiement, CA104 doit être créée directement en mode ON ou maintenue désactivée jusqu'à activation.

![CA104-Admins-IdentityProtection-AllApps-AnyPlatform-ContinuousAccessEvaluation](/assets/img/posts/conditional-access-framework/)

## CA105 - Admins Identity Protection - Phishing Resistant MFA

CA105 impose des méthodes MFA résistantes au phishing pour les comptes à privilèges. C'est la politique la plus contraignante du bloc Admins, et la plus importante.

### Pourquoi les méthodes MFA classiques ne suffisent plus

Les méthodes MFA génériques - OTP (TOTP), push notification (Microsoft Authenticator en mode push), SMS - partagent une faiblesse structurelle : elles sont vulnérables aux attaques de type **adversary-in-the-middle (AiTM)** et aux attaques par **MFA fatigue**.

Dans une attaque AiTM, l'attaquant intercepte en temps réel la session d'authentification via un proxy transparent (outils comme Evilginx, Modlishka). L'utilisateur s'authentifie sur ce qu'il croit être le portail légitime, valide le prompt MFA, et l'attaquant récupère le session cookie côté serveur. L'authentification réussit, le code OTP ou le push a été validé, mais le token est entre les mains de l'attaquant.

Dans une attaque par MFA fatigue, l'attaquant envoie des dizaines de notifications push consécutives jusqu'à ce que l'utilisateur valide par erreur ou par lassitude. Ce type d'attaque a compromis des environnements Microsoft en production ces dernières années.

### Les méthodes résistantes au phishing

CA105 restreint l'authentification aux méthodes qui résistent structurellement à ces attaques :

**FIDO2 / Passkeys** - l'authentification est liée cryptographiquement à l'origine du site. Une clé FIDO2 (YubiKey, clé logicielle) ne peut pas être utilisée sur un site frauduleux, même si l'URL semble identique. L'origine est vérifiée côté client avant toute réponse au serveur.

**Certificate-Based Authentication (CBA)** - l'authentification repose sur un certificat X.509 stocké sur une smartcard ou dans un TPM. Le challenge est signé localement, aucun secret ne transite sur le réseau, et l'opération est liée à la possession physique du certificat.

Ces deux méthodes rompent le modèle d'interception : il n'y a pas de code à capturer, pas de notification à valider sur un site tiers, pas de secret réutilisable.

> **Prérequis avant activation.** CA105 doit être précédée du déploiement des méthodes résistantes dans `Entra ID > Authentication methods`. Si FIDO2 ou CBA ne sont pas configurés et assignés aux comptes concernés avant l'activation de CA105, ces comptes seront bloqués. Un déploiement progressif sur un groupe pilote de comptes admin est fortement recommandé avant une activation généralisée.

![CA105-Admins-IdentityProtection-AnyApp-AnyPlatform-PhishingResistantMFA](/assets/img/posts/conditional-access-framework/)

## Ce que le bloc Admins ne fait pas - le rôle de PIM

Les politiques CA100-CA105 protègent les comptes à privilèges au moment de l'authentification et pendant la session. Elles ne gèrent pas ce qui précède ni ce qui suit.

**Privileged Identity Management (PIM)** couvre ce que CA ne peut pas faire :

- l'**activation temporelle des rôles** (just-in-time access) : un compte n'est administrateur que pendant la durée nécessaire à une tâche, et le rôle expire automatiquement ;
- les **workflows d'approbation** : l'élévation d'un rôle sensible peut nécessiter la validation d'un second administrateur ;
- l'**audit des activations** : chaque élévation de rôle est journalisée avec le contexte et la justification ;
- les **alertes sur les assignations permanentes** : PIM détecte les rôles assignés de manière permanente là où une assignation éligible suffirait.

CA et PIM sont complémentaires et non substituables. CA protège l'accès des comptes pendant qu'ils sont actifs. PIM gouverne quand et comment ces comptes accèdent à leurs privilèges. Un environnement avec CA100-CA105 sans PIM protège les sessions administratives mais laisse les rôles exposés en permanence. Un environnement avec PIM sans CA protège la gouvernance des rôles mais laisse les sessions vulnérables.

## Conclusion

Le bloc CA100-CA105 n'est pas le socle global appliqué plus strictement. C'est un modèle de contrôle distinct, conçu pour des identités dont la compromission aurait un impact immédiat sur l'ensemble du tenant.

La rupture la plus significative est CA105 : imposer une MFA résistante au phishing aux comptes administrateurs n'est plus une bonne pratique optionnelle. C'est la réponse technique aux attaques AiTM qui ont compromis des tenants Microsoft en production.

Conformément à la logique de déploiement progressif du framework, ce bloc s'active après les Internals - une fois la mécanique d'activation rodée sur un périmètre moins exposé - et avant le socle global.