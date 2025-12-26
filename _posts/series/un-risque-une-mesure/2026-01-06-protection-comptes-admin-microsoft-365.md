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
level: sécurité opérationnelle
scope:
  - Entra ID
  - Comptes à privilèges
  - Accès conditionnel
  - Sécurité de l’identité
---

> 💡 **Un compte à privilèges n’est pas un utilisateur disposant de droits supplémentaires.  
Il constitue un point de contrôle direct sur le système d’information.**

Dans de nombreux environnements Microsoft Entra ID, les comptes à privilèges sont protégés en appliquant une version renforcée des mécanismes utilisés pour les utilisateurs standards. L’authentification multifacteur est activée, des politiques d’accès conditionnel sont en place et, parfois, des restrictions supplémentaires sont ajoutées.

Cette approche peut sembler cohérente d’un point de vue technique. Elle ne l’est pas d’un point de vue du risque.

Un compte à privilèges ne se distingue pas par la quantité de données auxquelles il donne accès, mais par sa capacité à modifier les règles, les identités et les mécanismes de sécurité du système lui-même. Il s’agit d’une différence structurelle, et non d’un simple niveau de sensibilité supérieur.

## Le risque : considérer le privilège comme un attribut permanent

Le risque principal ne réside pas dans l’absence de contrôles de sécurité, mais dans une hypothèse implicite largement répandue : celle selon laquelle le privilège serait une propriété durable de l’identité.

Dans ce modèle, un compte est administrateur en permanence, indépendamment de la tâche réalisée, du contexte d’accès ou de la durée réelle du besoin. Le privilège devient un état, et non une capacité temporaire.

Lorsqu’un compte utilisateur est compromis, l’impact est généralement limité à l’accès à des données ou à des services spécifiques. Lorsqu’un compte à privilèges est compromis, l’attaquant peut modifier les mécanismes de sécurité, créer de nouveaux accès, altérer les journaux ou désactiver les contrôles existants.

La compromission ne concerne alors plus un accès, mais la gouvernance même du système.

## Distinguer les usages : comptes opérationnels et comptes brise-glace

Un modèle réaliste de gestion des comptes à privilèges repose sur une distinction claire entre les usages.

Les comptes administrateurs opérationnels sont destinés aux actions courantes d’administration : gestion des identités, configuration des politiques, administration des services. Ils doivent être strictement séparés des comptes utilisateurs standards et ne disposer d’aucun privilège permanent. Leur activation doit être limitée dans le temps et conditionnée à un besoin opérationnel identifié.

Les comptes dits « brise-glace » (break-glass) répondent à une logique différente. Ils existent pour faire face à des scénarios exceptionnels, tels qu’une perte d’accès généralisée, une défaillance de l’authentification ou un incident majeur affectant les mécanismes de sécurité. Ces comptes ne doivent jamais être utilisés dans le cadre de l’exploitation quotidienne.

Ils doivent être présents en nombre très limité, protégés par des mécanismes d’authentification particulièrement robustes, exclus des usages ordinaires et surveillés de manière spécifique. Leur existence relève de la continuité d’activité, non de l’administration courante.

Confondre ces deux catégories conduit à banaliser des comptes qui devraient rester exceptionnels.

## Limiter structurellement le nombre de comptes à fort privilège

Microsoft recommande de limiter strictement le nombre de comptes disposant du rôle Global Administrator, généralement à moins de cinq comptes par tenant. Cette recommandation ne relève pas d’une contrainte arbitraire, mais d’un principe de réduction mécanique du risque.

Chaque compte Global Administrator supplémentaire augmente la surface d’attaque, complexifie les contrôles et rend plus difficile la supervision des usages. Un tenant n’a pas besoin d’un grand nombre de comptes sur-privilégiés, mais de privilèges activables, contrôlés et temporaires.

La multiplication des comptes à privilèges est souvent le symptôme d’un modèle d’administration mal structuré, et non d’un besoin réel.

## Authentification forte et accès conditionnel : des prérequis, pas une réponse complète

