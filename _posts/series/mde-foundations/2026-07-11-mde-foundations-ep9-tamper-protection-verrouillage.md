---
title: "MDE Foundations - Episode 9 : Tamper Protection et verrouillage de la configuration"
date: 2026-07-11 08:00:00 +01:00
layout: post
categories: [securite, MDE]
tags:
  - Microsoft Defender for Endpoint
  - Tamper Protection
  - Intune
  - MDE Foundations
  - Endpoint Security
readtime: true
comments: true
sidebar: false
level: Intermédiaire
platform: Microsoft Defender for Endpoint
scope: Postes de travail / Serveurs
cover-img: assets/img/posts/series/mde-foundations/2026/07/mde-foundations-ep9-cover.png
thumbnail-img: assets/img/posts/series/mde-foundations/2026/07/mde-foundations-ep9-thumb.png
series: MDE Foundations
series_order: 9
---

Tu as passé huit épisodes à configurer MDE proprement. Antivirus, firewall, ASR, exclusions justifiées, groupes Entra ID structurés, policies en couches. Il reste une question : qu'est-ce qui empêche un attaquant, un administrateur local imprudent, ou un script tiers de défaire tout ça en une commande ?

Cet épisode pose le verrou final : Tamper Protection au niveau Windows Defender, plus quelques bonnes pratiques de verrouillage au niveau Intune et MDE.

## Ce que fait Tamper Protection

Tamper Protection est une fonctionnalité Windows Defender qui bloque les modifications des paramètres de sécurité par d'autres sources que MDE et Intune. Concrètement, quand Tamper Protection est activée, les actions suivantes sont rejetées :

- Désactivation de l'antivirus en temps réel via PowerShell, registre, ou GPO locale
- Désactivation de la protection cloud
- Désactivation des règles ASR
- Désactivation de la protection comportementale
- Désactivation de la protection IOAV (scan des téléchargements)
- Suppression des signatures de sécurité
- Modification des paramètres de scan
- Désactivation de Tamper Protection elle-même via les méthodes locales

Les seuls vecteurs autorisés pour modifier ces paramètres sont les policies Intune, les configurations MDE poussées via Security Management for MDE, et les administrateurs explicitement autorisés depuis le portail Microsoft Defender.

Les GPO classiques, les scripts PowerShell locaux (`Set-MpPreference -DisableRealtimeMonitoring $true`), les modifications de registre, ne fonctionnent pas. Tamper Protection les ignore silencieusement et logge la tentative.

![Tamper protection - Avant/Après](/assets/img/posts/series/mde-foundations/2026/07/mde-foundations-ep9-figure1.png)

## Le rôle critique en cas de compromission

L'intérêt principal de Tamper Protection se manifeste en cas de compromission active. Un attaquant qui obtient des privilèges administrateur sur un poste a historiquement plusieurs vecteurs pour neutraliser l'antivirus avant de déclencher son payload :

- `Set-MpPreference -DisableRealtimeMonitoring $true` en PowerShell
- Modification de la clé registre `HKLM\Software\Policies\Microsoft\Windows Defender`
- Création d'une GPO locale via `gpedit.msc`
- Désactivation du service Windows Defender via `sc stop windefend`

Sans Tamper Protection, toutes ces actions réussissent si l'attaquant a les droits admin local. Avec Tamper Protection, toutes ces actions échouent. L'attaquant doit alors trouver une autre voie, généralement plus bruyante (BYOVD pour désactiver le driver, exploit kernel), ce qui laisse plus de chances de détection.

C'est pourquoi Tamper Protection n'est pas une option de confort. C'est un contrôle critique qui transforme la valeur réelle de toutes les configurations posées dans les épisodes précédents.

## La désactivation comme anti-pattern d'audit

En audit, on trouve Tamper Protection désactivée dans environ la moitié des tenants. Les raisons invoquées sont presque toujours les mêmes :

**"On l'a désactivée pour installer notre antivirus tiers"**

Cas légitime au moment de l'installation, qui ne devrait plus l'être ensuite. Mais Tamper Protection n'a pas été réactivée après. Si l'antivirus tiers est encore en place, Tamper Protection doit quand même être active : elle protège les paramètres Windows Defender résiduel, et n'empêche pas l'antivirus tiers de fonctionner en mode actif (Windows Defender bascule alors en passif).

