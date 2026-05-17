---
title: "MDE Foundations - Episode 6 : firewall Windows, profils et règles de base"
date: 2026-06-20 08:00:00 +01:00
layout: post
categories: [securite, MDE]
tags:
  - Microsoft Defender for Endpoint
  - Windows Firewall
  - Intune
  - MDE Foundations
  - Firewall
readtime: true
comments: true
sidebar: false
level: Intermédiaire
platform: Microsoft Defender for Endpoint
scope: Postes de travail / Serveurs
cover-img: assets/img/posts/series/mde-foundations/2026/06/mde-foundations-ep6-cover.png
thumbnail-img: assets/img/posts/series/mde-foundations/2026/06/mde-foundations-ep6-thumb.png
series: MDE Foundations
series_order: 6
---

Le firewall Windows est intégré à Windows depuis quinze ans. Il est mature, performant, et géré centralement via Intune dans le cadre de MDE. Pourtant, en audit, c'est la brique de configuration la moins maîtrisée après les exclusions antivirus. Soit il est désactivé sur le profil Domaine "parce que c'est un environnement de confiance", soit il est laissé sur ses valeurs par défaut sans cohérence d'ensemble, soit il est rempli de règles obsolètes qui datent de logiciels désinstallés depuis longtemps.

Cet épisode pose une configuration firewall structurée, postes de travail et serveurs. La couverture n'est pas identique pour les deux : côté postes, on déploie des règles spécifiques ; côté serveurs, on s'en tient à l'activation globale du firewall sans règles applicatives. La raison est simple : les règles firewall serveur dépendent du rôle applicatif, du contexte d'administration et de la topologie réseau. Une règle générique mal calibrée peut couper un flux métier vital. Le sujet des règles serveur relève d'un travail d'analyse cas par cas, hors périmètre de cette série Foundations.

## Les trois profils réseau

Windows Firewall applique des règles différentes selon le profil réseau actif sur la machine. C'est un point souvent mal compris : ce n'est pas un seul firewall avec une configuration, c'est trois configurations distinctes selon le contexte.

**Profil Domaine**

Actif quand la machine détecte qu'elle est connectée au domaine Active Directory auquel elle est jointe. Concrètement, la machine arrive à contacter un contrôleur de domaine sur le réseau.

**Profil Privé**

Actif quand l'utilisateur a déclaré le réseau comme "privé" (réseau domestique, télétravail). Aucune validation technique : c'est une déclaration utilisateur.

**Profil Public**

Actif quand l'utilisateur a déclaré le réseau comme "public" (café, aéroport, hôtel). C'est aussi le profil par défaut quand aucun choix n'a été fait.

Sur un poste de travail nomade, ces trois profils peuvent changer plusieurs fois par jour selon les déplacements. Sur un serveur, le profil reste généralement stable sur Domaine.

![Windows Firewall - Les profils](/assets/img/posts/series/mde-foundations/2026/06/mde-foundations-ep6-figure1.png)

## Le piège du profil Domaine désactivé

C'est la configuration la plus fréquente en audit, et la plus problématique : le firewall est activé sur Privé et Public, mais désactivé sur Domaine. La justification est toujours la même : "c'est un environnement de confiance, on n'a pas besoin du firewall en interne".

Cette logique est dépassée pour deux raisons.

La première, c'est la notion de Zero Trust. Le réseau interne n'est pas plus sûr que le réseau externe. Une compromission qui démarre sur un poste utilisateur se propage latéralement, et le firewall local est l'un des rares contrôles qui peut ralentir cette propagation.

La deuxième, c'est que les ransomwares modernes scannent activement les ports SMB, RDP, et WinRM des machines voisines après l'infection initiale. Un firewall actif sur Domaine, même avec une politique permissive, bloque par défaut les connexions entrantes non autorisées et complique le mouvement latéral.

Pour cette série, le firewall est activé sur les trois profils, sans exception.

## L'architecture des règles

