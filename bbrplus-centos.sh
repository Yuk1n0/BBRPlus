#!/usr/bin/env bash
#
# Original Author: cx9208 <https://github.com/cx9208>  Licensed: GPLv3
# Copyright (C) 2019-2020 Yuk1n0

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'
kernel_version="4.14.172"

if [[ ! -f /etc/redhat-release ]]; then
	echo -e "[${red}Error${plain}] Only support Centos..."
	exit 0
fi

if [[ "$(uname -r)" == "${kernel_version}" ]]; then
	echo -e "[${yellow}Warning${plain}] bbrplus kernel has been installed..."
	exit 0
fi

echo -e "[${green}Info${plain}] Checking lotServer..."
sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
if [[ -e /appex/bin/lotServer.sh ]]; then
	echo -e "[${green}Info${plain}] Uninstalling lotServer..."
	wget --no-check-certificate -O appex.sh https://raw.githubusercontent.com/MoeClub/lotServer/master/Install.sh && chmod +x appex.sh && bash appex.sh uninstall
	rm -f appex.sh
fi
echo -e "[${green}Info${plain}] Checking lotServer comlete..."

echo -e "[${green}Info${plain}] Downloading bbrplus kernel..."
wget --no-check-certificate https://github.com/Yuk1n0/BBRPlus/raw/master/x86_64/kernel-${kernel_version}.rpm
wget --no-check-certificate https://github.com/Yuk1n0/BBRPlus/raw/master/x86_64/kernel-headers-${kernel_version}.rpm
echo -e "[${green}Info${plain}] Installing bbrplus kernel..."
yum install -y kernel-headers-${kernel_version}.rpm
yum install -y kernel-${kernel_version}.rpm 

#Check
list="$(awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg)"
target="CentOS Linux (${kernel_version})"
result=$(echo $list | grep "${target}")
if [[ "$result" == "" ]]; then
	echo -e "[${red}Error${plain}] Failed to install bbrplus kernel..."
	exit 1
fi
echo -e "[${green}Info${plain}] Installing bbrplus kernel complete..."

echo -e "[${green}Info${plain}] Switching to new bbrplus kernel..."
grub2-set-default 'CentOS Linux (${kernel_version}) 7 (Core)'
echo -e "[${green}Info${plain}] Enable bbr module..."
echo "net.core.default_qdisc=fq" >>/etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbrplus" >>/etc/sysctl.conf
rm -f kernel-${kernel_version}.rpm
rm -f kernel-headers-${kernel_version}.rpm

while true; do
	read -p "bbrplus installation completed，reboot server now ? [Y/y] :" answer
	[ -z "${answer}" ] && answer="y"
	if [[ $answer == [Yy] ]]; then
		echo -e "[${green}Info${plain}] Rebooting..."
		break
	else
		echo -e "[${red}Error${plain}] Please enter [Y/y] !"
		echo
	fi
done
reboot
