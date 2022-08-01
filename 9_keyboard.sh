#!/bin/bash
#### install osk

chroot chroot apt --fix-broken install -y
chroot chroot apt-get install -f -y # eksik bağımlılıkları tamamlaması için.
echo "kurulacak***************************************************************"
chroot chroot apt install git wget gir1.2-gtk-3.0 console-setup python3-gi python3-pip usbutils tzdata python3-dev -y
chroot chroot pip3 install pynput
#chroot chroot cd chroot/tmp
chroot chroot git clone https://gitlab.com/sulincix/gtk-keyboard-osk.git /tmp/gtk-keyboard-osk
#chroot chroot cd gtk-keyboard-osk
chroot chroot make install
#chroot chroot rm -rf /tmp/gtk-keyboard-osk