**"Ça posait problème pour notre logiciel de déploiement"**

Argument plus rare et généralement infondé. Les outils modernes de déploiement (Intune, MECM, Ansible avec WinRM) ne sont pas bloqués par Tamper Protection. Les outils qui poussent des modifications de paramètres Windows Defender via registre ou script local sont bloqués, mais c'est exactement le comportement souhaité.

**"On ne sait pas pourquoi, c'est resté comme ça"**

Le cas le plus fréquent. Tamper Protection a été désactivée à un moment donné pour une raison ponctuelle, et personne ne l'a réactivée.

Dans tous ces cas, la réponse est la même : réactiver Tamper Protection dans toutes les policies antivirus de la série. C’est un paramètre qui doit être à *Enabled* dans `MDE-AV-CatchAll`, `MDE-AV-Workstations-Production`, `MDE-AV-Workstations-Pilot`, `MDE-AV-Servers-Production` et `MDE-AV-Servers-Pilot`. Avec le modèle d’exclusivité de la série (un appareil reçoit une seule policy par domaine), Tamper Protection doit être présente et activée dans chaque policy pour qu’aucune machine, quelle que soit son groupe, ne s’en passe.


## Activer Tamper Protection via Intune

L'activation se fait au niveau de chaque policy Antivirus créée dans l'épisode 5. Le paramètre est présent dans toutes les policies AV de la série :

```
Tamper Protection : Enabled
```

Cette ligne doit être présente dans les cinq policies antivirus `MDE-AV-CatchAll`, `MDE-AV-Workstations-Production`, `MDE-AV-Workstations-Pilot`, `MDE-AV-Servers-Production`, `MDE-AV-Servers-Pilot`). Si elle manque dans l’une d’elles, c’est le moment de corriger : une machine ne doit jamais avoir Tamper Protection à Off, quelle que soit la policy qui la cible.

Une fois la policy déployée, Tamper Protection devient active sur le poste dans les minutes qui suivent l'application. Le changement d'état est tracé dans les logs Windows Defender (`Event ID 5007` dans le journal `Microsoft-Windows-Windows Defender/Operational`).

Vérification depuis PowerShell :

```powershell
Get-MpComputerStatus | Select-Object -Property IsTamperProtected
```

Valeur attendue : `True`.

## Activer Tamper Protection au niveau tenant

Au-delà de la policy Intune, Tamper Protection peut être activée globalement au niveau tenant depuis le portail Microsoft Defender. Cette activation tenant-wide s'applique à toutes les machines onboardées, et constitue une seconde ligne de défense en cas de défaillance de la policy Intune (policy non appliquée, conflit, machine hors scope).

Accès : `security.microsoft.com > Paramètres > Points de terminaison > Caractéristiques avancées > Protection contre les altérations`.

Active le toggle. La protection s'applique à toutes les machines onboardées dans MDE, indépendamment de leur configuration Intune. C'est une couche supplémentaire, gratuite, et qui ne devrait pas être désactivée sauf cas exceptionnel.

## Le contournement légitime : le mode Troubleshooting

