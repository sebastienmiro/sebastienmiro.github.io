---
title: "La fin du tunnel : Couper le mouvement latéral en remplaçant le VPN"
date: 2026-02-03 08:00:00 +01:00
layout: post
tags: [series:un-risque-une-mesure, entra-private-access, gsa, vpn, zero-trust, ztna, lateral-movement]
categories: [reseau, entra-id]
readtime: true
comments: true
cover-img: "assets/img/banners/banner-tunnel.png"
thumbnail-img: "assets/img/posts/series/un-risque-une-mesure/2026-02-03-vpn-vs-gsa.png"
series: R1M
series_order: 090
sidebar: true
level: architecture sécurité
scope:
  - Entra Private Access
  - Global Secure Access Client
  - Remplacement VPN
  - Prévention Mouvement Latéral
---

> 💡 **Le réseau est un moyen de transport, pas une zone de confiance.**
> Connecter un utilisateur au réseau entier pour qu'il accède à une seule application, c'est comme donner le passe-partout de tout l'immeuble à un livreur qui doit juste déposer un colis à l'étage 4.

Le VPN (Virtual Private Network) a été le héros des années 2000 et le sauveur du COVID en 2020. En 2026, il est devenu une dette technique majeure et, paradoxalement, l'un des vecteurs d'attaque les plus efficaces pour les ransomwares.

Pourquoi ? Parce que le VPN repose sur un paradigme obsolète : l'extension du périmètre (Network Extension). Une fois le tunnel monté, l'ordinateur distant obtient une adresse IP interne et devient un membre à part entière du réseau local. Si cet ordinateur est compromis, l'attaquant ne frappe plus à la porte : il est déjà dans le salon.

C'est ce qu'on appelle le **mouvement latéral**. Et c'est précisément ce que le modèle Zero Trust Network Access (ZTNA), incarné par **Microsoft Entra Private Access**, vient éradiquer.

## Le Risque : L'effet "Autoroute" du VPN et le réseau plat

Dans une architecture VPN classique, la sécurité est périmétrique.
1.  L'utilisateur s'authentifie (fortement, espérons-le).
2.  Le tunnel s'établit.
3.  Des routes réseaux sont poussées vers le client (Split Tunneling).

À cet instant précis, la barrière tombe. Le poste client dispose d'une visibilité réseau directe (*Line of Sight*) sur les serveurs. Même avec des VLANs et des ACLs pare-feu internes, la granularité est généralement faible (par sous-réseau ou par zone).

**Le scénario d'attaque standard :**
Un poste utilisateur compromis (par un malware ou un attaquant humain) monte le VPN légitimement. L'attaquant lance un scan de ports sur le segment serveur (192.168.x.x). Il découvre un serveur de fichiers vulnérable via le port 445 (SMB) ou un serveur de rebond en RDP (3389). Il s'y connecte, dump les hashs d'identifiants, et rebondit vers le contrôleur de domaine.
L'attaque se propage d'Est en Ouest, invisible pour le pare-feu périmétrique qui ne surveille que les flux Nord-Sud.

Le VPN connecte des **réseaux**. Nous avons besoin de connecter des **applications**.

## La Mesure : L'accès "Inside-Out" (Microsoft Entra Private Access)

Microsoft Entra Private Access (brique de la suite *Global Secure Access*) change radicalement la topologie réseau. Il ne s'agit plus d'ouvrir un tunnel *entrant*, mais d'utiliser des connexions *sortantes* pour relier l'utilisateur à l'application.

### L'Architecture technique
Au lieu d'un concentrateur VPN exposé sur Internet (qui doit être patché en urgence à chaque CVE critique), vous installez des agents légers appelés **Connecteurs de réseau privé** sur des serveurs Windows proches de vos applications backend.

La mécanique est la suivante :
1.  **Fermeture des ports entrants :** Le Connecteur n'a besoin d'aucun port ouvert vers l'extérieur. Il initie une connexion sortante persistante (Outbound TCP 443) vers le cloud Microsoft. Votre pare-feu devient une forteresse hermétique.
2.  **L'intermédiation Cloud :** L'utilisateur lance son application (ex: `\\app-finance\data`). Le client GSA (installé sur son poste) intercepte le flux réseau au niveau de l'OS.
3.  **Le Broker d'Identité :** Le trafic est encapsulé et envoyé au cloud Microsoft. C'est ici, **avant même que le premier paquet n'atteigne le réseau interne**, que la sécurité s'applique.
4.  **Le Rendez-vous :** Si l'accès est autorisé par Entra ID (MFA, conformité), le cloud Microsoft "colle" la session de l'utilisateur avec la session du Connecteur.