Le firewall Windows fonctionne selon une logique simple :

- **Entrant** : par défaut, tout est bloqué. Tu ouvres explicitement ce que tu veux autoriser.
- **Sortant** : par défaut, tout est autorisé. Tu bloques explicitement ce que tu veux interdire.

Cette dissymétrie est volontaire. Bloquer tout en sortant casserait la majorité des applications sans bénéfice de sécurité significatif sur un poste de travail. Bloquer tout en entrant est en revanche la posture standard.

```mermaid
flowchart LR
    A[Trafic réseau] --> B{Direction ?}
    B -->|Entrant| C[Posture par défaut<br/>BLOCK]
    B -->|Sortant| D[Posture par défaut<br/>ALLOW]

    C --> E[Liste blanche<br/>Ouvertures explicites]
    D --> F[Liste noire<br/>Blocages explicites]

    E --> G[Exemples<br/>RDP depuis subnet admin<br/>ICMP sur Domaine]
    F --> H[Exemples<br/>SMB vers Internet<br/>Telnet, FTP, TFTP]

    style C fill:#ffd4d4
    style D fill:#d4f4d4
```
Les règles s'évaluent dans l'ordre suivant :

1. Règles de sécurité de connexion (IPsec)
2. Règles de blocage explicite
3. Règles d'autorisation explicite
4. Comportement par défaut du profil

Une règle de blocage explicite gagne toujours contre une règle d'autorisation. C'est utile pour poser des interdictions strictes qui ne peuvent pas être contournées par d'autres règles.

## Configurer le firewall via Intune

Dans Intune, la configuration firewall se fait depuis **Sécurité des points de terminaison > Pare-feu**.

Tu vas créer deux types de policies distinctes :

- Une policy de **configuration globale** qui définit l'état du firewall par profil (activé, comportement par défaut)
- Une ou plusieurs policies de **règles** qui définissent les autorisations et blocages spécifiques

Cette séparation est importante. La policy de configuration globale est stable, elle change rarement. Les policies de règles évoluent plus souvent au gré des besoins applicatifs. Les gérer séparément évite d'avoir à modifier la configuration globale à chaque ajustement de règle.

Avec le modèle d’exclusivité appliqué à cette série d'aticles, cette séparation permet aussi de réutiliser la même configuration globale (firewall activé sur les trois profils) à la fois sur le catch-all et sur les policies spécifiques. Les règles, elles, sont déclinées par périmètre et par étape de déploiement.

### Policy de configuration globale

Plateforme : **Windows 10, Windows 11 et Windows Server**. Profil : **Pare-feu Microsoft Defender**.

Paramètres à configurer pour chacun des trois profils (Domaine, Privé, Public) :

| Paramètre | Valeur |
|---|---|
| Enable Firewall | Enabled (sur les trois profils) |
| Default Inbound Action | Block |
| Default Outbound Action | Allow |
| Disable Unicast Responses To Multicast Broadcast Traffic | Disabled |
| Disable Inbound Notifications | Disabled (pour postes) / Enabled (pour serveurs) |
| Disable Stealth Mode | Disabled |
| Disable Stealth Mode IPsec Secured Packet Exemption | Disabled |
| Allow Local Policy Merge | Disabled |
| Allow Local IPsec Policy Merge | Disabled |

Deux paramètres méritent une explication.

**Allow Local Policy Merge** à `Disabled` signifie que les règles définies localement (par un utilisateur admin ou par un installeur de logiciel) sont ignorées. Seules les règles poussées par Intune s'appliquent. C'est une configuration stricte, à valider avec les équipes applicatives avant déploiement.

**Disable Inbound Notifications** à `Enabled` sur serveurs supprime la popup qui apparaît quand une application tente d'écouter un port pour la première fois. Sur un serveur sans utilisateur interactif, cette popup ne sert à rien. Sur un poste de travail, elle peut être utile pour identifier des comportements anormaux d'application.

