#!/usr/bin/env bash

echo "Display manager:"
echo 'Install "ly" or "lightdm"?'
while true; do
    read -p '"ly", "lightdm": ' dm
# https://stackoverflow.com/questions/2264428/how-to-convert-a-string-to-lower-case-in-bash
    dm="$dm" | awk '{print tolower($0)}'
    case $dm in
    ly )        
            yay -S ly --noconfirm
            sudo systemctl enable ly.service
            break
    ;;
    lightdm )   
            sudo pacman -S --needed --noconfirm lightdm lightdm-webkit2-greeter lightdm-webkit-theme-litarvan
            sudo sed -i '/greeter-session=/c\greeter-session=lightdm-webkit2-greeter' /etc/lightdm/lightdm.conf
            sudo sed -i "s/# webkit_theme/# webkit_tmp_theme/" /etc/lightdm/lightdm-webkit2-greeter.conf
            sudo sed -i "/webkit_theme/c\webkit_theme = litarvan" /etc/lightdm/lightdm-webkit2-greeter.conf
            sudo sed -i "s/# webkit_tmp_theme/# webkit_theme/" /etc/lightdm/lightdm-webkit2-greeter.conf
            sudo systemctl enable lightdm.service
            break
    ;;
    *)
        echo "Invalid input!"
    ;;
    esac
done
