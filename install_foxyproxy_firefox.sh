#!/bin/bash

# Script pour installer FoxyProxy dans un profil Firefox-ESR existant sans interaction graphique

# 1. Détecter le profil par défaut
PROFILE_PATH=$(grep 'Path=' ~/.mozilla/firefox/profiles.ini | grep default | head -n1 | cut -d'=' -f2)
if [ -z "$PROFILE_PATH" ]; then
  echo "Profil Firefox par défaut non trouvé. Création en cours..."
  # Lancer puis fermer Firefox-ESR pour forcer la création du profil
  firefox-esr &
  sleep 5
  pkill firefox-esr
  sleep 2
  # Re-détecter le profil
  PROFILE_PATH=$(grep 'Path=' ~/.mozilla/firefox/profiles.ini | grep default | head -n1 | cut -d'=' -f2)
  if [ -z "$PROFILE_PATH" ]; then
    echo "Échec de la création du profil Firefox."
    exit 1
  fi
fi
FULL_PROFILE_PATH="$HOME/.mozilla/firefox/$PROFILE_PATH"

# 2. Télécharger l'extension FoxyProxy
wget -O /tmp/foxyproxy.xpi "https://addons.mozilla.org/firefox/downloads/latest/foxyproxy-standard/latest.xpi"
if [ $? -ne 0 ]; then
  echo "Échec du téléchargement de FoxyProxy."
  exit 2
fi

# 3. Copier l'extension dans le dossier extensions du profil
mkdir -p "$FULL_PROFILE_PATH/extensions"
cp /tmp/foxyproxy.xpi "$FULL_PROFILE_PATH/extensions/foxyproxy@eric.h.jung.xpi"

# 4. Message de succès
echo "FoxyProxy a été installé dans le profil : $FULL_PROFILE_PATH"
echo "Redémarre Firefox-ESR pour activer l'extension."

# -----------------------------------------------------------------------------
# SECTION : Exporter la configuration de FoxyProxy sans ouvrir le navigateur
# -----------------------------------------------------------------------------

# Dossier d'export (à personnaliser)
EXPORT_DIR="$HOME/foxyproxy_export"

# Chemin du dossier de configuration FoxyProxy
FOXYPROXY_DATA_DIR="$FULL_PROFILE_PATH/browser-extension-data/foxyproxy@eric.h.jung"

# Créer le dossier d'export si besoin
mkdir -p "$EXPORT_DIR"

# Exporter les fichiers de configuration s'ils existent
if [ -d "$FOXYPROXY_DATA_DIR" ]; then
  cp "$FOXYPROXY_DATA_DIR"/* "$EXPORT_DIR/"
  echo "Configuration FoxyProxy exportée dans $EXPORT_DIR/"
else
  echo "Aucune configuration FoxyProxy trouvée à exporter."
fi

# -----------------------------------------------------------------------------
# SECTION : Récupérer la version de l'extension FoxyProxy téléchargée
# -----------------------------------------------------------------------------

VERSION=$(unzip -p /tmp/foxyproxy.xpi manifest.json | grep '"version"' | head -1 | cut -d':' -f2 | tr -d '", ')
echo "Version de FoxyProxy téléchargée : $VERSION" 