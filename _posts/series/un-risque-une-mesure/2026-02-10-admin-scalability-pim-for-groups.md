---
title: "L’enfer du micro-management : Passer à l'échelle avec PIM for Groups"
date: 2026-02-10 08:00:00 +01:00
layout: post
tags: [series:un-risque-une-mesure, entra-id, pim, governance, groups, automation, scalability, powershell]
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
---

> 💡 **La complexité est l'ennemie de la sécurité.**
> Si votre procédure de sécurité demande à un administrateur de faire 12 clics chaque matin et de valider 4 invites MFA pour commencer à travailler, il trouvera un moyen de la contourner. Ou pire, il demandera un compte "Dépannage" permanent.

Vous avez déployé Privileged Identity Management (PIM). Bravo. Vous avez supprimé les droits permanents (Standing Access) et imposé le Just-In-Time (JIT). Sur le papier, votre score de sécurité (Secure Score) a bondi et vos auditeurs sont ravis.

Mais sur le terrain, l'ambiance est différente. Vos administrateurs Niveau 2 et 3 commencent à grogner. Ils parlent de "lourdeur administrative" et de "perte de productivité".
Pourquoi ? Parce qu'un administrateur système moderne ne gère pas *juste* Exchange. Il gère Exchange, Teams, SharePoint, une partie des utilisateurs, et doit souvent consulter les logs de sécurité.

Dans une implémentation PIM naïve (1 utilisateur = 1 rôle), cet administrateur doit, chaque matin, effectuer un rituel pénible :
1.  Aller sur le portail PIM.
2.  Activer le rôle *Exchange Admin* (Saisir motif + MFA).
3.  Attendre l'activation (et le rafraîchissement du token).
4.  Activer le rôle *Teams Admin* (Saisir motif).
5.  Activer le rôle *SharePoint Admin* (Saisir motif).
6.  Se déconnecter/reconnecter pour être sûr que tout est pris en compte.

C'est ce qu'on appelle la **"Fatigue du Clic"**. Et c'est un risque réel : face à cette friction, les admins finissent par demander le rôle *Global Admin* "juste pour simplifier", ou ils utilisent des scripts d'activation automatique qui stockent leurs credentials, annulant le bénéfice de sécurité.

## Le Risque : L'ingérabilité à l'échelle

Le problème ne vient pas de PIM, mais de la **granularité** de l'assignation.

Si vous avez 50 administrateurs et 30 rôles Entra ID différents, gérer les éligibilités individuellement (User A -> Role B) crée une matrice de 1500 points de contrôle potentiels.

* **Onboarding douloureux :** Quand "Julie" arrive au support N2, l'équipe IAM doit l'ajouter manuellement à 6 rôles différents dans PIM.
* **Erreur humaine (Offboarding) :** Si Julie change de poste pour aller aux RH, on oublie souvent de retirer l'un des 6 rôles. Elle garde un accès dormant dangereux.
* **Incohérence des profils :** Au fil du temps, deux administrateurs censés avoir le même poste finissent avec des droits différents ("Configuration Drift"), rendant le dépannage impossible ("Pourquoi ça marche pour Bob et pas pour moi ?").

Le modèle "Utilisateur vers Rôle" ne passe pas l'échelle (Does not scale).

## La Mesure : PIM pour les Groupes (Le "Bundling")

La solution consiste à changer d'unité de mesure. Au lieu d'assigner des utilisateurs à des rôles, nous allons assigner des **Groupes** à des rôles, et rendre les utilisateurs éligibles à ces **Groupes**.

C'est la fonctionnalité **PIM for Groups** (anciennement *Privileged Access Groups*).

### L'Architecture "Role-Assignable Group"

L'idée est de créer des "Profils Métier" techniques sous forme de groupes. L'architecture change radicalement :

1.  **Création du Groupe Spécial :** Vous créez un groupe Entra ID nommé `ROLE-Collab-Admins`.
    * *Détail Critique :* Ce groupe doit avoir l'option **"Microsoft Entra roles can be assigned to the group"** (propriété `isAssignableToRole`) activée à la création.
