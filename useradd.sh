#!/bin/bash

# Prasa ievadit lietotajvardu
read -p "Ievadi lietotāju: " username

# Parbauda vai ievadita vertiba nav tukša
if [ -z "$username" ]; then
    echo "Lietotājs nevar būt tukšs."
    exit 1
fi

# Izveidot lietotāju un ievieto to docker un sudo grupa
sudo adduser $username
sudo usermod -aG sudo $username
sudo usermod -aG docker $username
echo "Lietotājs izveidots un pievienots sudo un docker grupās."
groups $username
# Kopē instalacijas failus uz jaunā lietotāja home direktoriju
echo "Kopēju nepieciešamos instalacijas failus uz jauno lietotāja home direktoriju."
mkdir /home/$username/ltv
cp -r config /home/$username/ltv/
cp README.md /home/$username/ltv/
cp changesitename.sh /home/$username/ltv/
cp install_lavarel.sh /home/$username/ltv/
chown -R $username:$username /home/$username/ltv

su $username -c 'cd ~ && exec bash'
