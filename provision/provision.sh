#!/bin/bash
echo "Provisioning Galileo box"
apt-get install -y build-essential gcc-multilib vim-common uuid-dev iasl subversion git autoconf diffstat gawk chrpath texinfo
useradd builder -d /home/builder -m -s /bin/bash
su - builder -c 'git config --global user.name "Galileo Builder"'
su - builder -c 'git config --global user.email builder@galileo.light-source.net'
su - builder -c 'git clone https://github.com/smartmachine/Galileo-Runtime.git'
su - builder -c 'cd Galileo-Runtime ; tar xvf patches_v1.0.4.tar.gz ; tar xvf meta-clanton_v1.0.1.tar.gz ; ./patches_v1.0.4/patch.meta-clanton.sh'
