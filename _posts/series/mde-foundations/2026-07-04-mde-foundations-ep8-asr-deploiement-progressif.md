---
title: "MDE Foundations - Episode 8 : ASR, déploiement progressif et gestion des faux positifs"
date: 2026-07-04 08:00:00 +01:00
layout: post
categories: [securite, MDE]
tags:
  - Microsoft Defender for Endpoint
  - ASR
  - Intune
  - MDE Foundations
  - Attack Surface Reduction
readtime: true
comments: true
sidebar: false
level: Avancé
platform: Microsoft Defender for Endpoint
scope: Postes de travail / Serveurs
cover-img: assets/img/posts/2025/07/mde-foundations-ep8-cover.png
thumbnail-img: assets/img/posts/2025/07/mde-foundations-ep8-thumb.png
series: MDE Foundations
series_order: 8
---

L'épisode précédent a posé les bases conceptuelles d'ASR. Tu sais maintenant ce que sont les règles, leurs modes, et le prérequis Cloud Block Level High. Cet épisode passe à la mise en pratique : comment déployer ASR progressivement sur un parc existant, comment structurer les policies par catégorie, et comment gérer les faux positifs sans accumuler des exclusions ingérables.

## Le principe du déploiement par vagues

Plutôt que d'activer toutes les règles ASR en même temps sur l'ensemble du parc, la méthode qui fonctionne s'appuie sur deux dimensions :

- **Par règle** : chaque règle a son rythme de déploiement selon son risque d'impact métier
- **Par groupe d'appareils** : pilote, puis production, sur des fenêtres temporelles décalées

Le croisement de ces deux dimensions donne une matrice de déploiement. Tu n'actives pas les règles "à risque métier élevé" sur le groupe production en même temps que tu actives les règles "à risque faible" sur le groupe pilote.

## La classification des règles par risque d'impact

Les règles ASR n'ont pas le même risque de générer des faux positifs métier. Voici une classification utilisable pour structurer le déploiement.

**Risque très faible - Activation directe en Block**

Ces règles ciblent des comportements quasi exclusivement malveillants. Aucune raison légitime d'écrire un workflow métier qui les déclenche.

- LSASS credential stealing (activée par défaut, à laisser en Block)
- Block abuse of exploited vulnerable signed drivers
- Block persistence through WMI event subscription
- Block execution of potentially obfuscated scripts
- Block JavaScript or VBScript from launching downloaded executable content

**Risque faible - Phase Audit courte (1 semaine) puis Block**

Comportements rarement utilisés en légitime, mais ponctuellement possibles. Une semaine en Audit permet de détecter les cas particuliers.

- Block executable content from email client and webmail
- Block executable files from running unless they meet a prevalence, age, or trusted list criterion
- Block untrusted and unsigned processes that run from USB

**Risque modéré - Phase Audit 2 à 4 semaines puis Warn, puis Block**

Ces règles touchent à des comportements utilisés par certaines applications métier ou par des workflows utilisateurs. Phase d'observation nécessaire.

- Block all Office applications from creating child processes
- Block Office applications from creating executable content
- Block Office applications from injecting code into other processes
- Block Win32 API calls from Office macros (ne supporte pas Warn, donc Audit puis Block direct)
- Block Adobe Reader from creating child processes

**Risque élevé - Évaluation au cas par cas**

Ces règles ont un fort potentiel d'impact métier selon l'environnement. À évaluer en fonction du contexte.

