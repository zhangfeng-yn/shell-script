#/bin/sh
#更新软件源并升级包
if [ ! -d  /etc/apt/sources.list.bak ];then
  cp /etc/apt/sources.list /etc/apt/sources.list.bak
fi
SOURCES="deb https://mirrors.huaweicloud.com/debian/ buster main contrib non-free
deb https://mirrors.huaweicloud.com/debian/ buster-updates main contrib non-free
deb https://mirrors.huaweicloud.com/debian/ buster-backports main contrib non-free
deb https://mirrors.huaweicloud.com/debian-security/ buster/updates main contrib non-free

deb-src https://mirrors.huaweicloud.com/debian/ buster main contrib non-free
deb-src https://mirrors.huaweicloud.com/debian/ buster-updates main contrib non-free
deb-src https://mirrors.huaweicloud.com/debian/ buster-backports main contrib non-free"
echo "$SOURCES" > /etc/apt/sources.list
apt update & apt upgrade -y

#安装依赖
apt install -y  libtool  cmake  clang-format-8  automake  autoconf  make  ninja-build  curl  unzip  virtualenv

#安装ntp同步时间
apt install -y ntp

#防火墙和selinux
systemctl stop firewalld
systemctl disable firewalld
if [ -d /etc/selinux/config ];then
  sed -i 's/SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
  sed -i 's/SELINUXTYPE=.*/SELINUXTYPE=targeted/' /etc/selinux/config
fi

#转发配置
echo -e "net.bridge.bridge-nf-call-ip6tables = 1\nnet.bridge.bridge-nf-call-iptables = 1\nnet.ipv4.ip_forward = 1" > /etc/sysctl.conf
sysctl --system

#关闭swap
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

#安装依赖
apt install -y yum-utils device-mapper-persistent-data lvm2

#安装docker
curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/debian/gpg | apt-key add -
echo -e "deb https://mirrors.aliyun.com/docker-ce/linux/debian buster stable" > /etc/apt/sources.list.d/docker.list
apt update & install -y docker-ce
echo -e "{\n\t\"exec-opts\": [\"native.cgroupdriver=systemd\"],\n\t\"registry-mirrors\": [\"https://44fgn779.mirror.aliyuncs.com\"]\n}" > /etc/docker/daemon.json
systemctl  daemon-reload
systemctl restart docker

#安装kubernetes
curl -fsSL https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | apt-key add -
echo -e "deb  https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
apt update & install -y kubelet kubeadm kubectl
