---
title: "Conditional Access Framework v2026.2.1 - Guide de déploiement progressif"
date: 2026-02-20 09:00:00 +01:00
layout: post
tags: [series:conditional-access-framework, deploiement, synthese]
categories: [identite, entra-id]
readtime: true
comments: true
cover-img: "assets/img/banners/banner-conditional-access.png"
thumbnail-img: "assets/img/posts/series/conditional-access-framework/090/090-thumb.png"
series: CA
series_order: 090
sidebar: true
level: opérationnel
scope:
  - Entra ID
  - Déploiement
  - Audit
platform: Microsoft Entra
---

## Pourquoi le déploiement progressif n'est pas une option

Déployer le Conditional Access Framework v2026.2.1 dans un tenant de production, c'est intervenir sur le plan de contrôle de toutes les authentifications. Une mauvaise séquence se traduit immédiatement : blocage d'utilisateurs, régression de sécurité, ou pire, une configuration apparemment cohérente qui laisse passer ce qu'elle est censée bloquer.

Ce guide ne décrit pas où cliquer dans le portail. Il décrit la séquence, la logique et les points de contrôle qui permettent d'introduire le framework sans casser l'existant et sans avancer à l'aveugle.



## Étape 1 - Audit de l'existant

C'est le point de départ non négociable. Sans cartographie précise de ce qui est en place, toute décision de déploiement repose sur des hypothèses.

### Ce qu'on cherche

**Security Defaults.** Premier réflexe : vérifier dans le portail Entra ID si Security Defaults est actif (`Entra ID > Properties > Manage security defaults`). S'il est actif, aucune politique d'accès conditionnel ne peut être créée ni activée : les deux mécanismes sont mutuellement exclusifs. Le constater à ce stade, ne pas le désactiver. La transition est traitée à l'étape 2.

**Les politiques d'accès conditionnel existantes.** Il ne s'agit pas de les lister, mais de les comprendre :
- Quel est leur périmètre réel d'inclusion (utilisateurs, groupes, rôles) ?
- Quelles exclusions sont en place, et pourquoi ?
- Sont-elles en mode ON ou Report-only ?
- Quelle décision prennent-elles réellement sur les authentifications en cours ?

Une politique active dont personne ne comprend plus les exclusions est un risque, pas une protection.

**Les méthodes d'authentification disponibles.** Vérifier dans `Entra ID > Authentication methods` quelles méthodes sont activées et pour quels utilisateurs. Le framework exige MFA pour l'ensemble des personas. Si les méthodes ne sont pas configurées cohéremment, les politiques MFA bloqueront des utilisateurs légitimes dès leur activation.

**Les comptes à privilèges réellement utilisés.** Lister les comptes portant des rôles Entra ID ou Microsoft 365 (Global Administrator, Privileged Role Administrator, Exchange Administrator, etc.). Identifier ceux qui sont utilisés pour des tâches quotidiennes non administratives - situation courante, et incompatible avec les politiques CA100-CA105 sans exclusions réfléchies.

**Les comptes break-glass.** Vérifier leur existence, leur état MFA, et la date de leur dernier test. Ces comptes doivent impérativement être dans le groupe d'exclusion `CA-BreakGlassAccounts - Exclude` avant toute activation. Si ce groupe n'existe pas, le créer maintenant.

**Les applications cibles.** Identifier les applications clés de l'environnement : lesquelles sont couvertes par des politiques existantes, lesquelles ne le sont pas, et lesquelles ont des comportements d'authentification spécifiques (applications legacy, applications sans support MFA, Autopilot Device Preparation v2...).

### Les outils

