---
title: "Comptes à privilèges : Pourquoi les protéger comme les autres ne suffit pas"
date: 2026-01-06 08:00:00 +01:00
layout: post
tags: [series:un-risque-une-mesure, entra-id, privileged-access, pim, just-in-time, tiering-model]
categories: [identite, entra-id]
readtime: true
comments: true
cover-img: "assets/img/banners/banner1.png"
thumbnail-img: "assets/img/posts/series/un-risque-une-mesure/2026-01-06-entra-id-privileged-accounts.png"
series: R1M
series_order: 050
sidebar: true
level: sécurité opérationnelle
scope:
  - Entra ID
  - Privileged Identity Management (PIM)
  - Modèle de Tiering
  - Sécurité de l’identité
---

> 💡 **Le privilège n'est pas un attribut de l'identité, c'est une fonction critique du système.**
> Un compte à privilèges n’est pas un utilisateur avec "plus de droits". C’est un point de contrôle capable de modifier les règles de sécurité pour l'ensemble de l'organisation.

Dans la majorité des environnements Microsoft Entra ID, la protection des comptes à privilèges se résume souvent à une version "renforcée" de la politique standard : on applique le MFA à tout le monde, admins compris, et l'on se sent protégé. Parfois, on ajoute une conformité de l'appareil via Intune. Sur le papier, les voyants sont au vert.

Cette approche, bien que nécessaire, est dangereusement incomplète. Elle traite l'administrateur comme un "super-utilisateur", alors qu'il est la clé de voûte du système.

Protéger l'authentification d'un administrateur est une condition *nécessaire*, mais ce n'est pas une condition *suffisante*. Le véritable risque ne réside pas uniquement dans la manière dont l'administrateur se connecte, mais dans la **permanence de son pouvoir**.

## Le risque structurel : L'accès permanent (Standing Access)

La faille majeure de la plupart des modèles d'administration actuels réside dans le concept d'**accès permanent** (*Standing Access*).

![Microsoft 365 - Standing access](/assets/img/posts/series/un-risque-une-mesure/2026-01-06-microsoft-admins-standing-privileges.png)

Dans ce modèle traditionnel, si un collaborateur est nommé "Administrateur Global" ou "Administrateur Exchange", il détient ce privilège 24 heures sur 24, 7 jours sur 7, 365 jours par an.
* Qu'il soit en train d'effectuer une migration critique le mardi matin.
* Qu'il soit en train de lire ses mails personnels à la pause déjeuner.
* Qu'il soit en vacances à l'autre bout du monde.
* Ou qu'il dorme le dimanche à 3 heures du matin.

Le privilège est attaché à son identité de manière statique.

### Pourquoi c'est critique dans le Cloud
Si ce compte est compromis (Phishing, vol de token, malware sur le poste), l'attaquant hérite **immédiatement** et **sans effort** de la totalité des pouvoirs. Il n'a pas besoin d'effectuer une escalade de privilèges complexe ou de se déplacer latéralement : il est *déjà* Dieu dans le tenant.

La surface d'attaque est temporelle : elle est égale à 100% du temps d'existence du compte. C'est une fenêtre d'opportunité gigantesque offerte aux attaquants.

## Hygiène d'architecture : La séparation des identités

Avant même d'aborder les outils techniques, la première mesure de protection est architecturale. Un principe fondamental, hérité du modèle de *Tiering* Active Directory (Red Forest), s'applique tout autant au Cloud : la séparation des comptes.

### 1. Le compte "Bureautique" (Productivité)
C'est le compte synchronisé (Hybrid) ou Cloud utilisé pour Teams, Outlook, le web, et l'accès aux données.
* **Surface d'attaque :** Élevée (reçoit des mails externes, navigue sur internet, cible de phishing).
* **Privilège :** **Zéro**. Ce compte ne doit jamais avoir de rôle d'administration.

