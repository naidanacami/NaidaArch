#!/usr/bin/env bash

# ------------- XDG specification -------------
if [ ! -d "~/.icons/default/" ]; then
    mkdir -p ~/.icons/default/
fi

if [ ! -f "~/.icons/default/index.theme" ]; then
    touch ~/.icons/default/index.theme
    cat <<EOF >~/.icons/default/index.theme
[icon theme] 
Inherits=phinger-cursors
EOF
else
    cp ~/.icons/default/index.theme ~/.icons/default/index.theme.old
    sed -i '/Inherits=/c\Inherits=phinger-cursors' ~/.icons/default/index.theme 
fi


# ------------- GTK -------------
if [ ! -d "~/.config/gtk-3.0/" ]; then
    mkdir -p ~/.config/gtk-3.0/
fi

if [ ! -f "~/.config/gtk-3.0/settings.ini" ]; then
    touch ~/.config/gtk-3.0/settings.ini
    cat <<EOF >~/.config/gtk-3.0/settings.ini
[Settings]
gtk-cursor-theme-name=phinger-cursors
EOF
else
    cp ~/.icons/default/index.theme ~/.icons/default/index.theme.old
    sed -i '/gtk-cursor-theme-name=/c\gtk-cursor-theme-name=phinger-cursors' ~/.icons/default/index.theme 
fi