### Policy de règles

Plateforme : **Windows 10, Windows 11 et Windows Server**. Profil : **Règles de pare-feu Microsoft Defender**.

Chaque règle se compose de plusieurs paramètres :

- **Nom** : descriptif (par exemple `Allow-RDP-Inbound-From-AdminSubnet`)
- **Direction** : Inbound ou Outbound
- **Action** : Allow ou Block
- **Profils ciblés** : Domaine, Privé, Public (un ou plusieurs)
- **Application** : chemin d'un exécutable ou nom de service
- **Protocole** : TCP, UDP, ICMP
- **Ports locaux et distants** : valeurs ou plages
- **Adresses IP locales et distantes** : valeurs, plages, ou groupes prédéfinis (LocalSubnet, Internet, DNS)

Une règle bien construite est aussi étroite que possible. Plutôt qu'un `Allow TCP 3389 From Any`, on écrit `Allow TCP 3389 From 10.20.30.0/24 Sur profil Domaine uniquement`.

## Un socle de règles de base pour postes de travail

Pour démarrer, voici un ensemble de règles minimales pour les postes de travail. Ces règles s'ajoutent au comportement par défaut, elles ne le remplacent pas.

**Bloquer SMB sortant vers Internet**

Les ransomwares utilisent SMB pour les mouvements latéraux. Aucune raison légitime pour un poste utilisateur de faire du SMB sortant vers Internet.

```
Direction : Outbound
Action : Block
Protocole : TCP
Ports distants : 445
Adresses distantes : Internet (groupe prédéfini)
Profils : Domaine, Privé, Public
```

**Bloquer Telnet, FTP, et autres protocoles obsolètes en sortant**

```
Direction : Outbound
Action : Block
Protocole : TCP
Ports distants : 21, 23, 69
Profils : Domaine, Privé, Public
```

**Bloquer RDP entrant sur profil Public**

Aucune raison qu'un poste utilisateur accepte du RDP entrant depuis un café ou un aéroport.

```
Direction : Inbound
Action : Block
Protocole : TCP
Ports locaux : 3389
Profils : Public
```

**Autoriser ICMPv4 Echo Request entrant sur Domaine**

Utile pour les outils de supervision et de troubleshooting.

```
Direction : Inbound
Action : Allow
Protocole : ICMPv4
Type ICMP : 8 (Echo Request)
Profils : Domaine
```

## Côté serveurs : activation seule, pas de règles

Sur les serveurs, on s'arrête à l'activation globale du firewall. Trois raisons pour cette prudence.

**Les flux entrants sont vitaux et variables**

Un serveur héberge des applications dont les ports d'écoute dépendent du rôle : IIS sur 443, SQL Server sur 1433, Exchange sur SMTP/IMAP/HTTPS, contrôleur de domaine sur une vingtaine de ports différents, application métier sur un port custom. Une règle entrante trop restrictive coupe un flux applicatif. Une règle entrante "bien intentionnée" peut casser la production.

**L'administration distante repose sur des conventions locales**

Les règles d'autorisation RDP, WinRM ou SSH depuis un subnet admin présupposent qu'un subnet admin existe et qu'il est bien défini. Dans beaucoup d'environnements, l'administration passe par un bastion, par un VPN multi-segments, par un outil tiers. Une règle générique "Allow RDP from 10.0.0.0/24" ne reflète aucune réalité d'environnement.

**Le risque "admin qui désactive tout" est réel**

En audit, on rencontre régulièrement des serveurs avec le firewall complètement désactivé sur les trois profils, parce que "ça posait problème pour une application". Pousser des règles génériques mal calibrées via Intune est le meilleur moyen de provoquer ce comportement à grande échelle.

L'objectif de cette série est donc minimal mais essentiel pour les serveurs : **garantir que le firewall est activé sur les trois profils**, et qu'aucune règle locale obsolète ne s'applique. C'est déjà un gain considérable par rapport à la configuration courante en audit.