Le poste utilisateur ne touche jamais le réseau interne. Il ne voit pas les adresses IP réelles. Il ne peut pas scanner les ports voisins. Il voit juste un tunnel chiffré vers l'application spécifique autorisée.

[Image suggestion: Schematic comparison of VPN "Tunnel" vs GSA "Broker"]

## Stratégie de déploiement : Quick Access vs Per-App Access

La migration vers ce modèle peut sembler complexe. Microsoft propose deux niveaux de maturité pour faciliter la transition :

### 1. Niveau 1 : Quick Access (Le remplacement tactique du VPN)
C'est l'étape de transition. Vous définissez un large segment réseau (ex: tout le sous-réseau `10.0.1.0/24` ou le port 443 sur tout le domaine `*.interne.local`) et vous l'attribuez à vos utilisateurs.
* **Avantage :** Remplace fonctionnellement le VPN en quelques heures sans casser les usages.
* **Limite :** Vous reproduisez l'effet "réseau plat" du VPN, mais avec une authentification plus moderne.

### 2. Niveau 2 : Per-App Access (Le vrai Zero Trust)
C'est la cible. Vous définissez l'application "App Finance" de manière granulaire (IP: 10.0.1.5, Ports: 443, 1433). Vous créez une politique : "Seul le groupe Finance peut accéder à cette App".
* **Le gain :** Si le comptable est compromis et essaie de faire un Ping sur le serveur RH situé juste à côté (10.0.1.6), le trafic est bloqué. Soit par le client GSA, soit par le cloud Microsoft. Le mouvement latéral réseau devient impossible par design.

## La Puissance de l'Accès Conditionnel Granulaire

C'est la différence majeure avec un VPN traditionnel. Sur un VPN, l'authentification se fait à la connexion du tunnel. Une fois dedans, c'est fini.

Avec Private Access, l'authentification est continue et contextuelle **par application**.
* **L'Intranet :** Accès autorisé avec un simple MFA.
* **Le Code Source (Git) :** Accès autorisé uniquement depuis un appareil conforme (Intune) et sans risque détecté.
* **Le Serveur SWIFT :** Accès autorisé uniquement avec une clé FIDO2 et depuis un pays spécifique.

Vous appliquez la logique de sécurité du Cloud (SaaS) à vos vieilles applications TCP/UDP héritées (Legacy), sans toucher une ligne de code de l'application.

## Focus Technique : Ce qui change pour l'Admin Réseau

### 1. Le Single Sign-On (SSO) pour le Legacy
Comment gérer l'authentification sur une vieille application Web IIS qui demande une authentification Windows intégrée (IWA/Kerberos) ?
Entra Private Access intègre la gestion de Kerberos. Le connecteur peut obtenir un ticket Kerberos pour le compte de l'utilisateur Cloud et le présenter au serveur On-Prem.
*Résultat :* L'utilisateur se logue sur Entra ID (Cloud), et accède à l'appli On-Prem sans ressaisir de mot de passe, comme par magie.

### 2. La gestion du DNS (Le point critique)
Le client GSA intercepte les requêtes DNS.
Si l'utilisateur demande `crm.interne.corp`, le client GSA capture la requête, voit qu'elle correspond à une règle Private Access, et l'envoie au cloud. Le Connecteur On-Prem résout alors le nom via le DNS interne de l'entreprise.
Cela permet d'utiliser des noms courts ou des domaines privés sans exposer votre DNS interne sur Internet.

## Conclusion

Soyons réalistes : le VPN ne disparaîtra pas de votre infrastructure demain matin. La dette technique a la vie dure, et certains usages spécifiques nécessiteront encore du tunnel pendant un temps.

Cependant, la trajectoire est claire. L'objectif n'est pas un "Grand Soir" où l'on coupe les câbles, mais une atrophie progressive du VPN. Commencez par publier vos applications critiques et celles accessibles aux prestataires via Entra Private Access. Réduisez peu à peu le nombre d'utilisateurs ayant besoin du client VPN historique.

En basculant vers cette logique, vous transformez votre sécurité : vous passez d'une défense de périmètre (vulnérable une fois percée) à une défense de ressource (robuste par design).

Le sujet du Global Secure Access est vaste, mais il ne s'agit pas d'acheter un outil de plus. Il s'agit de fermer, port après port, les entrées béantes de votre réseau pour ne laisser passer que ce qui est légitime. C'est un chantier d'architecture, pas juste un projet produit.

---

### Ressources externes
* 🔗 [Microsoft — Learn about Microsoft Entra Private Access](https://learn.microsoft.com/en-us/entra/global-secure-access/concept-private-access)
* 🔗 [Microsoft — How to configure Quick Access](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-configure-quick-access)
* 🔗 [NIST — Zero Trust Architecture (SP 800-207)](