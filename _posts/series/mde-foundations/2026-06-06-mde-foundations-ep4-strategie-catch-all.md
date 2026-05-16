---
title: "MDE Foundations - Episode 4 : la stratégie catch-all"
date: 2026-06-06 08:00:00 +01:00
layout: post
categories: [securite, MDE]
tags:
  - Microsoft Defender for Endpoint
  - Intune
  - MDE Foundations
  - Endpoint Security
  - Catch-all
readtime: true
comments: true
sidebar: false
level: Intermédiaire
platform: Microsoft Defender for Endpoint
scope: Postes de travail / Serveurs
cover-img: assets/img/posts/series/mde-foundations/2026/06/mde-foundations-ep4-cover.png
thumbnail-img: assets/img/posts/series/mde-foundations/2026/06/mde-foundations-ep4-thumb.png
series: MDE Foundations
series_order: 4
---

Tu as construit tes groupes pilote et production, postes et serveurs. Tu vas maintenant pousser des policies de configuration de plus en plus fines : antivirus, firewall, ASR, Tamper Protection. Avant de commencer, il faut traiter un cas que beaucoup de déploiements négligent : les machines qui ne tombent dans aucun de tes groupes.

Cet épisode pose un filet de sécurité pour ces machines, et clarifie au passage la logique des priorités d'assignment Intune.

## Pourquoi un catch-all

Les groupes dynamiques que tu as construits aux épisodes précédents reposent sur des règles : préfixe de nommage, `extensionAttribute`, ou listes statiques. Ces règles ont toutes la même faiblesse : elles ne couvrent que ce qu'on a prévu.

Voici les cas typiques où une machine onboardée dans MDE ne reçoit aucune policy Intune :

- Poste hors convention de nommage (machine de test renommée à la main, vieux serveur qui ne suit pas le standard actuel)
- Serveur joint au domaine sans hybrid join correctement propagé à Entra Connect
- Poste fraîchement onboardé qui n'a pas encore été affecté à son groupe métier
- Machine créée par un autre admin sans respecter la procédure
- Erreur dans la règle dynamique qui exclut involontairement une catégorie de machines

Sans catch-all, ces machines restent avec leur configuration MDE par défaut. Et la configuration par défaut de MDE est minimale : antivirus actif mais sans tuning, pas de protection cloud renforcée, pas de règles ASR, Tamper Protection souvent à Off selon l'OS et la version.

Le catch-all est une policy minimale qui s'applique à **toutes les machines onboardées**, et qui garantit un socle de sécurité même quand le ciblage fin a échoué.

## Le principe

L'idée est simple : tu crées un groupe qui contient l'ensemble des appareils du tenant, et tu lui assignes une policy contenant les paramètres non négociables :

