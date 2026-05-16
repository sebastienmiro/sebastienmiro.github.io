---
title: "MDE Foundations - Episode 5 : configurer Windows Defender correctement"
date: 2026-06-13 08:00:00 +01:00
layout: post
categories: [securite, MDE]
tags:
  - Microsoft Defender for Endpoint
  - Windows Defender
  - Intune
  - MDE Foundations
  - Antivirus
readtime: true
comments: true
sidebar: false
level: Intermédiaire
platform: Microsoft Defender for Endpoint
scope: Postes de travail / Serveurs
cover-img: assets/img/posts/2025/06/mde-foundations-ep5-cover.png
thumbnail-img: assets/img/posts/2025/06/mde-foundations-ep5-thumb.png
series: MDE Foundations
series_order: 5
---

L'antivirus est la brique la plus visible de MDE, et c'est souvent celle qui est le moins bien configurée. Pas parce que les paramètres sont compliqués, mais parce qu'on hérite de configurations issues d'anciens antivirus, parce que les exclusions ne sont jamais réévaluées, et parce que la protection cloud est laissée sur ses valeurs par défaut alors qu'elle fait l'essentiel du travail moderne.

Cet épisode pose une configuration antivirus complète, postes de travail et serveurs, avec une logique d'exclusions maîtrisée.

## Ce que fait Windows Defender aujourd'hui

Windows Defender Antivirus dans MDE ne se résume plus à la détection par signatures. Il combine plusieurs moteurs qui fonctionnent en parallèle :

- **Détection par signatures** : la base historique, mise à jour plusieurs fois par jour
- **Détection heuristique et comportementale** : analyse des comportements suspects au runtime
- **Protection cloud** (Microsoft Advanced Protection Service, ou MAPS) : consultation en temps réel de la télémétrie Microsoft pour évaluer des fichiers inconnus en quelques centaines de millisecondes
- **Machine learning local et cloud** : modèles entraînés sur la télémétrie globale pour détecter des variantes non signées
- **Block at First Sight** : blocage de fichiers nouvellement vus, basé sur la décision cloud avant même que la signature soit publiée

La protection cloud n'est pas une option de confort. Sans elle, Windows Defender perd la majorité de ses capacités modernes de détection. Désactiver la protection cloud, c'est revenir à un antivirus de 2010.

## Le mode actif et le mode passif

Avant de configurer quoi que ce soit, il faut comprendre dans quel mode Windows Defender tourne sur tes machines.

**Mode actif** : Windows Defender est l'antivirus principal. Il scanne en temps réel, met à jour ses signatures, applique les remédiations.

**Mode passif** : un autre antivirus est installé et déclaré comme antivirus principal. Windows Defender reste présent mais ne scanne plus en temps réel. Il continue à remonter de la télémétrie pour l'EDR si MDE P2 est activé, mais il ne bloque rien.

**Mode désactivé** : Windows Defender est complètement désactivé, généralement via une GPO ou un script. Cas problématique : la machine n'a aucune protection antivirus Microsoft, et MDE ne peut pas appliquer ses policies.

Sur les postes de travail, Windows Defender doit être en mode actif sauf cas très spécifique. Sur les serveurs, c'est plus nuancé : si tu as un antivirus tiers sur certains serveurs métier (par exemple un AV embarqué dans une solution applicative), Windows Defender peut rester en mode passif sur ces serveurs. Sur tous les autres serveurs, mode actif.

Vérifier le mode depuis PowerShell :

```powershell
Get-MpComputerStatus | Select-Object AMRunningMode
```

Les valeurs possibles : `Normal` (actif), `Passive`, `EDR Block`, `SxS Passive Mode`.

## Les paramètres de protection cloud

Trois paramètres pilotent la protection cloud. C'est la première chose à configurer correctement.

**Allow Cloud Protection** : autorise la machine à consulter le service cloud Microsoft. Valeur : `Allowed`. Sans ça, rien ne fonctionne en cloud.

**Cloud Block Level** : niveau d'agressivité du blocage cloud. Valeurs :

