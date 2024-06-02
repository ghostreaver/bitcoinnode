## Bitcoin Pruned Node Server

Setup for a server hosting a Bitcoin pruned node on Ubuntu 24.04 server freshly installed.

* * *

#### Change the user password

Change user password

```shell
passwd ${USER}
```

* * *

#### Prepare the environment

Configure APT sources

```shell
sudo add-apt-repository -y main && sudo add-apt-repository -y restricted && sudo add-apt-repository -y universe && sudo add-apt-repository -y multiverse
```

Keep system safe

```shell
sudo apt -y update && sudo apt -y upgrade && sudo apt -y dist-upgrade
sudo apt -y remove && sudo apt -y autoremove
sudo apt -y clean && sudo apt -y autoclean
```

Disable error reporting

```shell
sudo sed -i "s/enabled=1/enabled=0/" /etc/default/apport
```

Edit SSH settings

```shell
sudo sed -i "s/#Port 22/Port 49622/" /etc/ssh/sshd_config
sudo sed -i "s/#LoginGraceTime 2m/LoginGraceTime 2m/" /etc/ssh/sshd_config
sudo sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin no/" /etc/ssh/sshd_config
sudo sed -i "s/#StrictModes yes/StrictModes yes/" /etc/ssh/sshd_config
sudo systemctl restart sshd.service
```

Install prerequisite packages

```shell
sudo apt -y install git build-essential libtool autotools-dev automake pkg-config bsdmainutils python3 libssl-dev libevent-dev libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-test-dev libboost-thread-dev libminiupnpc-dev libzmq3-dev
```

Install Berkeley DB

```shell
sudo apt -y install libdb5.3++-dev
```

Clone the Bitcoin Core repository from GitHub.

```shell
cd /home/ubuntu
git clone https://github.com/bitcoin/bitcoin
```

Build Bitcoin Core

```shell
cd bitcoin
./autogen.sh
./configure --enable-cxx --disable-shared --with-pic --prefix=$PWD/depends/x86_64-pc-linux-gnu
make
```

Build the necessary dependencies

```shell
make -C depends
```

Configure Bitcoin Core with pruning enabled

```shell
./configure --with-incompatible-bdb --enable-upnp-default --disable-wallet --disable-bench --disable-tests --disable-gui-tests --disable-gui --disable-zmq --enable-reduce-exports --enable-debug --enable-hardening --enable-werror --with-gui=no --prefix=/usr/local --mandir=/usr/local/share/man --bindir=/usr/local/bin --libdir=/usr/local/lib --libexecdir=/usr/local/lib --disable-dependency-tracking --with-daemon --with-utils --enable-pruning
```

Build Bitcoin Core with the configuration

```shell
make -j$(nproc)
```

Install Bitcoin Core

```shell
sudo make install
```

Initialize the Bitcoin Core data directory

```shell
bitcoind -daemon
```

Check synchronization progress

```shell
bitcoin-cli getblockchaininfo
```

Reboot server

```shell
sudo reboot now
```

* * *

#### Automated Setup

If you prefer and in order to save time, you can use our deployment script which reproduces all the commands above.

```shell
cd /tmp/ && wget -O - https://raw.githubusercontent.com/neoslab/bitcoinnode/main/install.sh | bash
```

* * *

#### Synchronization

When the synchronization is complete, you can stop Bitcoin Core.

```shell
bitcoin-cli stop
```

Open the Bitcoin configuration file

```shell
nano ~/.bitcoin/bitcoin.conf
```

Add the following line to enable pruning (replace XXXX with the desired size in MB).

```shell
prune=XXXX
```

Start Bitcoin Core again

```shell
bitcoind -daemon
```

* * *

#### Conclusion


Your pruned Bitcoin node should now be running on Ubuntu 22.04. Make sure to keep your node updated regularly and monitor its performance.