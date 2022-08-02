#!/bin/bash
#################### environment setting
source ./1_init.sh
#################### createsystem
source ./2_createsystem.sh
#################### meb sertifikası
source ./3_0_sertifika.sh
#################### kernel install
source ./3_kernel.sh
#################### firmware install
source ./4_firmware.sh
#################### 17g install
source ./5_17g.sh
#################### language settings (Turkish)
source ./6_language.sh
#################### xorg install (gui)
source ./7_xorg.sh
#################### packagex86_64 install
source ./8_package_x86_64.sh
#################### install osk keyboard
source ./9_keyboard.sh
#################### Set root password
pass="live"
echo -e "$pass\n$pass\n" | chroot chroot passwd
#################### purge unmount clean command
source ./19_purge_unmount.sh
#################### create live iso
source ./20_liveiso.sh
