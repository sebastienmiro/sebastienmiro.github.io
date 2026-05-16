---
title: "MDE Foundations - Episode 7 : Attack Surface Reduction, comprendre les règles"
date: 2026-06-27 08:00:00 +01:00
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
cover-img: assets/img/posts/2025/06/mde-foundations-ep7-cover.png
thumbnail-img: assets/img/posts/2025/06/mde-foundations-ep7-thumb.png
series: MDE Foundations
series_order: 7
---

Attack Surface Reduction est la fonctionnalité MDE la plus puissante pour réduire la surface d'attaque d'un poste Windows, et c'est aussi celle qui est la plus mal déployée. La raison est presque toujours la même : on active des règles en Audit lors d'un projet, on collecte de la télémétrie pendant quelques semaines, le projet s'arrête, et les règles restent en Audit pour toujours. La protection effective est nulle.

Cet épisode pose les bases conceptuelles d'ASR avant tout déploiement : ce que c'est, comment ça fonctionne, et surtout comment lire la documentation Microsoft pour décider quel mode appliquer à quelle règle. L'épisode 8 traitera de la stratégie de déploiement progressif.

## Ce qu'est ASR

ASR est un ensemble de règles préconçues qui bloquent des comportements précis fréquemment utilisés par les attaquants : un document Office qui crée un processus enfant, un script Office qui télécharge du contenu, un exécutable qui lit la mémoire du processus LSASS, etc.

Chaque règle est identifiée par un GUID unique et cible un comportement très spécifique. Tu n'écris pas de règles ASR toi-même : tu choisis parmi celles que Microsoft maintient, et tu décides du mode dans lequel chacune doit fonctionner.

ASR fonctionne au niveau du moteur antivirus Windows Defender. Si Windows Defender est en mode passif (un autre antivirus est actif), ASR ne s'applique pas. C'est un prérequis qui élimine d'emblée les environnements avec un AV tiers actif.

## Les modes d'une règle ASR

Chaque règle peut être dans l'un des cinq états suivants.

**Not Configured** ou **Disabled** : la règle n'est pas évaluée. Pas de blocage, pas de télémétrie. Équivalent à un retour à l'état d'origine du système.

**Audit** : la règle est évaluée mais ne bloque rien. Quand un comportement correspondant est détecté, un événement est enregistré dans le journal Windows Defender et remonte dans MDE. Aucune notification utilisateur, aucune action visible.

**Warn** : la règle bloque le comportement mais affiche à l'utilisateur une popup qui lui permet de débloquer l'action pour les 24 heures suivantes. Disponible sur Windows 10 1809 et plus récent. Sur les versions antérieures, Warn se comporte comme Block.

**Block** : la règle bloque le comportement sans possibilité de contournement par l'utilisateur.

Trois règles ne supportent pas le mode Warn et passent automatiquement en Block si tu le configures : la règle de blocage du vol de credentials LSASS, la règle de blocage des appels API Win32 depuis les macros Office, et la règle de blocage de la persistance via WMI.

## Le prérequis Cloud Block Level High

C'est un point critique souvent ignoré : **les alertes EDR pour les règles ASR ne sont générées que sur les appareils configurés en Cloud Block Level High ou High Plus**. Sur les appareils en Cloud Block Level Default ou inférieur, les règles ASR fonctionnent (elles bloquent ou auditent), mais aucune alerte EDR n'est levée.

De la même manière, les notifications toast (popup utilisateur) en mode Block ne sont affichées que sur les appareils en Cloud Block Level High.

Concrètement : si tu déploies des règles ASR sur un parc dont le Cloud Block Level est par défaut, tu protèges les machines, mais tu ne verras rien dans le portail MDE. Aucune alerte, aucune visibilité. Tu auras juste un événement dans le journal local du poste, ce qui n'est pas exploitable opérationnellement.

C'est pour cette raison que l'épisode 5 a posé Cloud Block Level à High dans la policy antivirus. Sans ça, tout le travail sur ASR est invisible côté SOC.

## La matrice règle / état / alerte

