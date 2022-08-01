#!/bin/bash
chroot chroot apt-get install network-manager-gnome gvfs-backends pavucontrol chromium chromium-l10n vlc -y
chroot chroot apt-get install zip unzip sudo -y

#Tab key parameters listing
chroot chroot apt-get install bash-completion -y

#### Usefull stuff
#chroot chroot apt-get install network-manager-gnome pulseaudio -y
#chroot chroot apt-get install network-manager xterm -y
