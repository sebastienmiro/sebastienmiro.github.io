---
title: "Nouveau rapport de gouvernance SharePoint : Site permissions for users "
date: 2025-12-22 13:37:00:00 +02:00
layout: post
tags: [sharepoint, gouvernance, copilot, sécurité, permissions]
categories: [sharepoint, gouvernance]
readtime: true
comments: true
cover-img: "assets/img/banners/banner-ops.png"
thumbnail-img: "assets/img/posts/2025/12/2025-12-22-sharepoint-data-access-governance-site-permissions-users-report.png"
featured: true
featured_reason: "Astuce de la semaine."
sidebar: true

---

> Un rapport **instantané** qui dresse, pour un ou plusieurs utilisateurs, la **liste des sites** auxquels ils ont accès et **l’étendue** de cet accès (site complet vs quelques éléments, accès direct vs via des groupes). Disponible dans **SharePoint Admin Center** au sein de **Data access governance (DAG)**, avec SharePoint Advanced Management / SharePoint Premium. [1](https://learn.microsoft.com/en-us/sharepoint/data-access-governance-site-permissions-users-report)

# À quoi sert ce rapport ?

- **Vision claire par utilisateur** : vous obtenez l’état des permissions **à un instant donné** et pouvez qualifier si l’accès porte sur le **site entier** ou seulement sur **certains fichiers/dossiers**. 
- **Cas d’usage clés** : revue de permissions **avant attribution d’une licence Copilot**, ou **nettoyage** des accès lors d’un **départ** ou d’un **changement de département**. 

# Comment l’exécuter (admin center)

1. Dans **SharePoint Admin Center** > **Reports** > **Data access governance**, ouvrez **Site permissions for users** puis **Create report**.  
2. **Add users** pour sélectionner les comptes cibles, choisissez le **Scope** (**SharePoint** ou **OneDrive**), nommez le rapport, puis **Create and run**.  
3. Suivez la **colonne Status** pour savoir quand le rapport est prêt / mis à jour. 

**Points importants** :  
- Les données peuvent dater de **jusqu’à 48 heures** au moment de la génération. 
- **Maximum 5 rapports** simultanés, **exécutable tous les 30 jours**. 

# Consultation & export

- L’interface affiche, pour chaque utilisateur, la **liste des sites accessibles** et indique si l’accès est **total ou partiel**, **direct ou indirect (groupes)**. 
- **Téléchargements** :  
  - **CSV** pour l’utilisateur sélectionné (**limite 1 million de sites**). 
  - **Detailed report** : **ZIP** contenant les CSV **pour tous les utilisateurs** du rapport (depuis la page du rapport ou la liste des rapports).
  ![Exemple de rapport visualisable](assets/img/posts/2025/12/2025-12-22-user-permission-report.png)

# Données fournies (aperçu des colonnes)

Le CSV agrège des **métadonnées de site** (ID, nom, URL, modèle, admin primaire), des **paramètres de partage** (invités externes, confidentialité du site), la **sensibilité** (label appliqué), des **volumétries** (fichiers), et des **compteurs** d’items partagés **directement** ou **indirectement** avec l’utilisateur. Il inclut aussi les **identifiants Entra ID** et le **UPN** de l’utilisateur, plus la **date de rapport**. 

# Pré‑requis & disponibilité

- **Licences** : base **Microsoft 365 / Office 365** (E1/E3/E5/A5) **et** soit **au moins une licence Copilot** (qui donne accès aux fonctionnalités SharePoint Advanced Management nécessaires), soit la **licence SharePoint Advanced Management** en achat autonome.   
- **Déploiement** : la fonctionnalité « permissions par utilisateur » est annoncée en **Message Center** (Roadmap ID 492621), déployée **mi‑déc. 2025 → mi‑janv. 2026** au niveau mondial, GCC/GCCH/DoD. 

# Mon regard de RSSI : où ce rapport apporte du **ROI** immédiat

## 1) Hygiène avant Copilot
Copilot élargit les surfaces de découverte de contenu. Avant d’activer une licence, passez chaque compte au crible avec ce rapport :  
- **Objectif** : éviter que Copilot « révèle » par inadvertance des documents **sur‑partagés**.  
- **Action** : sur les sites à forte exposition (accès très large, liens « Anyone », invités), enclenchez **Restricted Access Control (RAC)** pour **resserrer l’accès** sur un groupe dédié, puis faites une **Site Access Review** auprès des propriétaires pour ajuster les droits. 

## 2) Processus JML (Joiner/Mover/Leaver)
- **Joiner** : vérifier que l’utilisateur n’hérite **que** des groupes attendus (pas d’ajouts manuels intempestifs).  
- **Mover** : tracer les **sites abandonnés** et **sites à rejoindre** selon le nouveau périmètre ; retirer systématiquement les accès indirects historiques.  
- **Leaver** : à **J+0**, exporter le rapport et **purger** les accès (groupes, liens, partages directs). Conserver l’export au **dossier d’audit**.

## 3) Assainir les écarts « groupes vs partage direct »
- **Prioriser les groupes** (SharePoint/M365 group) plutôt que les **partages directs sur items** ; ce rapport met en évidence les **comptages d’items partagés** qui dérivent au fil du temps.  
- **Quick wins** : convertir les partages individuels récurrents en **groupes** + politique de **partage** plus stricte sur les sites concernés (et formation des propriétaires).

## 4) Gouvernance opérationnelle
- **Fréquence** : intégrer ce rapport dans votre **revue trimestrielle** des accès (baseline « snapshot »), en le complétant par les **activity reports** (liens de partage, EEEU) en **mensuel** pour capter les dérives. 
- **Remédiation collaborative** : privilégier la **Site Access Review** afin d’impliquer les métiers, puis appliquer **RAC** là où le risque est élevé sans bloquer l’activité. 

## Conseils pratiques

- **Nommer les rapports** par **périmètre** et **motif** : `DAG-UsersPerms_Offboarding-Dec2025`. 
- **Limiter les faux‑positifs** : tenir compte du **décalage possible (≤ 48 h)** et planifier la génération **après** vos changements majeurs de permissions. 
- **Documenter les exceptions** (partages item‑level justifiés, besoins temporaires).  
- **Archiver les ZIP détaillés** dans un espace **d’audit** avec horodatage (chaîne de preuves).

## Ressources officielles

- **Site permissions for users (snapshot report)** — documentation Microsoft Learn. [1](https://learn.microsoft.com/en-us/sharepoint/data-access-governance-site-permissions-users-report)  
- **Data access governance reports (vue d’ensemble, licences, actions RAC & Site Access Review)** — Microsoft Learn. [2](https://learn.microsoft.com/en-us/sharepoint/data-access-governance-reports)  

---

# En résumé
Ce rapport **réduit drastiquement le temps d’analyse** des accès par utilisateur et **cadre** la remédiation. Employé avant Copilot et dans vos cycles de vie d’un collaborateur et de son identité, il devient un **levier concret** de maîtrise des risques de **sur‑partage** dans SharePoint/OneDrive.

# Annexe : colonnes du CSV


| Column                           | Description                                                                                               |
| -------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| TenantID                         | GUID identifiant l’organisation                                                                            |
| Site ID                          | GUID identifiant le site                                                                                   |
| Site Name                        | Nom du site                                                                                                |
| Site URL                         | URL du site                                                                                                |
| Site Template                    | Type de site (ex. : site de communication, site d’équipe, site d’équipe — sans groupe Microsoft 365, autres) |
| Primary admin                    | Administrateur du site marqué comme **Primary** dans la page **Active sites**                              |
| Primary admin email              | Adresse e‑mail de l’administrateur principal du site                                                       |
| ExternalSharing                  | Indique si le contenu peut être partagé avec des invités externes (Oui/Non)                               |
| Site Privacy                     | Pour les sites d’équipe connectés à Microsoft 365 : niveau de confidentialité du groupe (Public/Privé)     |
| Site Sensitivity                 | Étiquette de sensibilité appliquée au site                                                                 |
| Files                            | Nombre approximatif de fichiers présents sur le site                                                       |
| Is site shared                   | Indique si l’utilisateur appartient à un ou plusieurs groupes SharePoint avec accès au niveau **site** (Oui/Non) |
| Items with direct access count   | Nombre de fichiers/dossiers partagés **directement** avec l’utilisateur                                    |
| Items with indirect access count | Nombre de fichiers/dossiers accessibles **indirectement** via l’appartenance à un groupe                   |
| Microsoft Entra object ID        | GUID identifiant l’utilisateur dans Microsoft Entra                                                        |
| User principle name              | Nom principal de l’utilisateur (UPN) dans Microsoft Entra                                                  |
| Display name                     | Nom tel qu’affiché dans les expériences de sélection/recherche de personnes                                |
| Report Date                      | Date/heure de génération du rapport (les changements peuvent mettre **jusqu’à 48 h** à apparaître)         |
