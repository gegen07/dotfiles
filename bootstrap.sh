#!/usr/bin/env bash

DIR=$(pwd)
HOMEDIR=$HOME
USERNAME=$(whoami)

SUDO=''
if [ $USERNAME != "root" ]; then
	SUDO="sudo "
fi

which wget > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "cURL not installed. Installing..."
	$SUDO apt-get -y install wget
fi

which unzip > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "unzip not installed. Installing..."
	$SUDO apt-get -y install unzip
fi

which salt-call > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "SaltStack not installed. Installing..."
	
	sudo curl -fsSL -o /usr/share/keyrings/salt-archive-keyring.gpg https://repo.saltproject.io/py3/ubuntu/20.04/amd64/3004/salt-archive-keyring.gpg | sudo apt-key add -
	echo "deb [signed-by=/usr/share/keyrings/salt-archive-keyring.gpg arch=amd64] https://repo.saltproject.io/py3/ubuntu/20.04/amd64/3004 focal main" | sudo tee /etc/apt/sources.list.d/salt.list
	sudo apt-get update
	sudo apt-get install salt-minion -y
fi

SSHKEY=id_rsa

$SUDO salt-call --local --config=./ --state-output=changes grains.setvals 	"{ \"user\": \"$USERNAME\", \"homedir\": \"$HOMEDIR\", \"stateroot\": \"$DIR/states\", \"sshkey\": \"$HOMEDIR/.ssh/$SSHKEY_NAME\", \"oscodename\": \"$(lsb_release -cs)\" }"

if [[ ! $1 ]]; then
	echo "Setting Up all dependencies"
	$SUDO salt-call \
		--local \
		--config=./ \
		--state-output=mixed \
		--retcode-passthrough state.highstate
else
	if [[ $1 == 'fonts' ]]; then
		echo "Installing FiraCode and Fira Code NerdFonts"
		
		wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Meslo.zip
		unzip Meslo.zip -d ~/.local/share/fonts
		
		wget https://github.com/tonsky/FiraCode/releases/download/5.2/Fira_Code_v5.2.zip
		unzip Fira_Code_v5.2.zip -d ~/.local/share/fonts
		
		fc-cache -fv
		echo "Done!"
	else
		echo "Update $1"
		$SUDO salt-call \
			--local \
			--config=./ \
			--state-output=mixed \
			--retcode-passthrough state.sls $1
	fi
fi


