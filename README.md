# NaidaArch

This is a install script to setup my prefered arch linux setup using the i3 window manager



# Install guide:
---
```
pacman -Sy git
git clone https://github.com/naidanacami/NaidaArch.git
cd NaidaArch
chmod +x ./NaidaArch.sh
./NaidaArch.sh
```
There will then be several prompts, ending with disk format confirmation.
After the script is done, 
```
arch-chroot /mnt
passwd --yourPassword--
exit
reboot
```



# Post Install
---
- You will have to make your own swapfile. 
- Flexibility to install on a different drive (SSD integrity)
- I'm lazy

- Run post install script (WIP) (Not yet implemented)

WIP
