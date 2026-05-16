---
title: "MDE Foundations - Episode 11 : le template MDE Foundations, import clés en main"
date: 2026-07-25 08:00:00 +01:00
layout: post
categories: [securite, MDE]
tags:
  - Microsoft Defender for Endpoint
  - Intune
  - MDE Foundations
  - Template
  - IntuneManagement
readtime: true
comments: true
sidebar: false
level: Avancé
platform: Microsoft Defender for Endpoint
scope: Postes de travail / Serveurs
cover-img: assets/img/posts/2025/07/mde-foundations-ep11-cover.png
thumbnail-img: assets/img/posts/2025/07/mde-foundations-ep11-thumb.png
series: MDE Foundations
series_order: 11
---

Dix épisodes pour construire une configuration MDE complète, structurée par couches, avec une logique de groupes Entra ID, des policies différenciées postes et serveurs, et une stratégie de déploiement progressif. Cet épisode final consolide l'ensemble en un template importable, et clôt la série MDE Foundations.

## Vue d'ensemble du template

Le template MDE Foundations couvre l'ensemble des briques vues dans la série. Voici la liste des éléments à mettre en place dans un tenant cible.

**Groupes Entra ID**

- `MDE-CatchAll-Windows` : groupe dynamique couvrant tous les appareils Windows du tenant
- `MDE-Pilot-Workstations` : groupe statique pour les postes de travail pilotes
- `MDE-Production-Workstations` : groupe dynamique pour les postes de travail de production
- `MDE-Pilot-Servers` : groupe statique pour les serveurs pilotes
- `MDE-Production-Servers` : groupe dynamique pour les serveurs de production

**Policies Endpoint Security**

- Onboarding EDR : une policy unique pour les postes et serveurs
- Antivirus : cinq policies en couches (catch-all + production postes + production serveurs + pilote postes + pilote serveurs)
- Firewall : trois policies (configuration globale + règles postes + règles serveurs)
- ASR : quatre policies (faible risque + Office audit + Office warn + Office block)

**Configuration au niveau tenant**

- Activation de Security Management for MDE pour les postes hors Intune
- Activation globale de Tamper Protection
- Configuration de l'investigation automatisée

## Prérequis avant déploiement

Avant d'importer ou de créer quoi que ce soit, vérifie les points suivants dans ton tenant.

**Licences**

Au minimum une licence MDE P1 ou P2 par utilisateur pour les postes de travail (incluse dans M365 E3/E5 ou Business Premium). Pour les serveurs, une licence MDE for Servers, Defender for Business servers, ou Defender for Servers via Defender for Cloud (voir épisode 3).

**Activation MDE**

Le tenant MDE doit être initialisé : `security.microsoft.com > Paramètres > Points de terminaison`. Si tu n'as jamais activé MDE, la première connexion au portail propose un assistant d'initialisation.

**Intégration MDE et Intune**

Activée depuis le portail Microsoft Defender : `Paramètres > Points de terminaison > Caractéristiques avancées > Microsoft Intune connection`. Sans cette activation, les policies Intune ne peuvent pas pousser les paramètres MDE.

**Security Management for MDE**

Pour bénéficier de la gestion Intune sur les machines sans licence Intune (managed by MDE). Activée depuis : `Paramètres > Points de terminaison > Configuration management > Pilot Mode` puis `Enforcement Scope`.

**Convention de nommage des machines**

Les règles dynamiques des groupes reposent sur le préfixe du nom de machine. Adapte la convention à ton parc :

- Postes : généralement `WRK-`, `LAP-`, `PC-` ou similaire
- Serveurs : généralement `SRV-`, `SQL-`, `WEB-` ou similaire

Si tu n'as pas de convention, utilise un `extensionAttribute` renseigné dans Active Directory pour les environnements hybrid join, ou un ajustement statique en attendant.

## Étape 1 - Installer IntuneManagement

IntuneManagement est un outil open source qui permet d'exporter, importer et comparer des objets Intune via Microsoft Graph, depuis une interface graphique. Il s'installe en quelques minutes.

Prérequis :
- PowerShell 5.1 ou supérieur (Windows PowerShell, pas PowerShell 7 pour la version stable)
- Modules Graph PowerShell installés au préalable

Installation :

```powershell
# Récupération du dépôt
git clone https://github.com/Micke-K/IntuneManagement.git
cd IntuneManagement

# Premier lancement
.\Start-WithConsole.ps1
```

