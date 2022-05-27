#!/usr/bin/env bash
# yay -S ly --noconfirm
# sudo systemctl enable ly.service

sudo pacman -S --needed --noconfirm lightdm lightdm-webkit2-greeter lightdm-webkit-theme-litarvan
sudo sed -i '/greeter-session=/c\greeter-session=lightdm-webkit2-greeter' /etc/lightdm/lightdm.conf
sudo sed -i "s/# webkit_theme/# webkit_tmp_theme/" /etc/lightdm/lightdm-webkit2-greeter.conf
sudo sed -i "/webkit_theme/c\webkit_theme = litarvan" /etc/lightdm/lightdm-webkit2-greeter.conf
sudo sed -i "s/# webkit_tmp_theme/# webkit_theme/" /etc/lightdm/lightdm-webkit2-greeter.conf

sudo systemctl enable lightdm.service
