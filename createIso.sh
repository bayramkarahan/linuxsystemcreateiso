#!/bin/bash
#set -e
#### Check root
if [[ ! $UID -eq 0 ]] ; then
    echo -e "\033[31;1mYou must be root!\033[:0m"
    exit 1
fi
#### Remove all environmental variable
for e in $(env | sed "s/=.*//g") ; do
    unset "$e" &>/dev/null
done

#### Set environmental variables
export PATH=/bin:/usr/bin:/sbin:/usr/sbin
export LANG=C
export SHELL=/bin/bash
export TERM=linux
export DEBIAN_FRONTEND=noninteractive

#### Install dependencies
if which apt &>/dev/null && [[ -d /var/lib/dpkg && -d /etc/apt ]] ; then
    apt-get update
    apt-get install curl mtools squashfs-tools grub-pc-bin grub-efi xorriso debootstrap -y
#    # For 17g package build
#    apt-get install git devscripts equivs -y
fi

#set -ex
#### Chroot create
mkdir chroot  # || true


##### For debian
debootstrap --arch=amd64 --no-merged-usr sid chroot https://deb.debian.org/debian
echo 'deb https://deb.debian.org/debian sid main contrib non-free' > chroot/etc/apt/sources.list

#### Set root password
pass="live"
echo -e "$pass\n$pass\n" | chroot chroot passwd

#### Fix apt & bind
# apt sandbox user root
echo "APT::Sandbox::User root;" > chroot/etc/apt/apt.conf.d/99sandboxroot
for i in dev dev/pts proc sys; do mount -o bind /$i chroot/$i; done
chroot chroot apt-get install gnupg -y



git clone https://gitlab.com/ggggggggggggggggg/17g
cd 17g
mk-build-deps --install
debuild -us -uc -b
cd ..

cp 17g-installer_1.0_all.deb chroot/tmp
cp installer chroot/usr/bin/installer
cp installergui chroot/usr/bin/installergui

#### grub packages
#chroot chroot apt-get dist-upgrade -y
chroot chroot apt-get install grub-pc-bin grub-efi-ia32-bin grub-efi -y

#### live packages for debian/devuan
chroot chroot apt-get install live-config live-boot -y
echo "DISABLE_DM_VERITY=true" >> chroot/etc/live/boot.conf

#### Configure system
cat > chroot/etc/apt/apt.conf.d/01norecommend << EOF
APT::Install-Recommends "0";
APT::Install-Suggests "0";
EOF

# Set sh as bash inside of dash (optional)
rm -f chroot/bin/sh
ln -s bash chroot/bin/sh

#### Remove bloat files after dpkg invoke (optional)
cat > chroot/etc/apt/apt.conf.d/02antibloat << EOF
#DPkg::Post-Invoke {"rm -rf /usr/share/locale || true";};
DPkg::Post-Invoke {"rm -rf /usr/share/man || true";};
DPkg::Post-Invoke {"rm -rf /usr/share/help || true";};
DPkg::Post-Invoke {"rm -rf /usr/share/doc || true";};
DPkg::Post-Invoke {"rm -rf /usr/share/info || true";};
EOF


#### liquorix kernel
curl https://liquorix.net/liquorix-keyring.gpg | chroot chroot apt-key add -
echo "deb http://liquorix.net/debian testing main" > chroot/etc/apt/sources.list.d/liquorix.list
chroot chroot apt-get update -y
chroot chroot apt-get install linux-image-liquorix-amd64 -y
chroot chroot apt-get install linux-headers-liquorix-amd64 -y

#### stock kernel 
#chroot chroot apt-get install linux-image-amd64 -y
#chroot chroot apt-get install linux-headers-amd64 -y

chroot chroot apt-get install xorg xinit -y
chroot chroot apt-get install lightdm -y # giriş ekranı olarak lightdm yerine istediğinizi kurabilirsiniz.
chroot chroot apt-get install xfce4 -y

chroot chroot apt-get install bluez-firmware firmware-amd-graphics firmware-atheros \
      firmware-b43-installer firmware-b43legacy-installer firmware-bnx2 \
      firmware-bnx2x firmware-brcm80211 firmware-cavium firmware-intel-sound \
      firmware-intelwimax firmware-ipw2x00 firmware-ivtv firmware-iwlwifi \
      firmware-libertas firmware-linux firmware-linux-free firmware-linux-nonfree \
      firmware-misc-nonfree firmware-myricom firmware-netxen firmware-qlogic \
      firmware-ralink firmware-realtek firmware-samsung firmware-siano \
      firmware-ti-connectivity firmware-zd1211 zd1211-firmware -y

chroot chroot dpkg -i /tmp/17g-installer_1.0_all.deb # dosya adını uygun şekilde yazınız.
chroot chroot apt --fix-broken install -y
chroot chroot apt-get install -f -y # eksik bağımlılıkları tamamlaması için.