- `Not Configured` ou `Default` : équilibré, faible taux de faux positifs
- `High` : recommandé. Bloque plus agressivement, sur la base de réputation cloud
- `High Plus` : ajoute des mesures de protection supplémentaires, dont des scans plus longs
- `Zero Tolerance` : bloque tout fichier inconnu, taux de faux positifs élevé, non recommandé en production

Pour cette série, on utilise `High` sur le catch-all et la production, `High Plus` sur le groupe pilote pour identifier les éventuels faux positifs avant rollout.

**Cloud Extended Timeout** : temps maximum pendant lequel Windows Defender attend une réponse du cloud avant de prendre sa décision localement. Valeur par défaut : 0 seconde (timeout standard de 10 secondes). Valeur recommandée : `50` secondes, ce qui permet aux fichiers d'être pleinement analysés dans le cloud avant exécution.

**Submit Samples Consent** : autorise l'envoi d'échantillons à Microsoft pour analyse. Valeurs :

- `Send safe samples automatically` : recommandé. Envoie automatiquement les fichiers qui ne contiennent pas de données utilisateur (binaires, scripts)
- `Send all samples automatically` : envoie aussi les fichiers qui peuvent contenir des données utilisateur. À utiliser uniquement si tu n'as pas de contraintes RGPD ou conformité spécifiques
- `Always prompt` : demande à l'utilisateur. Inutile dans un contexte managé
- `Never send` : casse une partie de la chaîne cloud. À éviter sauf contrainte forte

Pour la majorité des tenants français, `Send safe samples automatically` est le bon compromis.

## La protection temps réel

Quelques paramètres à vérifier explicitement, même s'ils sont actifs par défaut sur les installations standard.

| Paramètre | Valeur | Commentaire |
|---|---|---|
| Allow Realtime Monitoring | Allowed | Protection temps réel active |
| Allow Behavior Monitoring | Allowed | Détection comportementale active |
| Allow IOAV Protection | Allowed | Scan des téléchargements et pièces jointes |
| Allow Script Scanning | Allowed | Scan des scripts (PowerShell, JScript, VBScript) |
| Allow On Access Protection | Allowed | Scan à l'accès aux fichiers |
| Disable Catchup Quick Scan | Disabled | Lance un scan rapide si plusieurs scans planifiés ont été manqués |
| Disable Catchup Full Scan | Disabled | Idem pour le scan complet |

Sur les serveurs avec une charge IO intense (bases de données, fichiers), tu peux ajuster le comportement des scans pour ne pas impacter les performances, mais sans jamais désactiver la protection temps réel.

## La gestion des exclusions

