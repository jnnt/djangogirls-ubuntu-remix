#/bin/bash

# Ubuntu - Django Girls Remix

# based on
# http://bazaar.launchpad.net/~timo-jyrinki/ubuntu-fi-remix/main/view/head:/finnish-remix.sh
# Started in 2007 based on https://help.ubuntu.com/community/LiveCDCustomization
# Updated from time to time.
# Ubuntu Trademark Policy requires ”Remix” suffix usage, more info at
# http://www.ubuntu.com/aboutus/trademarkpolicy
# Author: Timo Jyrinki
# Modifications from: Uwe Geuder
#
# License CC-BY-SA 3.0: http://creativecommons.org/licenses/by-sa/3.0/

# provisioning taken from scripts in https://github.com/mohae/packer-templates.git

echo
echo Ubuntu - Django Girls Remix
echo License CC-BY-SA 3.0: http://creativecommons.org/licenses/by-sa/3.0/
echo
echo Only run the commands in this script if you know what you are doing
echo
echo This script is not actually a script, copy-paste certain sections of
echo the file instead - processing stops at eg. moving into chroot.
echo And maybe it is better that way... no error checking of any kind included.
echo
read
exit

sudo apt-get install squashfs-tools syslinux-utils

# You may ignore all extra comment lines.

# Fetching the Ubuntu DVD, or using existing one like done here
export iso_file=lubuntu-16.04-desktop-amd64.iso


# Extracting image and chrooting into it
mkdir mnt
sudo mount -o loop ${iso_file} mnt/
mkdir extract-cd
sudo rsync --exclude=/casper/filesystem.squashfs -a mnt/ extract-cd

# mkdir squashfs
# sudo mount -t squashfs -o loop mnt/casper/filesystem.squashfs squashfs
# mkdir edit
# sudo cp -a squashfs/* edit/

# I've not noticed difference in the end result, cp seems faster
sudo unsquashfs mnt/casper/filesystem.squashfs
sudo mv squashfs-root edit

# chroot mounts
sudo mount --bind /dev/ edit/dev
sudo mount -o bind /run/ edit/run

sudo chroot edit
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devpts none /dev/pts
export HOME=/root
# export LC_ALL=C
export LC_ALL=C.UTF-8
export LANG=C.UTF-8


PATH=$PATH:/sbin:/usr/sbin:/usr/local/sbin
# Update repository information to find current packages
DEBIAN_FRONTEND=noninteractive apt update

# DEBIAN_FRONTEND=noninteractive apt upgrade -y
DEBIAN_FRONTEND=noninteractive apt install -y build-essential libssl-dev libcurl4-gnutls-dev libexpat1-dev gettext
DEBIAN_FRONTEND=noninteractive apt install -y bzip2 curl git rsync tree wget vim emacs
DEBIAN_FRONTEND=noninteractive apt install -y liblz4-tool
# Polish (basic support)
DEBIAN_FRONTEND=noninteractive apt install -y language-pack-pl language-pack-pl-base language-pack-gnome-pl language-pack-gnome-pl-base
#

# i like synapse
DEBIAN_FRONTEND=noninteractive apt install -y synapse

# Enable HTTPS for apt (hm, not needed right now)
DEBIAN_FRONTEND=noninteractive apt install apt-transport-https


# chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
DEBIAN_FRONTEND=noninteractive dpkg -i google-chrome-stable_current_amd64.deb
DEBIAN_FRONTEND=noninteractive apt install -y -f
rm -f google-chrome-stable_current_amd64.deb

# atom
DEBIAN_FRONTEND=noninteractive apt install -y gvfs-bin
curl -L https://atom.io/download/deb > atom-amd64.deb
DEBIAN_FRONTEND=noninteractive dpkg --install atom-amd64.deb
DEBIAN_FRONTEND=noninteractive apt install -y -f
rm -f /home/vagrant/atom-amd64.deb

# gedit
DEBIAN_FRONTEND=noninteractive apt install -y gedit

############# DJANGO GIRLS WORKSHOP RESOURCES
##### python 3.5 #######
DEBIAN_FRONTEND=noninteractive apt install -y python3-venv python3-pip virtualenv libxml2-dev libxslt1-dev
mkdir /usr/share/djangogirls
cd /usr/share/djangogirls
mkdir -p wheelhouse
pip3 wheel Django==1.8 --wheel-dir wheelhouse  # still present in some versions of the tutorial
pip3 wheel Django==1.9 --wheel-dir wheelhouse
pip3 wheel ipython ipdb --wheel-dir wheelhouse

