#!/bin/bash

# =========================
# Script de déploiement d'application
# Prend en charge : --install, --check, --repair, --update
# =========================

APP_NAME="MonApp"
CONFIG_FILE="/etc/monapp/monapp.conf"
LOG_FILE="/var/log/monapp_deploy.log"

# Crée le dossier de log si besoin
touch "$LOG_FILE" 2>/dev/null || sudo touch "$LOG_FILE"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

usage() {
    echo "Usage : $0 [--install|--check|--repair|--update]"
    exit 1
}

check_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        log "Fichier de configuration absent. Création..."
        sudo mkdir -p "$(dirname $CONFIG_FILE)"
        sudo bash -c "cat > $CONFIG_FILE" <<EOF
# Configuration de $APP_NAME
env=production
version=1.0.0
EOF
    fi
    log "Fichier de configuration OK."
}

install_app() {
    log "Début de l'installation de $APP_NAME..."
    check_config
    # Exemple d'installation de dépendances
    sudo apt-get update && sudo apt-get install -y nginx curl
    # Déploiement fictif
    sudo touch /usr/local/bin/monapp
    sudo chmod +x /usr/local/bin/monapp
    echo -e "#!/bin/bash\necho '$APP_NAME lancé !'" | sudo tee /usr/local/bin/monapp > /dev/null
    log "$APP_NAME installé avec succès."
}

check_app() {
    log "Vérification de l'état de $APP_NAME..."
    if [ -f /usr/local/bin/monapp ]; then
        log "$APP_NAME est installé."
    else
        log "$APP_NAME n'est PAS installé."
        return 1
    fi
    # Vérification de la config
    if grep -q 'env=production' "$CONFIG_FILE"; then
        log "Configuration correcte."
    else
        log "Configuration incorrecte."
        return 2
    fi
    return 0
}

repair_app() {
    log "Tentative de réparation de $APP_NAME..."
    check_config
    if [ ! -f /usr/local/bin/monapp ]; then
        log "Binaire absent, réinstallation..."
        install_app
    fi
    # Réparation de la config
    if ! grep -q 'env=production' "$CONFIG_FILE"; then
        log "Correction de la configuration..."
        sudo sed -i 's/^env=.*/env=production/' "$CONFIG_FILE"
    fi
    log "Réparation terminée."
}

update_app() {
    log "Mise à jour de $APP_NAME..."
    # Exemple de mise à jour fictive
    sudo sed -i 's/^version=.*/version=1.0.1/' "$CONFIG_FILE"
    log "$APP_NAME mis à jour en version 1.0.1."
}

# =========================
# Gestion des arguments
# =========================

if [ $# -ne 1 ]; then
    usage
fi

case "$1" in
    --install)
        install_app
        ;;
    --check)
        check_app
        ;;
    --repair)
        repair_app
        ;;
    --update)
        update_app
        ;;
    *)
        usage
        ;;
esac 