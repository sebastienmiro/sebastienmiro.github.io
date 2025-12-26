---
title: "Conditional Access Framework v4 — CA100 à CA105 : comptes à privilèges"
date: 2026-10-08 09:00:00 +01:00
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
## Conditional Access Framework v4 — CA100 à CA105 : comptes à privilèges

Les politiques CA100 à CA105 couvrent les comptes à privilèges. Elles ne constituent pas un simple durcissement du socle global, mais un **changement de logique**. À partir de ce bloc, le framework considère explicitement que certains comptes ne doivent plus suivre le flux normal des utilisateurs.

Les comptes à privilèges concentrent un risque disproportionné. Leur compromission a un impact immédiat et transversal. Le framework ne cherche donc pas à les protéger “un peu plus”, mais à les **sortir du modèle standard** et à leur appliquer des contrôles spécifiques, plus stricts et plus contraignants.

## Rôle du bloc Admins dans le framework

Le bloc CA100–CA105 a un rôle clair : traiter les comptes à privilèges comme une catégorie à part.

Contrairement au socle global, ces politiques ne servent pas de filet de sécurité. Elles sont conçues pour être **la règle finale** appliquée aux comptes concernés. Elles ne s’effacent pas au profit d’autres politiques plus spécifiques. Au contraire, elles excluent explicitement les règles globales afin d’éviter toute ambiguïté.

Les exclusions jouent ici un rôle inverse de celui du socle. Elles ne servent plus à céder la place, mais à **isoler strictement** le périmètre administrateur.

## Logique d’inclusion et d’exclusion

L’inclusion repose sur des groupes représentant explicitement les comptes à privilèges. Ces groupes doivent être restreints, maintenus manuellement et découplés des usages quotidiens.

Les exclusions sont volontairement limitées, mais critiques.

On retrouve systématiquement :
- les comptes de secours (break-glass), exclus de toutes les politiques, y compris administratives ;
- les exclusions propres à chaque règle, lorsqu’un flux précis ne peut pas être contraint immédiatement.

Les comptes administrateurs sont explicitement exclus des politiques globales et utilisateurs standards. Ils ne doivent jamais être évalués par des règles pensées pour des usages non privilégiés.

## CA100 — Admins Identity Protection — Admin Portals — MFA

CA100 impose une exigence MFA sur l’accès aux portails d’administration.

Cette règle vise à protéger les points d’entrée les plus évidents : portail Entra ID, centre d’administration Microsoft 365 et autres interfaces administratives. Elle constitue le premier niveau de séparation entre un compte utilisateur et un compte à privilèges.

CA100 n’est pas une optimisation. C’est une exigence minimale. Un accès administratif sans MFA est considéré comme inacceptable.

![CA000](/assets/img/posts/conditional-access-framework/)

## CA101 — Admins Identity Protection — Any App — MFA

CA101 étend l’exigence MFA à l’ensemble des applications accessibles par les comptes à privilèges.

L’objectif est d’éviter que des applications secondaires, souvent moins surveillées, deviennent des points d’entrée détournés vers des privilèges élevés. Un compte administrateur est administrateur partout, pas uniquement dans les portails dédiés.

Cette règle garantit une cohérence de protection sur l’ensemble des usages possibles du compte.

![CA000](/assets/img/posts/conditional-access-framework/)

## CA102 — Admins Identity Protection — Sign-in Frequency

CA102 impose une fréquence de réauthentification plus stricte pour les comptes à privilèges.

La persistance des sessions est un risque majeur pour ce type de comptes. Cette règle limite la durée de vie des sessions et réduit l’impact d’un vol de token ou d’un poste compromis.

Elle introduit une contrainte opérationnelle assumée. Les comptes à privilèges ne sont pas conçus pour le confort d’usage, mais pour des actions ponctuelles et maîtrisées.

![CA000](/assets/img/posts/conditional-access-framework/)

## CA103 — Admins Identity Protection — Persistent Browser

CA103 contrôle l’usage des sessions persistantes dans le navigateur.

Les sessions persistantes facilitent l’exploitation d’un accès compromis. Pour les comptes à privilèges, ce confort est considéré comme un risque inutile. Cette règle vise à empêcher l’ancrage durable d’une session administrative sur un poste.

Elle complète directement CA102 en réduisant la surface d’exposition temporelle.

![CA000](/assets/img/posts/conditional-access-framework/)

## CA104 — Admins Identity Protection — Continuous Access Evaluation

CA104 active l’évaluation continue de l’accès pour les comptes à privilèges.

Cette règle permet de réagir à des changements de contexte en cours de session, par exemple une élévation de risque détectée après l’authentification initiale. Elle réduit la fenêtre entre la détection d’un signal et la prise d’effet de la décision.

Pour des comptes à privilèges, cette capacité n’est pas optionnelle. Elle fait partie du socle de protection attendu.

![CA000](/assets/img/posts/conditional-access-framework/)

## CA105 — Admins Identity Protection — Phishing Resistant MFA

CA105 impose l’utilisation de mécanismes MFA résistants au phishing pour les comptes à privilèges.

Cette règle marque une frontière claire. Les méthodes MFA génériques, suffisantes pour des utilisateurs standards, ne sont plus considérées comme adaptées pour des comptes administratifs.

L’objectif n’est pas d’éliminer tout risque, mais de rendre les attaques par interception de flux d’authentification nettement plus difficiles à exploiter.

![CA000](/assets/img/posts/conditional-access-framework/)

## Ce que le bloc Admins ne fait volontairement pas

Les politiques CA100–CA105 ne cherchent pas à gérer la gouvernance des rôles, la séparation des tâches ou la rotation des privilèges. Elles ne remplacent ni PIM, ni les processus organisationnels.

Elles partent du principe que ces comptes existent et qu’ils doivent être protégés de manière stricte tant qu’ils sont utilisés.

## Conclusion

Le bloc CA100–CA105 ne renforce pas simplement le socle global. Il en sort volontairement. Il traite les comptes à privilèges comme ce qu’ils sont : des identités à risque élevé, nécessitant des contrôles dédiés et non négociables.

Comprendre cette rupture est essentiel. Appliquer aux administrateurs les mêmes règles qu’aux utilisateurs standards revient à sous-estimer leur impact réel en cas de compromission.
