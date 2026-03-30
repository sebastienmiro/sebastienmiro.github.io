---
title: "Conditional Access Framework v2026.2.1 - CA200 à CA210 : utilisateurs internes"
date: 2026-03-13 09:00:00 +01:00
layout: post
tags: [series:conditional-access-framework, utilisateurs, deploiement]
categories: [identite, entra-id]
readtime: true
comments: true
cover-img: "assets/img/banners/banner-conditional-access.png"
thumbnail-img: "assets/img/posts/series/conditional-access-framework/120/120-thumb.png"
series: CA
series_order: 120
sidebar: true
level: technique
scope:
  - Entra ID
  - Utilisateurs internes
  - Déploiement
platform: Microsoft Entra
---

## Le bloc le plus dense du framework

Les politiques CA200 à CA210 couvrent les utilisateurs internes standards. C'est le bloc le plus volumineux du framework - 11 politiques - et le plus actif en production : il traite les identités les plus nombreuses, celles qui génèrent l'essentiel du volume d'authentifications quotidiennes.

Ce bloc se situe délibérément entre deux extrêmes. Le socle global (CA000-CA006) couvre large mais reste minimal. Le bloc Admins (CA100-CA105) impose des contraintes fortes et non négociables. Le bloc Internals traduit un compromis assumé : suffisamment strict pour réduire les risques concrets, suffisamment pragmatique pour rester appliqué au quotidien sans friction excessive.

## Logique d'inclusion et d'exclusion

L'inclusion repose sur des groupes représentant explicitement les utilisateurs internes standards (APP_Microsoft365_E5 ou équivalents dans le framework de référence). Ces groupes définissent un périmètre d'usage, pas un niveau de confiance.

Les exclusions sont structurantes. On retrouve systématiquement :

- les comptes break-glass, exclus de l'ensemble du framework sans exception ;
- les comptes à privilèges, traités exclusivement par CA100-CA105 ;
- les comptes de service et identités non interactives, couverts par CA300-CA301 ;
- les invités et identités externes, couverts par CA400-CA404.

Cette logique garantit qu'un utilisateur interne est évalué par les règles de son bloc, ni surprotégé par des contraintes administratives, ni sous-couvert par le seul socle global.

## CA200 - Internals Identity Protection - MFA

CA200 impose la MFA pour l'ensemble des utilisateurs internes, sur toutes les applications, depuis toutes les plateformes.

C'est le point d'entrée du bloc. Elle prend le relais de CA000 dès lors que l'identité est identifiée comme utilisateur interne standard. Contrairement à CA105 qui impose des méthodes résistantes au phishing pour les admins, CA200 accepte les méthodes MFA classiques - OTP, push, clé FIDO2. L'objectif est de garantir un second facteur sans créer de blocage opérationnel sur un périmètre large.

> **Prérequis.** Vérifier avant activation que les méthodes MFA sont configurées et déployées pour l'ensemble des utilisateurs du groupe d'inclusion. Un utilisateur sans méthode MFA enregistrée sera bloqué dès l'activation de CA200.

![CA200-Internals-IdentityProtection-AnyApp-AnyPlatform-MFA](/assets/img/posts/conditional-access-framework/)

## CA201 - Internals Identity Protection - Block High-Risk User

CA201 bloque l'accès des utilisateurs internes dont le **user risk** est évalué à un niveau élevé par Entra ID Protection.

Le user risk est un signal cumulatif. Il reflète la probabilité qu'un compte soit compromis, calculée à partir de l'historique des comportements : credentials ayant fuité dans des bases de données publiques, patterns d'authentification anormaux, activités suspectes détectées sur le compte. Ce signal est persistent - il reste élevé jusqu'à ce qu'il soit explicitement remédié (réinitialisation du mot de passe, confirmation de sécurité par l'administrateur).

CA201 ne cherche pas à compenser ce risque par un contrôle supplémentaire. Elle interrompt l'accès. Un compte évalué comme probablement compromis n'a pas à accéder aux ressources de l'organisation, quelle que soit la méthode d'authentification présentée.

> **Prérequis.** CA201 nécessite des licences Entra ID Protection (incluses dans Microsoft Entra ID P2 / Microsoft 365 E5). Sans ces licences, les signaux de user risk ne sont pas calculés et la politique n'a aucun effet.

> **À noter.** CA201 et CA210 couvrent deux signaux distincts et complémentaires. CA201 agit sur le risque lié à l'identité (user risk). CA210 agit sur le risque lié à la transaction d'authentification en cours (sign-in risk). Ces deux politiques ont été séparées en v2025.2.3 - auparavant regroupées dans une seule politique, ce qui rendait l'analyse et la remédiation plus difficiles.

![CA201-Internals-IdentityProtection-AnyApp-AnyPlatform-BLOCK-HighRiskUser](/assets/img/posts/conditional-access-framework/)