Microsoft propose un mécanisme pour permettre des modifications ponctuelles malgré Tamper Protection : le **mode Troubleshooting**. Activable depuis le portail Defender, il désactive temporairement Tamper Protection sur une machine spécifique pour une durée définie (jusqu'à 4 heures).

Pendant cette fenêtre, un administrateur peut modifier localement les paramètres Windows Defender pour diagnostiquer un problème, tester une configuration, ou installer un logiciel qui nécessite ces modifications. Une fois la fenêtre expirée, Tamper Protection reprend automatiquement.

Cette fonctionnalité est tracée : chaque activation du mode Troubleshooting est loggée dans le portail MDE, avec l'identifiant de l'administrateur qui l'a déclenchée, l'appareil concerné, et la durée. C'est un audit-trail propre pour les opérations légitimes.

Accès : `security.microsoft.com > Assets > Devices > [poste concerné] > Troubleshoot`.

À utiliser avec parcimonie. Si tu te retrouves à activer le mode Troubleshooting fréquemment sur les mêmes machines pour les mêmes raisons, c'est probablement le signe qu'une exclusion ou une configuration manque dans tes policies Intune.

## Verrouiller la configuration Intune côté admin

Tamper Protection protège la configuration du côté de la machine. Reste à protéger la configuration du côté de l'administration : qui peut modifier les policies Intune, et avec quels droits.

Quelques bonnes pratiques de cloisonnement.

**Séparation des rôles**

Les administrateurs Intune qui gèrent les policies de déploiement applicatif ne devraient pas avoir les droits sur les policies de sécurité Endpoint Security. Les rôles intégrés Microsoft permettent cette séparation : `Endpoint Security Manager` pour la sécurité, `Intune Service Administrator` pour le reste.

**Privilèges Just-In-Time via PIM**

Les administrateurs de sécurité Endpoint ne devraient pas avoir leurs privilèges en permanence. L'activation via Privileged Identity Management (PIM) avec approbation et durée limitée trace chaque session d'administration et réduit la surface d'attaque sur les comptes admin.

**MFA obligatoire**

Évident mais à vérifier : aucun administrateur ayant un rôle sur Intune ou MDE ne doit pouvoir se connecter sans MFA. Ce contrôle se gère via les policies d'accès conditionnel sur les rôles privilégiés.

**Audit des modifications de policies**

Le portail Intune trace toutes les modifications de policies (créateur, date, contenu modifié). Cette piste d'audit doit être revue régulièrement, idéalement de manière automatisée en sortie sur un SIEM.

## Le cas des administrateurs locaux

Tamper Protection bloque les modifications locales y compris depuis un compte administrateur local. Tu n'as donc pas besoin de restreindre l'usage des comptes admin local sur tes postes pour protéger la configuration Windows Defender : c'est déjà géré.

En revanche, l'usage généralisé de comptes admin local sur les postes utilisateurs reste un anti-pattern de sécurité indépendant. La règle reste : aucun utilisateur n'a besoin d'être administrateur local sur son poste de travail, sauf cas spécifique justifié (développeurs avec besoin de compilation, administrateurs eux-mêmes sur leur poste d'admin). Pour ces cas, la solution moderne est **Windows LAPS** (Local Administrator Password Solution) qui gère l'élévation à la demande.

Cela dépasse le périmètre de cette série MDE, mais c'est un chantier connexe à ne pas oublier.

## Vérification après déploiement

Sur un poste, vérifier que Tamper Protection est bien active et que les tentatives de modification sont bloquées.

```powershell
Get-MpComputerStatus | Select-Object IsTamperProtected
```

Test de blocage. Tenter de désactiver la protection temps réel depuis PowerShell admin :

```powershell
Set-MpPreference -DisableRealtimeMonitoring $true
```

La commande retourne sans erreur, mais la valeur n'est pas appliquée. Vérification :

```powershell
Get-MpPreference | Select-Object DisableRealtimeMonitoring
```

La valeur doit rester à `False`. Si elle passe à `True`, Tamper Protection n'est pas active malgré l'apparence.

Dans le journal Windows Defender, l'événement bloqué apparaît :

```powershell
Get-WinEvent -LogName "Microsoft-Windows-Windows Defender/Operational" | `
  Where-Object { $_.Id -eq 5004 } | `
  Select-Object -First 5 TimeCreated, Message
```

Event ID `5004` correspond à une tentative de modification bloquée par Tamper Protection.

## Récapitulatif

Tu as maintenant :

- Tamper Protection activée au niveau machine via la policy Intune catch-all
- Tamper Protection activée également au niveau tenant comme seconde ligne
- Un mécanisme propre (mode Troubleshooting) pour les modifications légitimes ponctuelles
- Une séparation des rôles d'administration côté Intune avec PIM et MFA
- Une compréhension du rôle critique de cette brique en cas de compromission active

Avec cet épisode, la chaîne défensive est complète : antivirus correctement configuré, firewall sur les trois profils, règles ASR déployées progressivement, exclusions maîtrisées, et verrouillage de l'ensemble qui empêche les contournements locaux.

L'épisode suivant change d'angle : on passe à l'exploitation opérationnelle. Investigation et réponse avec MDE - comment exploiter la télémétrie remontée par tout ce qui vient d'être configuré.