C'est le point qui mérite le plus d'attention. Les exclusions antivirus sont la première porte d'entrée d'un attaquant qui a déjà un pied dans le système : une exclusion sur `C:\Temp\` permet d'y déposer n'importe quel binaire et de l'exécuter sans qu'il soit scanné.

### Les types d'exclusions

Windows Defender propose plusieurs types d'exclusions :

- **Chemin** : un dossier ou un fichier spécifique
- **Extension** : tous les fichiers d'une extension donnée
- **Processus** : les fichiers ouverts par un processus spécifique ne sont pas scannés

Les exclusions sont héritées et fusionnées si plusieurs policies définissent des exclusions. C'est pourquoi le catch-all ne doit pas en contenir : les exclusions doivent être justifiées et tracées.

### Les exclusions à éviter absolument

Voici des exclusions vues régulièrement en audit et qui sont presque toujours problématiques :

- `C:\Program Files\*` : trop large, expose tous les binaires d'application
- `C:\Windows\Temp\*` : dossier d'écriture exécutable accessible à de nombreux processus
- `C:\Users\*\AppData\Local\Temp\*` : cible classique des stagers et droppers
- Exclusions sur des extensions génériques (`.exe`, `.dll`, `.ps1`)
- Exclusions sur des partages réseau entiers
- Exclusions héritées d'un ancien antivirus sans réévaluation

Si tu trouves ce type d'exclusion dans un tenant audité, c'est presque toujours à supprimer.

### Les exclusions légitimes

Microsoft publie des listes d'exclusions recommandées pour des rôles serveurs spécifiques : Exchange, SQL Server, Hyper-V, contrôleurs de domaine, IIS, SCCM. Ces listes sont documentées et à jour : [Liste d'exclusions automatiques pour Windows Server](https://learn.microsoft.com/fr-fr/defender-endpoint/configure-server-exclusions-microsoft-defender-antivirus).

Bonne nouvelle : sur Windows Server 2016 et plus récent, Windows Defender applique automatiquement les exclusions liées aux rôles serveurs installés. Tu n'as donc pas besoin de pousser explicitement la liste des exclusions Exchange si le rôle Exchange est détecté. Cette fonctionnalité s'appelle **Automatic Exclusions** et est activée par défaut.

Tu peux la désactiver via le paramètre `Disable Auto Exclusions = Enabled` si tu préfères gérer toi-même les exclusions de manière explicite et tracée. Pour des serveurs critiques en environnement régulé, c'est un choix défendable : tu sais exactement ce qui est exclu, ça apparaît dans tes policies, et tu peux l'auditer.

### La règle pratique

Toute exclusion doit avoir :

1. Une justification documentée (ticket, demande applicative, recommandation Microsoft)
2. Une revue tous les six mois pour vérifier qu'elle est toujours nécessaire
3. Un périmètre le plus étroit possible (chemin précis plutôt qu'un dossier parent)
4. Un usage du type **Processus** plutôt que **Chemin** quand c'est possible (l'exclusion par processus est plus restrictive)

## La structure des policies pour cette série

À ce stade de la série, tu vas avoir plusieurs policies Antivirus qui se superposent :

| Policy | Cible | Contenu |
|---|---|---|
| MDE-AV-CatchAll | Groupe catch-all Windows | Protection cloud High, Tamper ON, pas d'exclusions |
| MDE-AV-Workstations-Production | Production postes | Comme catch-all + ajustements scans + exclusions justifiées spécifiques aux postes |
| MDE-AV-Servers-Production | Production serveurs | Comme catch-all + exclusions justifiées + Cloud Extended Timeout 50s |
| MDE-AV-Workstations-Pilot | Pilote postes | Comme production + Cloud Block Level High Plus |
| MDE-AV-Servers-Pilot | Pilote serveurs | Comme production serveurs + Cloud Block Level High Plus |

Cette structure peut paraître redondante. Elle est volontairement redondante : chaque policy est explicite sur ce qu'elle pose, sans dépendance implicite à la fusion. Si tu veux retirer une couche, tu sais exactement ce que ça enlève.

## Vérification après déploiement

Après application, sur un poste cible :

```powershell
Get-MpPreference | Select-Object `
  DisableRealtimeMonitoring, `
  MAPSReporting, `
  CloudBlockLevel, `
  CloudExtendedTimeout, `
  SubmitSamplesConsent, `
  ExclusionPath, `
  ExclusionExtension, `
  ExclusionProcess
```

Tu dois voir :

- `DisableRealtimeMonitoring : False`
- `MAPSReporting : Advanced` (équivalent à Allow Cloud Protection)
- `CloudBlockLevel : 4` (correspond à High)
- `CloudExtendedTimeout : 50`
- `SubmitSamplesConsent : 1` (Send safe samples automatically)

Les listes d'exclusions doivent correspondre exactement à ce que tu as poussé via Intune. Si tu vois des entrées inconnues, trace l'origine : exclusion locale héritée, GPO ancienne, ou autre policy Intune obsolète.

## Récapitulatif

Tu as maintenant :

- Une compréhension des moteurs de Windows Defender modernes et du rôle central de la protection cloud
- Une distinction claire entre les paramètres globaux (toujours actifs) et les exclusions (à justifier)
- Une structure de policies en couches : catch-all en socle, production puis pilote au-dessus
- Une méthode pour traquer les exclusions héritées qui ne sont plus justifiées

L'épisode suivant traite du firewall Windows : profils réseau, règles de base et logique d'application.