#cp config.yaml chroot/lib/live-installer/configs/config.yaml
#cp config_fullscreen.yaml chroot/lib/live-installer/configs/config_fullscreen.yaml


chroot chroot apt-get install network-manager-gnome gvfs-backends pavucontrol chromium vlc -y
chroot chroot apt-get install zip unzip sudo -y

#### language settings (Turkish)
echo "tr_TR.UTF-8 UTF-8" > chroot/etc/locale.gen
echo "LANG=tr_TR.UTF-8" > chroot/etc/default/locale
echo "Europe/Istanbul" > chroot/etc/timezone
chroot chroot timedatectl set-timezone Europe/Istanbul || true
ln -s ../usr/share/zoneinfo/Europe/Istanbul chroot/etc/localtime
cat > chroot/etc/X11/xorg.conf.d/10-keyboard.conf << EOF
Section "InputClass"
Identifier "system-keyboard"
MatchIsKeyboard "on"
Option "XkbLayout" "tr"
Option "XkbModel" "pc105"
#Option "XkbVariant" "f"
EndSection
EOF
chroot chroot locale-gen

#### xorg & desktop pkgs
#chroot chroot apt-get install xorg xserver-xorg xinit -y

#### Install lightdm (for lxde and xfce only)
#chroot chroot apt-get install lightdm lightdm-gtk-greeter -y

#### Install lxde-gtk3
#echo "deb https://raw.githubusercontent.com/lxde-gtk3/binary-packages/master stable main" > chroot/etc/apt/sources.list.d/lxde-gtk3.list
#curl https://raw.githubusercontent.com/lxde-gtk3/binary-packages/master/dists/stable/Release.key | chroot chroot apt-key add -
#chroot chroot apt-get update
#chroot chroot apt-get install lxde-core xdg-utils -y

#### Install xfce
#chroot chroot apt-get install xfce4 xfce4-goodies -y

#### Install gnome
#chroot chroot apt-get install gnome-core -y

#### Install kde
#chroot chroot apt-get install kde-plasma-desktop kwin-x11 -y


#### Usefull stuff
#chroot chroot apt-get install network-manager-gnome pulseaudio -y
#chroot chroot apt-get install network-manager xterm -y

#### Run chroot shell
#chroot chroot /bin/bash || true

### Remove sudo (optional)
chroot chroot apt purge sudo -y
chroot chroot apt autoremove -y

#### Clear logs and history
chroot chroot apt-get clean
rm -f chroot/root/.bash_history
rm -rf chroot/var/lib/apt/lists/*
find chroot/var/log/ -type f | xargs rm -f

#### Create squashfs
mkdir -p liveiso/boot || true
for dir in dev dev/pts proc sys ; do
    while umount -lf -R chroot/$dir 2>/dev/null ; do true; done
done
# For better installation time
mksquashfs chroot filesystem.squashfs -comp gzip -wildcards
# For better compress ratio
##mksquashfs chroot filesystem.squashfs -comp xz -wildcards

mkdir -p liveiso/live || true
#ln -s live liveiso/casper || true #for ubuntu 
mv filesystem.squashfs liveiso/live/filesystem.squashfs

#### Copy kernel and initramfs (Debian/Devuan)
cp -pf chroot/boot/initrd.img-* liveiso/boot/initrd.img
cp -pf chroot/boot/vmlinuz-* liveiso/boot/vmlinuz

#### Write grub.cfg
mkdir -p liveiso/boot/grub/
echo 'menuentry "Live GNU/Linux 64-bit" --class liveiso {' > liveiso/boot/grub/grub.cfg
echo '    linux /boot/vmlinuz boot=live quiet live-config --' >> liveiso/boot/grub/grub.cfg
echo '    initrd /boot/initrd.img' >> liveiso/boot/grub/grub.cfg
echo '}' >> liveiso/boot/grub/grub.cfg

echo 'menuentry "Installer GNU/Linux 64-bit" --class liveiso {' >> liveiso/boot/grub/grub.cfg
echo '    linux /boot/vmlinuz boot=live quiet init=/usr/bin/installer --' >> liveiso/boot/grub/grub.cfg
echo '    initrd /boot/initrd.img' >> liveiso/boot/grub/grub.cfg
echo '}' >> liveiso/boot/grub/grub.cfg

echo 'menuentry "Installer Graphic Screen GNU/Linux 64-bit" --class liveiso {' >> liveiso/boot/grub/grub.cfg
echo '    linux /boot/vmlinuz boot=live quiet init=/usr/bin/installergui --' >> liveiso/boot/grub/grub.cfg
echo '    initrd /boot/initrd.img' >> liveiso/boot/grub/grub.cfg
echo '}' >> liveiso/boot/grub/grub.cfg

#### Create iso
grub-mkrescue liveiso -o liveiso-gnulinux-$(date +%s).iso
