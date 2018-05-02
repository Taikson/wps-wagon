# wps-wagon

Automatic WPS bully tool embedded into a $8 router. Performs WPS attacks to all existing wireless and tries to aumomatically connect to them, and configure DNAT ports inside victim's router using upnpc. It creates a second AP serving internet from victim.

An A5-V11 type router us recommended, but any WiFi OpenWRT capable router is OK. A second WiFi USB dongle is recommended.

Build a custom OpenWRT image following those steps:


sudo apt-get install wget git build-essential libncurses5-dev libncursesw5-dev
zlib1g-dev gawk unzip subversion libssl-dev python netbeans

git clone https://git.lede-project.org/source.git openwrt #clonado repo openwrt

cd openwrt/scripts;

./feeds update -a;

./feeds install -a;

cd ../package;

git clone https://github.com/wiire/pixiewps;

git clone https://github.com/aanarchyy/bully;

cd ..

make defconfig

mkdir files

cd files

mkdir wps_wagon

#*Now Copy all *.sh file into wps_wagon folder*

cd ../../

#*Now Copy .config file into openwrt folder (file valid only for A5-V11 router)*


make menuconfig

#*exit from menu*


make j=4


#*wait a lot

Flash image into router

First run:

Configuration file is settings.sh

Run initial_config.sh

Tool can be launched from ./launch.sh script