- Antivirus actif en mode `Normal` (pas `Passive`)
- Tamper Protection activée
- Protection cloud activée
- EDR onboardé (déjà couvert par la policy de l'épisode 2 et 3)
- Quelques règles ASR en mode `Audit` minimum (pour la télémétrie)

Pas de configuration agressive, pas de blocage, pas d'exclusions spécifiques. Juste un filet.

Les policies plus spécifiques (postes pilote, postes production, serveurs pilote, serveurs production) viennent ensuite par-dessus avec des configurations plus fines. C'est là qu'il faut comprendre comment Intune résout les conflits entre policies.

## La logique de fusion des policies Intune

Quand plusieurs policies de sécurité Endpoint Security s'appliquent au même appareil via plusieurs groupes, Intune ne choisit pas "la dernière" ou "la plus prioritaire". Le comportement varie selon le type de paramètre.

**Fusion pour les listes** : pour les paramètres de type liste (exclusions antivirus, règles ASR, applications autorisées), Intune fusionne les valeurs des différentes policies. Si la policy catch-all définit une exclusion antivirus et la policy production en définit une autre, le poste reçoit les deux exclusions.

**Conflit pour les valeurs simples** : pour les paramètres à valeur unique (Tamper Protection on/off, protection cloud niveau, mode de protection temps réel), si deux policies définissent des valeurs différentes pour le même paramètre, il y a **conflit**. Le poste applique alors la **configuration la plus sécurisée par défaut**, et Intune remonte un statut `Conflit` dans le portail.

Cette logique a une conséquence pratique : si tu mets dans ta policy catch-all des valeurs strictes (Tamper Protection on, protection cloud à Élevé), et dans ta policy production des valeurs encore plus strictes, il n'y aura pas de conflit, tout fonctionne. Mais si une policy spécifique tente de **désactiver** quelque chose que le catch-all active, tu te retrouves avec un statut Conflit, et la configuration la plus stricte gagne.

C'est exactement le comportement souhaité pour un catch-all. Tu poses un plancher de sécurité, et les policies spécifiques ne peuvent que monter au-dessus.

**Attention** : ce comportement de "configuration la plus sécurisée gagne" s'applique aux paramètres de sécurité Endpoint Security. Pour les profils de configuration classiques Intune (Configuration Profiles), la logique est différente : un conflit reste un conflit non résolu, et aucune valeur ne s'applique. C'est pour cette raison que cette série utilise exclusivement les policies Endpoint Security, et pas les Configuration Profiles, pour MDE.

## Construire le groupe catch-all

Deux options pour cibler "toutes les machines onboardées dans MDE et enregistrées dans Entra ID".

**Option 1 - Affectation à "All devices"**

Intune propose une cible spéciale "All devices" lors de l'assignment d'une policy. Cette cible inclut automatiquement tous les appareils gérés par le tenant Intune, y compris les appareils en mode Security Management for MDE.

Avantage : pas de groupe à maintenir. Inconvénient : tu ne peux pas exclure des sous-ensembles facilement, et tu n'as pas de visibilité sur le périmètre exact.

**Option 2 - Groupe dynamique explicite**

Un groupe dynamique qui inclut tous les appareils avec un OS Windows.

```
(device.deviceOSType -eq "Windows")
```

Avantage : visibilité sur les membres, possibilité d'exclure des cas particuliers (postes de test à isoler par exemple). Inconvénient : la règle dynamique met quelques minutes à se propager pour les nouveaux appareils.

Je recommande l'**option 2** pour la traçabilité et la possibilité d'exclusion.

```
Nom : MDE-CatchAll-Windows
Type : Sécurité, membres dynamiques
Règle : (device.deviceOSType -eq "Windows")
```

## Construire la policy catch-all

La policy catch-all est volontairement minimale. Elle se construit dans **Sécurité des points de terminaison > Antivirus** (et plus tard, d'autres profils selon les épisodes).

Pour le moment, voici les paramètres à mettre dans la policy catch-all Antivirus :

| Paramètre | Valeur |
|---|---|
| Allow Realtime Monitoring | Allowed |
| Allow Cloud Protection | Allowed |
| Cloud Block Level | High |
| Submit Samples Consent | Send safe samples automatically |
| Disable Local Admin Merge | Disabled (les exclusions locales sont prises en compte) |
| Tamper Protection | Enabled |

Pas de liste d'exclusions à ce niveau. Pas de scan planifié spécifique. Pas de chemin réseau particulier. La policy doit pouvoir s'appliquer à n'importe quelle machine Windows sans casser quoi que ce soit.

Assigne cette policy au groupe `MDE-CatchAll-Windows`.

Dans les épisodes suivants, tu construiras des policies plus spécifiques (postes pilote, postes production, serveurs pilote, serveurs production) avec des configurations plus fines, qui viendront se superposer à ce socle.

## Vérifier que le catch-all fonctionne

Test rapide : prends un poste qui n'est dans aucun groupe spécifique (par exemple un poste de test que tu viens d'onboarder). Après application de la policy, vérifie depuis PowerShell :

```powershell
Get-MpComputerStatus | Select-Object -Property `
  RealTimeProtectionEnabled, `
  AntivirusEnabled, `
  IsTamperProtected, `
  AMRunningMode
```

Tu dois obtenir :

- `RealTimeProtectionEnabled : True`
- `AntivirusEnabled : True`
- `IsTamperProtected : True`
- `AMRunningMode : Normal`

Dans Intune, le statut de la policy sur cet appareil doit être `Réussi`. Si tu vois un statut `Conflit`, c'est qu'une autre policy assigne une valeur différente pour un paramètre, et qu'il faut tracer laquelle.

## Anti-patterns à éviter

Quelques erreurs courantes quand on met en place un catch-all.

**Mettre des paramètres trop stricts dans le catch-all**

Le catch-all couvre des machines que tu ne connais pas en détail. Si tu y mets des règles ASR en mode Block ou des exclusions critiques, tu risques de casser des serveurs métier que personne n'avait recensés. Reste sur du non bloquant.

**Oublier l'ordre de déploiement**

Le catch-all se déploie en premier, avant les policies spécifiques. Si tu déploies une policy production avant le catch-all, tu pourrais te retrouver avec des machines couvertes par production qui basculent ensuite sous une configuration catch-all moins stricte si elles sortent du groupe production. Le catch-all doit toujours être en place avant.

**Mélanger catch-all et exclusions globales**

Certains admins utilisent le catch-all pour pousser une liste d'exclusions antivirus "universelles" (chemins Office, dossiers temp Windows). Mauvaise idée : ces exclusions doivent vivre dans la policy de production, pas dans le catch-all. Le catch-all est un filet pour les machines orphelines, pas un dépotoir de configuration générique.

**Ignorer les statuts Conflit**

Si tu vois apparaître des statuts Conflit sur des paramètres Endpoint Security après ajout du catch-all, ne les laisse pas traîner. Ils indiquent une incohérence entre policies, généralement parce qu'une policy plus ancienne contient une valeur héritée qui ne devrait plus être là. Trace, corrige, supprime les policies obsolètes.

## Récapitulatif

Tu as maintenant :

- Un groupe `MDE-CatchAll-Windows` qui couvre toutes les machines Windows du tenant
- Une policy Antivirus minimale assignée à ce groupe, qui garantit un socle de sécurité même sans ciblage spécifique
- Une compréhension claire de la logique de fusion des policies Endpoint Security : pour les listes, fusion ; pour les valeurs simples, la configuration la plus stricte gagne en cas de conflit

Les épisodes suivants construisent par-dessus ce socle. À chaque nouvelle policy ajoutée à la série (firewall, ASR, Tamper Protection avancé), tu auras d'abord une version catch-all minimale, puis des versions plus spécifiques pour pilote et production.