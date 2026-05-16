---
title: "MDE Foundations - Episode 10 : investigation et réponse avec MDE"
date: 2026-07-18 08:00:00 +01:00
layout: post
categories: [securite, MDE]
tags:
  - Microsoft Defender for Endpoint
  - EDR
  - Investigation
  - MDE Foundations
  - Live Response
readtime: true
comments: true
sidebar: false
level: Avancé
platform: Microsoft Defender for Endpoint
scope: Postes de travail / Serveurs
cover-img: assets/img/posts/series/mde-foundations/2026/07/mde-foundations-ep10-cover.png
thumbnail-img: assets/img/posts/series/mde-foundations/2026/07/mde-foundations-ep10-thumb.png
series: MDE Foundations
series_order: 10
---

Les neuf épisodes précédents ont posé une configuration MDE complète : antivirus, firewall, ASR, exclusions justifiées, Tamper Protection, verrouillage côté admin. Toute cette configuration produit en permanence de la télémétrie. Si personne ne la regarde, c'est juste du log qui s'accumule. Cet épisode couvre l'exploitation opérationnelle : comment lire les alertes, comment investiguer un incident, et comment répondre.

Cet épisode ne couvre pas tout le métier SOC. Il pose les bases pour qu'un administrateur système qui hérite de MDE sache où regarder, quoi y chercher, et quelles actions sont disponibles depuis le portail.

## Le portail Microsoft Defender

Toutes les opérations de cet épisode passent par `security.microsoft.com`. Ce portail unifie aujourd'hui MDE, Defender for Office 365, Defender for Identity, et Defender for Cloud Apps. Selon les licences de ton tenant, certaines sections sont visibles ou non.

Les sections utiles pour MDE :

- **Incidents et alertes > Incidents** : la vue agrégée, point d'entrée principal
- **Incidents et alertes > Alertes** : les alertes individuelles non corrélées
- **Assets > Devices** : inventaire des appareils et fiche détaillée par machine
- **Investigation et réponse > Hunting > Advanced hunting** : KQL sur la télémétrie
- **Investigation et réponse > Actions et soumissions** : historique des actions automatisées et manuelles
- **Threat analytics** : rapports d'analyse de menaces avec impact sur ton tenant

## Alerte, incident, et corrélation

Distinction importante avant de plonger dans l'opérationnel.

**Une alerte** est une détection unitaire : un événement précis remonté par un capteur (antivirus, EDR, ASR, etc.) qui correspond à une signature ou à un comportement suspect. Exemple : "PowerShell a exécuté un script obfusqué sur DESKTOP-001 à 14h32".

**Un incident** est un regroupement d'alertes corrélées que MDE estime liées à une même chaîne d'attaque. La corrélation est automatique : MDE relie les alertes par utilisateur, par appareil, par séquence temporelle, et par technique observée. Exemple : un incident peut regrouper "tentative de lecture LSASS bloquée" + "PowerShell obfusqué exécuté" + "connexion sortante vers IP suspecte" sur le même poste dans la même heure.

L'incident est le bon point d'entrée pour l'analyse. Plutôt que d'investiguer chaque alerte isolément, l'incident donne le contexte agrégé.

Chaque incident a une **gravité** (Informational, Low, Medium, High) et un **statut** (Active, In Progress, Resolved). La gravité est calculée par MDE à partir des règles de détection déclenchées. Le statut est piloté manuellement par l'analyste qui travaille sur l'incident.

## Premiers réflexes face à un nouvel incident

Quand un incident remonte dans le portail, voici la séquence de questions à poser dans l'ordre.

**Qu'est-ce qui a été détecté ?**

Lire la vue d'ensemble de l'incident. Quelles alertes le composent ? Quelles techniques MITRE ATT&CK sont mentionnées ? L'attaque est-elle bloquée par MDE ou simplement détectée ?

