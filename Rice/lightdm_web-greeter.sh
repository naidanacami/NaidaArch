#!/usr/bin/env bash
sudo pacman -S lightdm python-gobject python-pyqt5 python-pyqt5-webengine python-xlib python-ruamel-yaml qt5-webengine gobject-introspection --noconfirm --needed        # Web-greeter dependancies
sudo pacman -S rsync zip make pyrcc5 --noconfirm --needed
yay -S web-greeter
# cd ~
# git clone https://github.com/JezerM/web-greeter.git
# cd ~/web-greeter
# sudo make install