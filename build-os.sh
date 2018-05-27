
# Based off https://forum.armbian.com/topic/6850-document-about-compiling-a-kernel-and-rootfs-for-the-firefly-boards/
# Designed to build an Ubuntu 16.04 with tun for VPN

sudo apt install gcc python bc git gcc-arm-linux-gnueabihf gcc-aarch64-linux-gnu device-tree-compiler lzop libncurses5-dev libssl1.0.0 libssl-dev qemu qemu-user-static binfmt-support debootstrap swig libpython-dev mtools pv

mkdir ~/temp
mkdir ~/temp/firefly_build

git clone https://github.com/FireflyTeam/kernel.git
git clone https://github.com/FireflyTeam/build.git
git clone https://github.com/FireflyTeam/rkbin.git
git clone https://github.com/FireflyTeam/u-boot.git

cd kernel
make menuconfig

 

#-------
# Load Config from "arch/arm64/configs/fireflyrk3328_linux_defconfig"
#
# Device Drivers -->
#   Network Device Support --->
#     Universal TUN/TAP device driver support <Mark with an asterisk(*)>
#
# Networking Support --->
#   Networking Options --->
#     Network packet filtering framework (Netfilter) --->
#       Core Netfilter Configuration --->
#         <Mark all options with an asterisk (*)>
#
# Networking Support --->
#   Networking Options --->
#     Network packet filtering framework (Netfilter) --->
#      IP: Net Filter configurations -->
#        <Mark all options with an asterisk (*)>
#
# Save Config to "arch/arm64/configs/fireflyrk3328_linux_defconfig"
#-------

 

cd ..
./build/mk-kernel.sh roc-rk3328-cc
./build/mk-uboot.sh roc-rk3328-cc

mkdir ubuntu_core
install -d ./ubuntu_core/{linux,rootfs,archives/{ubuntu-base,debs,hwpacks},images,scripts}
cd ubuntu_core
wget -P archives/ubuntu-base -c http://cdimage.ubuntu.com/ubuntu-base/releases/16.04.4/release/ubuntu-base-16.04.4-base-arm64.tar.gz

 

dd if=/dev/zero of=images/rootfs.img bs=1M count=0 seek=1000
sudo mkfs.ext4 -F -L ROOTFS images/rootfs.img
# <enter user password>
rm -rf rootfs && install -d rootfs
sudo mount -o loop images/rootfs.img rootfs
sudo rm -rf rootfs/lost+found
sudo tar -xzf archives/ubuntu-base/ubuntu-base-16.04.4-base-arm64.tar.gz -C rootfs/
sudo cp -a /usr/bin/qemu-aarch64-static rootfs/usr/bin/

 

sudo chroot rootfs/
passwd root
# <enter new root password>
# <re-enter new root password>

useradd -G sudo -m -s /bin/bash <new user>
passwd <new user>
# <enter new user password>
# <re-enter new user password>

echo "<hostname>" > /etc/hostname
echo "127.0.0.1    localhost.localdomain localhost" > /etc/hosts
echo "127.0.0.1    <hostname>" >> /etc/hosts
mkdir /etc/network
mkdir /etc/network/interfaces.d
echo "auto eth0" > /etc/network/interfaces.d/eth0
echo "iface eth0 inet dhcp" >> /etc/network/interfaces.d/eth0
echo "nameserver 127.0.1.1" > /etc/resolv.conf

apt update
apt upgrade
apt install ifupdown net-tools sudo ssh iptables openvpn nano unzip

 

exit
sudo sync
# <enter user password>
sudo umount rootfs/

cd ..

 

build/mk-image.sh -c rk3328 -t system -r ubuntu_core/images/rootfs.img
build/flash_tool.sh -c rk3328 -d ubuntu_16.04.4_roc-rk3328-cc_arch64_$(date +%Y%m%d).img -p system -i out/system.img

