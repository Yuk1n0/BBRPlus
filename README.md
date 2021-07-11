# BBRplus 

## 脚本安装方法：  

一键脚本（全系统）：   
参见https://github.com/chiakge/Linux-NetSpeed   

一键脚本（仅CentOS）：  
```bash
wget --no-check-certificate https://raw.githubusercontent.com/Yuk1n0/BBRPlus/master/bbrplus-centos.sh && chmod +x bbrplus-centos.sh && ./bbrplus-centos.sh
```
安装后，执行uname -r，显示4.14.172则切换内核成功  
执行lsmod | grep bbr，显示有tcp_bbrplus则开启成功   

## 手动安装方法：  
1.  卸载本机的锐速（如果有）  

2.  下载内核  
wget --no-check-certificate https://github.com/Yuk1n0/BBRPlus/raw/master/x86_64/kernel-4.14.172.rpm

3.  安装内核  
yum install -y kernel-4.14.172.rpm  

4.  切换启动内核  
grub2-set-default 'CentOS Linux (4.14.172) 7 (Core)'  

5.  设置fq  
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf  
设置bbrplus  
echo "net.ipv4.tcp_congestion_control=bbrplus" >> /etc/sysctl.conf  

6.  重启  
reboot  

7.  检查内核版本  uname -r  
显示4.14.172则成功  

8.  检查bbrplus是否已经启动  
lsmod | grep bbrplus  显示有tcp_bbrplus则成功  

## 卸载方法：  
安装别的内核bbrplus自动失效，卸载内核自行谷歌即可  

## 内核编译：  

只能用于4.14.x内核，更高版本的tcp部分源码有改动，要移植到高版本内核得自己研究  

**下载内核源码(x更换为自己喜欢的版本号)**   
wget --no-check-certificate https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.14.x.tar.xz   

**解压**  
tar -Jxvf linux-4.14.x.tar.xz

**修改linux-4.14.x/include/net/inet_connection_sock.h，约139行**  
```C++
u64     icsk_ca_priv       [112 / sizeof(u64)];  
#define ICSK_CA_PRIV_SIZE  (14 * sizeof(u64))  
```
这两段数值改为**112**和**14**，如上  

**修改/net/ipv4/tcp_output.c#L，约1823行**  
tcp_snd_wnd_test函数大括号结尾{}后  
换行添加**EXPORT_SYMBOL(tcp_snd_wnd_test);**  

**添加tcp_bbrplus.c到/net/ipv4/，删除/net/ipv4/tcp_bbr.c  
修改linux-4.14.x/net/ipv4/Makefile，  
obj-$(CONFIG_TCP_CONG_BBR) += tcp_bbr.o，将bbr改为bbrplus**  

**安装依赖**  
**Centos**  
yum -y groupinstall Development tools  
yum -y install ncurses-devel bc gcc gcc-c++ ncurses ncurses-devel cmake elfutils-libelf-devel openssl-devel rpm-build redhat-rpm-config asciidoc hmaccalc perl-ExtUtils-Embed xmlto audit-libs-devel binutils-devel elfutils-devel elfutils-libelf-devel newt-devel python-devel zlib-devel  
**Debian**  
wget -qO- git.io/superupdate.sh | bash  
apt-get install build-essential libncurses5-dev  
apt-get build-dep linux  

**切换到目录**  
cd /root/linux-4.14.x  
make menuconfig  
确保CONFIG_TCP_CONG_BBR=m  

**在目录下禁用签名调试**  
scripts/config --disable MODULE_SIG  
scripts/config --disable DEBUG_INFO  

**开始编译**  
Centos：make rpm-pkg  
Debian：make deb-pkg

如果编译遇到没有规则可制作目标“debian/certs/debian-uefi-certs.pem”错误
编辑.config文件将CONFIG_SYSTEM_TRUSTED_KEYS设置为CONFIG_SYSTEM_TRUSTED_KEYS=""
