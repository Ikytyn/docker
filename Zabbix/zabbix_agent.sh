#!/bin/bash

# Vérifier si /etc/os-release est présent, sinon quitter le script
if [ ! -f /etc/os-release ]; then
    echo "Erreur : Impossible de trouver /etc/os-release. Impossible de déterminer la distribution et la version."
    exit 1
fi

# Lire les variables ID et VERSION_ID à partir de /etc/os-release
. /etc/os-release

# Fonction pour installer et configurer l'agent Zabbix sur les distributions basées sur Red Hat
install_rhel_agent() {
    # Vérifier si le dépôt Zabbix est déjà installé
    if rpm -qa | grep -q zabbix-release; then
        echo "Le dépôt Zabbix est déjà installé."
    else
        # Installer le dépôt Zabbix
        if [ "$ID" == "centos" ]; then
            rpm -Uvh https://repo.zabbix.com/zabbix/6.4/rhel/${VERSION_ID}/x86_64/zabbix-release-6.4-1.el${VERSION_ID}.noarch.rpm > /dev/null 2>&1
        elif [ "$ID" == "rocky" ]; then
            rpm -Uvh https://repo.zabbix.com/zabbix/6.4/rhel/${VERSION_ID}/x86_64/zabbix-release-6.4-1.el${VERSION_ID}.noarch.rpm > /dev/null 2>&1
        fi

        if [ "$?" -ne 0 ]; then
            echo "Erreur : Échec de l'installation du dépôt Zabbix."
            exit 1
        fi
    fi

    # Vérifier si dnf est disponible
    if command -v dnf > /dev/null 2>&1; then
        # Installer l'agent Zabbix version 2 avec dnf
        if dnf install -y zabbix-agent2 zabbix-agent2-plugin-* > /dev/null 2>&1; then
            echo ""
            echo -n "Installation de l'agent Zabbix pour RedHat-based distributions... [.......................] 0%"
            # Démarrer l'agent Zabbix et activer le démarrage au boot
            systemctl restart zabbix-agent2 > /dev/null 2>&1
            systemctl enable zabbix-agent2 > /dev/null 2>&1
            echo ""
            echo -n "Installation de l'agent Zabbix pour RedHat-based distributions... [#####..................] 15%"

            # Ouvrir les ports 10050 et 10051
            firewall-cmd --permanent --add-port=10050/tcp > /dev/null 2>&1
            firewall-cmd --permanent --add-port=10051/tcp > /dev/null 2>&1
            firewall-cmd --reload > /dev/null 2>&1
            echo ""
            echo -n "Installation de l'agent Zabbix pour RedHat-based distributions... [##########.............] 30%"
        else
            echo "Erreur : Échec de l'installation de l'agent Zabbix."
            exit 1
        fi
    else
        # Installer l'agent Zabbix version 2 avec yum
        if yum install -y zabbix-agent2 zabbix-agent2-plugin-* > /dev/null 2>&1; then
            echo ""
            echo -n "Installation de l'agent Zabbix pour RedHat-based distributions... [.......................] 0%"
            # Démarrer l'agent Zabbix et activer le démarrage au boot
            systemctl restart zabbix-agent2 > /dev/null 2>&1
            systemctl enable zabbix-agent2 > /dev/null 2>&1
            echo ""
            echo -n "Installation de l'agent Zabbix pour RedHat-based distributions... [#####..................] 15%"

            # Ouvrir les ports 10050 et 10051
            firewall-cmd --permanent --add-port=10050/tcp > /dev/null 2>&1
            firewall-cmd --permanent --add-port=10051/tcp > /dev/null 2>&1
            firewall-cmd --reload > /dev/null 2>&1
            echo ""
            echo -n "Installation de l'agent Zabbix pour RedHat-based distributions... [##########.............] 30%"
        else
            echo "Erreur : Échec de l'installation de l'agent Zabbix."
            exit 1
        fi
    fi

    # Configurer l'agent Zabbix version 2
    agent_version=2

    # Demander les informations nécessaires pour configurer le fichier /etc/zabbix/zabbix_agent2.conf
    echo ''
    read -p "Server (adresse du Zabbix server ou du proxy) : " server
    read -p "ServerActive (adresse du Zabbix proxy avec le port 10051) : " server_active
    read -p "Hostname (hostname de la machine) : " hostname
    echo ""
    echo -n "Installation de l'agent Zabbix pour RedHat-based distributions... [#############..........] 50%"

    # Configurer le fichier /etc/zabbix/zabbix_agent2.conf
    sed -i "s/^Server=.*/Server=$server/" /etc/zabbix/zabbix_agent2.conf
    sed -i "s/^ServerActive=.*/ServerActive=$server_active/" /etc/zabbix/zabbix_agent2.conf
    sed -i "s/^Hostname=.*/Hostname=$hostname/" /etc/zabbix/zabbix_agent2.conf
    echo ""
    echo -n "Installation de l'agent Zabbix pour RedHat-based distributions... [##################.....] 75%"

    # Redémarrer l'agent Zabbix pour appliquer les modifications
    systemctl restart zabbix-agent$agent_version > /dev/null 2>&1
    echo ""
    echo -n "Installation de l'agent Zabbix pour RedHat-based distributions... [#####################..] 90%"
    echo ""
    echo -n "Installation de l'agent Zabbix pour RedHat-based distributions... [#######################] 100%"
    echo ""

    # Afficher l'hostname, le DNS name et l'adresse IP de la machine
    echo "Il faut noter ces variables, elles seront demandées sur le serveur Zabbix. Si le port utilisé pour le ServeurActive n'est pas celui par défaut, il faudra le spécifier sur le serveur Zabbix."
    echo "---------------------------------------------------------------------------"
    echo "Hostname : $hostname"
    echo "DNS name : $(hostname --fqdn)"
    echo "IP address : $(ip route get 1 | awk '{print $NF;exit}')"
    echo "---------------------------------------------------------------------------"
}

