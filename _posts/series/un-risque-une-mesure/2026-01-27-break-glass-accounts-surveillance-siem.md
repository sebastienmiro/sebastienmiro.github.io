---
title: "S’enfermer dehors : le risque du Lockout et la stratégie Brise-Glace"
date: 2026-01-26 08:00:00 +01:00
layout: post
tags: [series:un-risque-une-mesure, entra-id, break-glass, emergency-access, sentinel, monitoring]
categories: [identite, entra-id]
readtime: true
comments: true
cover-img: "assets/img/banners/banner-lock.png"
thumbnail-img: "assets/img/posts/series/un-risque-une-mesure/2026-01-26-break-glass-accounts.png"
series: R1M
series_order: 080
sidebar: true
level: sécurité opérationnelle
scope:
  - Entra ID
  - Comptes d'urgence
  - Monitoring SIEM
  - Résilience
---

> 💡 **En sécurité, la disponibilité est aussi critique que la confidentialité.**
> Si votre politique de sécurité est si robuste qu'elle finit par vous empêcher d'administrer votre propre tenant lors d'une crise, elle devient elle-même la menace.

Nous passons notre temps à construire des murailles numériques : Accès Conditionnel, MFA résistant au phishing, PIM, conformité des appareils. C'est nécessaire. Mais que se passe-t-il si la serrure se grippe ?

Que faites-vous si le service MFA d'Azure tombe en panne mondialement (c'est déjà arrivé) ?
Que faites-vous si une erreur humaine dans une politique d'Accès Conditionnel bloque "Tous les utilisateurs" (y compris les admins) sur "Toutes les applications" ?
Que faites-vous si votre fédération (ADFS ou autre) est compromise ou indisponible ?

![Breakglass - Oups, la boulette !](/assets/img/posts/series/un-risque-une-mesure/2026-01-26-break-glass-fail-oups-la-boulette.png)

Sans une stratégie de comptes d'urgence (Break Glass Accounts), la réponse est simple : vous devenez dépendant d'une procédure de récupération externe qui, pour des raisons de sécurité évidentes, impose des délais de vérification d'identité incompatibles avec l'urgence d'une crise.

## Le Risque : Le *Single Point of Failure* (SPOF) de l'administration

Le risque ici n'est pas l'intrusion, c'est l'**exclusion** (Lockout).

Dans une architecture Zero Trust, nous centralisons tout sur l'identité. Si le plan de contrôle de l'identité (Entra ID) devient inaccessible pour les administrateurs à cause d'une dépendance technique (MFA, Device Compliance, Fédération), vous perdez le contrôle du navire.

Le paradoxe est le suivant : pour sécuriser les administrateurs, nous ajoutons des couches de contrôle. Mais chaque couche est un point de défaillance potentiel pour l'accès d'urgence.

Si vos comptes administrateurs dépendent :
1.  De la synchronisation AD (Hybrid),
2.  Du réseau d'entreprise (Location based),
3.  D'un téléphone mobile (MFA),
4.  Ou d'un jeton FIDO2...

...alors vous avez quatre dépendances critiques qui peuvent vous empêcher d'intervenir en cas de cyberattaque majeure ou de panne technique.

## La Mesure : L'Indépendance Totale

La mesure ne consiste pas simplement à créer "un autre compte admin". Elle consiste à créer une identité qui s'affranchit de **toutes** les dépendances de votre environnement standard.

Un compte Brise-Glace doit être un "Alien" dans votre système : il ne doit ressembler à aucun autre.

### 1. Architecture du compte
* **Source :** **Cloud-Only**. Jamais synchronisé depuis l'AD on-prem. Si votre AD est victime d'un ransomware, votre accès Cloud doit survivre.
* **Domaine :** Utilisez le domaine `*.onmicrosoft.com`. Ne dépendez pas de votre DNS public ou de votre fédération.
* **Quantité :** **Deux comptes**. Pas un seul (SPOF), pas dix (ingérable). Juste deux, stockés dans deux lieux physiques différents.
* **Privilège :** **Global Administrator permanent**. N'utilisez **JAMAIS PIM** pour un compte Brise-Glace. Si le service PIM est inaccessible, le compte ne sert à rien.

### 2. L'authentification 
C'est le point qui fait débat. Pour qu'un compte soit utilisable quand le MFA Azure est en panne, il doit... **être exclu du MFA Azure**.

Cela semble être une hérésie de sécurité. C'est pourtant une nécessité de résilience.
L'authentification doit reposer sur :
* Soit un mot de passe extrêmement complexe (100 caractères aléatoires), divisé en deux parties stockées dans des coffres-forts physiques séparés.
* Soit une clé matérielle FIDO2 (recommandé), mais en s'assurant que l'authentification FIDO2 ne dépend pas d'une politique CA qui pourrait être défaillante.

### Focus Technique : Configurer FIDO2 sur un compte exclu

Comment enrôler une clé de sécurité sur un compte qui est volontairement exclu de toutes les politiques de sécurité ? La procédure se joue en deux temps : l'autorisation au niveau du tenant, et l'enrôlement au niveau de l'utilisateur.

![Breakglass - FIDO2 protected account](/assets/img/posts/series/un-risque-une-mesure/2026-01-26-fido2-break-glass.png)