[**idPowerToys**](https://idpowertoys.merill.net/) génère une documentation visuelle et exportable des politiques Conditional Access existantes. C'est le meilleur point de départ pour avoir une vue d'ensemble exploitable rapidement.

**Log Analytics / Microsoft Entra Sign-in logs** permettent d'observer les authentifications réelles sur les 30 derniers jours : qui s'authentifie, depuis quoi, sur quelles applications, avec quelle méthode. Ces données sont indispensables pour anticiper l'impact des politiques avant leur activation.

**Microsoft Entra Recommendations** signale les configurations à risque détectées automatiquement dans le tenant. À consulter systématiquement en début d'audit.

À ce stade, on ne modifie rien. On observe, on cartographie, on documente.



## Étape 2 - Cas n°1 : Security Defaults actif

Si Security Defaults est actif, le désactiver immédiatement pour "repartir proprement" est la première erreur classique. Security Defaults assure implicitement plusieurs protections : MFA pour les administrateurs, blocage de l'authentification legacy, protection de l'enregistrement MFA. Les supprimer sans équivalent prêt à être activé crée une fenêtre de vulnérabilité réelle.

Le portail Entra ID ne permet pas de créer des politiques Conditional Access tant que Security Defaults est actif. La transition ne peut donc pas se faire par superposition. Elle se prépare en amont et s'exécute en séquence rapide.

D'abord, on prépare un socle minimal de politiques Conditional Access couvrant explicitement ce que Security Defaults couvre implicitement :

- blocage de l'authentification legacy (équivalent futur de CA002) ;
- MFA sur les accès administratifs (équivalent futur de CA100/CA101) ;
- protection de l'enregistrement et de la jonction d'appareils (équivalent futur de CA003).

Préparer signifie : documenter les politiques, valider les périmètres d'inclusion et d'exclusion, identifier les groupes nécessaires et les créer. Les politiques elles-mêmes ne peuvent pas encore être créées dans le portail.

Une fois cette préparation terminée, la bascule s'exécute en une seule session :

1. Désactiver Security Defaults.
2. Créer et activer immédiatement les politiques CA du socle de remplacement, en mode ON.
3. Valider les premiers Sign-in logs pour confirmer que les contrôles sont appliqués.

Cette séquence implique une fenêtre de vulnérabilité incompressible entre la désactivation de Security Defaults et l'activation des politiques CA. En pratique, avec une préparation rigoureuse, elle se réduit à quelques minutes. C'est un risque accepté, pas un risque ignoré.

C'est seulement à partir de là que le déploiement du framework démarre.

## Étape 3 - Cas n°2 : politiques héritées déjà en place

C'est le cas le plus fréquent en environnement de production. Des politiques ont été créées au fil du temps pour répondre à des besoins ponctuels, sans cadre global. Elles sont souvent partiellement documentées, avec des exclusions dont la raison d'être n'est plus claire.

### Ce qu'on ne fait pas

On ne supprime rien. On ne modifie rien. On ne cherche pas à simplifier avant d'avoir observé.

La tentation de "faire le ménage" avant de déployer le framework est compréhensible, mais elle est risquée : une politique héritée que personne ne comprend plus couvre peut-être un scénario réel. La supprimer sans observation préalable peut créer un blocage ou une régression invisible.

### Ce qu'on fait

On déploie l'intégralité du framework v2026.2.1 en mode Report-only, par-dessus les politiques existantes.

L'objectif n'est pas de remplacer immédiatement, mais de poser une grille de lecture cohérente sur une configuration hétérogène. En mode Report-only, les politiques du framework sont évaluées sur toutes les authentifications réelles et leurs décisions sont journalisées, sans affecter les utilisateurs.

C'est à partir de ces journaux qu'on peut répondre aux vraies questions :
- Quelle politique héritée couvre le même périmètre que CA200 ?
- Cette exclusion dans la politique existante est-elle justifiée dans le contexte du framework ?
- Est-ce que CA401 bloquerait des guests qui ont aujourd'hui accès à des applications non couvertes par une exception ?

### La cohabitation dans le temps

Pendant la phase Report-only, les politiques héritées restent actives et continuent de prendre les décisions. Le framework observe en parallèle. Cette cohabitation peut durer plusieurs semaines selon la complexité de l'environnement : c'est normal et souhaitable.

La substitution se fait politique par politique, dans l'ordre défini à l'étape suivante. Pour chaque bascule, la séquence est :

1. Vérifier les journaux Report-only de la politique concernée.
2. Valider que son périmètre couvre ce qu'on attend.
3. Ajuster les exclusions si nécessaire.
4. Passer la politique du framework en mode ON.
5. Désactiver (pas supprimer) la politique héritée correspondante.
6. Observer 48 à 72 heures avant de continuer.

Les politiques héritées désactivées restent présentes dans le tenant pendant au moins 30 jours. Si une régression est détectée, elles peuvent être réactivées immédiatement.



## Étape 4 - Pourquoi le framework se déploie en totalité, même en Report-only

Le framework n'est pas une liste de règles indépendantes. Il repose sur une logique de spécialisation progressive : les politiques globales posent le socle, et des politiques plus ciblées prennent le relais pour des personas ou des contextes spécifiques. Cette spécialisation fonctionne grâce aux exclusions croisées entre politiques.

Déployer seulement une partie du framework en Report-only fausse l'analyse :
- les recouvrements entre politiques ne sont pas visibles ;
- les exclusions croisées ne peuvent pas être interprétées correctement ;
- les journaux sont partiels et donc trompeurs.

Déployer l'ensemble permet au contraire d'observer quelle politique aurait pris la décision sur chaque authentification, comment les flux sont orientés entre politiques globales et spécialisées, et si les périmètres sont cohérents.

Le mode Report-only n'est pas une temporisation. C'est la phase d'ingénierie du déploiement.



## Étape 5 - Ordre d'activation recommandé

L'activation part des personas les plus spécifiques vers le socle global. La raison est simple : chaque persona activée avant les politiques globales constitue un périmètre d'exclusion naturel et maîtrisé. Quand CA000-CA006 entrent en jeu en dernier, les identités les plus sensibles sont déjà couvertes par leurs propres politiques - et explicitement exclues du socle.

**1. Agents - CA501**

Point de départ logique : c'est le périmètre le plus restreint du framework. CA501 bloque les agents présentant un workload identity risk élevé via Entra ID Protection. Avant activation, vérifier que les workload identities concernées sont couvertes par les licences Entra ID Protection et que les signaux de risque sont déjà collectés.

**2. Service accounts - CA300 et CA301**

CA301 repose sur la named location `ALLOWED COUNTRIES - SERVICE ACCOUNTS`. Vérifier qu'elle est correctement configurée avant activation. Une named location mal définie sur cette politique peut bloquer des flux d'automatisation critiques sans alerte immédiate.

**3. Guests - CA400 à CA404**

CA401 bloque par défaut l'accès des invités à toutes les applications hors exceptions explicites. Valider la liste des exclusions applicatives avant activation, en particulier si des partenaires MSP ont accès au tenant.

**4. Internals - CA200 à CA210**

Les utilisateurs internes représentent le volume d'authentifications le plus important. C'est sur cette persona que l'analyse Report-only aura été la plus riche en données. Vérifier en priorité CA203 si Autopilot Device Preparation v2 est utilisé : les utilisateurs concernés doivent être exclus de cette politique.

**5. Admins - CA100 à CA105**

Les politiques admin arrivent après les internals, une fois la mécanique rodée sur un périmètre moins exposé. Vérifier avant activation que les comptes break-glass sont correctement exclus et que les méthodes phishing-resistant (FIDO2, CBA) sont disponibles pour les comptes ciblés par CA105. Un blocage sur cette politique sans FIDO2 en place peut verrouiller des comptes critiques.

**6. Politiques globales - CA000 à CA006**

Le socle s'applique en dernier, quand toutes les personas spécialisées sont actives et correctement exclues. Attention particulière à CA005 : le contrôle *Require approved client app* sera retiré le 30 juin 2026 (date repoussée depuis l'annonce initiale de mars 2026). CA005 doit utiliser *Require app protection policy* en remplacement. Les politiques héritées s'appuyant encore sur l'ancien contrôle doivent être migrées avant cette échéance.

## Ce qu'il ne faut pas faire

- Activer un groupe de politiques complet sans avoir analysé les journaux Report-only au préalable.
- Supprimer les politiques héritées avant d'avoir observé les interactions avec le framework.
- Accumuler des exclusions "temporaires" sans les documenter. Elles deviennent permanentes.
- Confondre le mode Report-only avec une absence de risque : une politique en Report-only n'applique pas de contrôle, elle observe uniquement.
- Ignorer CA210 (blocage sign-in risk élevé) sous prétexte que CA201 (blocage user risk) est déjà active : les deux signaux sont distincts et complémentaires.

Ces erreurs sont rarement techniques. Elles sont méthodologiques.

## Conclusion

Le Conditional Access Framework v2026.2.1 ne s'active pas d'un clic. Il se déploie par superposition, observation et substitution progressive, en respectant la logique interne des politiques et de leurs exclusions.

Quel que soit le point de départ - Security Defaults, accès conditionnel partiel ou déploiement automatisé - la règle reste la même : cartographier d'abord, observer ensuite, activer en dernier.

Les articles suivants de cette série couvrent les politiques groupe par groupe. Ce guide en est la colonne vertébrale opérationnelle.