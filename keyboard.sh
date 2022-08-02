#!/bin/bash
#### install osk

apt --fix-broken install -y
apt-get install -f -y # eksik bağımlılıkları tamamlaması için.

cd /tmp
git clone https://gitlab.com/sulincix/gtk-keyboard-osk.git /tmp/gtk-keyboard-osk
cd gtk-keyboard-osk
make install
#rm -rf /tmp/gtk-keyboard-osk