La distinction "bloquée" / "détectée" est critique. Une alerte ASR en mode Block sur LSASS qui a bloqué Mimikatz est une bonne nouvelle. Une alerte EDR qui détecte un dump LSASS réussi avec un autre outil est un incident actif à traiter en priorité.

**Quel est le périmètre ?**

Un seul appareil, ou plusieurs ? Un seul utilisateur, ou plusieurs ? Une attaque ciblée sur un poste isolé n'a pas la même gravité opérationnelle qu'une propagation latérale sur cinq postes en une heure.

**Quelle est l'antériorité ?**

Le premier événement de l'incident date de quand ? Si c'est il y a deux minutes, l'attaque est en cours et la priorité est de contenir. Si c'est il y a trois jours et que rien ne s'est passé depuis, la priorité est différente.

**Qu'est-ce qui a été fait automatiquement ?**

MDE peut avoir déjà pris des actions : isolation de la machine, suppression de fichier, blocage de processus. Lire la section "Actions" de l'incident pour savoir ce qui a été remédié automatiquement avant d'agir manuellement.

## La fiche appareil

La fiche détaillée d'un appareil (`Assets > Devices > [nom]`) est l'endroit où on passe le plus de temps en investigation. Elle agrège :

- **Vue d'ensemble** : informations machine, utilisateur principal, niveau d'exposition aux vulnérabilités, statut de santé du capteur
- **Alertes** : toutes les alertes liées à cet appareil, sur la période sélectionnée
- **Timeline** : flux chronologique de tous les événements remontés, avec filtres par type
- **Vulnérabilités** : CVE détectées sur le logiciel installé
- **Inventaire logiciel** : applications installées, versions, état de patch
- **Lignes de base de sécurité** : configuration de sécurité actuelle vs recommandée
- **Recommandations** : actions de durcissement suggérées

Pour une investigation, la **Timeline** est la vue centrale. Elle permet de remonter le fil des événements autour du moment de la détection : quel processus a démarré quoi, quelle connexion réseau a été établie, quel fichier a été créé ou modifié.

## Advanced hunting et KQL

Le portail propose des vues prédéfinies, mais en investigation poussée, il faut souvent aller au-delà. Advanced hunting expose la télémétrie brute via le langage KQL.

Les tables principales :

- `DeviceProcessEvents` : créations de processus avec ligne de commande, parent, hash
- `DeviceFileEvents` : créations, modifications, suppressions de fichiers
- `DeviceNetworkEvents` : connexions réseau initiées par des processus
- `DeviceRegistryEvents` : modifications de registre
- `DeviceLogonEvents` : authentifications locales et distantes
- `DeviceEvents` : événements de sécurité divers (ASR, exploits, suspicion comportementale)
- `DeviceImageLoadEvents` : chargements de DLL
- `AlertInfo` et `AlertEvidence` : alertes et leurs preuves associées

Quelques requêtes utiles à connaître.

Lister tous les processus PowerShell exécutés sur un appareil avec une ligne de commande longue (suspect : payload encodé) :

```kql
DeviceProcessEvents
| where DeviceName == "DESKTOP-001"
| where FileName in~ ("powershell.exe", "pwsh.exe")
| where strlen(ProcessCommandLine) > 500
| project Timestamp, AccountName, ProcessCommandLine, InitiatingProcessFileName
| order by Timestamp desc
```

Identifier les connexions réseau sortantes vers des destinations rares dans le tenant sur les dernières 24 heures :

```kql
DeviceNetworkEvents
| where Timestamp > ago(24h)
| where RemoteUrl != "" and ActionType == "ConnectionSuccess"
| summarize Devices = dcount(DeviceName), Hits = count() by RemoteUrl
| where Devices == 1 and Hits < 10
| order by Hits desc
```

Lister les créations de comptes locaux sur les serveurs ces 30 derniers jours :

```kql
DeviceProcessEvents
| where Timestamp > ago(30d)
| where DeviceName contains "SRV-"
| where ProcessCommandLine has_any ("net user /add", "New-LocalUser")
| project Timestamp, DeviceName, AccountName, ProcessCommandLine, InitiatingProcessFileName
| order by Timestamp desc
```