### 2. Le compte "Admin" (Cloud-Only)
C'est un compte dédié, distinct (ex: `admin-jean.dupont@societe.onmicrosoft.com`).
* **Licence :** Aucune licence Office 365. Pas de boîte mail (donc insensibilisé au Phishing par email), pas de Teams.
* **Usage :** Strictement réservé aux tâches d'administration via le portail Azure/Entra ou PowerShell.
* **Type :** "Cloud-Only" (non synchronisé depuis l'AD local) pour éviter qu'une compromission de l'AD on-prem ne permette une escalade vers le Cloud.

### 3. Les comptes "Brise-Glace" (Break Glass)
Ce sont les comptes de la dernière chance, utilisés uniquement en cas de panne majeure (ex: panne du service MFA Azure ou erreur de configuration CA verrouillant tout le monde).
* **Usage :** Jamais, sauf en cas de crise absolue.
* **Protection :** Exclus des politiques d'Accès Conditionnel standard, mot de passe complexe coffré physiquement, et surveillance SIEM hyper-critique (toute authentification génère une alerte P1 au SOC).

*Note : Nous détaillerons la gestion spécifique des comptes Brise-Glace dans un prochain article dédié.*

## La Mesure : Le Juste-à-Temps (Just-In-Time)

Une fois l'architecture de comptes assainie, il faut traiter le problème de l'accès permanent. La réponse de l'industrie, et de Microsoft, est le modèle **Just-In-Time (JIT)**.

Le principe est simple : par défaut, votre compte `admin-jean.dupont` n'a **aucun droit**. S'il se connecte au portail Azure, il ne voit rien de plus qu'un utilisateur lambda. Il est "éligible" au rôle, mais il ne le "détient" pas.

### L'implémentation via Privileged Identity Management (PIM)
Dans l'écosystème Entra, c'est le service **PIM** (nécessite des licences Entra ID P2 / E5) qui opère cette mécanique.

Le workflow de sécurité se transforme radicalement :

1.  **L'intention :** L'administrateur a besoin de modifier une configuration Exchange.
2.  **L'activation :** Il se rend dans PIM et demande à "activer" son rôle *Exchange Administrator*.
3.  **Le contrôle (MFA Step-Up) :** Entra ID exige une authentification forte à cet instant précis (par exemple, une clé FIDO2 ou un défi Authenticator), même si l'utilisateur s'est déjà connecté auparavant.
4.  **La justification :** L'admin doit saisir un motif (ou un numéro de ticket ITSM).
5.  **L'élévation :** Le rôle lui est attribué temporairement (par exemple pour 4 heures).
6.  **La révocation :** Au bout de 4 heures, le rôle est retiré automatiquement. L'administrateur redevient un utilisateur standard.

### Le gain de sécurité
Si un attaquant compromet ce compte à 3h du matin, il se retrouve dans une coquille vide. Pour faire des dégâts, il doit tenter une activation de rôle. Ce faisant, il déclenche un défi MFA (qu'il ne peut pas passer) et génère des logs d'activation suspects.

Le privilège n'est plus un état ("Je suis Admin"), c'est un événement ("J'administre").

## Durcissement de l'accès : Authentification et Poste

Le JIT réduit la fenêtre de tir, mais pendant les 4 heures d'activation, le risque persiste. Il faut donc durcir les conditions d'accès de manière drastique pour ces rôles.

### 1. Authentification résistante au Phishing
Pour les rôles hautement privilégiés (Global Admin, Privileged Role Admin, Security Admin), le MFA par notification push ou SMS n'est plus suffisant (vulnérable au *MFA Fatigue* ou *SIM Swapping*).
Il est impératif d'imposer, via l'Accès Conditionnel, une **Force d'authentification** (Authentication Strength) exigeant une clé de sécurité FIDO2 ou Windows Hello for Business.

### 2. Contexte du poste (Device Trust)
Un administrateur ne devrait jamais administrer le tenant depuis un PC personnel ou une machine non maîtrisée.
La politique d'accès conditionnel doit exiger un poste **Conforme** (géré par Intune et sain) ou **Hybrid Join**. Pour les environnements très sensibles, l'usage de stations d'administration privilégiées (PAW - Privileged Access Workstations) permet de garantir que le poste utilisé pour l'administration ne sert pas à lire des mails ou naviguer sur le web.

## Gouvernance : La confiance n'est pas éternelle

Enfin, la protection des comptes à privilèges inclut leur cycle de vie. Dans beaucoup d'entreprises, on accumule les droits : un admin change d'équipe, garde ses anciens droits et en gagne de nouveaux.

L'outil **Access Reviews** (Revue d'accès) doit être configuré pour les rôles PIM.
* **Fréquence :** Mensuelle ou trimestrielle.
* **Processus :** Chaque administrateur (ou son manager) doit reconfirmer qu'il a toujours besoin d'être éligible à ce rôle.
* **Sanction :** Sans réponse, le droit d'éligibilité est retiré.

Cela permet de lutter contre la dérive des droits (*Privilege Creep*) et de s'assurer que la liste des administrateurs correspond à la réalité de l'organigramme, et non à l'historique de l'AD.

## Conclusion

Protéger un compte à privilèges demande un changement de mentalité. Il ne s'agit pas seulement de "sécuriser le login", mais de repenser la nature même du pouvoir dans le système d'information.

Tant que vous tolérez des accès permanents (*Standing Access*), vous acceptez qu'une simple compromission d'identité se transforme instantanément en compromission totale du système.

Le passage au modèle **Just-In-Time** via PIM, couplé à une ségrégation stricte des comptes (Cloud-Only), est la seule réponse structurelle adaptée aux menaces actuelles. L'administration ne doit pas être un état de fait, mais un acte conscient, temporaire et surveillé.

---
*Dans le prochain article de la série, nous quitterons le monde des humains pour nous attaquer aux **Identités Applicatives**, ces comptes de service silencieux qui accumulent souvent des privilèges permanents sans aucune surveillance.*