L'outil ouvre une fenêtre WPF avec une zone de navigation à gauche et une zone de travail à droite. La première utilisation demande de s'authentifier sur ton tenant via une App Registration Entra ID. L'App requise peut être créée automatiquement par l'outil avec les permissions Graph nécessaires, ou tu peux pointer vers une App existante si ton tenant restreint la création d'App.

Permissions Graph requises :
- `DeviceManagementApps.ReadWrite.All`
- `DeviceManagementConfiguration.ReadWrite.All`
- `DeviceManagementServiceConfig.ReadWrite.All`
- `Group.ReadWrite.All`
- `Policy.ReadWrite.ConditionalAccess`
- `User.Read.All`

Une fois connecté, tu accèdes aux différents types d'objets : Configuration Profiles, Endpoint Security Policies, Groupes, etc.

## Étape 2 - Créer les groupes Entra ID

Les groupes peuvent être créés directement depuis IntuneManagement ou depuis le portail Entra ID. Voici les définitions exactes.

**MDE-CatchAll-Windows**

```
Type : Sécurité, membres dynamiques
Description : Catch-all - Tous les appareils Windows onboardés
Règle dynamique :
  (device.deviceOSType -eq "Windows")
```

**MDE-Pilot-Workstations**

```
Type : Sécurité, membres statiques
Description : Postes de travail pilotes - Validation pré-production
Membres : sélection manuelle de 5 à 20 postes représentatifs
```

**MDE-Production-Workstations**

```
Type : Sécurité, membres dynamiques
Description : Postes de travail en production
Règle dynamique (à adapter à ta convention) :
  (device.deviceOSType -eq "Windows") 
  and (device.deviceOSVersion -notStartsWith "10.0.17763")
  and (device.displayName -startsWith "WRK-")
```

Le filtre sur `deviceOSVersion` exclut Windows Server (qui a un OS Version qui démarre par 10.0.17763 pour 2019, 10.0.20348 pour 2022). Adapte selon les versions présentes dans ton parc.

**MDE-Pilot-Servers**

```
Type : Sécurité, membres statiques
Description : Serveurs pilotes - Idéalement serveurs non critiques ou lab
Membres : sélection manuelle de 2 à 5 serveurs
```

**MDE-Production-Servers**

```
Type : Sécurité, membres dynamiques
Description : Serveurs Windows en production
Règle dynamique (à adapter) :
  (device.deviceOSType -eq "Windows") 
  and (device.displayName -startsWith "SRV-")
```

## Étape 3 - Créer la policy d'onboarding EDR

Une seule policy d'onboarding couvre postes et serveurs.

`Sécurité des points de terminaison > Détection de point de terminaison et réponse > Créer une policy`

```
Nom : MDE-EDR-Onboarding
Plateforme : Windows 10, Windows 11 et Windows Server
Profile : Endpoint detection and response
```

Paramètres :

| Paramètre | Valeur |
|---|---|
| Microsoft Defender for Endpoint client configuration package type | Auto from connector |
| Sample sharing | All |
| Telemetry Reporting Frequency | Expedite |

Assignations :

- `MDE-CatchAll-Windows` (inclusion)

## Étape 4 - Créer les policies Antivirus

Cinq policies en couches. Toutes sont créées depuis `Sécurité des points de terminaison > Antivirus > Créer une policy`, plateforme `Windows 10, Windows 11 et Windows Server`, profil `Microsoft Defender Antivirus`.

### MDE-AV-CatchAll

Le socle minimal appliqué à tout appareil Windows.

| Paramètre | Valeur |
|---|---|
| Allow Realtime Monitoring | Allowed |
| Allow Behavior Monitoring | Allowed |
| Allow IOAV Protection | Allowed |
| Allow Script Scanning | Allowed |
| Allow On Access Protection | Allowed |
| Allow Cloud Protection | Allowed |
| Cloud Block Level | High |
| Cloud Extended Timeout | 50 |
| Submit Samples Consent | Send safe samples automatically |
| Disable Catchup Quick Scan | Disabled |
| Disable Catchup Full Scan | Disabled |
| Disable Local Admin Merge | Disabled |
| Allow Archive Scanning | Allowed |
| Allow Email Scanning | Allowed |
| Allow Full Scan On Mapped Network Drives | Not Allowed |
| Allow Scanning Network Files | Not Allowed |
| Real Time Scan Direction | Monitor all files (bi-directional) |
| Days To Retain Cleaned Malware | 30 |
| Tamper Protection | Enabled |
| Disable Auto Exclusions | Not Configured |

