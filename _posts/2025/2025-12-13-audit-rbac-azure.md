---
title: "Auditer les permissions RBAC sur un abonnement Azure (PowerShell)"
date: 2025-12-13 12:23:00:00 +02:00
layout: post
tags: [rbac, audit, azure, powershell, identite]
categories: [identite, entra-id]
readtime: true
comments: true
cover-img: "assets/img/banners/banner-ops.png"
thumbnail-img: "assets/img/posts/2025/12/13/azure-audit.png"
featured: true
featured_reason: "Astuce de la semaine."
sidebar: true

---
Lors d’une mission, j’ai dû auditer les permissions effectives sur un abonnement Azure client.  
Objectif simple sur le papier : savoir **qui a accès à quoi**, avec **quel rôle**, et **à quel niveau de périmètre**.

En pratique, l’abonnement avait vécu :
- héritage de rôles multiples,
- affectations historiques jamais nettoyées,
- comptes techniques, groupes, identités managées mélangés.

Il fallait une **vue exploitable**, exportable, et partageable — sans passer par le portail Azure à la main.

### L’approche retenue

Le script s’appuie sur :
- `Az.Accounts` pour la sélection du tenant et de l’abonnement,
- `Az.Resources` pour l’inventaire RBAC,
- une résolution des **principaux (User / Group / SPN / MSI)**,
- une sortie structurée :
  - **CSV** pour l’outillage brut,
  - **Excel** pour l’analyse et le partage (mise en forme minimale).

Aucune dépendance exotique, hormis le module **ImportExcel** pour la génération du fichier `.xlsx`.

**Périmètre couvert**

Le script audite l’ensemble des affectations RBAC visibles dans le contexte de l’abonnement sélectionné, quel que soit leur niveau :
- abonnement,
- groupes de ressources,
- ressources individuelles.

Chaque affectation expose son périmètre exact via le champ `Scope`, ce qui permet d’identifier précisément où le rôle est appliqué.

**RBAC : affectations vs privilèges effectifs**

Le script liste les affectations RBAC déclarées, pas les droits effectifs cumulés.
L’héritage (subscription → resource group → ressource) n’est pas recalculé.

L’analyse des privilèges réellement disponibles reste volontairement humaine
(exploitation du champ `Scope`, filtres Excel, revue ciblée).

### Le script PowerShell

> La version complète et maintenue est publiée sur GitHub.  
> Le script ci-dessous est strictement identique à la version source.

```powershell
<#
.SYNOPSIS
Audit Azure RBAC permissions across a subscription.

.DESCRIPTION
This script collects all visible Azure RBAC role assignments within a selected
Azure subscription, across all scope levels:
- subscription
- resource groups
- individual resources

The output is exported to CSV and Excel formats to support review,
governance analysis, and reporting.

.CONTEXT
- Usage: IAM / RBAC audit
- Environment: Azure subscription
- Scenarios: RSSI/CISO engagement, customer audit, periodic review, MSP context

.PREREQUISITES
- PowerShell modules:
  - Az.Accounts
  - Az.Resources
  - ImportExcel
- Minimum permissions:
  - Reader on the subscription
  - Azure AD read access (identity resolution)

.LIMITATIONS
- Effective permissions are not calculated (RBAC inheritance is not evaluated).
- PIM-eligible role assignments are not included.
- Visibility depends on the permissions of the executing account (eg. you are owner on a resource group, you will see only RBAC on resource group and its descendat resources)

.OUTPUTS
- Azure-RBAC-Audit.csv
- Azure-RBAC-Audit.xlsx

.AUTHOR
Sébastien Miro

.VERSION
1.0

.LASTUPDATED
2025-12-13

.SOURCE
https://github.com/sebastienmiro/azure-rbac-audit
#>

#Requires -Modules Az.Accounts, Az.Resources

param (
    [string]$OutputPath = ".\Azure-RBAC-Audit"
)

# --- Pré-requis ---
if (-not (Get-Module -ListAvailable -Name ImportExcel)) {
    Write-Error "Le module ImportExcel est requis (Install-Module ImportExcel)."
    return
}

# --- Connexion et sélection ---
Connect-AzAccount | Out-Null

$tenant = Get-AzTenant | Out-GridView -Title "Sélection du tenant" -PassThru
Set-AzContext -TenantId $tenant.Id | Out-Null

$subscription = Get-AzSubscription | Out-GridView -Title "Sélection de l'abonnement" -PassThru
Set-AzContext -SubscriptionId $subscription.Id | Out-Null

Write-Host "Audit RBAC sur l'abonnement $($subscription.Name)" -ForegroundColor Cyan

# --- Collecte RBAC ---
$assignments = Get-AzRoleAssignment -IncludeClassicAdministrators

$result = foreach ($a in $assignments) {

    $principalType = $a.ObjectType
    $displayName   = $null
    $upn           = $null

    try {
        switch ($principalType) {
            "User" {
                $u = Get-AzADUser -ObjectId $a.ObjectId
                $displayName = $u.DisplayName
                $upn = $u.UserPrincipalName
            }
            "Group" {
                $g = Get-AzADGroup -ObjectId $a.ObjectId
                $displayName = $g.DisplayName
            }
            "ServicePrincipal" {
                $sp = Get-AzADServicePrincipal -ObjectId $a.ObjectId
                $displayName = $sp.DisplayName
            }
            default {
                $displayName = "Inconnu"
            }
        }
    }
    catch {
        $displayName = "Non résolu"
    }

    [PSCustomObject]@{
        TenantName       = $tenant.Name
        SubscriptionName = $subscription.Name
        Scope            = $a.Scope
        RoleName         = $a.RoleDefinitionName
        PrincipalType    = $principalType
        DisplayName      = $displayName
        UserPrincipal    = $upn
        ObjectId         = $a.ObjectId
        AssignmentId     = $a.RoleAssignmentId
    }
}

# --- Sorties ---
New-Item -ItemType Directory -Force -Path $OutputPath | Out-Null

$csvPath   = Join-Path $OutputPath "Azure-RBAC-Audit.csv"
$xlsxPath  = Join-Path $OutputPath "Azure-RBAC-Audit.xlsx"

$result | Sort-Object Scope, RoleName |
    Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8

$result | Sort-Object Scope, RoleName |
    Export-Excel -Path $xlsxPath `
        -WorksheetName "RBAC" `
        -AutoSize `
        -TableName "RBAC_Audit" `
        -FreezeTopRow `
        -BoldTopRow

Write-Host "Audit terminé." -ForegroundColor Green
Write-Host "CSV  : $csvPath"
Write-Host "Excel: $xlsxPath"
```
