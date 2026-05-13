---
title: "ITDR Microsoft - Surface d'attaque identité dans un tenant moderne"
date: 2026-05-22 09:00:00 +02:00
layout: post
tags: [series:itdr-microsoft, surface-attaque, identity-threats]
categories: [identite, securite]
readtime: true
comments: true
cover-img: "assets/img/banners/banner-itdr.png"
thumbnail-img: "assets/img/posts/series/itdr-microsoft/010/010-thumb.png"
series: ITDR
series_order: 010
sidebar: true
mermaid: true
level: concepts
scope:
  - Entra ID
  - AD on-prem
  - Surface d'attaque
  - MITRE ATT&CK
platform: Microsoft Security
---

Avant de parler des outils Microsoft qui composent la pile ITDR, il faut savoir contre quoi ils sont censés défendre. Cet article cartographie la **surface d'attaque identité** d'un environnement Microsoft hybride réaliste. Il sort volontairement de la vue produit pour adopter la vue chaîne d'attaque, parce que c'est celle que les équipes adverses utilisent en pratique.

L'objectif n'est pas l'exhaustivité. Il est de donner une grille de lecture claire pour les articles suivants, qui présenteront chacun une brique de détection.

## Trois plans, une seule identité

Dans un environnement Microsoft moderne, une même identité existe simultanément sur plusieurs plans, avec des mécanismes d'authentification, des vecteurs de compromission et des outils de détection distincts.

```mermaid
flowchart LR
    subgraph OnPrem["Plan on-prem"]
        AD["Active Directory<br/>DS, CS, FS"]
        EC["Entra Connect<br/>ADFS"]
    end
    subgraph Cloud["Plan cloud"]
        EID["Entra ID"]
        Sessions["Sessions et tokens<br/>refresh, access, PRT"]
    end
    subgraph App["Plan applicatif"]
        Apps["Applications<br/>fédérées et SaaS"]
        SP["Service principals<br/>managed identities"]
        OAuth["OAuth consents"]
    end
    AD -- synchronisation --> EC
    EC --> EID
    EID --> Sessions
    Sessions --> Apps
    EID --> SP
    SP --> OAuth
    OAuth --> Apps
```

Ce découpage n'est pas théorique. Il correspond à des sources de signaux et à des outils de détection différents. Le plan on-prem est principalement couvert par Defender for Identity. Le plan cloud par Entra ID Protection et les journaux Entra. Le plan applicatif par Defender for Cloud Apps, les audits Entra et l'analyse des consentements OAuth.

Un attaquant ne se limite pas à un seul plan. Une compromission sérieuse traverse les trois.

## Plan cloud, ce que cible un attaquant aujourd'hui

Les vecteurs les plus actifs sur le plan cloud ne cherchent plus à casser la MFA, ils cherchent à la contourner ou à la rendre inutile.

**Password spray.** Tentative à faible volume sur un grand nombre de comptes pour rester sous les seuils de verrouillage. Visible dans les journaux Sign-in, classé par Entra ID Protection sous la catégorie *password spray*.

**Adversary-in-the-Middle.** Proxy de phishing qui capte simultanément les identifiants et le cookie de session après MFA réussie. Le token obtenu permet d'opérer sans repasser par l'authentification. Visible partiellement via les signaux d'anomalie de Defender for Cloud Apps et via les détections atypical sign-in côté EIDP, mais le moment exact du vol passe souvent sous le radar.

**Vol et réutilisation de tokens.** Extraction d'un refresh ou d'un PRT depuis un poste compromis. L'attaquant rejoue le token depuis son propre environnement, ce qui peut produire une session qui paraît légitime du point de vue d'Entra.

**OAuth consent illicite.** L'utilisateur accorde un consentement à une application malveillante qui demande des permissions élevées sur Graph. La persistance ne dépend plus du mot de passe ni de la MFA, mais des permissions consenties.

**Abus de service principals et managed identities.** Création ou réutilisation d'une identité applicative pour accéder à Graph et à des ressources, avec un niveau de surveillance souvent inférieur à celui des comptes utilisateurs.

**Abus du B2B.** Identité externe invitée dans le tenant, mal cadrée par les politiques d'accès, qui sert de point d'entrée à moindre coût.

## Plan on-prem, ce qui reste central

Beaucoup d'environnements modernes restent hybrides. La compromission d'Active Directory ouvre toujours l'accès au cloud par propagation.

**Kerberoasting.** Demande de tickets de service sur des comptes avec SPN, puis cassage hors-ligne. Visible si l'audit Kerberos est correctement configuré, et détecté par Defender for Identity quand le capteur DC est en place.

**AS-REP roasting.** Variante exploitant les comptes pour lesquels la pré-authentification Kerberos est désactivée.