Assignations : `MDE-CatchAll-Windows`

### MDE-AV-Workstations-Production

Couche spécifique aux postes de travail. Hérite du catch-all et ajoute des paramètres orientés usage utilisateur.

| Paramètre | Valeur |
|---|---|
| Scan Parameter | Full scan |
| Schedule Scan Day | Saturday |
| Schedule Quick Scan Time | 720 (12:00) |
| Schedule Scan Time | 120 (02:00) |
| Avg CPU Load Factor | 25 |
| Disable CPU Throttle On Idle Scans | Disabled |
| Check For Signatures Before Running Scan | Enabled |
| Signature Update Interval | 4 |

Pas d'exclusions à ce niveau. Les exclusions spécifiques métier doivent vivre dans une policy dédiée par application, pas dans cette policy générique.

Assignations : `MDE-Production-Workstations`

### MDE-AV-Servers-Production

Couche spécifique aux serveurs. Hérite du catch-all et ajuste pour le contexte serveur.

| Paramètre | Valeur |
|---|---|
| Scan Parameter | Quick scan |
| Schedule Scan Day | Sunday |
| Schedule Quick Scan Time | 180 (03:00) |
| Avg CPU Load Factor | 10 |
| Disable CPU Throttle On Idle Scans | Disabled |
| Disable Auto Exclusions | Not Configured |
| Allow On Access Protection | Allowed |

Les exclusions automatiques liées aux rôles serveur (Exchange, SQL Server, AD DS, IIS, Hyper-V) sont appliquées automatiquement par Windows Server 2016+ tant que `Disable Auto Exclusions` n'est pas explicitement à `Enabled`.

Assignations : `MDE-Production-Servers`

### MDE-AV-Workstations-Pilot

Couche encore plus stricte appliquée aux postes pilotes pour identifier les éventuels faux positifs avant rollout production.

| Paramètre | Valeur |
|---|---|
| Cloud Block Level | High Plus |

Assignations : `MDE-Pilot-Workstations`

### MDE-AV-Servers-Pilot

Identique au pilote postes pour le paramètre Cloud Block Level.

| Paramètre | Valeur |
|---|---|
| Cloud Block Level | High Plus |

Assignations : `MDE-Pilot-Servers`

## Étape 5 - Créer les policies Firewall

Trois policies. La première porte la configuration globale, les deux autres portent les règles différenciées par type d'appareil.

### MDE-FW-CatchAll

Configuration globale du firewall, appliquée à tout appareil Windows.

`Sécurité des points de terminaison > Pare-feu > Créer une policy`, plateforme `Windows 10, Windows 11 et Windows Server`, profil `Pare-feu Microsoft Defender`.

Pour chacun des trois profils (Domaine, Privé, Public), appliquer les mêmes valeurs :

| Paramètre | Valeur |
|---|---|
| Enable Firewall | True |
| Default Inbound Action | Block |
| Default Outbound Action | Allow |
| Disable Unicast Responses To Multicast Broadcast Traffic | False |
| Disable Stealth Mode | False |
| Disable Stealth Mode IPsec Secured Packet Exemption | False |
| Allow Local Policy Merge | False |
| Allow Local IPsec Policy Merge | False |
| Disable Inbound Notifications | False |

Pour les serveurs, créer une copie de cette policy avec `Disable Inbound Notifications` à `True` (pas de popup utilisateur pertinent sur serveur sans session interactive).

Assignations : `MDE-CatchAll-Windows`

### MDE-FW-Rules-Workstations

Règles spécifiques aux postes de travail.

`Sécurité des points de terminaison > Pare-feu > Créer une policy`, plateforme `Windows 10, Windows 11 et Windows Server`, profil `Règles de pare-feu Microsoft Defender`.

Règles à créer :

```
Nom : Block-Outbound-SMB-Internet
Direction : Outbound
Action : Block
Protocole : TCP
Ports distants : 445
Adresses distantes : Internet
Profils : Domaine, Privé, Public
Description : Empêche les mouvements latéraux SMB sortants vers Internet
```