## CA202 - Internals Identity Protection - Sign-in Frequency (Unmanaged Devices)

CA202 impose une fréquence de réauthentification maximale de 12 heures pour les utilisateurs internes accédant depuis des appareils Windows ou macOS non gérés.

Elle reconnaît explicitement que tous les accès internes ne se font pas depuis des postes maîtrisés - BYOD, postes personnels, accès depuis un hôtel ou un espace de coworking. Dans ces contextes, la durée de vie des sessions est réduite sans bloquer systématiquement l'accès.

Les appareils gérés et conformes sont exclus de cette politique : ils bénéficient d'une durée de session plus souple, car le niveau de confiance accordé au poste justifie cet assouplissement.

![CA202-Internals-IdentityProtection-AllApps-WindowsMacOS-SigninFrequency-UnmanagedDevices](/assets/img/posts/conditional-access-framework/)

## CA203 - Internals App Protection - Intune Enrollment - MFA

CA203 impose la MFA lors de l'enrôlement d'appareils dans Intune.

L'enrôlement est un acte structurant : il établit une relation de confiance entre un appareil et le tenant, et conditionne ensuite les décisions de conformité des politiques CA205 et CA208. Un enrôlement initié par un compte compromis peut introduire un appareil non maîtrisé dans le périmètre de confiance de l'organisation.

CA203 vise à s'assurer que seules des identités correctement authentifiées peuvent déclencher cette opération.

> **Point d'attention critique - Autopilot Device Preparation v2.** L'enrôlement automatisé via Autopilot Device Preparation (v2) peut échouer sous CA203 : le processus automatisé est incapable de satisfaire une exigence MFA interactive. Les appareils concernés restent bloqués pendant l'OOBE (Out-Of-Box Experience). Les utilisateurs Autopilot Device Preparation doivent être ajoutés au groupe d'exclusion de CA203 avant son activation.

![CA203-Internals-AppProtection-MicrosoftIntuneEnrollment-AnyPlatform-MFA](/assets/img/posts/conditional-access-framework/)

## CA204 - Internals Attack Surface Reduction - Block Unknown Platforms

CA204 bloque les accès depuis des plateformes non reconnues ou non supportées par le framework.

Les plateformes supportées sont Windows, macOS, iOS et Android. Toute tentative d'accès depuis une plateforme hors de cette liste - Linux, Windows Phone, ou un user-agent manipulé - est bloquée.

Ce filtre remplit deux fonctions. Il empêche l'exploitation de clients atypiques non couverts par les autres politiques du bloc. Il garantit également que les signaux device (conformité, jonction) peuvent être évalués correctement sur des plateformes connues.

> **Si Linux est utilisé dans votre environnement**, CA204 doit être ajustée avant activation. Le blocage de Linux est le comportement par défaut du framework - il ne correspond pas à tous les contextes.

![CA204-Internals-AttackSurfaceReduction-AllApps-AnyPlatform-BlockUnknownPlatforms](/assets/img/posts/conditional-access-framework/)

## CA205 - Internals Base Protection - Windows Compliant or AAD Hybrid Joined

CA205 conditionne l'accès depuis Windows à l'une des deux conditions suivantes : l'appareil est conforme (géré par Intune, politiques de conformité satisfaites) ou il est Hybrid Joined (joint à Active Directory et synchronisé avec Entra ID).

Cette politique introduit le signal device comme critère d'accès à part entière. Elle ne vise pas à garantir la sécurité absolue du poste - un appareil Hybrid Joined peut être compromis comme n'importe quel autre - mais à établir une frontière claire entre les postes intégrés à l'environnement et les postes complètement inconnus.

Un poste personnel non géré sous Windows ne satisfait ni la conformité Intune ni la jonction hybrid. Il sera bloqué par CA205, indépendamment des autres contrôles.

> **Prérequis.** L'application Microsoft Intune Enrollment (`d4ebce55-015a-49b5-a083-c84d1797ae8c`) doit exister dans le tenant. Si elle est absente : `New-MgServicePrincipal -AppId d4ebce55-015a-49b5-a083-c84d1797ae8c`.

![CA205-Internals-BaseProtection-AnyApp-Windows-CompliantorAADHJ](/assets/img/posts/conditional-access-framework/)

## CA206 - Internals Identity Protection - Persistent Browser

CA206 désactive les sessions persistantes dans le navigateur pour les utilisateurs internes accédant depuis des appareils non gérés.

Une session persistante maintient un état authentifié entre les fermetures de navigateur. Sur un poste non maîtrisé - poste partagé, appareil personnel - cela signifie que l'accès aux ressources de l'organisation reste ouvert bien au-delà de l'usage intentionnel.

Les appareils gérés et conformes sont exclus de cette politique. Le niveau de confiance accordé au poste justifie de maintenir le confort de session.

![CA206-Internals-IdentityProtection-AllApps-AnyPlatform-PersistentBrowser](/assets/img/posts/conditional-access-framework/)