**DCSync.** Utilisation des privilèges de réplication pour extraire les hashes des comptes du domaine, dont KRBTGT. La rotation du KRBTGT après compromission est rarement opérationnelle de bout en bout.

**Pass-the-hash, overpass-the-hash, pass-the-ticket.** Réutilisation d'éléments d'authentification volés pour s'authentifier sans connaître le mot de passe.

**Golden Ticket et Silver Ticket.** Forge de tickets Kerberos à partir du hash KRBTGT ou du hash d'un compte de service, donnant un accès persistant difficile à révoquer.

**Abus des comptes de service.** Comptes avec mots de passe statiques, privilèges élevés et activité difficile à distinguer d'un comportement légitime.

## Plan hybride, la zone la plus mal couverte

Les vecteurs hybrides exploitent la jointure entre on-prem et cloud, qui est aussi le maillon le moins observé.

**Compromission Entra Connect.** Le serveur Entra Connect manipule des identités synchronisées. Sa compromission permet de basculer ou de manipuler des identités côté cloud. Le compte de service utilisé pour la synchronisation a des privilèges élevés, parfois mal restreints.

**Compromission ADFS ou de la fédération.** Vol du token signing certificate, attaque Golden SAML. L'attaquant émet ses propres jetons SAML acceptés par Entra, ce qui contourne entièrement les mécanismes côté cloud.

**Propagation T0 vers cloud.** Compte administrateur de domaine compromis qui sert ensuite à pivoter vers une identité cloud à privilèges via un compte hybride.

**Propagation cloud vers on-prem.** Plus rare, mais possible quand certaines fonctions hybrides sont mal cloisonnées. Cloud Sync et certaines configurations d'écriture en sens inverse changent la posture.

## Mapping rapide MITRE ATT&CK

Pour situer ces vecteurs dans une grille reconnue, voici un mapping synthétique sur les tactiques les plus pertinentes côté identité.

| Tactique | Techniques identité courantes |
|---|---|
| Initial Access | Phishing, AiTM, Valid Accounts |
| Credential Access | Password Spray, Kerberoasting, AS-REP Roasting, Forced Authentication |
| Privilege Escalation | DCSync, Token Impersonation, Abuse of OAuth scopes |
| Persistence | Golden Ticket, Golden SAML, OAuth Consent, Service Principal abuse |
| Defense Evasion | Token theft, Session hijacking |
| Lateral Movement | Pass-the-Hash, Pass-the-Ticket, Remote Services with Valid Accounts |

Ce mapping n'a pas vocation à se substituer à une lecture complète de MITRE ATT&CK. Il sert de repère pour les articles suivants, qui rattacheront chaque détection Microsoft à une ou plusieurs de ces techniques.

## Ce qui change en contexte MSP

La surface d'attaque ne se limite pas à un tenant isolé. En contexte MSP, deux dimensions supplémentaires interviennent.

**Identités du prestataire.** Comptes d'administration utilisés par le MSP, dont la compromission impacte simultanément plusieurs tenants clients. C'est la raison pour laquelle la posture du prestataire doit être au minimum équivalente à celle de son client le plus exigeant.

**Delegated Admin Privileges et Granular Delegated Admin Privileges.** Modèle de délégation Microsoft Partner qui ouvre une voie d'accès depuis le tenant prestataire vers les tenants clients. Surface d'attaque concentrée, qui demande une attention spécifique côté Conditional Access et côté détection.

Ces deux dimensions ne sont pas approfondies dans cet article. Elles seront référencées chaque fois qu'une brique de détection les concerne.

## Ce que voit déjà la pile Microsoft

Tous les vecteurs ci-dessus ne sont pas équivalents devant les outils de détection. Voici une lecture rapide, qui sera affinée article par article :

**Bien couverts.** Password spray, atypical sign-in, AiTM via signaux EIDP et MDCA, Kerberoasting et AS-REP roasting avec capteurs MDI, OAuth consent suspect via Defender XDR.

**Couverture partielle.** Vol et réutilisation de tokens, attaque Golden SAML, abus de service principals, compromission Entra Connect.

**Mal couverts ou non couverts.** Comportements insider légitimes, certaines compromissions B2B côté tenant invitant, IdP tiers fédérés hors Microsoft.

Cette répartition n'est pas une critique de la pile, c'est une lecture honnête de son périmètre, et c'est précisément ce qui justifie la suite de la série.

## Conclusion

La surface d'attaque identité dans un environnement Microsoft moderne n'est pas concentrée sur l'authentification. Elle s'étend sur trois plans qui se chevauchent et se nourrissent mutuellement. Comprendre cette cartographie est un préalable à toute discussion sur les outils de détection et de réponse.

Les articles suivants prendront chaque brique de la pile ITDR Microsoft et la situeront sur cette cartographie. La semaine prochaine, panorama complet des briques, avec leurs zones de recouvrement et leurs limites de périmètre.