**1. Côté Tenant (Prérequis)**
Même si vous n'avez pas de politique CA, la méthode doit être active.
* Allez dans **Entra ID > Protection > Authentication methods > Policies**.
* Sélectionnez **FIDO2 Security Key**.
* Activez le paramètre (Enable).
* Dans l'onglet **Target**, assurez-vous que le compte Brise-Glace (ou son groupe) est bien inclus dans la cible.
    * *Conseil :* Ne mettez pas "All Users" si vous êtes en phase pilote, mais assurez-vous que votre compte d'urgence fait partie des inclusions.
* Dans l'onglet **Configure**, désactivez "Enforce attestation" sauf si vous avez des exigences strictes sur le modèle de clé, pour éviter tout blocage technique lors de l'enrôlement.

**2. Côté Compte Brise-Glace (Enrôlement)**
C'est la seule fois où vous utiliserez le mot de passe initial pour vous connecter "normalement".
* Connectez-vous avec le compte Brise-Glace sur `https://mysignins.microsoft.com/security-info`.
* Cliquez sur **+ Add sign-in method** > **Security key**.
* Sélectionnez **USB device** (ou NFC selon votre clé).
* Suivez l'assistant : votre navigateur vous demandera de créer un **PIN** pour la clé (ce PIN est local à la clé) et de toucher le bouton physique.
* Donnez un nom explicite à la clé (ex: "FIDO Coffre Rouge - Paris").

**3. Le Test de Connexion (Critique)**
Une fois la clé configurée :
1.  Déconnectez-vous ou ouvrez une navigation privée.
2.  Sur l'écran de login, saisissez l'UPN du compte Brise-Glace.
3.  Si le système ne vous propose pas la clé immédiatement, cliquez sur **"Other ways to sign in"** ou **"Sign-in options"**.
4.  Choisissez l'icône de la clé de sécurité.
5.  Le système ne vous demande plus votre mot de passe, mais votre PIN de clé + le toucher physique.

C'est ainsi que vous obtenez une authentification forte, résistante au phishing et aux keyloggers, sans dépendre d'aucune politique d'accès conditionnel.

### 3. L'Exclusion Explicite
Ce compte doit être ajouté dans un groupe de sécurité dédié (ex: `SEC-BreakGlass-Excluded`).
Ce groupe doit être placé en **Exclusion** de **TOUTES** vos politiques d'Accès Conditionnel. Toutes. Sans exception.

Pas de contrôle de pays, pas de contrôle de device, pas de MFA conditionnel. L'accès doit être possible depuis n'importe où, n'importe quand.

## La Contrepartie : L'Hyper-Surveillance

Si vous créez un compte Global Admin permanent, exclu du MFA et de l'Accès Conditionnel, vous venez techniquement de créer la Backdoor parfaite pour un attaquant.

Ce risque est inacceptable **sauf** s'il est compensé par une surveillance paranoïaque. C'est là que le SIEM entre en jeu.

Puisque nous ne pouvons pas prévenir (bloquer) l'accès, nous devons le **détecter** avec une certitude absolue et une latence nulle.

### La règle de détection
Toute activité sur un compte Brise-Glace doit déclencher une alerte de **Sévérité Critique** au SOC.
Il ne s'agit pas de détecter un "comportement suspect". L'usage même du compte *est* l'incident.

**Ce qu'il faut surveiller (Log Analytics / Sentinel) :**
1.  **Sign-in Logs :** Toute tentative de connexion (réussie OU échouée). Une tentative échouée signifie que quelqu'un a trouvé le login et tente un bruteforce.
2.  **Audit Logs :** Toute modification du compte lui-même (changement de mot de passe, modification des méthodes d'auth).

Le temps de réponse doit être inférieur à 5 minutes. Si ce compte s'allume, c'est que la maison brûle, ou que quelqu'un est en train de la cambrioler.

## Gouvernance : L'exercice incendie

Un compte d'urgence non testé est un compte qui ne fonctionnera pas le jour J.
* Le mot de passe dans le coffre est-il toujours le bon ?
* Le processus de récupération de la clé du coffre est-il connu ?
* L'alerte au SOC se déclenche-t-elle vraiment ?

![Breakglass login - SOC alert](/assets/img/posts/series/un-risque-une-mesure/2026-01-26-soc-breakglass-account-activity.png)

**La recommandation opérationnelle :**
Une fois par trimestre, effectuez un exercice réel :
1.  Ouvrez le coffre.
2.  Connectez-vous avec le compte Brise-Glace.
3.  Vérifiez que vous avez bien accès au portail.
4.  Vérifiez que le SOC vous appelle dans les minutes qui suivent.
5.  Changez le mot de passe (rotation) et remplacez l'enveloppe scellée dans le coffre.

## Conclusion

Les comptes Brise-Glace sont les airbags de votre tenant Entra ID. Vous espérez ne jamais les voir se déployer, mais vous ne conduiriez pas sans eux.

Ne tombez pas dans le piège de vouloir trop les sécuriser technologiquement (MFA, PIM, CA) au point de les rendre inutilisables en cas de crise. La sécurité de ces comptes repose sur leur **obscurité** (login inconnu), leur **protection physique** (coffre-fort) et leur **surveillance numérique** (SIEM).

Le jour où vous serez enfermé dehors, ces deux comptes seront les seuls amis qu'il vous restera.

---
*Dans le prochain article, nous aborderons la sécurité du poste d'administration et les risques liés au BYOD non maîtrisé.*