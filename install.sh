# Script to convert Libre Computer xUbuntu 14.04 desktop image to server

# Linux image here http://share.loverpi.com/board/libre-computer-project/libre-computer-board-roc-rk3328-cc/image/ubuntu/
# update
sudo apt-get update

# install the 'tasksel' package so we can remove the desktop image       
sudo apt-get install tasksel

# remove the desktop image
sudo tasksel remove ubuntu-desktop
# remove lightdm
sudo apt-get purge lightdm
# remove remaining x11 libraries
# these get re-added later, some dependacy to check out
#sudo apt-get remove --purge libx11-6 libx11-data libxau6 libxdmcp6 libxext6 libxml2 libxmuu1
sudo apt-get remove --purge chromium-codecs-ffmpeg-extra xubuntu-docs

# remove all packages no longer required
sudo apt-get --purge autoremove

# purge out configurations no longer needed
sudo apt purge $(dpkg --get-selections | grep deinstall | cut -f 1)

# Install GDebi which can fetch packages missing
sudo apt install gdebi-core wget

# Get meta package for Rockchip RK3328 Ubuntu
# More info for building it: https://github.com/palladius/debian-packages/tree/master/palladius-ubuntu-desktop
wget https://github.com/Kyrth/roc-rk3328-jeos/raw/master/roc-rk3328-server_1.333_arm64.deb
sudo gdebi roc-rk3328-server_1.333_arm64.deb

# Ensure SSHD running
sudo systemctl enable ssh.service

# install openvpn
sudo apt install openvpn resolvconf
sudo apt install ca-certificates # just incase

# make sure everything is updated
sudo apt dist-upgrade

# clean out archives
sudo apt clean

# reboot and pray!
sudo reboot