### Configuration globale serveurs

Plateforme : Windows 10, Windows 11 et Windows Server. Profil : Pare-feu Microsoft Defender. Mêmes paramètres que pour les postes :

| Paramètre | Valeur |
|---|---|
| Enable Firewall | Enabled (sur les trois profils) |
| Default Inbound Action | Block |
| Default Outbound Action | Allow |
| Disable Inbound Notifications | Enabled (serveurs sans utilisateur interactif) |
| Allow Local Policy Merge | Disabled |
| Allow Local IPsec Policy Merge | Disabled |

Le paramètre `Default Inbound Action = Block` ne casse rien sur un serveur correctement configuré : les flux applicatifs légitimes disposent déjà de leurs propres règles d'ouverture (créées par l'installation de l'application, par le rôle Windows correspondant, ou par les outils de provisioning). Le firewall Windows respecte ces règles préexistantes, il n'écrase que les règles locales ajoutées en dehors d'Intune via `Allow Local Policy Merge = Disabled`.

Si une application serveur perd ses flux après application de cette configuration, c'est que ses règles d'ouverture n'étaient pas correctement déclarées. C'est une information utile à traiter, pas un signal pour désactiver le firewall.

### Pourquoi pas de règles applicatives ici

Les règles applicatives serveurs (IIS, SQL, Exchange, AD DS, etc.) sont mieux gérées par d'autres mécanismes :