```
Nom : Block-Outbound-Legacy-Protocols
Direction : Outbound
Action : Block
Protocole : TCP
Ports distants : 21, 23, 69
Profils : Domaine, Privé, Public
Description : Bloque Telnet, FTP, TFTP sortants
```

```
Nom : Block-Inbound-RDP-Public
Direction : Inbound
Action : Block
Protocole : TCP
Ports locaux : 3389
Profils : Public
Description : Empêche RDP entrant sur profil Public (café, aéroport)
```

```
Nom : Allow-Inbound-ICMPv4-Echo-Domain
Direction : Inbound
Action : Allow
Protocole : ICMPv4
Type ICMP : 8
Profils : Domaine
Description : Autorise ping entrant sur profil Domaine pour supervision
```

Assignations : `MDE-Production-Workstations`

### MDE-FW-Rules-Servers

Règles spécifiques aux serveurs.

```
Nom : Block-Inbound-SMB-Internet
Direction : Inbound
Action : Block
Protocole : TCP
Ports locaux : 445
Adresses distantes : Internet
Profils : Domaine, Privé, Public
Description : Bloque SMB entrant depuis Internet
```

```
Nom : Block-Inbound-RDP-Public-Servers
Direction : Inbound
Action : Block
Protocole : TCP
Ports locaux : 3389
Profils : Public
Description : Bloque RDP sur Public en cas de bascule de profil involontaire
```

```
Nom : Allow-Inbound-RDP-Admin-Subnet
Direction : Inbound
Action : Allow
Protocole : TCP
Ports locaux : 3389
Adresses distantes : <subnet admin à renseigner>
Profils : Domaine
Description : Autorise RDP depuis le subnet d'administration uniquement
```

```
Nom : Allow-Inbound-WinRM-Admin-Subnet
Direction : Inbound
Action : Allow
Protocole : TCP
Ports locaux : 5985, 5986
Adresses distantes : <subnet admin à renseigner>
Profils : Domaine
Description : Autorise WinRM depuis le subnet d'administration uniquement
```

Assignations : `MDE-Production-Servers`

## Étape 6 - Créer les policies ASR

Quatre policies par catégorie de risque, déployées progressivement.

### MDE-ASR-LowRisk-Block

Règles à risque très faible, activables directement en Block.

`Sécurité des points de terminaison > Réduction de la surface d'attaque > Créer une policy`, plateforme `Windows 10, Windows 11 et Windows Server`, profil `Règles de réduction de la surface d'attaque`.

| Règle | GUID | État |
|---|---|---|
| Block credential stealing from LSASS | 9e6c4e1f-7d60-472f-ba1a-a39ef669e4b2 | Block |
| Block abuse of exploited vulnerable signed drivers | 56a863a9-875e-4185-98a7-b882c64b5ce5 | Block |
| Block persistence through WMI event subscription | e6db77e5-3df2-4cf1-b95a-636979351e5b | Block |
| Block execution of potentially obfuscated scripts | 5beb7efe-fd9a-4556-801d-275e5ffc04cc | Block |
| Block JavaScript or VBScript from launching downloaded executable content | d3e037e1-3eb8-44c8-a917-57927947596d | Block |
| Block executable content from email client and webmail | be9ba2d9-53ea-4cdc-84e5-9b1eeee46550 | Block |
| Block untrusted and unsigned processes that run from USB | b2b3f03d-6a65-4f7b-a9c7-1c7ef74a9ba4 | Block |
| Block executable files from running unless they meet a prevalence, age, or trusted list criterion | 01443614-cd74-433a-b99e-2ecdc07bfc25 | Block |
| Use advanced protection against ransomware | c1db55ab-c21a-4637-bb3f-a12568109d35 | Block |

Assignations : `MDE-CatchAll-Windows`

### MDE-ASR-Office-Audit

Règles Office en Audit pour identification des workflows métier impactés.

| Règle | GUID | État |
|---|---|---|
| Block all Office applications from creating child processes | d4f940ab-401b-4efc-aadc-ad5f3c50688a | Audit |
| Block Office applications from creating executable content | 3b576869-a4ec-4529-8536-b80a7769e899 | Audit |
| Block Office applications from injecting code into other processes | 75668c1f-73b5-4cf0-bb93-3ecf5cb7cc84 | Audit |
| Block Win32 API calls from Office macros | 92e97fa1-2edf-4476-bdd6-9dd0b4dddc7b | Audit |
| Block Adobe Reader from creating child processes | 7674ba52-37eb-4a4f-a9a1-f0f9a1619a2c | Audit |