# Fonction pour installer et configurer l'agent Zabbix sur Debian
install_debian_agent() {
    echo ''
    echo -n "Installation de l'agent Zabbix pour Debian-based distributions... [.......................] 0%"
    # Installer le dépôt Zabbix
    wget -O /tmp/zabbix-release.deb "https://repo.zabbix.com/zabbix/6.4/debian/pool/main/z/zabbix-release/zabbix-release_6.4-1+${ID}${VERSION_ID}_all.deb" > /dev/null 2>&1
    dpkg -i /tmp/zabbix-release.deb > /dev/null 2>&1
    apt update > /dev/null 2>&1

    # Installer l'agent Zabbix
    apt install -y zabbix-agent2 zabbix-agent2-plugin-* > /dev/null 2>&1

    # Démarrer l'agent Zabbix et activer le démarrage au boot
    systemctl restart zabbix-agent2 > /dev/null 2>&1
    systemctl enable zabbix-agent2 > /dev/null 2>&1

    # Ouvrir les ports 10050 et 10051
    ufw allow 10050/tcp > /dev/null 2>&1
    ufw allow 10051/tcp > /dev/null 2>&1
    ufw reload > /dev/null 2>&1

    echo ""
    echo -n "Installation de l'agent Zabbix pour Debian-based distributions... [#####..................] 15%"

    # Demander les informations nécessaires pour configurer le fichier /etc/zabbix/zabbix_agent2.conf
    echo ""
    read -p "Server (Tapez l'adresse IP du serveur Zabbix, si vous utilisez un proxy, tapez l'IP du proxy.) : " server
    read -p "ServerActive (Tapez l'adresse IP du serveur Zabbix ou celle du proxy si vous en avez un, spécifiez le port par défaut : 10051.) : " server_active
    read -p "Hostname (Tapez le nom de la machine.) : " hostname
    echo ""
    echo -n "Installation de l'agent Zabbix pour Debian-based distributions... [##########.............] 30%"

    # Configurer le fichier /etc/zabbix/zabbix_agent2.conf
    sed -i "s/^Server=.*/Server=$server/" /etc/zabbix/zabbix_agent2.conf
    sed -i "s/^ServerActive=.*/ServerActive=$server_active/" /etc/zabbix/zabbix_agent2.conf
    sed -i "s/^Hostname=.*/Hostname=$hostname/" /etc/zabbix/zabbix_agent2.conf

    echo ""
    echo -n "Installation de l'agent Zabbix pour Debian-based distributions... [#############..........] 50%"

    # Redémarrer l'agent Zabbix pour appliquer les modifications
    systemctl restart zabbix-agent2 > /dev/null 2>&1
    echo ""
    echo -n "Installation de l'agent Zabbix pour Debian-based distributions... [##################.....] 75%"
    echo ""
    echo -n "Installation de l'agent Zabbix pour Debian-based distributions... [#####################..] 90%"
    echo ""
    echo -n "Installation de l'agent Zabbix pour Debian-based distributions... [#######################] 100%"
    echo ""

    # Afficher l'hostname, le DNS name et l'adresse IP de la machine
    echo "Il faut noter ces variables, elles seront demandées sur le serveur Zabbix. Si le port utilisé pour le ServerActive n'est pas celui par défaut, il faudra le spécifier sur le serveur Zabbix."
    echo "---------------------------------------------------------------------------"
    echo "Hostname : $hostname"
    echo "DNS name : $(hostname --fqdn)"
    echo "IP address : $(ip a | grep 'inet ' | grep -v '127.0.0.1' | head -n 1 | awk '{print $2}' | cut -d'/' -f1)"
    echo "---------------------------------------------------------------------------"
}