## CA207 - Internals Attack Surface Reduction - Selected Apps - Block

CA207 permet de bloquer l'accès à des applications spécifiques pour les utilisateurs internes lorsque certaines conditions ne sont pas réunies.

C'est une politique template dans le framework de référence : les applications ciblées et les conditions de blocage sont à définir selon le contexte de chaque organisation. Elle introduit une segmentation applicative ciblée sans généraliser des contraintes à l'ensemble du tenant.

Un cas d'usage typique : bloquer l'accès à une application sensible depuis des appareils non conformes, ou restreindre certaines applications à des groupes d'utilisateurs précis.

![CA207-Internals-AttackSurfaceReduction-SelectedApps-AnyPlatform-BLOCK](/assets/img/posts/conditional-access-framework/)

## CA208 - Internals Base Protection - macOS Compliant

CA208 applique aux environnements macOS la même logique que CA205 pour Windows : l'accès est conditionné à la conformité Intune de l'appareil.

La jonction Hybrid (AADJ) n'est pas disponible nativement sur macOS, d'où l'absence de cette alternative. La conformité Intune est le seul signal device exploitable sur cette plateforme dans le cadre du framework.

> **Même prérequis que CA205** : l'application Microsoft Intune Enrollment doit exister dans le tenant.

![CA208-Internals-BaseProtection-AnyApp-MacOS-Compliant](/assets/img/posts/conditional-access-framework/)

## CA209 - Internals Identity Protection - Continuous Access Evaluation

CA209 active le Continuous Access Evaluation (CAE) pour les utilisateurs internes. Le fonctionnement est identique à CA104 pour les admins : Entra ID peut notifier les applications compatibles en temps quasi réel lors d'un événement critique (révocation de session, désactivation du compte, signal de risque), sans attendre l'expiration du token.

Pour les utilisateurs internes, cette capacité est particulièrement utile lors de départs ou de suspensions de comptes : l'accès aux ressources est coupé en quelques secondes plutôt qu'en plusieurs dizaines de minutes.

> **CA209 ne supporte pas le mode Report-only.** Les modes disponibles sont ON et OFF uniquement. Même contrainte que CA104 - à prendre en compte dans la séquence de déploiement.

![CA209-Internals-IdentityProtection-AllApps-AnyPlatform-ContinuousAccessEvaluation](/assets/img/posts/conditional-access-framework/)

## CA210 - Internals Identity Protection - Block High-Risk Sign-in

CA210 bloque les connexions dont le **sign-in risk** est évalué à un niveau élevé par Entra ID Protection au moment de l'authentification.

Contrairement au user risk (CA201), le sign-in risk est un signal transactionnel. Il est calculé à l'instant de la tentative de connexion, à partir de signaux contextuels : adresse IP associée à des activités malveillantes connues, propriétés de connexion atypiques (pays inhabituel, device inconnu, heure anormale), patterns correspondant à des attaques en cours détectées par Microsoft à l'échelle de son infrastructure.

CA210 et CA201 sont complémentaires et non redondantes. Un compte non compromis peut présenter un sign-in risk élevé (connexion depuis une IP malveillante). Un compte compromis peut présenter un user risk élevé sans déclencher de sign-in risk (attaquant utilisant une IP propre). Les deux signaux doivent être couverts séparément.

> **Prérequis identique à CA201.** Licences Entra ID Protection requises (Microsoft Entra ID P2 / Microsoft 365 E5).

![CA210-Internals-IdentityProtection-AnyApp-AnyPlatform-BLOCK-HighRiskSignIn](/assets/img/posts/conditional-access-framework/)

## Ce que le bloc Internals ne fait pas

CA200-CA210 ne traitent pas les usages administratifs et n'imposent pas les contraintes du bloc Admins. Elles ne garantissent pas non plus la sécurité intrinsèque des appareils ou des applications : elles exploitent des signaux et posent des garde-fous, elles ne certifient pas un niveau de sécurité absolu.

La conformité Intune (CA205, CA208) indique qu'un appareil respecte les politiques définies - pas qu'il est inviolable. Le sign-in risk (CA210) détecte les comportements anormaux connus - pas toutes les attaques sophistiquées.

## Conclusion

Le bloc CA200-CA210 est le cœur opérationnel du framework. C'est sur lui que repose l'efficacité quotidienne du dispositif, car il couvre le périmètre le plus large et le plus actif.

Sa densité - 11 politiques couvrant MFA, risque identité, risque transactionnel, conformité device, protection des sessions et réduction de surface - reflète la complexité réelle des usages internes. Chaque politique adresse un vecteur distinct. Elles ne se substituent pas les unes aux autres : elles se complètent.

Conformément à la logique de déploiement progressif du framework, ce bloc s'active avant les Admins - pour roder la mécanique sur un périmètre moins exposé - et avant le socle global.