Assignations : `MDE-Pilot-Workstations` puis `MDE-Production-Workstations` selon le calendrier (voir épisode 8)

### MDE-ASR-Office-Warn

Les mêmes règles que ci-dessus en mode Warn, sauf `Block Win32 API calls from Office macros` qui ne supporte pas Warn (passer en Block direct ou laisser en Audit).

Assignations : `MDE-Production-Workstations` (après validation de la phase Audit)

### MDE-ASR-Office-Block

Les mêmes règles en mode Block, après validation complète.

Assignations : `MDE-Production-Workstations` (en remplacement de Warn)

Sur les serveurs, on déploie uniquement la policy `MDE-ASR-LowRisk-Block`. Les règles Office et navigateur ne sont pas pertinentes sans utilisateur interactif.

## Étape 7 - Matrice d'assignation

Vue d'ensemble des affectations.

| Policy | CatchAll | Pilot WS | Prod WS | Pilot Srv | Prod Srv |
|---|---|---|---|---|---|
| MDE-EDR-Onboarding | X | | | | |
| MDE-AV-CatchAll | X | | | | |
| MDE-AV-Workstations-Production | | | X | | |
| MDE-AV-Servers-Production | | | | | X |
| MDE-AV-Workstations-Pilot | | X | | | |
| MDE-AV-Servers-Pilot | | | | X | |
| MDE-FW-CatchAll | X | | | | |
| MDE-FW-Rules-Workstations | | X | X | | |
| MDE-FW-Rules-Servers | | | | X | X |
| MDE-ASR-LowRisk-Block | X | | | | |
| MDE-ASR-Office-Audit | | X | | | |
| MDE-ASR-Office-Warn (après) | | | X | | |
| MDE-ASR-Office-Block (après) | | | X | | |

La logique de superposition (épisode 4) garantit que chaque appareil reçoit le socle catch-all plus les couches spécifiques à son rôle.

## Étape 8 - Activation au niveau tenant

Quelques paramètres à activer côté portail Microsoft Defender, indépendants des policies Intune.

**Tamper Protection au niveau tenant**

`security.microsoft.com > Paramètres > Points de terminaison > Caractéristiques avancées > Protection contre les altérations`

État : Activé

**Investigation automatisée**

`Paramètres > Points de terminaison > Caractéristiques avancées > Automated Investigation`

État : Activé. Mode initial recommandé : Semi (validation manuelle des remédiations).

**Live Response pour les serveurs**

`Paramètres > Points de terminaison > Caractéristiques avancées > Live Response for Servers`

État : Activé (nécessite MDE P2).

**Allow or block file**

`Paramètres > Points de terminaison > Caractéristiques avancées > Allow or block file`

État : Activé. Permet de bloquer manuellement des fichiers par hash depuis le portail.

## Étape 9 - Plan de déploiement

L'ordre d'activation est important. Voici la séquence recommandée.

**Semaine 1 - Socle**

1. Créer les cinq groupes Entra ID
2. Importer ou créer la policy `MDE-EDR-Onboarding`
3. Importer ou créer la policy `MDE-AV-CatchAll`
4. Importer ou créer la policy `MDE-FW-CatchAll` (postes et serveurs)
5. Activer Tamper Protection au niveau tenant

Validation : les machines remontent dans le portail MDE, Tamper Protection active sur quelques postes témoins.

**Semaine 2 - Production**

1. Importer les policies AV et FW production postes et serveurs
2. Activer Security Management for MDE pour les machines sans Intune
3. Déployer la policy `MDE-ASR-LowRisk-Block` sur le catch-all

Validation : pas de remontée d'incident applicatif sur les premières 48 heures.

**Semaines 3 à 6 - Phase pilote ASR Office**

1. Déployer `MDE-ASR-Office-Audit` sur le groupe pilote postes
2. Analyser hebdomadairement les remontées dans le portail MDE
3. Construire la liste des exclusions justifiées (par règle, par processus)
4. Identifier les workflows métier qui déclenchent les règles

**Semaine 7 - Bascule Warn**

1. Étendre la phase Audit Office au groupe production postes
2. Déployer `MDE-ASR-Office-Warn` sur les pilotes
3. Communication utilisateur préparatoire

