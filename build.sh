#!/bin/bash

set -e

date
ps axjf

#################################################################
# Update Ubuntu and install prerequisites for running Maignatum   #
#################################################################
sudo apt-get update
#################################################################
# Build Maignatum from source                                     #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
#################################################################
# Install all necessary packages for building Maignatum           #
#################################################################
sudo apt-get install -y qt4-qmake libqt4-dev libminiupnpc-dev libdb++-dev libdb-dev libcrypto++-dev libqrencode-dev libboost-all-dev build-essential libboost-system-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libssl-dev libdb++-dev libssl-dev ufw git
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev

cd /usr/local
file=/usr/local/maignatumX
if [ ! -e "$file" ]
then
        sudo git clone https://github.com/maignatumproject/maignatumX.git
fi

cd /usr/local/maignatumX/src
file=/usr/local/maignatumX/src/maignatumd
if [ ! -e "$file" ]
then
        sudo make -j$NPROC -f makefile.unix
fi

sudo cp /usr/local/maignatumX/src/maignatumd /usr/bin/maignatumd

################################################################
# Configure to auto start at boot                                      #
################################################################
file=$HOME/.maignatum
if [ ! -e "$file" ]
then
        sudo mkdir $HOME/.maignatum
fi
printf '%s\n%s\n%s\n%s\n' 'daemon=1' 'server=1' 'rpcuser=u' 'rpcpassword=p' | sudo tee $HOME/.maignatum/maignatum.conf
file=/etc/init.d/maignatum
if [ ! -e "$file" ]
then
        printf '%s\n%s\n' '#!/bin/sh' 'sudo maignatumd' | sudo tee /etc/init.d/maignatum
        sudo chmod +x /etc/init.d/maignatum
        sudo update-rc.d maignatum defaults
fi

/usr/bin/maignatumd
echo "Maignatum has been setup successfully and is running..."
exit 0

