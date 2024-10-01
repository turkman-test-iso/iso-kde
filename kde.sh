#!/bin/sh
# enable live
ymp repo --update --ignore-gpg --allow-oem
ymp install shadow audit --no-emerge --allow-oem
ymp install e2fsprogs dialog grub parted dosfstools rsync --no-emerge --allow-oem
rm -f /sbin/init
wget https://gitlab.com/turkman/devel/sources/installer/-/raw/master/main.sh -O /sbin/init
chmod 755 /sbin/init
# install x11
ymp repo --update --allow-oem --ignore-gpg
ymp it xinit xorg-server xterm freetype xauth xkbcomp xkeyboard-config @x11.drivers --no-emerge --allow-oem
ymp it elogind shadow pipewire wireplumber libtool firefox-installer fuse fuse2 --no-emerge --allow-oem
# install kde
ymp it @kde @kde.plasma @kde.frameworks dolphin konsole ark dejavu tzdata --no-emerge --allow-oem --jobs=1
# fstab add tmpfs
echo "tmpfs /tmp tmpfs rw 0 0" > /etc/fstab
ln -s /proc/mounts /etc/mtab
# enable login from shadow
sed -i "s|#agetty_options.*|agetty_options=\" -l /usr/bin/login\"|" /etc/conf.d/agetty
chmod u+s /bin/su /usr/bin/su
# set language
mkdir -p /lib64/locale
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "" >> /etc/locale.gen
echo "export LANG=en_US.UTF-8" > /etc/profile.d/locale.sh
echo "export LC_ALL=en_US.UTF-8" >> /etc/profile.d/locale.sh
locale-gen
# polkit enable
chmod u+s /usr/bin/pkexec /usr/lib64/polkit-1/polkit-agent-helper-1
echo "/bin/bash" > /etc/shells
echo "/bin/sh" >> /etc/shells
echo "/bin/ash" >> /etc/shells
# install wifi and bluetooth
ymp it wpa_supplicant networkmanager bluez --no-emerge --allow-oem
# install lightdm
ymp it sddm --no-emerge --allow-oem
# update hicolor icons
gtk-update-icon-cache /usr/share/icons/hicolor/
# enable services
rc-update add elogind
rc-update add eudev
rc-update add fuse
rc-update add seatd
rc-update add upowerd
rc-update add hostname
rc-update add wpa_supplicant
rc-update add networkmanager
rc-update add sddm
rc-update add bluetooth
rc-update add polkit
ymp clean --allow-oem
# revert hardened bindir
mkdir -p /usr/local/bin
chmod 755 /bin /usr/bin /sbin /usr/sbin /usr/local/bin
# remove static libraries
find / -type f -iname '*.a' -exec rm -f {} \;
exit 0
