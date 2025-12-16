---
title: "Comptes à privilèges : pourquoi les protéger comme les autres ne suffit pas"
date: 2026-01-06 11:00:00 +01:00
layout: post
tags: [series:un-risque-une-mesure, entra-id, privileged-access, admin, conditional-access]
categories: [identite, entra-id]
readtime: true
comments: true
cover-img: "assets/img/banners/banner1.png"
thumbnail-img: "assets/img/posts/series/un-risque-une-mesure/2026-01-06-entra-id-privileged-accounts.png"
series: R1M
series_order: 050
sidebar: true
level: concepts
scope:
  - Entra ID
  - Comptes à privilèges
  - Accès conditionnel
  - Sécurité de l’identité
---

💡 **Un compte à privilèges n’est pas un utilisateur “un peu plus important”.  
C’est un point de bascule.**

Dans beaucoup de tenants Microsoft Entra ID, la sécurité des comptes administrateurs est traitée comme une déclinaison renforcée de celle des utilisateurs standards. Même MFA, mêmes politiques d’accès conditionnel, parfois quelques exclusions ou contraintes supplémentaires. Sur le papier, la logique semble cohérente.

Dans la réalité opérationnelle, c’est précisément cette approche qui pose problème.

Un compte à privilèges ne s’inscrit pas dans le même modèle de risque. Il ne donne pas simplement accès à des données, mais à la **capacité de modifier le système lui-même**. C’est une différence de nature, pas de degré.

## Le risque : considérer un compte admin comme un utilisateur ordinaire

Le risque principal n’est pas l’absence de MFA ou de contrôles. Il est conceptuel.  
Appliquer aux comptes à privilèges les mêmes mécanismes que pour les utilisateurs standards revient à ignorer leur impact systémique.

Lorsqu’un compte utilisateur est compromis, les dégâts sont souvent contenus : accès aux données, messagerie, fichiers, éventuellement des mouvements latéraux limités.  
Lorsqu’un compte à privilèges est compromis, c’est l’architecture de confiance qui bascule. L’attaquant n’a plus besoin de persistance sophistiquée : il peut la créer.

Et pourtant, sur le terrain, on observe régulièrement :
- des comptes admin permanents,
- des sessions longues,
- des MFA identiques à celles des utilisateurs standards,
- des exclusions “temporaires” devenues structurelles.

La surface d’attaque est connue. Elle est simplement tolérée.

## Pourquoi les comptes à privilèges sont une cible à part

Un compte à privilèges concentre plusieurs caractéristiques qui le rendent particulièrement attractif.

Il est rarement utilisé, ce qui réduit la capacité à détecter un usage anormal.  
Il permet des actions à fort impact, souvent sans validation intermédiaire.  
Il donne accès à des plans de contrôle : identités, rôles, journaux, politiques de sécurité.

Dans beaucoup d’incidents, l’objectif final n’est pas l’accès aux données, mais l’accès à **ce type de compte**. Une fois obtenu, le reste devient trivial.

Ce n’est pas un hasard si les frameworks d’attaque modernes — y compris ceux observés dans les campagnes AiTM — visent explicitement les rôles à privilèges.

## MFA, accès conditionnel… et faux sentiment de robustesse

La MFA est souvent présentée comme le rempart ultime pour les comptes administrateurs. Dans Entra ID, elle est parfois imposée de manière plus stricte, avec des exclusions réduites et des contrôles renforcés.

Mais le problème est le même que pour les utilisateurs standards, amplifié par l’impact du rôle.

Une fois l’authentification validée, la session existe.  
Une fois la session établie, les jetons circulent.  
Et tant que le contexte n’est pas remis en question, l’accès reste légitime.

Un compte admin avec une session persistante est un **risque silencieux**.  
Il n’a pas besoin d’être utilisé activement pour être dangereux.

## Le piège des comptes administrateurs permanents

Dans beaucoup d’organisations, les administrateurs utilisent quotidiennement des comptes à privilèges pour des tâches ordinaires : navigation dans le portail, lecture de logs, tests, diagnostics.

Ce modèle est confortable. Il est aussi structurellement risqué.

Un compte permanent :
- accumule des sessions,
- multiplie les contextes d’accès,
- augmente la probabilité d’exposition à un poste compromis ou à un navigateur vulnérable.

La question n’est pas de savoir *si* ce compte sera exposé un jour, mais *quand*.

## La mesure : désolidariser identité et privilège

La réponse ne consiste pas à “mieux protéger” les comptes à privilèges.  
Elle consiste à **ne plus considérer le privilège comme une propriété permanente de l’identité**.

C’est exactement la logique portée par Privileged Identity Management (PIM) dans Entra ID.

Le privilège devient :
- temporaire,
- conditionnel,
- traçable,
- révocable.

Un administrateur n’est plus admin par défaut.  
Il le devient pour une durée limitée, dans un contexte précis, avec des contrôles explicites.

## Pourquoi le “Just-In-Time” change réellement le modèle

Le JIT n’est pas qu’un confort ou une bonne pratique. C’est un changement de posture défensive.

Il réduit mécaniquement :
- la surface d’attaque,
- la durée d’exposition,
- l’impact d’une session compromise.

Un attaquant qui récupère un token admin hors fenêtre d’activation n’a rien.  
Un attaquant qui arrive après la révocation du rôle ne peut rien faire.

Le privilège cesse d’être un état. Il devient un événement.

## Gouvernance et discipline opérationnelle

Mettre en place PIM ou des politiques spécifiques aux comptes à privilèges ne suffit pas si le modèle d’usage ne change pas.

Cela implique :
- des comptes utilisateurs distincts des comptes admin,
- des sessions courtes,
- des postes dédiés ou durcis,
- une journalisation réellement exploitée,
- et surtout, une discipline assumée.

Les comptes à privilèges ne doivent pas être pratiques.  
Ils doivent être **désagréables à utiliser**. C’est un signal sain.

## Ce qu’on observe dans les incidents réels

Dans beaucoup d’incidents post-compromission, l’accès initial n’est pas admin.  
Il le devient ensuite, souvent sans exploit complexe, simplement parce que le modèle l’autorise.

Des comptes à privilèges existent, sont permanents, et sont déjà prêts à être utilisés.

Le problème n’est pas l’outil.  
Le problème est l’hypothèse de confiance implicite.

## À retenir

Un compte à privilèges n’est pas un utilisateur comme les autres.  
Le protéger “un peu plus” ne suffit pas.  
Le privilège doit être temporaire, conditionnel et révocable.  
La sécurité de l’identité s’effondre dès que le contrôle du plan d’administration est perdu.

Dans le prochain épisode, nous aborderons un autre angle souvent sous-estimé : **les accès applicatifs et les identités non humaines**, là où l’automatisation devient parfois un angle mort.

---
Ressources externes
🔗 NIST — Least Privilege Principle ![NIST — Least Privilege Principle](https://csrc.nist.gov/glossary/term/least_privilege)
🔗 MITRE ATT&CK — Privilege Escalation ![MITRE ATT&CK — Privilege Escalation](https://attack.mitre.org/tactics/TA0004/)
🔗 Microsoft — Privileged Identity Management (PIM) ![Microsoft — Privileged Identity Management (PIM)](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-configure)
🔗 Microsoft — Conditional Access for privileged roles   ![Microsoft — Conditional Access for privileged roles   ](https://learn.microsoft.com/en-us/entra/identity/conditional-access/howto-conditional-access-policy-admins/)