- Les rôles Windows Server installent eux-mêmes les règles correspondantes
- Les outils de déploiement (MECM, Ansible, scripts d'installation) peuvent les pousser de manière contextuelle
- Une policy Intune par rôle (`MDE-FW-Rules-IIS`, `MDE-FW-Rules-SQL`) peut être créée séparément, ciblée sur les serveurs concernés via un groupe dédié

Ces approches sortent du périmètre d'une série Foundations. Elles relèvent d'un projet d'amélioration ultérieur, à mener avec une analyse cas par cas.

Pour l'instant, on s'en tient à l'activation globale. C'est l'amélioration la plus impactante avec le risque le plus maîtrisé.

## La structure des policies pour cette série

Le modèle d'exclusivité se traduit pour le firewall par cinq policies, mais la stratégie diffère entre postes et serveurs.

**Côté postes** : configuration globale + règles spécifiques (blocage SMB sortant Internet, Telnet, FTP, RDP entrant sur Public). Déploiement progressif Wave1 → Wave2 → Production.

**Côté serveurs** : uniquement la configuration globale (firewall activé sur les trois profils, comportements par défaut). Pas de règles fournies. L'objectif est de garantir que le firewall ne soit pas désactivé, sans imposer une posture qui pourrait casser des flux applicatifs non identifiés.

| Policy | Cible Intune | Contenu |
|---|---|---|
| MDE-FW-CatchAll | All Devices + Filter Windows-Only + Exclude des 6 groupes | Configuration globale firewall (firewall activé sur les trois profils), sans règles spécifiques, pour les orphelins |
| MDE-FW-Rules-Workstations | Include MDE-Production-Workstations + Exclude Pilot-WS-Wave1 et Wave2 | Configuration globale + règles postes (blocage SMB sortant Internet, Telnet/FTP, RDP sur Public, ICMP entrant) |
| MDE-FW-Rules-Workstations-Pilot | Include Pilot-WS-Wave1 et Pilot-WS-Wave2 | Identique à la production postes (validation des règles avant rollout production) |
| MDE-FW-Rules-Servers | Include MDE-Production-Servers + Exclude Pilot-Srv-Wave1 et Wave2 | Configuration globale uniquement (firewall activé sur les trois profils), pas de règles applicatives |
| MDE-FW-Rules-Servers-Pilot | Include Pilot-Srv-Wave1 et Pilot-Srv-Wave2 | Identique à la production serveurs (configuration globale uniquement) |

Chaque policy embarque sa configuration globale (firewall ON sur les trois profils, comportements par défaut, `Allow Local Policy Merge = Disabled`). Pas de socle commun, pas de superposition. Une machine reçoit une seule policy firewall.

## Le piège des règles préexistantes

Quand tu déploies les policies Intune sur des machines qui ont déjà des règles firewall locales (héritées de GPO, d'installeurs, ou de modifications manuelles), tu te retrouves avec un mélange.

Le paramètre **Allow Local Policy Merge** à `Disabled` que tu as posé sur le catch-all désactive les règles locales **uniquement pour les profils sur lesquels une policy Intune est appliquée**. C'est le comportement par défaut documenté par Microsoft.

Concrètement : si tu déploies une policy Intune sur le profil Domaine avec `Allow Local Policy Merge = Disabled`, les règles locales sur Domaine sont ignorées. Sur Privé et Public, les règles locales continuent à s'appliquer tant qu'aucune policy Intune ne couvre ces profils.

Pour avoir un comportement homogène, chaque policy de la série couvre les trois profils dans sa configuration globale (firewall activé sur Domain, Private, Public avec les comportements par défaut). Les règles spécifiques ciblent ensuite les profils pertinents (par exemple, blocage RDP entrant sur Public uniquement).

## Vérification après déploiement

Sur un poste cible, depuis PowerShell en administrateur :

```powershell
Get-NetFirewallProfile -PolicyStore ActiveStore | Select-Object `
  Name, Enabled, DefaultInboundAction, DefaultOutboundAction, `
  AllowLocalPolicyMerge, AllowLocalIPsecPolicyMerge
```

Tu dois voir pour chacun des trois profils :

- `Enabled : True`
- `DefaultInboundAction : Block`
- `DefaultOutboundAction : Allow`
- `AllowLocalPolicyMerge : False`

Pour lister les règles actives héritées d'Intune :

```powershell
Get-NetFirewallRule -PolicyStore ActiveStore | Where-Object { $_.PolicyStoreSource -like "*Intune*" }
```

Si tu vois apparaître des règles dont l'origine est `LocalStore` alors que tu as posé `AllowLocalPolicyMerge = Disabled`, vérifie que la policy Intune couvre bien le profil concerné.

## Anti-patterns à éviter

**Désactiver le firewall sur Domaine**

Déjà couvert plus haut. Cette pratique date d'une époque où le réseau interne était considéré comme intrinsèquement sûr. Cette époque est révolue.

**Ouvrir des ports avec "Any" en source**

Une règle qui autorise un port sans restreindre la source IP n'est pas une règle de sécurité, c'est une ouverture sans contrôle. Toujours restreindre les sources à un subnet, une plage, ou un groupe spécifique.

**Empiler des règles sans les nettoyer**

Sur des machines qui ont eu plusieurs vies (changement de domaine, migration de poste à serveur, installation/désinstallation de logiciels), les règles firewall locales s'accumulent. Le `AllowLocalPolicyMerge = Disabled` règle ce problème pour les nouvelles configurations, mais sur l'existant, un audit ponctuel s'impose.

**Confondre profil réseau et VPN**

Quand un utilisateur se connecte au VPN d'entreprise depuis un café, son profil réseau ne bascule pas automatiquement sur Domaine. Il reste sur Public ou Privé selon ce qu'il a déclaré pour le Wi-Fi sous-jacent. Les règles applicables sont donc celles de Public ou Privé, pas celles de Domaine. C'est un point à anticiper dans la conception des règles pour le télétravail.

## Récapitulatif

Tu as maintenant :

- Une configuration firewall homogène sur les trois profils, activée partout y compris sur Domaine
- Une séparation entre policy de configuration globale et policies de règles
- Un socle de règles de base différencié postes / serveurs
- Une compréhension du comportement `Allow Local Policy Merge` et de son impact selon les profils déployés

L'épisode suivant attaque Attack Surface Reduction : comprendre les règles avant de les activer.