Les comptes à privilèges doivent bénéficier des mécanismes d’authentification et de contrôle les plus stricts disponibles dans Entra ID. Cela inclut notamment l’usage d’une authentification multifacteur résistante au phishing, l’utilisation de clés FIDO2 lorsque cela est possible, ainsi que des politiques d’accès conditionnel dédiées.

Ces contrôles sont nécessaires, mais ils ne suffisent pas à eux seuls. Une fois l’authentification réussie, une session est établie et des jetons sont émis. Tant que le rôle reste actif et que la session est valide, l’accès demeure possible, indépendamment de l’évolution du contexte.

Un compte administrateur disposant d’un rôle permanent et de sessions longues constitue un risque structurel, même lorsque l’authentification est robuste.

## La mesure centrale : dissocier identité et privilège dans le temps

La réponse structurante consiste à ne plus considérer le privilège comme une propriété permanente de l’identité, mais comme une capacité temporaire, activée uniquement lorsqu’elle est nécessaire.

Dans Entra ID, cette approche est mise en œuvre via Privileged Identity Management (PIM), fonctionnalité disponible avec des licences Microsoft Entra ID P2 ou Microsoft 365 E5. En l’absence de ces licences, il n’est pas possible d’appliquer un modèle de gestion des privilèges réellement dynamique.

Avec PIM, les rôles à privilèges ne sont plus attribués de manière permanente. Leur activation est volontaire, limitée dans le temps, conditionnée à des contrôles explicites et systématiquement journalisée. Le privilège n’est plus un état durable associé à l’identité, mais un événement ponctuel, observable et révocable.

Ce modèle réduit mécaniquement la surface d’attaque et la durée d’exposition. Un privilège temporaire n’est exploitable que pendant une fenêtre limitée, tandis qu’un privilège permanent reste attaquable en continu, indépendamment du contexte réel d’utilisation.

## Discipline d’usage et gouvernance opérationnelle

Les outils fournis par Entra ID ne suffisent pas sans un modèle d’usage cohérent. Un dispositif efficace repose sur la séparation stricte des comptes utilisateurs et des comptes administrateurs, des activations de rôles courtes et justifiées, ainsi que sur des environnements d’administration durcis.

Les politiques d’accès conditionnel doivent être spécifiques aux rôles à privilèges et conçues en tenant compte des scénarios de session, de localisation et de posture des postes utilisés. La journalisation doit être exploitée, et non simplement activée.

L’administration ne doit pas être conçue pour être confortable. Elle doit être conçue pour être maîtrisée.

## Observations issues du terrain

Dans de nombreux incidents, l’accès initial n’est pas administratif. Il le devient ensuite, sans recours à des techniques complexes, simplement parce que le modèle d’administration autorise l’existence de privilèges permanents prêts à être exploités.

Les mécanismes sont présents, mais la confiance implicite associée aux rôles à privilèges n’est pas remise en question.

## Conclusion

Un compte à privilèges n’est pas un utilisateur standard disposant de droits supplémentaires. Il constitue un point de contrôle du système d’information.

Le protéger de la même manière que les autres comptes, même avec des contrôles renforcés, ne suffit pas. Le privilège doit être temporaire, conditionnel et révocable, et son usage doit être considéré comme un événement exceptionnel.

Tant que l’accès au plan d’administration n’est pas traité comme un risque à part entière, la sécurité de l’identité demeure fragile.

Dans le prochain article, nous aborderons les identités applicatives et non humaines, pour lesquelles la notion de privilège permanent pose d’autres défis structurels.

---
Ressources externes
🔗 NIST — Least Privilege Principle ![NIST — Least Privilege Principle](https://csrc.nist.gov/glossary/term/least_privilege)
🔗 MITRE ATT&CK — Privilege Escalation ![MITRE ATT&CK — Privilege Escalation](https://attack.mitre.org/tactics/TA0004/)
🔗 Microsoft — Privileged Identity Management (PIM) ![Microsoft — Privileged Identity Management (PIM)](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-configure)
🔗 Microsoft — Conditional Access for privileged roles   ![Microsoft — Conditional Access for privileged roles   ](https://learn.microsoft.com/en-us/entra/identity/conditional-access/howto-conditional-access-policy-admins/)