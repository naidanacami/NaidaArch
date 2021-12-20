#!/usr/bin/env bash
sudo pacman -S lightdm python-gobject python-pyqt5 python-pyqt5-webengine python-xlib python-ruamel-yaml qt5-webengine gobject-introspection        # Web-greeter dependancies
sudo pacman -S rsync zip make pyrcc5 
cd ~
git clone https://github.com/JezerM/web-greeter.git
cd ~/web-greeter
sudo make install