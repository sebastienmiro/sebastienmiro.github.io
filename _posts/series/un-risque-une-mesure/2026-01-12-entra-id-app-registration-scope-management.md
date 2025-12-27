---
title: "Identités applicatives et non humaines : le piège du privilège permanent"
date: 2026-01-13 11:00:00 +01:00
layout: post
tags: [series:un-risque-une-mesure, entra-id, workload-identity, app-registrations, conditional-access, governance]
categories: [identite, entra-id]
readtime: true
comments: true
cover-img: "assets/img/banners/banner4.png"
thumbnail-img: "assets/img/posts/series/un-risque-une-mesure/2026-01-13-entra-id-app-registration-scope-management.png"
series: R1M
series_order: 060
sidebar: true
level: concepts
scope:
  - Entra ID
  - Identités applicatives
  - Accès non humain
  - Sécurité de l’identité
---

> 💡 **Contexte :** Dans Microsoft Entra ID, les applications et automatisations accèdent aux ressources à l’aide d’identités non humaines (App Registrations, Managed Identities, Service Principals). Contrairement aux utilisateurs dont le cycle de vie est lié au contrat de travail, ces identités techniques s'accumulent souvent sans date de fin.

![Entra ID - App management overview](/assets/img/posts/series/un-risque-une-mesure/2026-01-13-app-management-overview.png)

L’authentification de ces identités repose sur des moyens techniques — secrets ou certificats — dont la durée de validité est nécessairement limitée. En revanche, les **permissions applicatives** accordées à ces identités ne sont, par défaut, ni temporaires ni soumises à un mécanisme systématique de remise en question dans le temps.

Cette dissociation entre la durée de vie du moyen d’authentification et celle du privilège constitue un risque spécifique, distinct de celui des identités humaines.

## Le risque : Des permissions applicatives sans temporalité

Une identité applicative ne s’authentifie pas de manière interactive et n’est pas soumise aux contrôles classiques (MFA, localisation).

Le piège réside dans la confusion entre sécurité de l'authentification et sécurité de l'autorisation :
* **Authentification :** Les secrets expirent et sont renouvelés.
* **Autorisation :** Les permissions (`User.ReadWrite.All`, `Files.Read.All`) restent valides tant qu’elles ne sont pas explicitement retirées.

Dans de nombreux environnements, ces permissions sont attribuées à la création de l’application et conservées indéfiniment. Le privilège devient alors durable par conception, sans lien direct avec un besoin opérationnel courant. Une compromission ultérieure de l'identité permettrait d'exploiter l'ensemble des permissions accumulées depuis des années.

### Détection et contrôles limités
De plus, l’absence d’interaction humaine limite l’efficacité de la détection comportementale. Les accès applicatifs légitimes et malveillants peuvent présenter des caractéristiques similaires (gros volumes de données, horaires 24/7), rendant l’analyse des journaux complexe.

## L'illusion de sécurité : Identités Managées et Rotation

On pourrait penser que l'usage des **Identités Managées (Managed Identities)** résout le problème. C'est en partie vrai pour l'authentification : la plateforme gère la rotation des secrets, éliminant le risque de fuite de mot de passe dans le code.

Toutefois, les identités managées ne résolvent pas le problème de fond. Les permissions applicatives accordées à ces identités restent durables tant qu’elles ne sont pas explicitement révoquées. La réduction du risque d’authentification ne doit pas être confondue avec la gouvernance du privilège. Une identité managée avec trop de droits reste une identité dangereuse.

## La Mesure : Implémenter une Gouvernance du Cycle de Vie (ALM)

Pour contrer ce risque de persistance, il ne suffit pas de "durcir" la configuration technique. Il faut instaurer un processus récurrent de validation des privilèges. Voici la démarche structurée pour reprendre le contrôle.

### Niveau 1 : L'hygiène des Propriétaires (Owners)
Aucune gouvernance n'est possible sans responsabilité (*Accountability*). La première étape consiste à auditer vos **Enterprise Applications**.

* **Le problème :** Les applications créées par des administrateurs partis de l'entreprise deviennent "orphelines". Personne ne sait ce qu'elles font, donc personne n'ose les supprimer.
* **L'action :** Imposer la présence d'au moins **deux propriétaires** (Owners) actifs sur chaque App Registration. Si une application n'a pas de propriétaire, elle est candidate à la désactivation.

### Niveau 2 : Access Reviews pour les Service Principals (La solution cible)
C'est la mesure technique phare proposée par Microsoft Entra ID (requiert une licence *Workload Identities Premium*). Elle permet d'automatiser la recertification des accès.

**Le principe :**
Plutôt que de faire un audit Excel annuel pénible, vous configurez une politique dans *Identity Governance* :
1.  **Cible :** Tous les Service Principals ayant des rôles privilégiés (ex: Application Permissions sur Graph API).
2.  **Réviseur :** Les propriétaires de l'application (Owners) ou, à défaut, un groupe de sécurité "Gouvernance".
3.  **Fréquence :** Trimestrielle ou semestrielle.
4.  **Action :** Si le propriétaire ne répond pas ou refuse l'accès, les permissions sont retirées ou le compte est désactivé.

**Pourquoi c'est efficace :**
Cela déplace la charge de la preuve. Ce n'est plus à l'équipe Sécurité de prouver que l'application est dangereuse. C'est au propriétaire de l'application de signer numériquement qu'elle est toujours légitime.

### Niveau 3 : Le Moindre Privilège par le Partitionnement
Pour les environnements matures, la mesure ultime est de réduire la portée des permissions via :
* **Resource Specific Consent (RSC) :** L'application n'a accès qu'aux données d'une équipe Teams spécifique, pas à tout le tenant.
* **Administrative Units :** Restreindre le champ d'action d'une identité applicative à uen partie de l'entreprise.

## Défense en profondeur : Accès Conditionnel pour Workload Identities

En complément de la gouvernance, l'accès conditionnel peut désormais s'appliquer aux identités de charge de travail (licences spécifiques requises).

Cela permet de restreindre l'usage d'un Service Principal à des adresses IP de confiance (ex: vos serveurs on-premise ou vos plages IP Azure). Bien que cela ne réduise pas les permissions, cela limite considérablement la capacité d'un attaquant à utiliser un token volé depuis l'extérieur de votre périmètre réseau.

## Mise en œuvre pratique : Par où commencer ?

Si vous devez prioriser vos actions demain matin :

1.  **Inventaire :** Listez toutes les applications ayant des *Application Permissions* (pas *Delegated*) sur Microsoft Graph.
2.  **Focus Critique :** Isolez celles qui ont des droits globaux de type `*.All` (ex: `User.ReadWrite.All`, `Mail.ReadWrite`, `RoleManagement.ReadWrite`).
3.  **Nettoyage immédiat :** Supprimez les secrets expirés depuis plus de 12 mois (signe d'abandon) et désactivez les Service Principals inactifs depuis 90 jours.
4.  **Automatisation :** Activez une première Access Review en mode "Audit seul" (sans blocage automatique) pour éduquer les propriétaires d'applications.

## Conclusion

Les identités applicatives sont des composants indispensables des environnements Microsoft 365. Le risque principal associé ne réside pas dans la durée de validité des secrets, mais dans la persistance des permissions.

Tant que ces permissions ne sont pas traitées comme des capacités à gouverner dans le temps — avec une portée définie, une justification explicite et une revue régulière — elles constituent un point de fragilité durable (et souvent invisible) dans la sécurité de votre identité.