2.  **Assignation des Droits au Groupe :** Vous assignez de manière **Permanente** (Active) les rôles *Exchange Administrator*, *Teams Administrator* et *SharePoint Administrator* à ce groupe.
    * *Note :* Oui, le groupe a les droits en permanence. Mais le groupe est **vide** par défaut.
3.  **La Magie PIM :** Au lieu de rendre l'utilisateur éligible aux rôles, vous le rendez **Eligible à l'appartenance au Groupe**.

### Le nouveau flux de travail (Workflow)

Pour l'administrateur, la vie change du tout au tout :
1.  Il se connecte le matin.
2.  Il va dans PIM > **Privileged Access Groups**.
3.  Il active son appartenance au groupe `ROLE-Collab-Admins`.
4.  **Résultat :** En une seule activation (et un seul MFA), il devient membre du groupe, et par transitivité, il hérite instantanément des 3, 5 ou 10 rôles associés.

C'est le principe du **Bundle de permissions**.

## Pourquoi c'est techniquement supérieur

Au-delà du confort, cette approche verrouille votre gouvernance.

### 1. Intégration IGA et Access Packages
Puisque l'accès technique est désormais représenté par un *Groupe*, vous pouvez utiliser tout l'arsenal de gestion de groupes d'Entra ID Governance.
Vous pouvez créer un **Access Package** "Onboarding Admin Support".
* Le manager demande l'accès pour le nouvel arrivant.
* L'approbation déclenche l'ajout en tant que membre éligible au groupe PIM.
* L'accès expire automatiquement après 6 mois si non renouvelé.
Tout est automatisé, auditable, et sans intervention manuelle de l'IT.

### 2. Access Reviews simplifiées (Recertification)
Imaginez devoir recertifier 50 admins sur 30 rôles. C'est un cauchemar que personne ne fait sérieusement.
Avec les groupes, vous lancez une **Access Review** trimestrielle sur le groupe `ROLE-Collab-Admins`.
* Question posée au manager : "Est-ce que Julie est toujours dans l'équipe Collab ?"
* Si la réponse est "Non", Julie est retirée du groupe. Elle perd **tous** ses accès Exchange, Teams et SharePoint d'un seul coup. C'est propre, net et sans bavure.

### 3. Protection contre l'élévation latérale
Les groupes assignables aux rôles (`isAssignableToRole = True`) sont protégés par conception.
* Ils ne peuvent pas être modifiés par des administrateurs "User Admin" ou "Group Admin".
* Seuls les *Global Admins* ou *Privileged Role Admins* peuvent toucher à leur composition.
Cela empêche un administrateur de bas niveau de s'ajouter lui-même (ou d'ajouter un compte de service) dans un groupe administrateur pour élever ses privilèges.

## Deep Dive Technique : Pièges et Limitations

Attention, ce n'est pas aussi simple que de cocher une case sur vos groupes existants.

**1. L'immuabilité de la propriété `isAssignableToRole`**
Vous ne pouvez pas transformer un groupe de sécurité existant en "Role-Assignable Group". Vous devez le créer neuf.
*Pourquoi ?* Microsoft verrouille l'objet dès sa naissance pour garantir qu'aucune permission héritée ou propriétaire caché n'existe.

**2. Automatisation via PowerShell**
L'interface graphique est bien, mais pour l'industrialisation, utilisez PowerShell (Microsoft Graph). Voici comment créer ce type de groupe spécifique :

```powershell
# Connexion à mGraph
Connect-MgGraph -Scopes "Group.ReadWrite.All", "RoleManagement.ReadWrite.Directory"

# Paramètres du groupe
$params = @{
    DisplayName = "ROLE-Tier2-Support"
    MailEnabled = $false
    MailNickname = "role-tier2-support"
    SecurityEnabled = $true
    IsAssignableToRole = $true # <--- LE point critique
}

# Création
New-MgGroup -BodyParameter $params