Microsoft maintient une matrice qui indique, pour chaque règle ASR, dans quels états une alerte EDR est générée. Cette matrice est disponible dans la documentation officielle : [Attack surface reduction rules reference](https://learn.microsoft.com/fr-fr/defender-endpoint/attack-surface-reduction-rules-reference).

Le comportement n'est pas uniforme. Certaines règles génèrent des alertes dans tous les modes actifs (Audit, Warn, Block), d'autres uniquement en Warn et Block, d'autres seulement en Block. Cette nuance est importante quand tu construis ta stratégie de déploiement :

- Si une règle génère des alertes en Audit, tu peux la laisser un certain temps en Audit pour analyser la télémétrie avant de basculer en Block
- Si une règle ne génère des alertes qu'en Block, le mode Audit ne te sert qu'à éviter le blocage en attendant : tu n'auras pas de remontée dans le SOC tant que tu n'es pas passé en Block

Avant chaque déploiement d'une règle, consulte sa fiche dans la référence Microsoft pour savoir dans quels modes elle remonte de la télémétrie EDR.

## Les règles à connaître par catégorie

Il existe une vingtaine de règles ASR. Plutôt que de les énumérer toutes, voici un regroupement par catégorie avec les règles à prioriser dans un déploiement initial.

### Catégorie : protection des credentials

**Block credential stealing from the Windows local security authority subsystem (LSASS)**

GUID : `9e6c4e1f-7d60-472f-ba1a-a39ef669e4b2`

Cette règle bloque les processus qui tentent de lire la mémoire du processus LSASS, comportement caractéristique de Mimikatz et de la quasi-totalité des outils de credential dumping.

C'est la règle ASR la plus importante. Microsoft l'a configurée **en mode Block par défaut** depuis 2022. Elle ne supporte pas le mode Warn (un Warn configuré passe automatiquement en Block). Microsoft a intégré au moteur de la règle un filtrage interne pour réduire les faux positifs sur les processus Windows légitimes.

La recommandation pratique : active-la directement en Block. Pas de phase Audit prolongée nécessaire. Le filtrage Microsoft fait le travail. Surveille tes alertes pendant quelques jours, ajoute des exclusions ciblées si tu identifies des processus métier légitimes qui sont bloqués.

Si tu as déjà activé la **LSA Protection** au niveau de Windows (via le registre ou via Credential Guard), la règle ASR est automatiquement classée "Not Applicable" dans le portail MDE. La protection est équivalente, mais elle est portée par Windows lui-même plutôt que par MDE.

### Catégorie : macros et exécution Office

**Block all Office applications from creating child processes**

GUID : `d4f940ab-401b-4efc-aadc-ad5f3c50688a`

Bloque les applications Office (Word, Excel, PowerPoint, Outlook, OneNote) quand elles tentent de lancer un processus enfant. C'est le vecteur historique des macros malveillantes : la macro lance powershell.exe ou cmd.exe pour exécuter le payload.

Cette règle a un impact métier réel. Certains workflows légitimes utilisent des macros qui lancent des processus (intégrations métier, automatisations Excel anciennes). Phase Audit recommandée pendant 2 à 4 semaines pour identifier les workflows légitimes avant de passer en Block.

**Block Office applications from injecting code into other processes**

GUID : `75668c1f-73b5-4cf0-bb93-3ecf5cb7cc84`

**Block Office applications from creating executable content**

GUID : `3b576869-a4ec-4529-8536-b80a7769e899`

**Block Win32 API calls from Office macros**

GUID : `92e97fa1-2edf-4476-bdd6-9dd0b4dddc7b`

Ces trois règles complètent la précédente. La première bloque l'injection de code Office dans d'autres processus, la deuxième bloque la création de fichiers exécutables par Office, la troisième bloque les appels Win32 API directs depuis les macros (ne supporte pas Warn).

### Catégorie : scripts et navigation

**Block JavaScript or VBScript from launching downloaded executable content**

GUID : `d3e037e1-3eb8-44c8-a917-57927947596d`

**Block execution of potentially obfuscated scripts**

GUID : `5beb7efe-fd9a-4556-801d-275e5ffc04cc`

**Block executable content from email client and webmail**

GUID : `be9ba2d9-53ea-4cdc-84e5-9b1eeee46550`

Ces règles ciblent les chaînes d'attaque qui passent par un script de navigateur, un script obfusqué, ou un exécutable reçu par email. Elles ont peu d'impact sur les usages métier classiques. Déploiement direct en Block envisageable après une phase Audit courte (1 semaine).

### Catégorie : exploits et persistence

**Block abuse of exploited vulnerable signed drivers**

GUID : `56a863a9-875e-4185-98a7-b882c64b5ce5`

Bloque l'exploitation des drivers signés mais vulnérables (BYOVD, Bring Your Own Vulnerable Driver). Technique de plus en plus utilisée par les ransomwares pour désactiver l'EDR avant chiffrement.

**Block persistence through WMI event subscription**

GUID : `e6db77e5-3df2-4cf1-b95a-636979351e5b`

Bloque la persistance via abonnements d'événements WMI. Technique classique des malwares avancés. Ne supporte pas Warn ni Audit (mode Audit n'est pas disponible pour cette règle).

