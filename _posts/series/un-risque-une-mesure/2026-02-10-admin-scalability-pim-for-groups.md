---
title: "L’enfer du micro-management : Passer à l'échelle avec PIM for Groups"
date: 2026-02-10 08:00:00 +01:00
layout: post
tags: [series:un-risque-une-mesure, entra-id, pim, governance, groups, automation, scalability, powershell, kql, sentinel]
categories: [gouvernance, entra-id]
readtime: true
comments: true
cover-img: "assets/img/banners/banner-pim-groups.png"
thumbnail-img: "assets/img/posts/series/un-risque-une-mesure/2026-02-10-pim-groups.png"
series: R1M
series_order: 100
sidebar: true
level: expert
scope:
  - Entra ID PIM
  - Role-Assignable Groups
  - Identity Governance
  - Entra ID Access Packages
  - Microsoft Sentinel (KQL)
---

> 💡 **La complexité est l'ennemie de la sécurité.**
> Si votre procédure de sécurité exige qu'un administrateur effectue 12 clics, navigue dans 3 menus et valide 4 invites MFA chaque matin avant même de pouvoir traiter son premier ticket, il trouvera un moyen de la contourner. Ou pire, il demandera un compte "Dépannage" permanent, brisant votre modèle Zero Trust.

Vous avez déployé Privileged Identity Management (PIM). Félicitations. C'est une étape majeure. Vous avez éradiqué les droits permanents (Standing Access) et imposé le Just-In-Time (JIT). Sur le papier, votre Secure Score a bondi, vos auditeurs sont ravis et votre CISO dort mieux.

Mais sur le terrain, dans les tranchées des opérations IT, la réalité est plus frictionnelle. Vos administrateurs Niveau 2 et 3 commencent à montrer des signes de fatigue.
Pourquoi ? Parce qu'un administrateur système moderne ne gère pas *juste* une technologie isolée. Il gère un écosystème interconnecté.

