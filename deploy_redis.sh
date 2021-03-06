#!/usr/bin/env bash
#
#

# download redis tarball.
if [ -f /usr/bin/wget ];then
  if [ -f /opt/redis-latest.tar.gz ];then
    echo "exists"
  else
    wget -O /opt/redis-latest.tar.gz http://download.redis.io/releases/redis-5.0.3.tar.gz
  fi
else
  yum -y install wget vim
  if [ -f /opt/redis-latest.tar.gz ];then
    echo "exists"
  else
    wget -O /opt/redis-latest.tar.gz http://download.redis.io/releases/redis-5.0.3.tar.gz
  fi
fi

# unzip redis tarball to /opt/ dir.
tar xf /opt/redis-latest.tar.gz -C /opt/

# change directory to /opt/redis-5.0.3.
cd $(ls -ld /opt/redis* | awk -F" " 'NR==1{ print $NF }')

# install depending software.
yum -y groupinstall "Development Tools"

# configure redis.
make

# change dir to src.
cd src/
if [ $? -eq 0 ];then
  make install
fi

# config redis running env.
mkdir -p /usr/local/redis/{conf,bin}
cp $(ls -ld /opt/redis* | awk -F" " 'NR==1{ print $NF }')/redis.conf /usr/local/redis/conf/
cp $(ls -ld /opt/redis* | awk -F" " 'NR==1{ print $NF }')/src/mkreleasehdr.sh /usr/local/redis/bin/
cp $(ls -ld /opt/redis* | awk -F" " 'NR==1{ print $NF }')/src/redis-benchmark /usr/local/redis/bin/
cp $(ls -ld /opt/redis* | awk -F" " 'NR==1{ print $NF }')/src/redis-check-aof /usr/local/redis/bin/
cp $(ls -ld /opt/redis* | awk -F" " 'NR==1{ print $NF }')/src/redis-check-rdb /usr/local/redis/bin/
cp $(ls -ld /opt/redis* | awk -F" " 'NR==1{ print $NF }')/src/redis-cli /usr/local/redis/bin/
cp $(ls -ld /opt/redis* | awk -F" " 'NR==1{ print $NF }')/src/redis-sentinel /usr/local/redis/bin/
cp $(ls -ld /opt/redis* | awk -F" " 'NR==1{ print $NF }')/src/redis-server /usr/local/redis/bin/
cp $(ls -ld /opt/redis* | awk -F" " 'NR==1{ print $NF }')/src/redis-trib.rb /usr/local/redis/bin/

# modify redis.conf daemonize=yes.
if [ -f /usr/bin/ifconfig ];then
  ip=$(ifconfig | awk -F' ' 'NR==2{ print $2 }')
else
  yum -y install net-tools
  ip=$(ifconfig | awk -F' ' 'NR==2{ print $2 }')
fi
sed -ri s/"daemonize no"/"daemonize yes"/g /usr/local/redis/conf/redis.conf
sed -ri s/"bind 127.0.0.1"/"bind $ip"/g /usr/local/redis/conf/redis.conf

# configure enviorment.
echo "export PATH=/usr/local/redis/bin:\$PATH" >>/etc/profile
source /etc/profile







