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
	wget -O - https://repo.saltstack.com/apt/ubuntu/18.04/amd64/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add -
	deb http://repo.saltstack.com/apt/ubuntu/18.04/amd64/latest bionic main
	sudo apt-get update
	sudo apt-get install salt-minion -y
fi

SSHKEY=id_rsa

$SUDO salt-call --local --config=./ --state-output=changes grains.setvals 	"{ \"user\": \"$USERNAME\", \"homedir\": \"$HOMEDIR\", \"stateroot\": \"$DIR/states\", \"sshkey\": \"$HOMEDIR/.ssh/$SSHKEY_NAME\", \"oscodename\": \"$(lsb_release -cs)\" }"

function download_fonts {
	echo "Installing FiraCode and Fira Code NerdFonts"
	wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Meslo.zip
	unzip Meslo.zip -d ~/.local/share/fonts

	wget https://github.com/tonsky/FiraCode/releases/download/5.2/Fira_Code_v5.2.zip
	unzip Fira_Code_v5.2.zip -d ~/.local/share/fonts

	fc-cache -fv
	echo "Done!"
}

if [[ ! $1 ]]; then
	echo "Setting Up all dependencies"
	$SUDO salt-call \
		--local \
		--config=./ \
		--state-output=mixed \
		--retcode-passthrough state.highstate
else
	if [[ $1 == 'fonts' ]]; then
		download_fonts
	else
		echo "Update $1"
		$SUDO salt-call \
			--local \
			--config=./ \
			--state-output=mixed \
			--retcode-passthrough state.sls $1
	fi
fi


