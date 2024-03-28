#!/bin/bash

## Change user password
## --------------------
passwd ${USER}

## Configure APT sources
## ---------------------
sudo add-apt-repository -y main && sudo add-apt-repository -y restricted && sudo add-apt-repository -y universe && sudo add-apt-repository -y multiverse

## Keep system safe
## ----------------
sudo apt-get -y update && sudo apt-get -y upgrade && sudo apt-get -y dist-upgrade
sudo apt-get -y remove && sudo apt-get -y autoremove
sudo apt-get -y clean && sudo apt-get -y autoclean

## Disable error reporting
## -----------------------
sudo sed -i "s/enabled=1/enabled=0/" /etc/default/apport

## Edit SSH settings
## -----------------
sudo sed -i "s/#Port 22/Port 49622/" /etc/ssh/sshd_config
sudo sed -i "s/#LoginGraceTime 2m/LoginGraceTime 2m/" /etc/ssh/sshd_config
sudo sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin no/" /etc/ssh/sshd_config
sudo sed -i "s/#StrictModes yes/StrictModes yes/" /etc/ssh/sshd_config
sudo systemctl restart sshd.service

## Install prerequisite packages
## -----------------------------
sudo apt-get -y install git build-essential libtool autotools-dev automake pkg-config bsdmainutils python3 libssl-dev libevent-dev libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-test-dev libboost-thread-dev libminiupnpc-dev libzmq3-dev

## Install Berkeley DB
## -------------------
sudo apt-get -y install libdb5.3++-dev

## Clone the Bitcoin Core repository from GitHub.
cd /home/ubuntu
git clone https://github.com/bitcoin/bitcoin

## Build Bitcoin Core
## ------------------
cd bitcoin
./autogen.sh
./configure --enable-cxx --disable-shared --with-pic --prefix=$PWD/depends/x86_64-pc-linux-gnu
make

## Build the necessary dependencies
## --------------------------------
make -C depends

## Configure Bitcoin Core with pruning enabled
## -------------------------------------------
./configure --with-incompatible-bdb --enable-upnp-default --disable-wallet --disable-bench --disable-tests --disable-gui-tests --disable-gui --disable-zmq --enable-reduce-exports --enable-debug --enable-hardening --enable-werror --with-gui=no --prefix=/usr/local --mandir=/usr/local/share/man --bindir=/usr/local/bin --libdir=/usr/local/lib --libexecdir=/usr/local/lib --disable-dependency-tracking --with-daemon --with-utils --enable-pruning

## Build Bitcoin Core with the configuration
## -----------------------------------------
make -j$(nproc)

## Install Bitcoin Core
## --------------------
sudo make install

## Initialize the Bitcoin Core data directory
## ------------------------------------------
bitcoind -daemon

## Check synchronization progress
## ------------------------------
bitcoin-cli getblockchaininfo