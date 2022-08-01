#!/bin/bash

git clone https://gitlab.com/ggggggggggggggggg/17g
cd 17g
mk-build-deps --install
debuild -us -uc -b
cd ..
cp 17g-installer_1.0_all.deb chroot/tmp
cp installer chroot/usr/bin/installer
cp installergui chroot/usr/bin/installergui

chroot chroot dpkg -i /tmp/17g-installer_1.0_all.deb # dosya adını uygun şekilde yazınız.
chroot chroot apt --fix-broken install -y
chroot chroot apt-get install -f -y # eksik bağımlılıkları tamamlaması için.

#cp config.yaml chroot/lib/live-installer/configs/config.yaml
#cp config_fullscreen.yaml chroot/lib/live-installer/configs/config_fullscreen.yaml
