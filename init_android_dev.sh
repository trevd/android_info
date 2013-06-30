#!/bin/bash
#
# This script will initialize an android build environment
# for use with the AOSP, Cyanogenmod Project, Ubuntu Touch
#
# Script has been tested with lubuntu 12.10 and 13.04
# Should be functional on any debian based Linux
#
#

SH=$(readlink /bin/sh)
BASH=$( which bash )


# trap ctrl-c and call ctrl_c()
trap ctrl_c INT

function ctrl_c() {
        echo "** Trapped CTRL-C"
        exit
}

function print_status(){
        
        echo "init_android_dev:$1"
        
        
        
        
}

if [ "$SH" != "$BASH" ] ; then

        
        print_status "Updating shell symlink to bash"
        sudo rm /bin/sh
        sudo ln -s $BASH /bin/sh
fi
echo -e "Android Developement Environment Initialization Script\nFor Debian Based Linux Distributions"

if [ "$1" != "noapt" ] ; then

# Ubuntu archive repositories which contain the sun-java-jdk's
# NOTE: The Official AOSP setup documentation is incorrect 
# All three repositories are required, regardless of whether you want
# to install the java5-jdk or not

# Remove the repos first, this should avoid a buildup of the same repo
# should the script be run multiple times


echo -e "Installing Packages\nAdding Required Repositories"
           
sudo add-apt-repository --remove --yes "deb http://archive.canonical.com/ lucid partner"
sudo add-apt-repository --remove --yes "deb http://archive.ubuntu.com/ubuntu hardy main multiverse"
sudo add-apt-repository --remove --yes "deb http://archive.ubuntu.com/ubuntu hardy-updates main multiverse"

sudo add-apt-repository "deb http://archive.canonical.com/ lucid partner"
sudo add-apt-repository "deb http://archive.ubuntu.com/ubuntu hardy main multiverse"
sudo add-apt-repository "deb http://archive.ubuntu.com/ubuntu hardy-updates main multiverse"
echo "Ubuntu archive respositories added for official sun java jdk version 5 & 6"

# webupd8 ppa repositories for new / alternative java apt repositories
sudo add-apt-repository --remove --yes ppa:webupd8team/java
sudo add-apt-repository --yes ppa:webupd8team/java
echo "Webupd8 respository added for official oracle java jdk version 6, 7 & 8"

# Ubuntu Touch Developer Preview Tools PPA 
sudo add-apt-repository --remove --yes ppa:phablet-team/tools
sudo add-apt-repository --yes ppa:phablet-team/tools
echo "Ubuntu Touch Developer Preview Tools repository added"
# Update 
echo "Running apt-get update"
sudo apt-get --yes update
sleep 2
echo "Killing Previous dpkg instances"
sudo pkill -9 dpkg

# Install both jdk's you never know when you might need to build Pre Gingerbread
echo -e "Installing Java\nInstalling sun-java5-jdk" 
sudo apt-get --yes install sun-java5-jdk
sleep 2
echo "Installing sun-java6-jdk" 
sudo apt-get --yes install sun-java6-jdk 
sleep 2
# Install java 7 from wepupd8
echo "Auto Accepting Oracle License"
sudo echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections -v
sleep 2
echo "Installing oracle-java7-installer" 
sudo apt-get --yes  install oracle-java7-installer

# Baseline AOSP Tool List
# Note: Again Ignoring any official documentation which suggests installing
# architecture based packages ( ending in :i386 ) this is insanity if
# you want a coherant system after 6 months or need to build anything other
# than Android

# Instead of i386 packages we get the multi-arch compatible 32* versions
echo "Install Required 32bit libraries"
sudo apt-get --yes install lib32ncurses5-dev lib32readline6-dev lib32z1-dev

# The build-essential packages contains a list of packages essential for building
# debian but not really! see the package information for further details
# This list contains the following:
# base-files base-passwd bash bsdutils coreutils dash debianutils diffutils dpkg
# e2fsprogs findutils grep gzip hostname libc-bin login mount ncurses-base ncurses-bin
# perl-base sed tar util-linux
# Additional the following development packages are installed
# bison         - LALR to C - context free grammar parser
# libc6-dev     - Standard C Library headers
# g++-multilib  - GNU C++ compiler with support for the non-default architecture
#                 In simple terms allow compiling of 32bit binaries on 64bit systems
# mingw32       - A Linux hosted win32 cross compiler, used if you need to compile
#               - the windows version of the sdk
echo "Installing Build Essential MetaPackage"
sudo apt-get --yes install build-essential 

echo "Installing Cross Compilers and Multilib Utils"
sudo apt-get --yes install libc6-dev g++-multilib mingw32 mingw-w64

sudo apt-get --yes install git-core gnupg flex bison  gperf  \
  curl  libx11-dev  libgl1-mesa-glx x11proto-core-dev \
  libgl1-mesa-dev tofrodos python-markdown \
  libxml2-utils xsltproc 

## Ubuntu Touch Recommended Tools 
## phablet-tools        - This contains the following programs 
## phablet-demo-setup phablet-dev-bootstrap  phablet-network-setup  
## phablet-test-run phablet-flash repo
echo "Installing Recommended Ubuntu Touch Development Tools"
sudo apt-get ---yes install phablet-tools android-tools-adb android-tools-fastboot \
schedtool ubuntu-dev-tools

## Additional Tools
# lzop          - Required if you want to enable lzo compression when building a kernel
#                 as part of a Cyanogenmod installation
echo "Installing lzop lzma zip xz archive support"
sudo apt-get install lzop zip xz-utils zlib1g-dev
 