### download tutorial and webpage resources (bootstrap, font)
cd /usr/share/djangogirls
git clone https://github.com/jnnt/djangogirls_usbgenerator.git
cd djangogirls_usbgenerator
python3 -m venv venv
source venv/bin/activate
pip install wheel
pip install -e .
djangogirls_usbgenerator --all-langs --all --skip-apps
mkdir -p tutorial
mv downloads/*.pdf tutorial
mv downloads webtools

cd /usr/share/djangogirls
rm -rf djangogirls_usbgenerator


#############################################################################################
# Cleanups
# copied from provisioning scripts in  https://github.com/mohae/packer-templates.git
############
# references:
#    http://vstone.eu/reducing-vagrant-box-size/
#    https://github.com/mitchellh/vagrant/issues/343
PATH=$PATH:/sbin:/usr/sbin:/usr/local/sbin
DEBIAN_FRONTEND=noninteractive apt install -fy
DEBIAN_FRONTEND=noninteractive apt -y install deborphan
DEBIAN_FRONTEND=noninteractive deborphan | xargs apt purge -y
DEBIAN_FRONTEND=noninteractive apt clean -y
DEBIAN_FRONTEND=noninteractive apt autoclean -y
DEBIAN_FRONTEND=noninteractive apt autoremove -y
DEBIAN_FRONTEND=noninteractive apt purge -y locate

# delete old dev libraries
DEBIAN_FRONTEND=noninteractive dpkg -l | grep -- '-dev' | xargs apt purge -y


# log files
DEBIAN_FRONTEND=noninteractive find /var/log -type f | while read f; do echo -ne '' > $f; done;

# TODO: /var/lib/dpkg/info? it's already populated, not allowed to be cleaned
rm -rf /tmp/*
rm -rf /var/cache/apt-xapian-index/*
rm -rf /var/lib/apt/lists/*
umount /proc
umount /sys
umount /dev/pts
##
## You may want to put the /run/resolvconf/resolv.conf back to zero size now
##
exit
sudo umount edit/dev

# modify some resources
sudo cp resources/casper.conf edit/etc/
sudo cp resources/dg_logo_bg.png edit/usr/share/lubuntu/wallpapers
sudo cp edit/usr/share/lubuntu/wallpapers/lubuntu-default-wallpaper.png edit/usr/share/lubuntu/wallpapers/lubuntu-default-wallpaper-orig.png
# TODO configure wallpaper in /etc/skel
sudo cp edit/usr/share/lubuntu/wallpapers/dg_logo_bg.png edit/usr/share/lubuntu/wallpapers/lubuntu-default-wallpaper.png

sudo mkdir edit/etc/skel/Desktop
sudo cp edit/usr/share/applications/lxterminal.desktop edit/etc/skel/Desktop
sudo cp edit/usr/share/applications/firefox.desktop edit/etc/skel/Desktop
sudo sed -i 's@Exec=firefox %u@Exec=firefox https://tutorial.djangogirls.org@' edit/etc/skel/Desktop/firefox.desktop
sudo cp edit/usr/share/applications/google-chrome.desktop edit/etc/skel/Desktop
sudo sed -i 's@Exec=google-chrome %u@Exec=google-chrome https://tutorial.djangogirls.org@' edit/etc/skel/Desktop/google-chrome.desktop

sudo cp edit/usr/share/applications/leafpad.desktop edit/etc/skel/Desktop
sudo cp edit/usr/share/applications/gedit.desktop edit/etc/skel/Desktop
sudo cp edit/usr/share/applications/atom.desktop edit/etc/skel/Desktop
sudo cp resources/djangogirls-offline-files.desktop edit/etc/skel/Desktop
sudo chmod +x edit/etc/skel/Desktop

# sudo sed -i 's/lubuntu-default-wallpaper.png/dg_logo_bg.png/' edit/etc/lxdm/default.conf

# Re-creation of "manifest" file
sudo -s
chmod +w extract-cd/casper/filesystem.manifest
chroot edit dpkg-query -W --showformat='${Package} ${Version}\n' > extract-cd/casper/filesystem.manifest
# Pack the filesystem
mksquashfs edit extract-cd/casper/filesystem.squashfs
# Create the disk image itself
export output_file=lubuntu-16.04-desktop-amd64-djangogirls-remix.iso
export IMAGE_NAME="Ubuntu 16.04 LTS"
sed -i -e "s/$IMAGE_NAME/$IMAGE_NAME (Django Girls Remix)/" extract-cd/README.diskdefines
sed -i -e "s/$IMAGE_NAME/$IMAGE_NAME (Django Girls Remix)/" extract-cd/.disk/info

cd extract-cd

# Localizing the UEFI boot
# sed -i '6i    loadfont /boot/grub/fonts/unicode.pf2' boot/grub/grub.cfg
# sed -i '7i    set locale_dir=$prefix/locale' boot/grub/grub.cfg
# sed -i '8i    set lang=pl_PL' boot/grub/grub.cfg
# sed -i '9i    insmod gettext' boot/grub/grub.cfg
# sed -i 's%splash%splash locale=pl_PL console-setup/layoutcode=pl%' boot/grub/grub.cfg
# sed -i 's/Try Ubuntu without installing/Wypróbuj Ubuntu bez instalowania/' boot/grub/grub.cfg
# sed -i 's/Install Ubuntu/Zainstaluj Ubuntu/' boot/grub/grub.cfg
# sed -i 's/OEM install (for manufacturers)/Instalacja OEM dla producentów sprzętu/' boot/grub/grub.cfg
# sed -i 's/Check disc for defects/Sprawdź dysk/' boot/grub/grub.cfg
# mkdir -p boot/grub/locale/
# mkdir -p boot/grub/fonts/
# cp -a /boot/grub/locale/pl.mo boot/grub/locale/
# cp -a /boot/grub/fonts/unicode.pf2 boot/grub/fonts/

rm -f md5sum.txt
(find -type f -print0 | xargs -0 md5sum | grep -v isolinux/boot.cat | sudo tee ../md5sum.txt)
mv -f ../md5sum.txt ./
# If the following is not done, causes an error in the boot menu disk check option
sed -i -e '/isolinux/d' md5sum.txt
# Different volume name than the IMAGE_NAME above. On the official image it's of the type Ubuntu 12.04 LTS amd64
export IMAGE_NAME="Ubuntu 16.04 LTS amd64 dg-remix"
# 16.04 LTS
genisoimage -r -V "$IMAGE_NAME" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot -o ../${output_file} .
cd ..
isohybrid --uefi ${output_file}
umount squashfs/
umount mnt/
exit