- Block process creations originating from PSExec and WMI commands (impacte les outils d'administration legacy)
- Block Office communication applications from creating child processes (impacte certains plugins Outlook métier)

## La structure des policies ASR

Plutôt qu'une grosse policy ASR unique qui contient toutes les règles, la série recommande **une policy par catégorie de risque**. Cette structure facilite les itérations : tu fais évoluer une catégorie sans toucher aux autres.

| Policy | Cible | Contenu |
|---|---|---|
| MDE-ASR-LowRisk-Block | Catch-all + Production (postes et serveurs) | Règles à risque très faible, directement en Block |
| MDE-ASR-Office-Audit | Pilote (postes uniquement) | Règles Office en Audit |
| MDE-ASR-Office-Warn | Production (postes uniquement) après validation pilote | Règles Office en Warn |
| MDE-ASR-Office-Block | Production (postes uniquement) après validation Warn | Règles Office en Block |
| MDE-ASR-Exclusions | Tous groupes | Exclusions ASR par règle, gérées de manière centralisée |

Les règles ASR sur serveurs sont volontairement plus restreintes. Les règles Office et navigateur n'ont pas de sens sur un serveur sans utilisateur interactif. On y déploie uniquement les règles de la catégorie "Risque très faible" plus la règle LSASS.

## La temporalité du déploiement

Voici un calendrier indicatif pour un parc de plusieurs centaines de postes. Adapte les durées à la taille de ton parc et au volume de remontées observé.

**Semaine 1**

Déploiement de `MDE-ASR-LowRisk-Block` sur le groupe pilote postes et serveurs. Validation que les machines ne remontent pas d'incident applicatif majeur. Surveillance des alertes EDR ASR dans le portail MDE.

**Semaine 2**

Si pas de problème sur pilote, extension de `MDE-ASR-LowRisk-Block` à l'ensemble production postes et serveurs. En parallèle, déploiement de `MDE-ASR-Office-Audit` sur pilote postes uniquement.

**Semaines 3 à 6**

Phase d'observation des règles Office en Audit sur le groupe pilote. Analyse hebdomadaire des événements remontés dans le portail MDE. Identification des processus métier qui déclenchent les règles. Ajustement des exclusions au fur et à mesure.

**Semaine 7**

Bascule des règles Office en Warn sur production postes. Cette phase Warn est volontairement courte : les utilisateurs ont une popup avec bypass, ce qui te permet de capter les derniers cas non détectés en Audit (utilisateurs qui ne se servent pas régulièrement de leurs macros, intégrations rares).

**Semaines 8 à 10**

Observation du nombre de clics utilisateur sur "Débloquer" via les remontées MDE. Si le volume est faible et concentré sur quelques cas identifiés, on ajuste les exclusions. Si le volume est élevé, on retourne en Audit pour creuser.

**Semaine 11**

Bascule des règles Office en Block sur production postes. Communication aux utilisateurs avant déploiement, avec un canal de remontée d'incident dédié pendant les deux premières semaines.

Sur un parc plus petit ou plus homogène, ces durées peuvent être divisées par deux. Sur un parc plus grand ou avec beaucoup d'applications métier hétérogènes, multiplie par deux et n'hésite pas à étendre les phases d'observation.

## Analyser la télémétrie ASR

Toute la stratégie progressive repose sur la capacité à exploiter les remontées MDE pendant les phases Audit et Warn. Trois endroits où regarder.

**Le dashboard ASR du portail Defender**

Accessible via `security.microsoft.com > Reports > Attack surface reduction rules`. Vue d'ensemble par règle et par appareil sur la période sélectionnée. Filtres sur le mode (Audit, Warn, Block), sur les utilisateurs, et sur les processus.

C'est le point de départ pour identifier rapidement quelles règles génèrent le plus de remontées, et sur quels appareils.

**L'advanced hunting**

Pour creuser au-delà des graphiques, la table `DeviceEvents` du langage KQL contient les événements ASR détaillés. Quelques requêtes utiles.

Lister les processus déclencheurs sur une règle donnée pour les 30 derniers jours :

```kql
DeviceEvents
| where Timestamp > ago(30d)
| where ActionType startswith "AsrLsassCredentialTheft"
| summarize Count = count() by InitiatingProcessFileName, InitiatingProcessFolderPath
| order by Count desc
```

Identifier les appareils qui déclenchent le plus la règle "macros Office créent des processus enfants" :

```kql
DeviceEvents
| where Timestamp > ago(30d)
| where ActionType == "AsrOfficeChildProcessAudited" or ActionType == "AsrOfficeChildProcessBlocked"
| summarize Count = count() by DeviceName
| order by Count desc
```

Lister les chemins de processus enfants déclenchés par les macros :

```kql
DeviceEvents
| where Timestamp > ago(30d)
| where ActionType startswith "AsrOfficeChildProcess"
| summarize Count = count() by FolderPath, FileName
| order by Count desc
```

**Les logs locaux du poste**

En cas d'incident utilisateur signalé, l'observateur d'événements du poste contient le détail. Sur le poste concerné :

```powershell
Get-WinEvent -LogName "Microsoft-Windows-Windows Defender/Operational" | `
  Where-Object { $_.Id -in 1121, 1122, 1125, 1126, 1129 } | `
  Select-Object TimeCreated, Id, Message
```

Identifiants utiles :

- `1121` : règle ASR a bloqué (Block)
- `1122` : règle ASR aurait bloqué (Audit)
- `1125` : règle ASR a affiché Warn (utilisateur n'a pas encore choisi)
- `1126` : utilisateur a cliqué Débloquer dans une popup Warn
- `1129` : règle ASR n'a pas pu bloquer pour raison technique

## La gestion des exclusions ASR

Les exclusions sont l'aspect qui se dégrade le plus vite dans la durée. Voici une discipline qui tient sur le long terme.

**Toujours par règle, jamais globales**

Le paramètre `ASR Only Per Rule Exclusions` permet d'exclure un processus pour une règle spécifique. Une exclusion par règle limite la brèche à la règle concernée. Une exclusion globale ouvre une porte sur l'ensemble des règles ASR.

**Toujours par processus si possible**

Plutôt qu'exclure un chemin (`C:\AppliMetier\bin\*`), exclure le processus précis (`C:\AppliMetier\bin\AppliMetier.exe`). L'attaquant qui réussit à déposer un fichier dans le dossier exclu n'est pas couvert par l'exclusion s'il ne s'agit pas du processus précis.

**Documenter chaque exclusion**

Une exclusion sans contexte sera reconduite indéfiniment "par sécurité". Le minimum à tracer :

- Date de création
- Règle concernée et processus exclu
- Demandeur (équipe métier, application)
- Justification (workflow légitime confirmé)
- Date de revue prévue (six mois plus tard)

Cette documentation peut vivre dans un fichier maintenu à côté de l'export IntuneManagement, ou dans un ticket de référence accessible.

**Réviser tous les six mois**

Une exclusion qui dure plus de six mois sans revue est suspecte. À chaque revue, vérifier : l'application est-elle toujours utilisée ? Le workflow est-il toujours nécessaire ? Une version plus récente de l'application a-t-elle corrigé le comportement ?

## Le cas particulier des serveurs

Sur les serveurs, la stratégie ASR est nettement plus simple. Tu ne déploies que les règles à risque très faible plus LSASS. Les règles Office, navigateur et utilisateur n'ont pas de sens dans un contexte serveur sans session interactive.

Les serveurs qui hébergent des applications avec composants Office côté serveur (rare en 2025, mais existant : SharePoint en mode classique, intégrations Excel automatisées) constituent une exception. Pour ces serveurs, traiter les règles Office comme sur un poste utilisateur, avec une phase Audit prolongée.

## Anti-patterns à éviter

**Déployer toutes les règles en même temps**

C'est la garantie de ne pas pouvoir tracer l'origine d'un incident applicatif. Si un poste casse au moment du déploiement, et que tu as activé six règles dans la même policy, tu vas passer plusieurs jours à isoler laquelle est responsable.

**Rester en Audit indéfiniment**

Déjà couvert dans l'épisode 7. Audit n'est pas une configuration cible. Si une règle est en Audit depuis plus de deux mois sans décision de bascule, soit elle est validée et tu passes en Warn ou Block, soit elle pose un problème et il faut documenter pourquoi tu ne la passes pas en Block.

**Activer Block sur des règles sans observer en Audit avant**

L'inverse du précédent. Pour les règles à risque modéré ou élevé, sauter la phase Audit revient à découvrir les impacts métier en production. Sauf indication contraire de Microsoft (règle activée par défaut comme LSASS), respecter la phase Audit.

**Empiler des exclusions sans les justifier**

Une liste d'exclusions ASR qui dépasse 20 entrées sur un environnement courant est généralement un signal de dérive. Soit les règles activées sont trop agressives pour le contexte, soit les exclusions auraient pu être plus étroites, soit certaines sont obsolètes.

**Désactiver une règle pour résoudre un faux positif**

Devant un faux positif persistant, la tentation est de désactiver la règle. C'est rarement la bonne réponse : une exclusion ciblée résout le cas sans perdre la protection sur tous les autres processus. Désactiver une règle doit être une décision documentée, pas un réflexe de troubleshooting.

## Récapitulatif

Tu as maintenant :

- Une classification des règles ASR par risque d'impact métier
- Une structure de policies ASR par catégorie de risque, pour pouvoir itérer indépendamment
- Un calendrier de déploiement progressif sur 11 semaines, adaptable selon la taille du parc
- Les requêtes KQL et les Event ID pour analyser la télémétrie ASR pendant les phases Audit et Warn
- Une discipline d'exclusions par règle, par processus, documentées et révisées tous les six mois

L'épisode suivant traite de Tamper Protection et du verrouillage de la configuration pour empêcher qu'une compromission ou une mauvaise manipulation ne désactive les protections que tu viens de poser.