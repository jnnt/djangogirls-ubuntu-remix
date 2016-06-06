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

sudo apt-get install squashfs-tools

# You may ignore all extra comment lines.

# Fetching the Ubuntu DVD, or using existing one like done here
export iso_file=lubuntu-16.04-desktop-amd64.iso

### prepare resources to copy


# Extracting image and chrooting into it
mkdir mnt
sudo mount -o loop ${iso_file} mnt/
mkdir extract-cd
sudo rsync --exclude=/casper/filesystem.squashfs -a mnt/ extract-cd
mkdir squashfs
sudo mount -t squashfs -o loop mnt/casper/filesystem.squashfs squashfs
mkdir edit
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
export LC_ALL=C

# Installing the wanted language support, optionally first removing non-wanted
# packages. We're far beyond 700MB limit anyway, the next sensible limit to
# keep under is 1GB (so that fits on 1GB USB memory).
#apt-get remove --purge language-pack-bn language-pack-bn-base language-pack-gnome-bn language-pack-gnome-bn-base language-pack-es language-pack-es-base language-pack-gnome-es language-pack-gnome-es-base language-pack-pt language-pack-pt-base language-pack-gnome-pt language-pack-gnome-pt-base language-pack-xh language-pack-xh-base language-pack-gnome-xh language-pack-gnome-xh-base language-pack-hi language-pack-hi-base language-pack-gnome-hi language-pack-gnome-hi-base language-pack-de language-pack-de-base language-pack-fr language-pack-fr-base language-pack-gnome-de language-pack-gnome-de-base language-pack-gnome-fr language-pack-gnome-fr-base firefox-locale-bn firefox-locale-de firefox-locale-es firefox-locale-pt language-pack-gnome-zh-hans language-pack-gnome-zh-hans-base language-pack-zh-hans language-pack-zh-hans-base firefox-locale-zh-hans

# BEGIN XXX THIS IS THE ONLY NON-COPYPASTEABLE PART OF THIS FILE XXX
#
# You may need (read: you do need) to add "nameserver 8.8.8.8" to the file
# /run/resolvconf/resolv.conf temporarily. Preferably remove the line to
# restore original (empty) content afterwards.
#
# END   XXX THIS IS THE ONLY NON-COPYPASTEABLE PART OF THIS FILE XXX

PATH=$PATH:/sbin:/usr/sbin:/usr/local/sbin
# Update repository information to find current packages
DEBIAN_FRONTEND=noninteractive apt update

DEBIAN_FRONTEND=noninteractive apt upgrade -y
DEBIAN_FRONTEND=noninteractive apt install -y build-essential libssl-dev libcurl4-gnutls-dev libexpat1-dev gettext
DEBIAN_FRONTEND=noninteractive apt install -y bzip2 curl git rsync tree wget vim
DEBIAN_FRONTEND=noninteractive apt install -y liblz4-tool
# Polish (basic support)
DEBIAN_FRONTEND=noninteractive apt install -y language-pack-pl language-pack-pl-base language-pack-gnome-pl language-pack-gnome-pl-base
#

DEBIAN_FRONTEND=noninteractive apt install -y vim emacs
# install git
DEBIAN_FRONTEND=noninteractive apt install -y git

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
dpkg --install atom-amd64.deb
DEBIAN_FRONTEND=noninteractive apt install -y -f
rm -f /home/vagrant/atom-amd64.deb

# gedit
DEBIAN_FRONTEND=noninteractive apt install -y gedit

############# DJANGO GIRLS WORKSHOP RESOURCES
##### python 3.5 #######
DEBIAN_FRONTEND=noninteractive apt install -y python3-venv python3-pip virtualenv
mkdir /usr/share/djangogirls
cd /usr/share/djangogirls
mkdir wheelhouse
pip3 wheel Django==1.8 --wheel-dir wheelhouse  # still present in some versions of the tutorial
pip3 wheel Django==1.9 --wheel-dir wheelhouse
pip3 wheel ipython ipdb --wheel-dir wheelhouse