Prenons l'exemple d'un administrateur "Digital Workplace". Pour faire son travail, il a besoin de :
1.  **Exchange Administrator** (pour les boîtes mails).
2.  **Teams Administrator** (pour la téléphonie et les politiques).
3.  **SharePoint Administrator** (pour les sites d'équipes).
4.  **Reports Reader** (pour analyser l'usage).
5.  **Message Center Reader** (pour voir les incidents).

Dans une implémentation PIM traditionnelle (modèle atomique 1 utilisateur = 1 rôle), cet administrateur doit, chaque matin, subir un rituel pénible :
1.  Se connecter au portail PIM.
2.  Chercher et activer *Exchange Administrator* (Saisir motif + MFA).
3.  Attendre l'activation.
4.  Répéter l'opération pour *Teams Administrator*.
5.  Répéter pour *SharePoint Administrator*.
6.  Répéter pour les autres rôles...
7.  Se déconnecter/reconnecter pour forcer la prise en compte des nouveaux claims dans le token PRT.

C'est ce qu'on appelle la **"Fatigue du Clic"** (Click Fatigue). Et c'est un risque de sécurité réel : face à cette friction, les admins finissent par réclamer le rôle *Global Admin* "juste pour simplifier", ou utilisent des scripts d'activation automatique qui stockent leurs credentials, annulant le bénéfice de sécurité.

## Le Risque : L'ingérabilité à l'échelle (The Scale Problem)

Le problème ne vient pas de l'outil PIM, mais de la **granularité** de l'assignation.

Si vous avez 50 administrateurs et 30 rôles Entra ID différents, gérer les éligibilités individuellement (User A -> Role B) crée une matrice de **1500 points de contrôle**.

### Les conséquences opérationnelles
* **Onboarding douloureux :** Quand "Julie" arrive au support N2, l'équipe IAM doit l'ajouter manuellement à 6 rôles différents. C'est lent, fastidieux et sujet à l'erreur humaine.
* **Offboarding risqué :** Si Julie change de poste pour aller aux RH, on oublie souvent de retirer l'un des 6 rôles. Elle conserve un accès dormant, invisible car "éligible" et non "actif".
* **Dérive de configuration (Drift) :** Au fil du temps, deux administrateurs censés avoir le même poste finissent avec des droits différents ("Pourquoi ça marche pour Bob et pas pour moi ?"). Le dépannage devient un cauchemar.

Le modèle "Utilisateur vers Rôle" ne passe pas l'échelle (**Does not scale**).

## La Mesure : PIM pour les Groupes (Le "Bundling")

La solution consiste à changer d'unité de gestion. Au lieu d'assigner des utilisateurs à des rôles, nous allons assigner des **Groupes** à des rôles, et rendre les utilisateurs éligibles à ces **Groupes**.

C'est la fonctionnalité **PIM for Groups** (anciennement *Privileged Access Groups*).

### L'Architecture "Role-Assignable Group"

L'idée est de créer des "Profils Métier" techniques. L'architecture change radicalement :

1.  **Création du Groupe Spécial :** Vous créez un groupe Entra ID nommé `ROLE-Collab-Admins`.
    * *Détail Critique :* Ce groupe doit avoir l'option **"Microsoft Entra roles can be assigned to the group"** (propriété `isAssignableToRole`) activée à la création.
2.  **Assignation des Droits au Groupe :** Vous assignez de manière **Permanente** (Active) les rôles *Exchange*, *Teams* et *SharePoint* à ce groupe.
    * *Note :* Oui, le groupe a les droits en permanence. Mais le groupe est **vide** par défaut.
3.  **L'Éligibilité :** Au lieu de rendre l'utilisateur éligible aux rôles, vous le rendez **Eligible à l'appartenance au Groupe**.

### Le nouveau flux de travail (Workflow)

Pour l'administrateur, la vie change du tout au tout :
1.  Il se connecte le matin.
2.  Il va dans PIM > **Privileged Access Groups**.
3.  Il active son appartenance au groupe `ROLE-Collab-Admins`.
4.  **Résultat :** En une seule activation (et un seul challenge MFA), il devient membre du groupe. Par transitivité, il hérite instantanément des 3, 5 ou 10 rôles associés.

C'est le principe du **Bundle de permissions**.

## Comparatif Détaillé : PIM Classique vs PIM Groups

Pour justifier ce changement d'architecture auprès de votre direction, voici les arguments clés :

| Caractéristique | PIM Classique (User -> Rôle) | PIM Groups (User -> Groupe -> Rôles) |
| :--- | :--- | :--- |
| **Activation** | 1 activation par rôle (3 rôles = 3 MFAs) | **1 activation unique pour N rôles** |
| **Maintenance** | N assignations à modifier par utilisateur | **1 assignation unique par utilisateur** |
| **Gouvernance** | Difficile (trop d'objets) | **Simplifiée (Gestion par profil)** |
| **Latence** | ~2-5 minutes par rôle | **~5-10 minutes (Propagation groupe)** |
| **Coût Licence** | Entra ID P2 | Entra ID P2 |
| **Audit** | "User A activated Exchange Admin" | "User A added member to Group X" |

## Deep Dive Technique : Automatisation PowerShell

L'interface graphique est bien pour tester, mais pour la production, vous devez industrialiser.
Voici un script PowerShell robuste pour créer ces groupes "Role-Assignable" (ce qui n'est pas possible via `New-AzAdGroup` standard).

### Prérequis
Vous devez disposer du module `Microsoft.Graph.Groups` et `Microsoft.Graph.Identity.DirectoryManagement`.

### Le Script de Provisioning

```powershell
<#
.SYNOPSIS
    Crée un groupe Role-Assignable et lui assigne des rôles Entra ID.
.DESCRIPTION
    Ce script crée un groupe compatible PIM et assigne les rôles spécifiés.
#>

Import-Module Microsoft.Graph.Groups
Import-Module Microsoft.Graph.Identity.DirectoryManagement

# Connexion (Nécessite Privileged Role Admin)
Connect-MgGraph -Scopes "Group.ReadWrite.All", "RoleManagement.ReadWrite.Directory"

# --- CONFIGURATION ---
$GroupName = "ROLE-Tier2-Support"
$GroupDesc = "Bundle pour le support N2 (Exchange, User, Teams)"
$RolesToAssign = @("Exchange Administrator", "Teams Administrator", "User Administrator")

# 1. Création du groupe "Role Assignable"
# Note: IsAssignableToRole ne peut être défini qu'à la création !
$groupParams = @{
    DisplayName = $GroupName
    Description = $GroupDesc
    MailEnabled = $false
    MailNickname = ($GroupName -replace " ", "").ToLower()
    SecurityEnabled = $true
    IsAssignableToRole = $true # <--- LE paramètre critique indispensable
}

Write-Host "Création du groupe $GroupName..." -ForegroundColor Cyan
$group = New-MgGroup -BodyParameter $groupParams
Write-Host "Groupe créé avec succès. ID : $($group.Id)" -ForegroundColor Green

# 2. Boucle d'assignation des rôles
foreach ($roleName in $RolesToAssign) {
    Write-Host "Recherche du rôle : $roleName"
    
    $roleDef = Get-MgRoleManagementDirectoryRoleDefinition -Filter "DisplayName eq '$roleName'"
    
    if ($roleDef) {
        # Assignation PERMANENTE du rôle au GROUPE
        $params = @{
            PrincipalId = $group.Id
            RoleDefinitionId = $roleDef.Id
            DirectoryScopeId = "/"
            AssignmentType = "Assigned" # Permanent car c'est le groupe qui porte le droit
        }
        
        New-MgRoleManagementDirectoryRoleAssignment -BodyParameter $params
        Write-Host "Rôle $roleName assigné au groupe." -ForegroundColor Green
    }
    else {
        Write-Host "Erreur : Rôle $roleName introuvable." -ForegroundColor Red
    }
}