**Semaines 8 à 10 - Observation Warn**

1. Suivi des clics utilisateur sur Débloquer
2. Ajustement des exclusions selon les remontées
3. Validation que le volume est acceptable

**Semaine 11 - Bascule Block**

1. Déployer `MDE-ASR-Office-Block` sur production postes
2. Communication finale
3. Surveillance renforcée pendant deux semaines

## Étape 10 - Vérification globale

Sur un poste cible, vérifier l'état complet :

```powershell
# Antivirus et Tamper Protection
Get-MpComputerStatus | Select-Object `
  AMRunningMode, `
  AntivirusEnabled, `
  RealTimeProtectionEnabled, `
  IsTamperProtected, `
  OnboardingState

# Configuration cloud
Get-MpPreference | Select-Object `
  MAPSReporting, `
  CloudBlockLevel, `
  CloudExtendedTimeout, `
  SubmitSamplesConsent

# Règles ASR
Get-MpPreference | Select-Object `
  AttackSurfaceReductionRules_Ids, `
  AttackSurfaceReductionRules_Actions

# Firewall
Get-NetFirewallProfile -PolicyStore ActiveStore | Select-Object `
  Name, Enabled, DefaultInboundAction, AllowLocalPolicyMerge
```

Sur un serveur cible, mêmes commandes plus :

```powershell
# Service MDE
Get-Service -Name Sense | Select-Object Status, StartType
```

Côté portail Intune, vérifier l'état d'application de chaque policy : `Sécurité des points de terminaison > [type de policy] > [nom de policy] > État de l'appareil`. Cibler les statuts `Erreur` et `Conflit` pour diagnostic.

Côté portail Defender, vérifier les remontées des règles ASR : `Reports > Attack surface reduction rules`. Si rien n'apparaît après 48 heures, vérifier le Cloud Block Level (doit être à High ou High Plus pour que les alertes EDR soient générées).

## Récapitulatif de la série MDE Foundations

Onze épisodes pour construire une configuration MDE complète à partir d'un tenant non configuré ou mal configuré.

- **Episode 1** : état des lieux des configurations courantes et feuille de route
- **Episode 2** : licences et onboarding des postes de travail
- **Episode 3** : licences et onboarding des serveurs Windows
- **Episode 4** : stratégie catch-all et logique de superposition des policies
- **Episode 5** : configuration antivirus, protection cloud et exclusions
- **Episode 6** : firewall sur les trois profils réseau
- **Episode 7** : comprendre les règles ASR avant déploiement
- **Episode 8** : déploiement progressif des règles ASR
- **Episode 9** : Tamper Protection et verrouillage de la configuration
- **Episode 10** : exploitation opérationnelle, alertes, incidents, Live Response
- **Episode 11** : template clés en main et plan de déploiement

La configuration posée n'est pas figée. Elle constitue un socle solide qui couvre la majorité des cas et qui doit ensuite être adapté au contexte spécifique de chaque tenant : applications métier, contraintes de conformité, taille du parc, niveau de maturité SOC.

## Note sur l'export du template

Cet article décrit la composition du template MDE Foundations en termes de groupes, policies et paramètres. La publication d'un export IntuneManagement directement importable est prévue ultérieurement, après validation complète en environnement de test.

En attendant, les paramètres documentés dans cet article peuvent être recréés manuellement dans n'importe quel tenant Intune en suivant la séquence proposée. La majeure partie du travail consiste à créer les groupes Entra ID et à reproduire les valeurs des tableaux par policy.

## Conclusion de la série

Cette série a été construite autour d'un constat simple : les configurations MDE sont rarement propres en audit, et il n'existe pas de référence officielle prête à l'emploi qui couvre à la fois postes de travail et serveurs avec une logique cohérente de groupes et de déploiement progressif.

Le template MDE Foundations ne prétend pas être la seule manière de faire. Il représente une approche qui a fait ses preuves en environnement réel, qui s'appuie sur les recommandations Microsoft, et qui reste auditable parce que chaque paramètre est justifié quelque part dans la série.

Si tu déploies tout ou partie de ce template dans ton tenant et que tu identifies des ajustements pertinents, des manques, ou des erreurs, les retours sont les bienvenus. C'est le genre de socle qui s'améliore avec les retours terrain.