**Use advanced protection against ransomware**

GUID : `c1db55ab-c21a-4637-bb3f-a12568109d35`

Active la protection avancée contre les ransomwares au niveau du moteur antivirus. Pas une règle ASR au sens strict mais configurée dans la même policy. Recommandée en mode Block.

### Catégorie : périphériques USB

**Block untrusted and unsigned processes that run from USB**

GUID : `b2b3f03d-6a65-4f7b-a9c7-1c7ef74a9ba4`

Bloque l'exécution de binaires non signés depuis des supports USB. Recommandée dans les environnements où l'usage USB est limité ou tracé. Plus invasive sur les environnements industriels avec usage USB courant.

## Les exclusions ASR

Comme pour l'antivirus, des exclusions peuvent être ajoutées aux règles ASR. Deux types d'exclusions :

- **Exclusion par chemin de fichier ou de dossier** : le contenu spécifié n'est pas évalué par ASR
- **Exclusion par règle spécifique** : un processus est exclu pour une règle donnée uniquement, et pas pour les autres

L'exclusion par règle spécifique (paramètre `ASR Only Per Rule Exclusions`) est très préférable. Une exclusion globale s'applique à toutes les règles ASR. Une exclusion par règle limite la portée de l'exception à ce qui est strictement nécessaire.

Les exclusions ASR suivent la même règle d'or que les exclusions antivirus : chaque exclusion doit être justifiée, tracée, et revue. Pas d'exclusions héritées d'un audit qui datent d'il y a deux ans.

## La stratégie de déploiement en trois étapes

L'épisode 8 développera la stratégie de déploiement. À ce stade, voici les trois étapes à connaître :

1. **Phase Audit** sur les règles qui supportent Audit et qui ont un risque d'impact métier (macros Office, processus enfants, scripts). Durée : 2 à 4 semaines. Analyse de la télémétrie pour identifier les workflows légitimes à exclure.

2. **Activation directe en Block** pour les règles à faible risque d'impact (LSASS, scripts obfusqués, drivers vulnérables, WMI). Microsoft a déjà fait le travail de filtrage pour ces règles.

3. **Mode Warn** comme palier intermédiaire entre Audit et Block sur les règles qui le supportent, pour les utilisateurs avertis et les groupes pilotes.

Le piège classique est de tout mettre en Audit "par sécurité" et de ne jamais sortir de cette phase. Audit n'est pas une configuration cible. Audit est une étape de validation, point.

## Vérification après déploiement

Sur un poste cible, lister les règles ASR configurées et leur état :

```powershell
Get-MpPreference | Select-Object -Property `
  AttackSurfaceReductionRules_Ids, `
  AttackSurfaceReductionRules_Actions, `
  AttackSurfaceReductionOnlyExclusions
```

Les valeurs de `AttackSurfaceReductionRules_Actions` correspondent à :

- `0` : Not Configured / Disabled
- `1` : Block
- `2` : Audit
- `6` : Warn

Croiser avec les GUID dans `AttackSurfaceReductionRules_Ids` pour vérifier que chaque règle est dans l'état attendu.

Côté portail MDE, les remontées ASR sont visibles dans **Reports > Attack surface reduction rules**. Cette vue permet de filtrer par règle, par appareil, et par état (Audit ou Block), et de visualiser les détections sur la période choisie.

## Récapitulatif

Tu as maintenant :

- Une compréhension des cinq états possibles d'une règle ASR
- La connaissance du prérequis Cloud Block Level High pour bénéficier des alertes EDR sur ASR
- Une vision par catégorie des règles principales à déployer
- Le cas particulier de la règle LSASS, activée par défaut et à laisser en Block sans phase Audit prolongée
- La règle d'or des exclusions : par règle plutôt que globale, et toujours justifiées

L'épisode suivant attaque la mise en pratique : stratégie de déploiement progressif par vagues, gestion des faux positifs, et structure de policies par catégorie de règles.