Ces requêtes peuvent être sauvegardées dans le portail pour réutilisation, et transformées en règles de détection custom si elles s'avèrent récurrentes.

## Les actions de réponse

Depuis la fiche d'un appareil ou d'une alerte, plusieurs actions de réponse sont disponibles. Elles nécessitent des droits spécifiques dans MDE.

**Isoler l'appareil**

L'appareil est coupé de tout le réseau sauf de la connexion vers MDE. L'utilisateur ne peut plus accéder à Internet, aux ressources internes, aux partages. L'analyste conserve la possibilité de prendre la main à distance via Live Response.

Deux modes d'isolation :

- **Isolation complète** : toutes les connexions sont coupées, y compris les communications avec les services Microsoft 365 standard. À utiliser pour une compromission avérée et grave.
- **Isolation sélective** : Outlook, Teams, Skype Entreprise restent fonctionnels. À utiliser quand on veut isoler sans couper l'utilisateur de la communication avec l'équipe sécurité pour qu'il puisse répondre.

L'isolation est réversible en un clic. Penser à documenter l'action dans l'incident.

**Restreindre l'exécution d'applications**

Mode plus permissif que l'isolation : seuls les exécutables signés par Microsoft peuvent s'exécuter sur la machine. Tout autre processus est bloqué. Utile pour stopper l'exécution d'un malware tout en maintenant le poste utilisable pour de l'investigation locale.

**Démarrer une analyse antivirus**

Force un scan Windows Defender complet sur la machine ciblée. Utile en complément d'une investigation, ne remplace pas l'isolation en cas de compromission active.

**Collecter un package d'enquête**

Génère et télécharge une archive contenant les logs, événements, configurations, et liste de processus de la machine au moment de la collecte. Utile pour analyse forensique offline ou pour escalation vers une équipe spécialisée.

**Live Response**

Session interactive distante avec le poste, type shell. Permet d'exécuter des commandes PowerShell, de récupérer des fichiers depuis la machine, de déposer des outils d'analyse, sans interrompre la session utilisateur. Trace complète des commandes exécutées.

Disponible uniquement avec MDE P2 et nécessite des droits spécifiques. Voir la section dédiée plus bas.

## Live Response en détail

Live Response est l'outil le plus puissant côté investigation. Une session se déclenche depuis la fiche d'un appareil : `Initiate Live Response Session`.

Le portail ouvre un shell distant avec un prompt similaire à PowerShell. Quelques commandes natives utiles :

