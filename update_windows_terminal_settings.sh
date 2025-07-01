#!/bin/bash

# Script pour modifier le fichier settings.json de Windows Terminal depuis WSL
# Par défaut, change le thème en "dark" (modifiable)

# À personnaliser : nom d'utilisateur Windows
USER_WIN="<TON_UTILISATEUR>"

# Chemin du fichier settings.json
SETTINGS="/mnt/c/Users/$USER_WIN/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"

# Vérification de l'existence du fichier
if [ ! -f "$SETTINGS" ]; then
  echo "Fichier settings.json introuvable à l'emplacement : $SETTINGS"
  exit 1
fi

# Sauvegarde de l'original
cp "$SETTINGS" "$SETTINGS.bak"
echo "Sauvegarde créée : $SETTINGS.bak"

# Exemple de modification : changer le thème en 'dark'
# (Tu peux adapter la commande jq selon tes besoins)
jq '.theme = "dark"' "$SETTINGS" > /tmp/settings.json && mv /tmp/settings.json "$SETTINGS"
echo "Thème modifié en 'dark' dans $SETTINGS"

# Fin du script 