fi
shift
echo "Creating udev [ /etc/udev/rules.d/51-android.rules ] rules for known android devices"
# Create a 51-android.rules for udev - using all known vendors
sudo sh -c "echo '
# /etc/udev/rules.d/51-android.rules - generated by init_android_dev.sh
# sudo udevadm control --reload-rules

# Acer - Vendorid 0x0502 
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"0502\", MODE=\"0666\", GROUP=\"plugdev\"
# Archos - Vendorid 0xe79
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"0e79\", MODE=\"0666\", GROUP=\"plugdev\"
# Asus - Vendorid 0x0b05 
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"0b05\", MODE=\"0666\", GROUP=\"plugdev\"
# Dell - Vendorid 0x413c
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"413c\", MODE=\"0666\", GROUP=\"plugdev\"
# Foxconn - Vendorid 0x0489
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"0489\", MODE=\"0666\", GROUP=\"plugdev\"
# Fujitsu/Fujitsu Toshiba - Vendorid 0x04c5
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"04c5\", MODE=\"0666\", GROUP=\"plugdev\"
# Garmin-Asus - Vendorid 0x091e
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"091e\", MODE=\"0666\", GROUP=\"plugdev\"
# Google - Vendorid 0x18d1
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"18d1\", MODE=\"0666\", GROUP=\"plugdev\"
# Hisense - Vendorid 0x109b
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"109b\", MODE=\"0666\", GROUP=\"plugdev\"
# HTC - Vendorid 0x0bb4
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"0bb4\", MODE=\"0666\", GROUP=\"plugdev\"
# Huawei - Vendorid 0x12d1
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"12d1\", MODE=\"0666\", GROUP=\"plugdev\"
# Intel - Vendorid 0x8087
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"8087\", MODE=\"0666\", GROUP=\"plugdev\"
# K-Touch - Vendorid 0x24e3
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"24e3\", MODE=\"0666\", GROUP=\"plugdev\"
# KT Tech - Vendorid 0x2116
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"2116\", MODE=\"0666\", GROUP=\"plugdev\"
# Kyocera - Vendorid 0x-482
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"0482\", MODE=\"0666\", GROUP=\"plugdev\"
# Lab126 ( Amazon )   - Vendorid 0x1949
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"1949\", MODE=\"0666\", GROUP=\"plugdev\"
# Lenovo  - Vendorid 0x17ef
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"17ef\", MODE=\"0666\", GROUP=\"plugdev\"
# Lenovo Mobile  - Vendorid 0x2006
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"2006\", MODE=\"0666\", GROUP=\"plugdev\"
# LG - Vendorid 0x1004
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"1004\", MODE=\"0666\", GROUP=\"plugdev\"
# Motorola - Vendorid 0x22b8
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"22b8\", MODE=\"0666\", GROUP=\"plugdev\"
# NEC - Vendorid 0x0409
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"0409\", MODE=\"0666\", GROUP=\"plugdev\"
# Nook - Vendorid 0x2080
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"2080\", MODE=\"0666\", GROUP=\"plugdev\"
# Nvida - Vendorid 0x0955
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"0955\", MODE=\"0666\", GROUP=\"plugdev\"
# OTGV - Vendorid 0x2257
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"2257\", MODE=\"0666\", GROUP=\"plugdev\"
# Pantech - Vendorid 0x10a9
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"10a9\", MODE=\"0666\", GROUP=\"plugdev\"
# Pegatron - Vendorid 0x1d4f
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"1d4d\", MODE=\"0666\", GROUP=\"plugdev\"
# Philips - Vendorid 0x0471
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"0471\", MODE=\"0666\", GROUP=\"plugdev\"
# Panasonic Mobile Communications -Sierra - Vendorid 0x04da
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"04da\", MODE=\"0666\", GROUP=\"plugdev\"
# Qualcomm - Vendorid 0x05c6
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"05c6\", MODE=\"0666\", GROUP=\"plugdev\"
# SK Telesys - Vendorid 0x5c6
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"1f53\", MODE=\"0666\", GROUP=\"plugdev\"
# Samsung - Vendorid 0x04e8
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"04e8\", MODE=\"0666\", GROUP=\"plugdev\"
# Sharp - Vendorid 0x04dd
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"04dd\", MODE=\"0666\", GROUP=\"plugdev\"
# Sony - Vendorid 0x054c
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"054c\", MODE=\"0666\", GROUP=\"plugdev\"
# Sony Ericsson - Vendorid 0x0fce
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"0fce\", MODE=\"0666\", GROUP=\"plugdev\"
# Teleepoch - Vendorid 0x2340
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"2340\", MODE=\"0666\", GROUP=\"plugdev\"
# Texas Instruments - Vendorid 0x0451
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"0451\", MODE=\"0666\", GROUP=\"plugdev\"
# Toshiba - Vendorid 0x0930
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"0930\", MODE=\"0666\", GROUP=\"plugdev\"
# ZTE - Vendorid 0x19d2
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"19d2\", MODE=\"0666\", GROUP=\"plugdev\"
# Rokchip 3066 Mk809ii - Vendorid 0x2207
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"2207\", MODE=\"0666\", GROUP=\"plugdev\"' \
> /etc/udev/rules.d/51-android.rules"

# Restart udev so we can get busy straight away
echo "Reloading udev rules"
sudo udevadm control --reload-rules

if [ ! -f /usr/bin/repo ] ; then 
        # download the repo tool if needed
        echo "Downloading repo"
        sudo sh -c "curl https://dl-ssl.google.com/dl/googlesource/git-repo/repo > /usr/bin/repo"
        sudo chmod 755 /usr/bin/repo
fi
