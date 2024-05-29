#!/bin/bash

# Vérifier si au moins un argument a été fourni
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <chemin_du_dossier_de_l_application> [nom_de_l_executable_avec_extension]"
    exit 1
fi


FULL_PATH=$1
EXECUTABLE=$2
LOGO=""

# Extraire le nom du dernier répertoire dans le chemin complet
APP_DIR=$(basename "$FULL_PATH")

# Vérifier l'existence du répertoire de l'application
if [ ! -d "$FULL_PATH" ]; then
    echo "Le répertoire spécifié n'existe pas."
    exit 1
fi

# Si le nom de l'exécutable n'est pas fourni, utiliser le nom du dossier
if [ -z "$EXECUTABLE" ]; then
    EXECUTABLE=$APP_DIR
fi

# Trouver le logo dans le répertoire de l'application
for file in "$FULL_PATH"/*; do
    if [[ $file == *.svg ]]; then
        LOGO=$(basename "$file")
        break
    fi
done

# Copier le répertoire de l'application dans /opt/
echo "Installation de l'application dans /opt/..."
sudo cp -r "$FULL_PATH" /opt/

# Extraire le nom de base de l'exécutable sans l'extension
EXECUTABLE_NAME=$(echo "$EXECUTABLE" | cut -f 1 -d '.')

# Créer un lien symbolique pour l'exécutable
echo "Création d'un lien symbolique pour l'exécutable..."
sudo ln -s "/opt/$APP_DIR/$EXECUTABLE" "/usr/local/bin/$EXECUTABLE_NAME"

# Créer le fichier .desktop dans le répertoire des applications
DESKTOP_FILE="/usr/share/applications/$EXECUTABLE_NAME.desktop"
echo "Création du fichier $DESKTOP_FILE..."
echo "[Desktop Entry]
Name=$EXECUTABLE_NAME
Comment=$EXECUTABLE_NAME
Exec=$EXECUTABLE_NAME # --no-sandbox, in the case of cursor
Icon=/opt/$APP_DIR/$LOGO
Terminal=false
Type=Application
Categories=Application;" | sudo tee "$DESKTOP_FILE"

# Créer un lien symbolique pour le logo si nécessaire
#if [ -n "$LOGO" ]; then
#    echo "Création d'un lien symbolique pour le logo..."
#    sudo ln -s "/opt/$APP_DIR/$LOGO" "/usr/share/icons/hicolor/scalable/apps/$EXECUTABLE.svg"
#fi

echo "L'installation de $EXECUTABLE est terminée."
