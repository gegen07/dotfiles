#!/usr/bin/env bash

DIR=$(pwd)
HOMEDIR=$HOME
USERNAME=$(whoami)

SUDO=''
if [ $USERNAME != "root" ]; then
	SUDO="sudo "
fi

which salt-call > /dev/null 2>&1
if [ $? -ne 0 ]; then
	which wget > /dev/null 2>&1
	if [ $? -ne 0 ]; then
		echo "cURL not installed. Installing..."
		$SUDO apt-get -y install wget
	fi

	echo "SaltStack not installed. Installing..."
	wget -O - https://repo.saltstack.com/apt/ubuntu/18.04/amd64/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add -
	deb http://repo.saltstack.com/apt/ubuntu/18.04/amd64/latest bionic main
	sudo apt-get update
	sudo apt-get install salt-minion -y
	#wget -qO- https://bootstrap.saltstack.com | $USE_SUDO sh -s -- -P -d git v2018.11
fi

SSHKEY=id_rsa

$SUDO salt-call --local --config=./ --state-output=changes grains.setvals "{ \"user\": \"$USERNAME\", \"homedir\": \"$HOMEDIR\", \"stateroot\": \"$DIR/states\", \"sshkey\": \"$HOMEDIR/.ssh/$SSHKEY_NAME\", \"oscodename\": \"$(lsb_release -cs)\" }"

if [[ ! $1 ]]; then
	echo "Setting Up all dependencies"
	$SUDO salt-call \
		--local \
		--config=./ \
		--state-output=mixed \
		--retcode-passthrough state.highstate
else
	echo "Update $1"
	$SUDO salt-call \
		--local \
		--config=./ \
		--state-output=mixed \
		--retcode-passthrough state.sls $1
fi