# Fonction pour installer et configurer l'agent Zabbix sur Ubuntu
install_ubuntu_agent() {

    echo -n "Installation de l'agent Zabbix pour Ubuntu-based distributions... [.......................] 0%"

    # Vérifier si le dépôt Zabbix est déjà installé
    if dpkg -l | grep -q zabbix-release; then
        echo "Le dépôt Zabbix est déjà installé."
    else
        # Installer le dépôt Zabbix
        wget -O /tmp/zabbix-release.deb "https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.4-1+${ID}${VERSION_ID}_all.deb" > /dev/null 2>&1
        dpkg -i /tmp/zabbix-release.deb > /dev/null 2>&1
        apt update > /dev/null 2>&1
    fi

    # Vérifier la version d'Ubuntu pour installer l'agent Zabbix approprié
    if [ "$VERSION_ID" == "14.04" ] || [ "$VERSION_ID" == "16.04" ]; then
        # Installer l'agent Zabbix 1
        apt install -y zabbix-agent > /dev/null 2>&1
        agent_version=1
    else
        # Installer l'agent Zabbix 2
        apt install -y zabbix-agent2 zabbix-agent2-plugin-* > /dev/null 2>&1
        agent_version=2
    fi

    # Démarrer l'agent Zabbix et activer le démarrage au boot
    systemctl restart zabbix-agent$agent_version > /dev/null 2>&1
    systemctl enable zabbix-agent$agent_version > /dev/null 2>&1

    # Ouvrir les ports 10050 et 10051
    ufw allow 10050/tcp > /dev/null 2>&1
    ufw allow 10051/tcp > /dev/null 2>&1
    ufw reload > /dev/null 2>&1

    echo ""
    echo -n "Installation de l'agent Zabbix pour Ubuntu-based distributions... [#####..................] 15%"

    # Demander les informations nécessaires pour configurer le fichier /etc/zabbix/zabbix_agent2.conf
    echo ""
    read -p "Server (Tapez l'adresse IP du serveur Zabbix, si vous utilisez un proxy, tapez l'IP du proxy.) : " server
    read -p "ServerActive (Tapez l'adresse IP du serveur Zabbix ou celle du proxy si vous en avez un, spécifiez le port par défaut : 10051.) : " server_active
    read -p "Hostname (Tapez le nom de la machine.) : " hostname
    echo ""
    echo -n "Installation de l'agent Zabbix pour Ubuntu-based distributions... [##########.............] 30%"

    # Configurer le fichier /etc/zabbix/zabbix_agent2.conf
    if [ "$agent_version" == "1" ]; then
        sed -i "s/^Server=.*/Server=$server/" /etc/zabbix/zabbix_agentd.conf
        sed -i "s/^ServerActive=.*/ServerActive=$server_active/" /etc/zabbix/zabbix_agentd.conf
        sed -i "s/^Hostname=.*/Hostname=$hostname/" /etc/zabbix/zabbix_agentd.conf
    else
        sed -i "s/^Server=.*/Server=$server/" /etc/zabbix/zabbix_agent2.conf
        sed -i "s/^ServerActive=.*/ServerActive=$server_active/" /etc/zabbix/zabbix_agent2.conf
        sed -i "s/^Hostname=.*/Hostname=$hostname/" /etc/zabbix/zabbix_agent2.conf
    fi

    echo ""
    echo -n "Installation de l'agent Zabbix pour Ubuntu-based distributions... [#############..........] 50%"

    # Redémarrer l'agent Zabbix pour appliquer les modifications
    systemctl restart zabbix-agent$agent_version > /dev/null 2>&1
    echo ""
    echo -n "Installation de l'agent Zabbix pour Ubuntu-based distributions... [##################.....] 75%"
    echo ""
    echo -n "Installation de l'agent Zabbix pour Ubuntu-based distributions... [#####################..] 90%"
    echo ""
    echo -n "Installation de l'agent Zabbix pour Ubuntu-based distributions... [#######################] 100%"
    echo ""

    # Afficher l'hostname, le DNS name et l'adresse IP de la machine
    echo "Il faut noter ces variables, elles seront demandées sur le serveur Zabbix. Si le port utilisé pour le ServerActive n'est pas celui par défaut, il faudra le spécifier sur le serveur Zabbix."
    echo "---------------------------------------------------------------------------"
    echo "Hostname : $hostname"
    echo "DNS name : $(hostname --fqdn)"
    echo "IP address : $(ip a | grep 'inet ' | grep -v '127.0.0.1' | head -n 1 | awk '{print $2}' | cut -d'/' -f1)"
    echo "---------------------------------------------------------------------------"
}

# Vérifier si la distribution est prise en charge et appeler la fonction correspondante
if [ "$ID" == "centos" ] || [ "$ID" == "rhel" ] || [ "$ID" == "rocky" ]; then
    echo "Installation de l'agent Zabbix pour RedHat-based distributions..."
    install_rhel_agent
elif [ "$ID" == "debian" ]; then
    echo "Installation de l'agent Zabbix pour Debian-based distributions..."
    install_debian_agent
elif [ "$ID" == "ubuntu" ]; then
    echo "Installation de l'agent Zabbix pour Ubuntu-based distributions..."
    install_ubuntu_agent
else
    echo "Erreur : La distribution $ID n'est pas prise en charge."
    exit 1
fi