### download tutorial and webpage resources (bootstrap, font)
cd /usr/share/djangogirls
git clone https://github.com/jnnt/djangogirls_usbgenerator.git
cd djangogirls_usbgenerator
python3 -m venv venv
source venv/bin/activate
pip install -e .
djangogirls_usbgenerator --all-langs --all --skip-apps
mkdir ../tutorial && cd ../tutorial
mv ../djangogirls_usbgenerator/downloads/*.pdf .
mkdir ../webtools && cd ../webtools
mv ../djangogirls_usbgenerator/downloads/* .
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

# the history isn't needed
DEBIAN_FRONTEND=noninteractive unset HISTFILE
DEBIAN_FRONTEND=noninteractive rm -f /root/.bash_history
DEBIAN_FRONTEND=noninteractive rm -f /home/vagrant/.bash_history

# log files
DEBIAN_FRONTEND=noninteractive find /var/log -type f | while read f; do echo -ne '' > $f; done;

echo 'Whiteout root'
DEBIAN_FRONTEND=noninteractive count=`df --sync -kP / | tail -n1  | awk -F ' ' '{print $4}'`;
DEBIAN_FRONTEND=noninteractive count=$((count-1))
DEBIAN_FRONTEND=noninteractive dd if=/dev/zero of=/tmp/whitespace bs=1024 count=$count;
DEBIAN_FRONTEND=noninteractive rm /tmp/whitespace;

echo 'Whiteout /boot'
DEBIAN_FRONTEND=noninteractive count=`df --sync -kP /boot | tail -n1 | awk -F ' ' '{print $4}'`;
DEBIAN_FRONTEND=noninteractive count=$((count-1))
DEBIAN_FRONTEND=noninteractive dd if=/dev/zero of=/boot/whitespace bs=1024 count=$count;
DEBIAN_FRONTEND=noninteractive rm /boot/whitespace;

DEBIAN_FRONTEND=noninteractive swappart=`cat /proc/swaps | tail -n1 | awk -F ' ' '{print $1}'`
DEBIAN_FRONTEND=noninteractive swapoff $swappart;
DEBIAN_FRONTEND=noninteractive dd if=/dev/zero of=$swappart;
DEBIAN_FRONTEND=noninteractive mkswap $swappart;
DEBIAN_FRONTEND=noninteractive swapon $swappart;

# zero all empty space
DEBIAN_FRONTEND=noninteractive dd if=/dev/zero of=/EMPTY bs=1M
DEBIAN_FRONTEND=noninteractive rm -f /EMPTY

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

# setting default language
# 16.04 LTS: seems broken (for legacy boot mode), no known solution. English is still the default.
echo fi | sudo tee extract-cd/isolinux/lang

# Translating Examples desktop icon in live mode LP: #441986 -> FIXED

# Re-creation of "manifest" file
sudo -s
chmod +w extract-cd/casper/filesystem.manifest
chroot edit dpkg-query -W --showformat='${Package} ${Version}\n' > extract-cd/casper/filesystem.manifest
# 10+ packages are not part of the finished installation
# earlier it was tried to recreate filesystem.manifest-desktop
# but that caused too many packages to get installed
# (of which at least casper caused side effects ie ramzswap)
# Trial & error with Lucid 10.04.1 lead to using the original
# filesystem.manifest-desktop without changes, which works!
# (apparently the language support system takes care of the
# changed packages)
#
# Pack the filesystem
mksquashfs edit extract-cd/casper/filesystem.squashfs
# Create the disk image itself
export output_file=ubuntu-16.04-desktop-amd64-finnishremix.iso
#export IMAGE_NAME="Ubuntu 12.04 LTS \"Precise Pangolin\""
export IMAGE_NAME="Ubuntu 16.04 LTS"
sed -i -e "s/$IMAGE_NAME/$IMAGE_NAME (Finnish Remix)/" extract-cd/README.diskdefines
sed -i -e "s/$IMAGE_NAME/$IMAGE_NAME (Finnish Remix)/" extract-cd/.disk/info
# NOTE: 14.04.3 official amd64 image has "Beta", one can change that to "Release"

cd extract-cd
# Localizing the UEFI boot
sed -i '6i    loadfont /boot/grub/fonts/unicode.pf2' boot/grub/grub.cfg
sed -i '7i    set locale_dir=$prefix/locale' boot/grub/grub.cfg
sed -i '8i    set lang=fi_FI' boot/grub/grub.cfg
sed -i '9i    insmod gettext' boot/grub/grub.cfg
sed -i 's%splash%splash locale=fi_FI console-setup/layoutcode=fi%' boot/grub/grub.cfg
sed -i 's/Try Ubuntu without installing/Kokeile Ubuntua asentamatta/' boot/grub/grub.cfg
sed -i 's/Install Ubuntu/Asenna Ubuntu/' boot/grub/grub.cfg
sed -i 's/OEM install (for manufacturers)/OEM-asennus (laitevalmistajille)/' boot/grub/grub.cfg
sed -i 's/Check disc for defects/Tarkista asennusmedian eheys/' boot/grub/grub.cfg
mkdir -p boot/grub/locale/
mkdir -p boot/grub/fonts/
cp -a /boot/grub/locale/fi.mo boot/grub/locale/
cp -a /boot/grub/fonts/unicode.pf2 boot/grub/fonts/

rm -f md5sum.txt
(find -type f -print0 | xargs -0 md5sum | grep -v isolinux/boot.cat | sudo tee ../md5sum.txt)
mv -f ../md5sum.txt ./
# If the following is not done, causes an error in the boot menu disk check option
sed -i -e '/isolinux/d' md5sum.txt
# Different volume name than the IMAGE_NAME above. On the official image it's of the type Ubuntu 12.04 LTS amd64
export IMAGE_NAME="Ubuntu 16.04 LTS amd64 fi"
# 14.04 LTS
#mkisofs -r -V "$IMAGE_NAME" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o ../${output_file} .
# 16.04 LTS
genisoimage -r -V "$IMAGE_NAME" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot -o ../${output_file} .
cd ..
isohybrid --uefi ${output_file}
umount squashfs/
umount mnt/
exit



# not in use, a more difficult way of setting the default language in boot menu
## apt source gfxboot-theme-ubuntu gfxboot dpkg-dev
## apt-get build-dep gfxboot-theme-ubuntu
## cd gfxboot-theme-ubuntu*/
## make DEFAULT_LANG=fi
## sudo cp -a boot/* ../extract-cd/isolinux/
## sudo cp -a langlist ../extract-cd/isolinux/
