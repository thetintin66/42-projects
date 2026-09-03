*This project has been created as part of the 42 curriculum by qhumblot.*

---

# Born2beroot

## Description

Born2beroot est un projet d'administration système de l'école 42 qui consiste à créer et configurer une machine virtuelle suivant des règles strictes. L'objectif est de découvrir le monde de la virtualisation et d'apprendre les bases de l'administration système sous Linux : gestion des utilisateurs, politique de sécurité, configuration réseau, services, et automatisation.

Ce projet m'a permis de mettre en place un serveur Debian sécurisé avec partitionnement LVM chiffré, gestion stricte des mots de passe, pare-feu UFW, service SSH, et un script de monitoring automatisé. En bonus, j'ai également configuré un serveur web avec WordPress, MariaDB et LiteSpeed.

---

## Table des matières

1. [Choix techniques et comparaisons](#choix-techniques-et-comparaisons)
2. [Commandes de vérification pour l'évaluation](#commandes-de-vérification-pour-lévaluation)
3. [Instructions d'installation](#instructions)
4. [Ressources](#ressources)

---

## Choix techniques et comparaisons

### Debian vs Rocky Linux

| Critère | Debian | Rocky Linux |
|---------|--------|-------------|
| **Base** | Indépendante | Clone de RHEL (Red Hat) |
| **Gestionnaire de paquets** | APT (apt, aptitude) | DNF/YUM |
| **Cycle de release** | Stable tous les ~2 ans | Suit RHEL |
| **Communauté** | Très large, orientée communauté | Entreprise, successeur de CentOS |
| **Stabilité** | Excellente, paquets testés | Excellente, grade entreprise |
| **Facilité** | Plus accessible aux débutants | Plus complexe (SELinux par défaut) |

**Mon choix : Debian 13**
- Plus simple à configurer pour un premier projet de virtualisation
- Documentation abondante et communauté active
- APT est plus intuitif que DNF
- AppArmor est plus simple à gérer que SELinux pour un débutant
- Parfait pour apprendre les bases de l'administration système

---

### AppArmor vs SELinux

| Critère | AppArmor | SELinux |
|---------|----------|---------|
| **Approche** | Basée sur les chemins (paths) | Basée sur les étiquettes (labels) |
| **Complexité** | Simple à configurer | Très complexe |
| **Granularité** | Moyenne | Très fine |
| **Distribution** | Debian, Ubuntu | RHEL, Rocky, Fedora |
| **Courbe d'apprentissage** | Douce | Raide |
| **Profils** | Faciles à créer/modifier | Politiques complexes |

**Mon choix : AppArmor**
- Installé par défaut sur Debian
- Configuration plus intuitive basée sur les chemins de fichiers
- Profils facilement lisibles et modifiables
- Suffisant pour sécuriser un serveur de base
- Permet de se concentrer sur l'apprentissage sans complexité excessive

---

### UFW vs firewalld

| Critère | UFW | firewalld |
|---------|-----|-----------|
| **Interface** | Simple, ligne de commande | Zones et services |
| **Backend** | iptables/nftables | nftables |
| **Configuration** | Règles directes | Zones de confiance |
| **Distribution** | Debian, Ubuntu | RHEL, Rocky, Fedora |
| **Rechargement** | Nécessite parfois redémarrage | À chaud (runtime) |
| **Complexité** | Très simple | Plus complexe |

**Mon choix : UFW (Uncomplicated Firewall)**
- Nom explicite : "Uncomplicated" = simple
- Syntaxe intuitive pour gérer les règles
- Parfait pour des configurations basiques
- Commandes faciles à retenir
- Idéal pour apprendre les concepts de pare-feu

---

### VirtualBox vs UTM

| Critère | VirtualBox | UTM |
|---------|------------|-----|
| **Plateforme** | Windows, macOS, Linux | macOS (Apple Silicon & Intel) |
| **Type** | Hyperviseur Type 2 | Frontend pour QEMU |
| **Performance** | Bonne sur x86 | Excellente sur Apple Silicon |
| **Interface** | Complète, professionnelle | Simple, moderne |
| **Fonctionnalités** | Très complètes | Essentielles |
| **Prix** | Gratuit | Gratuit |

**Note** : Le choix dépend de votre matériel. VirtualBox est le standard pour les machines x86, UTM est préférable sur Mac Apple Silicon.

---

## Commandes de vérification pour l'évaluation

### 🔷 PRÉLIMINAIRES

#### Vérifier la signature du fichier .vdi
```bash
# Sur la machine hôte (pas la VM), dans le dossier contenant le .vdi
sha1sum <nom_du_fichier>.vdi

# Comparer avec le contenu de signature.txt
cat signature.txt
```

---

### 🔷 PROJECT OVERVIEW - Questions théoriques

#### Comment fonctionne une machine virtuelle ?
> Une machine virtuelle est un environnement informatique virtualisé qui émule un ordinateur physique complet. Elle utilise un hyperviseur (comme VirtualBox) qui alloue des ressources matérielles (CPU, RAM, stockage) de la machine hôte pour créer un système isolé. La VM possède son propre OS, son propre espace disque (fichier .vdi), et fonctionne indépendamment de l'hôte.

#### Pourquoi Debian ?
> J'ai choisi Debian car c'est une distribution stable, bien documentée et plus accessible pour un premier projet de virtualisation. APT est intuitif, AppArmor est simple à configurer, et la communauté est très active. Debian est aussi réputée pour sa stabilité et sa sécurité.

#### Différences entre CentOS/Rocky et Debian ?
> - **Gestionnaire de paquets** : Debian utilise APT, Rocky utilise DNF
> - **Sécurité** : Debian utilise AppArmor, Rocky utilise SELinux
> - **Pare-feu** : Debian utilise UFW, Rocky utilise firewalld
> - **Origine** : Debian est indépendante, Rocky est basée sur RHEL
> - **Philosophie** : Debian est communautaire, Rocky est orientée entreprise

#### Qu'est-ce que le but des machines virtuelles ?
> - Isolation : tester des configurations sans risquer le système hôte
> - Portabilité : déplacer facilement un environnement complet
> - Économie : faire tourner plusieurs OS sur une seule machine
> - Tests : environnement de développement/test reproductible
> - Sécurité : sandboxing d'applications potentiellement dangereuses

#### Qu'est-ce qu'AppArmor ?
> AppArmor (Application Armor) est un module de sécurité Linux qui protège le système en confinant les programmes selon des profils de sécurité. Il contrôle les accès aux fichiers, aux capacités réseau et aux ressources système. Contrairement à SELinux qui utilise des étiquettes, AppArmor utilise les chemins de fichiers, ce qui le rend plus simple à configurer.

#### Différence entre aptitude et apt ?
> - **apt** : outil en ligne de commande simple et direct, interface utilisateur basique
> - **aptitude** : outil plus avancé avec interface ncurses, meilleure gestion des dépendances, résolution automatique des conflits, système de recherche plus puissant
> - aptitude garde un historique des actions et peut suggérer des solutions en cas de conflit

---

### 🔷 SIMPLE SETUP

#### Vérifier qu'il n'y a pas d'interface graphique
```bash
# La VM doit démarrer en mode console (TTY)
# Si vous voyez un écran de login texte, c'est bon
ls /usr/bin/*session* 2>/dev/null  # Ne doit rien retourner de graphique
systemctl get-default  # Doit afficher "multi-user.target" et non "graphical.target"
```

#### Se connecter avec un utilisateur (non root)
```bash
# Au login, entrer votre login42 et mot de passe
# Le mot de passe doit respecter la politique (voir section password policy)
```

#### Vérifier que UFW est démarré
```bash
sudo systemctl status ufw
# ou
sudo ufw status
```

#### Vérifier que SSH est démarré
```bash
sudo systemctl status ssh
# ou
sudo systemctl status sshd
```

#### Vérifier l'OS (Debian ou Rocky)
```bash
cat /etc/os-release
# ou
lsb_release -a
# ou
hostnamectl
```

---

### 🔷 USER

#### Vérifier que l'utilisateur existe et appartient aux groupes sudo et user42
```bash
# Vérifier l'existence de l'utilisateur
id <login>

# Vérifier les groupes
groups <login>
# Doit afficher : <login> : <login> sudo user42

# Ou plus détaillé
getent group sudo
getent group user42
```

#### Vérifier la politique de mot de passe
```bash
# Voir la configuration
sudo cat /etc/login.defs | grep PASS

# Les valeurs importantes :
# PASS_MAX_DAYS   30    (expiration tous les 30 jours)
# PASS_MIN_DAYS   2     (2 jours minimum avant changement)
# PASS_WARN_AGE   7     (avertissement 7 jours avant expiration)

# Voir la politique de complexité
sudo cat /etc/pam.d/common-password
# ou vérifier libpam-pwquality
sudo cat /etc/security/pwquality.conf
```

#### Créer un nouvel utilisateur et lui assigner un mot de passe
```bash
# Créer l'utilisateur
sudo adduser <nouveau_nom>

# Le mot de passe doit respecter :
# - Minimum 10 caractères
# - Au moins 1 majuscule
# - Au moins 1 minuscule  
# - Au moins 1 chiffre
# - Pas plus de 3 caractères identiques consécutifs
# - Ne doit pas contenir le nom de l'utilisateur
# - Au moins 7 caractères différents de l'ancien mot de passe (sauf root)
```

#### Créer le groupe "evaluating" et y ajouter l'utilisateur
```bash
# Créer le groupe
sudo groupadd evaluating

# Ajouter l'utilisateur au groupe
sudo usermod -aG evaluating <nouveau_nom>

# Vérifier
groups <nouveau_nom>
# ou
getent group evaluating
```

#### Expliquer les avantages/inconvénients de la politique de mot de passe
> **Avantages :**
> - Sécurité renforcée contre les attaques par force brute
> - Mots de passe plus difficiles à deviner
> - Rotation régulière limite l'impact d'une compromission
> - Complexité obligatoire empêche les mots de passe faibles

> **Inconvénients :**
> - Les utilisateurs peuvent noter leurs mots de passe (risque physique)
> - Frustration des utilisateurs
> - Risque de mots de passe prévisibles (Password1, Password2...)
> - Charge cognitive importante

---

### 🔷 HOSTNAME AND PARTITIONS

#### Vérifier le hostname (doit être login42)
```bash
hostname
# ou
hostnamectl
```

#### Modifier le hostname avec celui de l'évaluateur
```bash
# Modifier le hostname
sudo hostnamectl set-hostname <nouveau_hostname>

# Modifier aussi /etc/hosts
sudo nano /etc/hosts
# Remplacer l'ancien hostname par le nouveau sur la ligne 127.0.1.1

# Redémarrer pour appliquer
sudo reboot
```

#### Restaurer le hostname original
```bash
sudo hostnamectl set-hostname <login>42
sudo nano /etc/hosts  # Remettre <login>42
sudo reboot
```

#### Afficher les partitions
```bash
lsblk
```

#### Exemple de sortie attendue (avec bonus) :
```
NAME                    MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINTS
sda                       8:0    0   30G  0 disk  
├─sda1                    8:1    0  500M  0 part  /boot
├─sda2                    8:2    0    1K  0 part  
└─sda5                    8:5    0 29.5G  0 part  
  └─sda5_crypt          254:0    0 29.5G  0 crypt 
    ├─LVMGroup-root     254:1    0   10G  0 lvm   /
    ├─LVMGroup-swap     254:2    0  2.3G  0 lvm   [SWAP]
    ├─LVMGroup-home     254:3    0    5G  0 lvm   /home
    ├─LVMGroup-var      254:4    0    3G  0 lvm   /var
    ├─LVMGroup-srv      254:5    0    3G  0 lvm   /srv
    ├─LVMGroup-tmp      254:6    0    3G  0 lvm   /tmp
    └─LVMGroup-var--log 254:7    0    4G  0 lvm   /var/log
```

#### Expliquer LVM
> **LVM (Logical Volume Manager)** permet de gérer le stockage de manière flexible :
> - **Physical Volumes (PV)** : partitions physiques (/dev/sda5)
> - **Volume Groups (VG)** : regroupement de PV (LVMGroup)
> - **Logical Volumes (LV)** : partitions logiques (root, home, var...)

> **Avantages :**
> - Redimensionnement à chaud des partitions
> - Snapshots pour les sauvegardes
> - Ajout de disques sans réorganisation
> - Gestion centralisée du stockage

---

### 🔷 SUDO

#### Vérifier que sudo est installé
```bash
which sudo
# ou
dpkg -l | grep sudo
# ou
sudo --version
```

#### Assigner le nouvel utilisateur au groupe sudo
```bash
sudo usermod -aG sudo <nouveau_nom>

# Vérifier
groups <nouveau_nom>
```

#### Expliquer sudo et son intérêt
> **sudo (Superuser Do)** permet à un utilisateur autorisé d'exécuter des commandes avec les privilèges root.

> **Avantages :**
> - Évite de se connecter directement en root (risqué)
> - Traçabilité : toutes les commandes sont loguées
> - Granularité : on peut limiter les commandes autorisées
> - Sécurité : mot de passe requis, timeout configurable
> - Principe du moindre privilège respecté

#### Montrer l'implémentation des règles sudo
```bash
sudo visudo
# ou
sudo cat /etc/sudoers.d/sudo_config
```

#### Contenu attendu du fichier de configuration sudo :
```bash
Defaults        passwd_tries=3
Defaults        badpass_message="Wrong password. Try again!"
Defaults        logfile="/var/log/sudo/sudo.log"
Defaults        log_input, log_output
Defaults        iolog_dir="/var/log/sudo"
Defaults        requiretty
Defaults        secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"
```

#### Vérifier que /var/log/sudo/ existe et contient des logs
```bash
# Vérifier le dossier
ls -la /var/log/sudo/

# Voir les logs
sudo cat /var/log/sudo/sudo.log

# Tester en exécutant une commande sudo
sudo ls
sudo cat /var/log/sudo/sudo.log  # Doit montrer la nouvelle entrée
```

---

### 🔷 UFW

#### Vérifier que UFW est installé
```bash
which ufw
# ou
dpkg -l | grep ufw
# ou
sudo ufw version
```

#### Vérifier que UFW fonctionne
```bash
sudo ufw status verbose
# ou
sudo systemctl status ufw
```

#### Expliquer UFW
> **UFW (Uncomplicated Firewall)** est une interface simplifiée pour iptables/nftables qui permet de gérer facilement les règles de pare-feu.

> **Utilité :**
> - Filtrer le trafic réseau entrant et sortant
> - Bloquer les ports non utilisés
> - Autoriser uniquement les services nécessaires (SSH sur 4242)
> - Protection contre les intrusions réseau
> - Simple à configurer pour les débutants

#### Lister les règles UFW actives
```bash
sudo ufw status numbered
```

#### Sortie attendue :
```
Status: active

     To                         Action      From
     --                         ------      ----
[ 1] 4242                       ALLOW IN    Anywhere
[ 2] 4242 (v6)                  ALLOW IN    Anywhere (v6)
```

#### Ajouter une règle pour le port 8080
```bash
sudo ufw allow 8080

# Vérifier
sudo ufw status numbered
```

#### Supprimer la règle du port 8080
```bash
# Afficher les numéros des règles
sudo ufw status numbered

# Supprimer par numéro (attention à l'ordre!)
sudo ufw delete <numéro_règle_8080>
sudo ufw delete <numéro_règle_8080_v6>

# Ou supprimer par spécification
sudo ufw delete allow 8080

# Vérifier
sudo ufw status numbered
```

---

### 🔷 SSH

#### Vérifier que SSH est installé
```bash
which ssh
# ou
dpkg -l | grep openssh-server
# ou
ssh -V
```

#### Vérifier que SSH fonctionne
```bash
sudo systemctl status ssh
# ou
sudo systemctl status sshd
```

#### Expliquer SSH
> **SSH (Secure Shell)** est un protocole de communication sécurisé qui permet :
> - Connexion à distance chiffrée (remplace Telnet non sécurisé)
> - Transfert de fichiers sécurisé (SCP, SFTP)
> - Tunneling de ports
> - Authentification par mot de passe ou clés

> **Utilité :**
> - Administration à distance des serveurs
> - Connexion sécurisée sans accès physique
> - Chiffrement de bout en bout
> - Authentification forte

#### Vérifier que SSH utilise le port 4242
```bash
sudo cat /etc/ssh/sshd_config | grep Port
# ou
sudo grep -i port /etc/ssh/sshd_config
# Doit afficher : Port 4242
```

#### Vérifier que root ne peut pas se connecter en SSH
```bash
sudo cat /etc/ssh/sshd_config | grep PermitRootLogin
# Doit afficher : PermitRootLogin no
```

#### Se connecter en SSH avec le nouvel utilisateur
```bash
# Depuis la machine hôte (terminal)
ssh <nouveau_nom>@localhost -p 4242
# ou avec l'IP de la VM
ssh <nouveau_nom>@<IP_VM> -p 4242
```

#### Vérifier qu'on ne peut pas se connecter en root via SSH
```bash
# Depuis la machine hôte
ssh root@localhost -p 4242
# Doit être refusé : "Permission denied"
```

---

### 🔷 SCRIPT MONITORING

#### Expliquer le fonctionnement du script
> Le script `monitoring.sh` collecte et affiche des informations système :
> - Architecture et kernel
> - CPU physiques et virtuels
> - Utilisation RAM et disque
> - Charge CPU
> - Dernier boot
> - Statut LVM
> - Connexions TCP actives
> - Utilisateurs connectés
> - Adresse IP et MAC
> - Nombre de commandes sudo exécutées

#### Afficher le script
```bash
sudo cat /usr/local/bin/monitoring.sh
```

#### Contenu du script monitoring.sh :
```bash
#!/bin/bash

# Architecture
arch=$(uname -a)

# CPU physical
cpuf=$(grep "physical id" /proc/cpuinfo | wc -l)

# CPU virtual
cpuv=$(grep "processor" /proc/cpuinfo | wc -l)

# RAM
ram_total=$(free --mega | awk '$1 == "Mem:" {print $2}')
ram_use=$(free --mega | awk '$1 == "Mem:" {print $3}')
ram_percent=$(free --mega | awk '$1 == "Mem:" {printf("%.2f"), $3/$2*100}')

# Disk
disk_total=$(df -m | grep "/dev/" | grep -v "/boot" | awk '{disk_t += $2} END {printf ("%.1fGb\n"), disk_t/1024}')
disk_use=$(df -m | grep "/dev/" | grep -v "/boot" | awk '{disk_u += $3} END {print disk_u}')
disk_percent=$(df -m | grep "/dev/" | grep -v "/boot" | awk '{disk_u += $3} {disk_t+= $2} END {printf("%d"), disk_u/disk_t*100}')

# CPU load
cpul=$(vmstat 1 2 | tail -1 | awk '{printf $15}')
cpu_op=$(expr 100 - $cpul)
cpu_fin=$(printf "%.1f" $cpu_op)

# Last boot
lb=$(who -b | awk '$1 == "system" {print $3 " " $4}')

# LVM use
lvmu=$(if [ $(lsblk | grep "lvm" | wc -l) -gt 0 ]; then echo yes; else echo no; fi)

# TCP Connexions
tcpc=$(ss -ta | grep ESTAB | wc -l)

# User log
ulog=$(users | wc -w)

# Network
ip=$(hostname -I)
mac=$(ip link | grep "link/ether" | awk '{print $2}')

# Sudo
cmnd=$(journalctl _COMM=sudo | grep COMMAND | wc -l)

wall "	Architecture: $arch
	CPU physical: $cpuf
	vCPU: $cpuv
	Memory Usage: $ram_use/${ram_total}MB ($ram_percent%)
	Disk Usage: $disk_use/${disk_total} ($disk_percent%)
	CPU load: $cpu_fin%
	Last boot: $lb
	LVM use: $lvmu
	Connections TCP: $tcpc ESTABLISHED
	User log: $ulog
	Network: IP $ip ($mac)
	Sudo: $cmnd cmd"
```

#### Qu'est-ce que cron ?
> **Cron** est un planificateur de tâches qui permet d'exécuter automatiquement des scripts ou commandes à des intervalles définis. Le fichier crontab contient la programmation des tâches.

> Format crontab : `minute heure jour_du_mois mois jour_de_semaine commande`

#### Vérifier que le script tourne toutes les 10 minutes
```bash
sudo crontab -l
# Doit afficher quelque chose comme :
# */10 * * * * /usr/local/bin/monitoring.sh
```

#### Faire tourner le script toutes les minutes (pour la démo)
```bash
sudo crontab -e
# Modifier la ligne pour :
# */1 * * * * /usr/local/bin/monitoring.sh
```

#### Arrêter le script sans modifier le script lui-même
```bash
# Méthode 1 : Commenter la ligne dans crontab
sudo crontab -e
# Ajouter # devant la ligne

# Méthode 2 : Arrêter le service cron
sudo systemctl stop cron

# Pour redémarrer
sudo systemctl start cron
```

#### Vérifier après redémarrage que le script est toujours là et tourne
```bash
sudo reboot
# Après redémarrage :
sudo crontab -l  # Le script doit toujours être configuré
```

---

## 🔷 BONUS

> **Important** : Les bonus ne sont évalués que si la partie obligatoire est parfaitement réalisée !

### Partitionnement (2 points)

#### Vérifier le partitionnement bonus
```bash
lsblk
```
Le schéma doit correspondre exactement à celui du sujet avec les partitions séparées pour `/home`, `/var`, `/srv`, `/tmp`, `/var/log`.

---

### WordPress avec Lighttpd, MariaDB, PHP (2 points)

> **Note** : J'ai utilisé une configuration NAT pour permettre l'accès au serveur web.

#### Vérifier Lighttpd
```bash
# Statut du service
sudo systemctl status lighttpd

# Version
lighttpd -v

# Configuration
sudo cat /etc/lighttpd/lighttpd.conf
```

#### Vérifier MariaDB
```bash
# Statut du service
sudo systemctl status mariadb

# Version
mysql --version

# Se connecter à la base
sudo mysql -u root -p
# Puis dans MySQL :
SHOW DATABASES;
USE wordpress;
SHOW TABLES;
EXIT;
```

#### Vérifier PHP
```bash
# Version
php -v

# Modules PHP
php -m
```

#### Vérifier WordPress
```bash
# Les fichiers WordPress
ls -la /var/www/html/

# Configuration
sudo cat /var/www/html/wp-config.php
```

#### Accéder au site WordPress
```
# Dans le navigateur de la machine hôte :
http://localhost:80
# ou
http://<IP_VM>:80
```

---

### Service additionnel : LiteSpeed (1 point)

> **Note** : NGINX et Apache2 sont interdits !

#### Qu'est-ce que LiteSpeed ?
> **LiteSpeed** est un serveur web haute performance compatible avec Apache. Il offre :
> - Meilleure performance que Apache
> - Support HTTP/3 et QUIC
> - Cache intégré
> - Interface d'administration web
> - Compatible .htaccess
> - Faible consommation de ressources

#### Pourquoi LiteSpeed ?
> J'ai choisi LiteSpeed car :
> - Il est plus performant que les serveurs traditionnels
> - Il consomme moins de ressources
> - Il a un cache intégré optimisé pour WordPress
> - Il est facile à configurer
> - C'est une alternative intéressante aux serveurs interdits

#### Vérifier LiteSpeed
```bash
# Statut du service
sudo systemctl status lsws

# ou
sudo /usr/local/lsws/bin/lswsctrl status

# Version
/usr/local/lsws/bin/lshttpd -v
```

---

## Instructions

### Prérequis
- VirtualBox (ou UTM pour Mac Apple Silicon)
- Image ISO Debian 13
- Minimum 8GB d'espace disque
- 1GB RAM minimum

### Installation rapide

1. **Créer la VM** dans VirtualBox avec les paramètres requis
2. **Installer Debian** en mode expert sans interface graphique
3. **Configurer le partitionnement LVM** selon le schéma du bonus
4. **Installer et configurer** :
   ```bash
   # Mettre à jour le système
   sudo apt update && sudo apt upgrade

   # Installer les outils de base
   sudo apt install vim ufw openssh-server

   # Configurer SSH (port 4242, no root login)
   sudo nano /etc/ssh/sshd_config

   # Configurer UFW
   sudo ufw enable
   sudo ufw allow 4242

   # Configurer sudo
   sudo apt install sudo
   sudo visudo
   ```

5. **Créer le script monitoring.sh** et le configurer avec cron

6. **Générer la signature**
   ```bash
   # Sur la machine hôte, dans le dossier des VMs
   sha1sum <nom_vm>.vdi > signature.txt
   ```

---

## Ressources

### Documentation officielle
- [Debian Administrator's Handbook](https://debian-handbook.info/)
- [Wiki Debian](https://wiki.debian.org/)
- [Documentation AppArmor](https://gitlab.com/apparmor/apparmor/-/wikis/Documentation)
- [UFW Documentation](https://help.ubuntu.com/community/UFW)
- [OpenSSH Manual](https://www.openssh.com/manual.html)
- [LVM Guide](https://wiki.debian.org/LVM)

### Tutoriels
- [Guide complet Born2beroot](https://github.com/pasqualerossi/Born2BeRoot-Guide)
- [WordPress Installation Guide](https://wordpress.org/support/article/how-to-install-wordpress/)

### Utilisation de l'IA
L'IA (Claude) a été utilisée pour :
- Structurer et formater ce README
- Vérifier la syntaxe des commandes
- Clarifier les explications techniques
- Organiser les informations de manière pédagogique

Le projet lui-même (configuration de la VM, scripts, installation) a été réalisé manuellement en suivant le sujet et la documentation officielle.

---

## Aide-mémoire rapide pour l'évaluation

### Commandes essentielles

| Vérification | Commande |
|--------------|----------|
| OS | `cat /etc/os-release` |
| Hostname | `hostname` |
| Partitions | `lsblk` |
| Utilisateur et groupes | `id <user>` ou `groups <user>` |
| UFW status | `sudo ufw status` |
| SSH status | `sudo systemctl status ssh` |
| AppArmor | `sudo aa-status` |
| Sudo logs | `sudo cat /var/log/sudo/sudo.log` |
| Crontab | `sudo crontab -l` |
| Password policy | `sudo cat /etc/login.defs \| grep PASS` |

### Créer utilisateur complet
```bash
sudo adduser <nom>
sudo usermod -aG sudo <nom>
sudo usermod -aG user42 <nom>
```

### Modifier hostname
```bash
sudo hostnamectl set-hostname <nouveau>
sudo nano /etc/hosts
sudo reboot
```

### Gérer UFW
```bash
sudo ufw status numbered
sudo ufw allow <port>
sudo ufw delete allow <port>
```

### Gérer cron
```bash
sudo crontab -e          # Éditer
sudo crontab -l          # Lister
sudo systemctl stop cron # Arrêter
```

---

