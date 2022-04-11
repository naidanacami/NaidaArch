#!/usr/bin/env bash
# yay -S ly --noconfirm
# sudo systemctl enable ly.service

pacman -S --needed --noconfirm lightdm lightdm-webkit2-greeter lightdm-webkit-theme-litarvan
sed -i '/greeter-session=/c\greeter-session=lightdm-webkit2-greeter' /etc/lightdm/lightdm.conf
sed -i '/# webkit-theme/# webk_tmp_it-theme' /etc/lightdm/lightdm-webkit2-greeter.conf
sed -i '/webkit-theme/c\webkit-theme=litarvan' /etc/lightdm/lightdm-webkit2-greeter.conf
sed -i '/# webk_tmp_it-theme/# webkit-theme' /etc/lightdm/lightdm-webkit2-greeter.conf

sudo systemctl enable lightdm.service
