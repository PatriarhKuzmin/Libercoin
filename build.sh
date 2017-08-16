#!/bin/bash

set -e

date
ps axjf

#################################################################
# Update Ubuntu and install prerequisites for running Libercoin   #
#################################################################
sudo apt-get update
#################################################################
# Build Libercoin from source                                     #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
#################################################################
# Install all necessary packages for building Libercoin           #
#################################################################
sudo apt-get install -y qt4-qmake libqt4-dev libminiupnpc-dev libdb++-dev libdb-dev libcrypto++-dev libqrencode-dev libboost-all-dev build-essential libboost-system-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libssl-dev libdb++-dev libssl-dev ufw git
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev

cd /usr/local
file=/usr/local/libercoinX
if [ ! -e "$file" ]
then
        sudo git clone https://github.com/libercoinproject/libercoinX.git
fi

cd /usr/local/libercoinX/src
file=/usr/local/libercoinX/src/libercoind
if [ ! -e "$file" ]
then
        sudo make -j$NPROC -f makefile.unix
fi

sudo cp /usr/local/libercoinX/src/libercoind /usr/bin/libercoind

################################################################
# Configure to auto start at boot                                      #
################################################################
file=$HOME/.libercoin
if [ ! -e "$file" ]
then
        sudo mkdir $HOME/.libercoin
fi
printf '%s\n%s\n%s\n%s\n' 'daemon=1' 'server=1' 'rpcuser=u' 'rpcpassword=p' | sudo tee $HOME/.libercoin/libercoin.conf
file=/etc/init.d/libercoin
if [ ! -e "$file" ]
then
        printf '%s\n%s\n' '#!/bin/sh' 'sudo libercoind' | sudo tee /etc/init.d/libercoin
        sudo chmod +x /etc/init.d/libercoin
        sudo update-rc.d libercoin defaults
fi

/usr/bin/libercoind
echo "Libercoin has been setup successfully and is running..."
exit 0