- `getfile <chemin>` : télécharge un fichier depuis la machine vers le portail (jusqu'à 3 GB)
- `putfile <fichier>` : dépose un fichier depuis la bibliothèque MDE sur la machine
- `run <script>` : exécute un script PowerShell ou bash de la bibliothèque
- `library` : liste les fichiers et scripts disponibles dans la bibliothèque du tenant
- `processes` : liste les processus en cours sur la machine
- `connections` : liste les connexions réseau actives
- `registry` : navigue dans le registre
- `analyze` : déclenche une analyse rapide d'un fichier ou processus

Toutes les commandes Live Response sont loggées : qui a fait quoi, à quel moment, avec quel résultat. C'est une piste d'audit non contournable.

**Bibliothèque de scripts**

La bibliothèque MDE permet de stocker des scripts PowerShell ou des binaires d'analyse utilisables en Live Response. Quelques scripts utiles à y mettre :

- Collecte d'événements Windows formatés
- Récupération de listes de processus avec hash et signatures
- Inventaire des tâches planifiées suspectes
- Récupération du contenu de répertoires sensibles

Ces scripts évitent d'avoir à taper les mêmes commandes manuellement à chaque investigation.

## L'investigation automatisée

MDE inclut une fonctionnalité d'investigation automatisée (Automated Investigation and Response, ou AIR). Quand une alerte se déclenche, MDE peut automatiquement :

- Analyser les fichiers, processus, et services impliqués
- Comparer les hash et indicateurs à la threat intelligence Microsoft
- Décider d'actions de remédiation (suppression de fichier, blocage de processus)
- Soit appliquer ces actions automatiquement, soit les proposer à l'analyste pour validation

Le comportement de l'AIR se configure dans `Paramètres > Points de terminaison > Caractéristiques avancées` :

- **Automated Investigation** : active ou désactive l'investigation automatique
- **Auto-resolve** : laisse MDE résoudre automatiquement les alertes considérées comme bénignes ou faux positifs

Pour les tenants qui débutent en exploitation, je recommande de configurer l'AIR en mode "Semi" : les investigations sont automatisées, mais les actions de remédiation nécessitent une approbation humaine. Ça permet d'apprendre ce que MDE propose comme actions avant de lui laisser la main complète.

## Le rôle des règles de détection custom

Au-delà des règles de détection Microsoft, MDE permet de créer ses propres règles basées sur des requêtes KQL. Ces règles s'exécutent périodiquement (toutes les 24h, 12h, 3h, ou 1h) et génèrent des alertes selon les critères que tu as définis.

Création depuis `Hunting > Custom detections`. Workflow :

1. Tester une requête KQL en advanced hunting jusqu'à obtenir des résultats pertinents
2. Convertir la requête en règle custom avec :
   - Nom et description
   - Fréquence d'exécution
   - Sévérité de l'alerte générée
   - Mapping vers la table des entités impliquées (utilisateur, appareil, fichier)
3. Activer la règle et surveiller les premières détections

Exemples de règles custom utiles dans un tenant :

- Création de compte local administrateur en dehors des comptes attendus
- Modification de membre du groupe Administrators sur un contrôleur de domaine
- Connexion RDP entrante depuis une IP hors plage admin connue
- Exécution de outils d'attaque connus (PsExec, certutil, bitsadmin) hors processus IT standard

## Anti-patterns à éviter

**Ne traiter que les alertes Critical et High**

Les alertes Low et Medium contiennent souvent les signaux faibles d'une attaque en préparation. Une alerte Medium qui se répète sur le même appareil plusieurs jours de suite peut être plus inquiétante qu'une alerte High isolée bloquée immédiatement.

**Marquer Résolu sans investigation**

Devant un volume d'alertes important, la tentation est de marquer rapidement Resolved pour vider la file. Sans une investigation minimale (au moins lire la timeline et vérifier le contexte), c'est de la suppression de signal.

**Désactiver une règle de détection bruyante sans creuser**

Si une règle génère beaucoup de faux positifs, le réflexe est de la désactiver. La bonne approche est de comprendre pourquoi elle remonte autant : workflow métier légitime à exclure, paramètre mal configuré qui élargit la détection, ou réelle activité suspecte sous-jacente.

**Ne pas documenter les investigations**

Une investigation qui a conclu à un faux positif sur tel processus sur tel appareil doit être tracée. Sans documentation, dans six mois, le même cas remontera et un autre analyste refera le même travail.

## Récapitulatif

Tu as maintenant :

- Une vue claire de la différence entre alerte et incident, et de la corrélation automatique
- Une séquence de réflexes face à un nouvel incident (détection, périmètre, antériorité, automatisation)
- Les bases de l'advanced hunting avec quelques requêtes KQL de référence
- Les actions de réponse disponibles (isolation, restriction, Live Response) et leurs cas d'usage
- Le rôle de l'investigation automatisée et son paramétrage recommandé
- La possibilité d'écrire tes propres règles de détection custom à partir de KQL

L'épisode suivant clôt la série : tout ce que tu viens de configurer sur dix épisodes est packagé dans un template prêt à importer via IntuneManagement. Groupes, policies, et structure d'exclusions, importables sur un tenant vide en quelques minutes.