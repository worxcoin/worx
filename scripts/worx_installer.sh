#!/bin/bash

SCRIPTVER=3.0.2
CONFIG_FILE='worx.conf'
CONFIGFOLDER=$(eval echo $HOME/.worx)
CFFULLPATH=$(eval echo $CONFIGFOLDER/$CONFIG_FILE)
COIN_DAEMON='worxd'
COIN_CLI='worx-cli'
COIN_PATH='/usr/local/bin/'
COIN_GIT='https://github.com/WorxCoin/worx.git'
COIN_BACKUP='~/WorxBackup'
COIN_TGZ=''
COIN_BOOTSTRAP_URL='https://worxcoin.io/'
COIN_BOOTSTRAP_HASH=''
COIN_ZIP=$(echo $COIN_TGZ | awk -F'/' '{print $NF}')
COIN_NAME='Worx'
COIN_PORT=3300
RPC_PORT=31313
COIN_CLI_COMMAND=$(eval echo $COIN_PATH$COIN_CLI)
COIND_COMMAND=$(eval echo $COIN_PATH$COIN_DAEMON)
STARTCMD=$(eval echo $COIND_COMMAND -daemon -conf=$CFFULLPATH -datadir=$CONFIGFOLDER)
STOPCMD=$(eval echo $COIN_CLI_COMMAND -conf=$CFFULLPATH -datadir=$CONFIGFOLDER stop)
PFile=$(eval echo $CONFIGFOLDER/$COIN_NAME.pid)

NODEIP=$(curl -s4 icanhazip.com)
WHITE="\033[0;37m"
BLUE="\033[0;34m"
YELLOW="\033[0;33m"
CYAN="\033[0;36m"
PURPLE="\033[0;35m"
RED='\033[0;31m'
GREEN="\033[0;32m"
NC='\033[0m'
Off='\E[0m'
Bold='\E[1m'
Dim='\E[2m'
Underline='\E[4m'
Blink='\E[5m'
Reverse='\E[7m'
Strike='\E[9m'
FgBlack='\E[39m'
FgRed='\E[31m'
FgGreen='\E[32m'
FgYellow='\E[33m'
FgBlue='\E[34m'
FgMagenta='\E[35m'
FgCyan='\E[36m'
FgWhite='\E[37m'
BgBlack='\E[40m'
BgRed='\E[41m'
BgGreen='\E[42m'
BgYellow='\E[43m'
BgBlue='\E[44m'4
BgMagenta='\E[45m'
BgCyan='\E[46m'
BgWhite='\E[47m'
FgLtBlack='\E[90m'
FgLtRed='\E[91m'
FgLtGreen='\E[92m'
FgLtYellow='\E[93m'
FgLtBlue='\E[94m'
FgLtMagenta='\E[95m'
FgLtCyan='\E[96m'
FgLtWhite='\E[97m'
BgLtBlack='\E[100m'
BgLtRed='\E[101m'
BgLtGreen='\E[102m'
BgLtYellow='\E[103m'
BgLtBlue='\E[104m'
BgLtMagenta='\E[105m'
BgLtCyan='\E[106m'
BgLtWhite='\E[107m'


function purgeOldInstallation() {
    echo -e "${GREEN}Searching and removing old $COIN_NAME files and configurations and making a backup to $HOME/WorxBackup if they exist ${NC}"
    if [[ -f $(eval echo $CONFIGFOLDER/wallet.dat) ]]; then
    echo -e "Exists, making backup${NC}" 
if [[ ! -d $(eval echo $COIN_BACKUP) ]]; then    
mkdir $(eval echo $COIN_BACKUP)
fi
    cp  $(eval echo $CFFULLPATH $COIN_BACKUP ) 2> /dev/null
    cp  $(eval echo $CONFIGFOLDER/masternode.conf $COIN_BACKUP ) 2> /dev/null
    cp $(eval echo $CONFIGFOLDER/wallet.dat $COIN_BACKUP ) 2> /dev/null
fi 

    #kill wallet daemon
    systemctl stop $COIN_NAME.service > /dev/null 2>&1
    sudo killall $COIN_DAEMON > /dev/null 2>&1
	# Save Key 
	OLDKEY=$(awk -F'=' '/masternodeprivkey/ {print $2}' $CFFULLPATH 2> /dev/null)
	if [[ $OLDKEY ]]; then
    		echo -e "${CYAN}Saving Old Installation Genkey ${WHITE} $OLDKEY"
	fi
    #remove old ufw port allow
    sudo ufw delete allow $COIN_PORT/tcp > /dev/null 2>&1
    #remove old files
    sudo rm -rf $CONFIGFOLDER > /dev/null 2>&1
    sudo rm -rf /usr/local/bin/$COIN_CLI /usr/local/bin/$COIN_DAEMON> /dev/null 2>&1
    sudo rm -rf /usr/bin/$COIN_CLI /usr/bin/$COIN_DAEMON > /dev/null 2>&1
    sudo rm -rf /tmp/*
    mkdir $CONFIGFOLDER
    sudo rm -rf ~/worx    
echo -e "${GREEN}* Done${NONE}";
}


function memorycheck() {

echo -e "${GREEN}Checking Memory${NC}"
FREEMEM=$(free -m |sed -n '2,2p' |awk '{ print $4 }')
SWAPS=$(free -m |tail -n1 |awk '{ print $2 }')

if [[ $FREEMEM -lt 3096 ]]; then 
	if [[ $SWAPS -eq 0 ]]; then
		echo -e "${GREEN}Adding swap${NC}"
		fallocate -l 2G /swapfile
		chmod 600 /swapfile
		mkswap /swapfile
		swapon /swapfile
		cp /etc/fstab /etc/fstab.bak
		echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
	else
		echo -e "Got ${WHITE}$SWAPS${GREEN} swap"
		if [[ $SWAPS -lt 2046 ]]; then
			echo -e "${YELLOW}But thats less than what we want, so increasing swap to correct size to allow compile to succeed"
			ADDSWAPS=$((2048 - $SWAPS))
			if [[ $ADDSWAPS -lt 1024 ]]; then 
				ADDSWAPS=1024
			fi
			fallocate -l $ADDSWAPS /swapfile2
			chmod 600 /swapfile2
			mkswap /swapfile2
			swapon /swapfile2
			cp /etc/fstab /etc/fstab.bak
			echo '/swapfile2 none swap sw 0 0' | sudo tee -a /etc/fstab
		fi 
		echo -e "${WHITE}And thats enough swap that compile should work"
	fi
	else
	echo -e "Enough free ram available for compile to succeed, not checking swap"
fi 
}

function download_node() {
  echo -e "${GREEN}Downloading and Installing VPS $COIN_NAME Daemon${NC}"
  echo -e "${GREEN}Installing Dependencies${NC}"
apt update > /dev/null 2>&1
apt-get install git automake build-essential libtool autotools-dev autoconf pkg-config omake cmake libssl-dev nano wget curl gzip -y > /dev/null 2>&1
cd ~

  echo -e "${GREEN}Git'ing source${NC}"
git clone $COIN_GIT > /dev/null 2>&1
cd worx
  echo -e "${GREEN}Configuring Source${NC}"

./autogen.sh > /dev/null 2>&1
./configure > /dev/null 2>&1
  echo -e "${GREEN}Compiling Wallet Binaries${NC}"
echo -e "${WHITE}    ___ _                       __    __      _ _   "
echo -e "${WHITE}   / _ \ | ___  __   ___  ___  / / /\ \ \__  (_) |_ "
echo -e "${WHITE}  / /_)/ |/ _ \/ _\ / __|/ _ \ \ \/  \/ / _\ | | __|"
echo -e "${WHITE} / ___/| |  __/ (_|_\__ \  __/  \  /\  / (_|_| | |_ "
echo -e "${WHITE} \/    |_|\___|\__,_|___/\___|   \/  \/ \__,_|_|\__|"
echo -e "                                             ${GREEN}This could take a few minutes..."
echo -e "                                                           "
echo -e "                                             ${RED}Or 10..."
echo -e "                                                           "
echo -e "${YELLOW}No, seriously, if you're only compiling with one core, on a 5 dollar vultr, expect this to take up to 45 minutes"
echo ""
echo ""
echo -e "${FgLtWhite}we're making .."
echo -e "${FgLtGreen}      ___           ___           ___           ___      ";
echo -e "     /\  \         /\  \         /\  \         /|  |     ";
echo -e "    _\:\  \       /::\  \       /::\  \       |:|  |     ";
echo -e "   /\ \:\  \     /:/\:\  \     /:/\:\__\      |:|  |     ";
echo -e "  _\:\ \:\  \   /:/  \:\  \   /:/ /:/  /    __|:|__|     ";
echo -e " /\ \:\ \:\__\ /:/__/ \:\__\ /:/_/:/__/___ /::::\__\_____";
echo -e " \:\ \:\/:/  / \:\  \ /:/  / \:\/:::::/  / ~~~~\::::/___/";
echo -e "  \:\ \::/  /   \:\  /:/  /   \::/~~/~~~~      |:|~~|    ";
echo -e "   \:\/:/  /     \:\/:/  /     \:\~~\          |:|  |    ";
echo -e "    \::/  /       \::/  /       \:\__\         |:|__|    ";
echo -e "     \/__/         \/__/         \/__/         |/__/     ";
echo -e "${FgLtBlue}"
echo -e "Work.. Please be patient....${Off}"

#CORES=$(grep ^cpu\\scores /proc/cpuinfo | wc -l)
CORES=$(($(grep ^proc /proc/cpuinfo |tail -n1 |awk -F: '{print $2}') + 1))

CF=$(eval expr $CORES - 1)
if [[ $CF -eq 0 ]]; then
CF='1'
fi
FM=$(($(($(eval echo $FREEMEM) + $(eval echo $SWAPS)))/1024))
if  [[ $CF -gt 4 ]]; then
        #CL=$(($FM/$CF+$(($CF/2))+5))
        CL=$(($CF/2+3))
                if [[ $CL -gt 5 ]]; then
                CL=5.2
                fi
        else 
        CL=4.5
fi
echo -e "${YELLOW} Compiling using $CF Cores with load $CL"
make -j$CF -l$CL > /dev/null 2>&1

if [[ -d $(eval echo $COIN_PATH)  ]]; then
cp src/worxd $(eval echo $COIN_PATH)
cp src/worx-cli $(eval echo $COIN_PATH)
cp src/worx-tx $(eval echo $COIN_PATH)
else 
cp src/worxd /usr/bin
cp src/worx-cli /usr/bin
cp src/worx-tx /usr/bin
COIN_PATH=/usr/bin
fi


}

function configure_systemd() {

DAEMONPID=$(pidof worxd)

if [[ -z $DAEMONPID ]]; then
echo -e "Daemon not currently running, Good!"
else
echo -e "Stopping running daemon"
$COIN_CLI_COMMAND stop > /dev/null 2>&1
sleep 10
kill -9 $DAEMONPID > /dev/null 2>&1
kill -15 $DAEMONPID > /dev/null 2>&1
fi


  echo -e "${GREEN} Setting Up Services ${NC}"

  cat << EOF > /etc/systemd/system/$COIN_NAME.service
[Unit]
Description=$COIN_NAME service
After=network.target
[Service]
User=root
Group=root
Type=forking
PIDFile=$PFILE
ExecStart=$STARTCMD
ExecStop=$STOPCMD
Restart=always
PrivateTmp=true
TimeoutStopSec=60s
TimeoutStartSec=10s
StartLimitInterval=120s
StartLimitBurst=5
[Install]
WantedBy=multi-user.target

EOF

  systemctl daemon-reload
}

function startsystemd() {

  systemctl start $COIN_NAME.service
  systemctl enable $COIN_NAME.service >/dev/null 2>&1

  if [[ -z "$(ps axo cmd:100 | egrep $COIN_DAEMON)" ]]; then
    echo -e "${RED}$COIN_NAME is not running${NC}, please investigate. You should start by running the following commands as root:"
    echo -e "${GREEN}systemctl start $COIN_NAME.service"
    echo -e "systemctl status $COIN_NAME.service"
    echo -e "less /var/log/syslog${NC}"
    exit 1
  fi
}

function create_config() {
  echo -e "${GREEN}Generating Config at $CFFULLPATH ${NC}"

if [[ ! -d $(eval echo $CONFIGFOLDER) ]]; then    
echo -e "Making Config Folder"
mkdir $(eval echo $CONFIGFOLDER)
fi

  RPCUSER=$(openssl rand -hex 11)
  RPCPASSWORD=$(openssl rand -hex 20)
  RPCPORT=$(netstat --listening -n |grep $RPC_PORT)
if [[ ! -z RPCPORT ]]; then
echo -e "Port $RPC_PORT is clear!"
else
echo -e "Something is listening on the RPC Port: $RPC_PORT."
RPC_PORT=$((($RPC_PORT) + 10))
echo -e "moving RPC port to $RPC_PORT"
fi

  cat << EOF > $(eval echo $CONFIGFOLDER/$CONFIG_FILE)

rpcuser=$RPCUSER
rpcpassword=$RPCPASSWORD
rpcport=$RPC_PORT
rpcallowip=127.0.0.1
listen=1
server=1
daemon=1
port=$COIN_PORT

EOF

echo -e "Done"
}

function create_key() {
if [[ $OLDKEY ]]; then
  echo -e "${GREEN}We have a previous key... Using that.. {NC}"
fi

    COINKEY=$OLDKEY
	if [[ ! $OLDKEY ]]; then 
		echo -e "${YELLOW}Enter your ${RED}$COIN_NAME Masternode GEN Key${NC}."
		while [[ -z "$COINKEY" ]]; do
		echo -e ""
		echo -e "============================================================="
		echo -e "${YELLOW}Enter your ${RED}$COIN_NAME Masternode GEN Key${NC}."
		echo -e "${WHITE}Please start your local wallet and go to"
		echo -e "Tools -> Debug Console and type ${GREEN}masternode genkey${WHITE}"
		echo -e "And please copy the string of letters and numbers"
		read -rp "and enter it here: " COINKEY
		done
	fi
	
#clear
}

function update_config() {
  echo -e "${GREEN}Adding Seeds to config ${NC}"
  EXTERNALIP=$(eval echo $NODEIP:$COIN_PORT)
  cat << EOF >> $(eval echo $CFFULLPATH)
logtimestamps=1
maxconnections=128
masternode=1
externalip=$EXTERNALIP
masternodeprivkey=$COINKEY

addnode=80.211.93.102
addnode=80.211.239.62
addnode=80.211.83.135
addnode=80.211.188.62
addnode=188.40.224.93

EOF

if [ -d $(eval echo $COIN_BACKUP) ]; then 
echo -e "${GREEN} Putting masternode.conf and wallet.dat back"
cp $(eval echo $COIN_BACKUP/masternode.conf $CONFIGFOLDER )
cp $(eval echo $COIN_BACKUP/wallet.dat $CONFIGFOLDER )
fi 

}


function update_config_wallet() {
  echo -e "${GREEN}Adding Seeds to config ${NC}"
  EXTERNALIP=$(eval echo $NODEIP:$COIN_PORT)
  cat << EOF >> $(eval echo $CFFULLPATH)
logintimestamps=1
maxconnections=25
#bind=$NODEIP
masternode=0
staking=1
externalip=$EXTERNALIP

addnode=80.211.93.102
addnode=80.211.239.62
addnode=80.211.83.135
addnode=80.211.188.62
addnode=188.40.224.93

EOF

if [ -d $(eval echo $COIN_BACKUP) ]; then 
echo -e "${GREEN} Putting masternode.conf and wallet.dat back"
cp $(eval echo $COIN_BACKUP/masternode.conf $CONFIGFOLDER )
cp $(eval echo $COIN_BACKUP/wallet.dat $CONFIGFOLDER )
fi 

}


function enable_firewall() {
  echo -e "Installing and setting up firewall to allow ingress on port ${GREEN}$COIN_PORT${NC}"
  ufw allow $COIN_PORT/tcp comment "$COIN_NAME MN port" >/dev/null
  ufw allow ssh comment "SSH" >/dev/null 2>&1
  ufw limit ssh/tcp >/dev/null 2>&1
  ufw default allow outgoing >/dev/null 2>&1
  echo "y" | ufw enable >/dev/null 2>&1
}


function get_ip() {
  declare -a NODE_IPS
  for ips in $(netstat -i | awk '!/Kernel|Iface|lo/ {print $1," "}')
  do
    NODE_IPS+=($(curl --interface $ips --connect-timeout 2 -s4 icanhazip.com))
  done

  if [ ${#NODE_IPS[@]} -gt 1 ]
    then
      echo -e "${GREEN}More than one IP. Please type 0 to use the first IP, 1 for the second and so on...${NC}"
      INDEX=0
      for ip in "${NODE_IPS[@]}"
      do
        echo ${INDEX} $ip
        let INDEX=${INDEX}+1
      done
      read -e choose_ip
      NODEIP=${NODE_IPS[$choose_ip]}
  else
    NODEIP=${NODE_IPS[0]}
  fi
}


function compile_error() {
if [ "$?" -gt "0" ];
 then
  echo -e "${RED}Failed to compile $COIN_NAME. Please investigate.${NC}"
  exit 1
fi
}


function checks() {
if [[ $(lsb_release -d) != *16.04* ]]; then
  echo -e "${RED}You are not running Ubuntu 16.04. Installation is cancelled.${NC}"
  exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}$0 must be run as root.${NC}"
   exit 1
fi

}

function prepare_system() {
echo -e "Preparing the VPS to setup. ${CYAN}$COIN_NAME${NC} ${RED}Masternode${NC}"
apt-get update >/dev/null 2>&1
DEBIAN_FRONTEND=noninteractive apt-get update > /dev/null 2>&1
DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y -qq upgrade >/dev/null 2>&1
if [[ ! -e /etc/apt/sources.list.d/bitcoin-ubuntu-bitcoin-xenial.list ]]; then 
apt install -y software-properties-common >/dev/null 2>&1
echo -e "${PURPLE}Adding bitcoin PPA repository"
apt-add-repository -y ppa:bitcoin/bitcoin >/dev/null 2>&1
fi
echo -e "Installing required packages, it may take some time to finish.${NC}"
apt-get update >/dev/null 2>&1
apt-get install libzmq3-dev -y >/dev/null 2>&1
apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" make software-properties-common \
build-essential libtool autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev libboost-program-options-dev \
libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git wget curl libdb4.8-dev bsdmainutils libdb4.8++-dev \
libminiupnpc-dev libgmp3-dev ufw pkg-config libevent-dev  libdb5.3++ unzip libzmq5 >/dev/null 2>&1
if [ "$?" -gt "0" ];
  then
    echo -e "${RED}Not all required packages were installed properly. Try to install them manually by running the following commands:${NC}\n"
    echo "apt-get update"
    echo "apt -y install software-properties-common"
    echo "apt-add-repository -y ppa:bitcoin/bitcoin"
    echo "apt-get update"

echo "apt install -y make build-essential libtool software-properties-common autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev \
libboost-program-options-dev libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git curl libdb4.8-dev \
bsdmainutils libdb4.8++-dev libminiupnpc-dev libgmp3-dev ufw pkg-config libevent-dev libdb5.3++ unzip libzmq5"
 exit 1
fi
#clear
}

function important_information() {
 echo
 echo -e "${RED} ${RED}Dragon${PURPLE}Lady Flexi-compile edit $SCRIPTVER${NC}"
 echo -e "${BLUE}================================================================================================================================${NC}"
 echo -e "${PURPLE}Windows Wallet Guide. https://github.com/Worx/master/README.md${NC}"
 echo -e "${BLUE}================================================================================================================================${NC}"
 echo -e "${GREEN}$COIN_NAME Masternode is up and running listening on port${NC}${PURPLE}$COIN_PORT${NC}."
 echo -e "${GREEN}Configuration file is:${NC}${RED}$CFFULLPATH${NC}"
 echo -e "${GREEN}Start:${NC}${RED}systemctl start $COIN_NAME.service${NC}"
 echo -e "${GREEN}Stop:${NC}${RED}systemctl stop $COIN_NAME.service${NC}"
 echo -e "${GREEN}VPS_IP:PORT${NC}${GREEN}$NODEIP:$COIN_PORT${NC}"
if [[ ! $OLDKEY ]]; then
 echo -e "${GREEN}***NEW*** MASTERNODE GENKEY is:${NC}${PURPLE}$COINKEY${NC}"
else
 echo -e "${GREEN}Copied from previous config MASTERNODE GENKEY is:${NC}${PURPLE}$COINKEY${NC}"
fi
 echo -e "${BLUE}================================================================================================================================"
read -rp "Press any key to continue" pause
 echo -e "Whipped up by "
logo
 echo -e "for Worx with some stuff borrowed from RealBiYoda. " 
 echo -e "${BLUE}================================================================================================================================${NC}"
 echo -e "${CYAN}Ensure Node is fully SYNCED with BLOCKCHAIN.${NC}"
 echo -e "${BLUE}================================================================================================================================${NC}"
 echo -e "${GREEN}Usage Commands.${NC}"
 echo -e "${GREEN}worx-cli masternode status${NC}"
 echo -e "${GREEN}worx-cli getinfo.${NC}"
 echo -e "${BLUE}================================================================================================================================${NC}"
 echo -e "${RED}Donations always accepted gratefully.${NC}"
 echo -e "${BLUE}================================================================================================================================${NC}"
 echo -e "${RED}Dragon${PURPLE}Lady ${BLUE}Worx: ${WHITE}Wm8dAnLhcJcYuRYGBoL4NX2EepQeSBPDS3${NC}"
 echo -e "${BLUE}================================================================================================================================${NC}"

}


function important_information_wallet() {
 echo
 echo -e "${RED} ${RED}Dragon${PURPLE}Lady Flexi-compile edit $SCRIPTVER${NC}"
 echo -e "${BLUE}================================================================================================================================${NC}"
 echo -e "${PURPLE}You now have a working CLI wallet for ${BLUE}Worx${WHITE}!!!"
 echo -e "${BLUE}================================================================================================================================${NC}"
 echo -e "${GREEN}Configuration file is:${NC}${RED}$CFFULLPATH${NC}"
 echo -e "${GREEN}Start:${NC}${RED}systemctl start $COIN_NAME.service${NC}"
 echo -e "${GREEN}Stop:${NC}${RED}systemctl stop $COIN_NAME.service${NC}"
 echo -e "${BLUE}================================================================================================================================"
 echo -e "Whipped up by "
 logo
 echo -e "${YELLOW} for Worx with some stuff borrowed from RealBitYoda." 
 echo -e "${BLUE}================================================================================================================================${NC}"
 echo -e "${CYAN}Ensure Node is fully SYNCED with BLOCKCHAIN.${NC}"
 echo -e "${BLUE}================================================================================================================================${NC}"
 echo -e "${GREEN}Usage Commands.${NC}"
 echo -e "${GREEN}worx-cli getinfo${NC}"
 echo -e "${GREEN}worx-cli help${NC}"
 echo -e "${BLUE}================================================================================================================================${NC}"
 echo -e "${RED}Donations always accepted gratefully.${NC}"
 echo -e "${BLUE}================================================================================================================================${NC}"
 echo -e "${RED}Dragon${PURPLE}Lady ${BLUE}Worx: ${WHITE}Wm8dAnLhcJcYuRYGBoL4NX2EepQeSBPDS3 ${NC}"
 echo -e "${BLUE}================================================================================================================================${NC}"

}

function bootstrap() {

 echo -e "${BLUE}================================================================================================================================${NC}"
 echo -e "${RED}Bootstrapping Blockchain with IPFS hash ${WHITE}$COIN_BOOTSTRAP_HASH"
 echo -e "${BLUE}================================================================================================================================${NC}"
  cd $CONFIGFOLDER
  rm -rf blocks chainstate sporks banlist.dat peers.dat 2>/dev/null
  echo -e "${CYAN}Downloading Bootstrap...${NC}"
  wget -q $COIN_BOOTSTRAP_URL -O bootstrap.tar.gz
  tar -zxvf bootstrap.tar.gz >/dev/null 2>&1
  rm bootstrap.tar.gz
  cd ~
}

function support() {
memfree=$(free -m |sed -n '2,2p' |awk '{ print $4 }')
swapspace=$(free -m |tail -n1 |awk '{ print $2 }')
getinfo=$(/usr/local/bin/worx-cli getinfo)
coldlook=$(cat ~/.worx/debug.log |grep cold)
last20=$(tail ~/.worx/debug.log -n20)
mnstatus=$(/usr/local/bin/worx-cli masternode status)
corecount=$(($(grep ^proc /proc/cpuinfo |tail -n1 |awk -F: '{print $2}')+1))
synchedstatus=$(($COIN_CLI_COMMAND |grep 'IsBlockchainSynced' |awk '{ print $2 }'))

 echo -e "${BLUE}================================================================================================================================${NC}"
 echo -e "${FgLtBlue}Worx ${Blink}${FgLtWhite}Support${Off}${FgLtWhite}${BgLtBlue} ${FgLtRed}Help ${Off}${FgLtWhite}${BgLtBlue}Screen"
 echo -e "${BLUE}================================================================================================================================${NC}"
echo -e  "                                                                                                          "
echo -e  " Getinfo: $getinfo            Sync status: $synchedstatus                                                                                            "
echo -e  "                                                                                                          "
echo -e  " Cores: $corecount  		Free Memory: $memfree  		Swap Space: $swapspace  "
echo -e  " "
echo -e  " Coldlook:  $coldlook                                                                                               "
echo -e  "                                                                                                          "
echo -e  " Last20debug: $last20                                             "
echo -e  "                                                                                                          "
echo -e  " MNStatus:  $mnstatus                                                                                                        "


}

function logo() {
 
 
echo -e "${FgLtRed}${Bold}▓█████▄  ██▀███   ▄▄▄        ▄████  ▒█████   ███▄    █  ██▓    ▄▄▄      ▓█████▄▓██   ██▓"
echo -e "${FgLtRed}${Bold}▒██▀ ██▌▓██ ▒ ██▒▒████▄     ██▒ ▀█▒▒██▒  ██▒ ██ ▀█   █ ▓██▒   ▒████▄    ▒██▀ ██▌▒██  ██▒"
echo -e "${FgLtRed}${Bold}░██   █▌▓██ ░▄█ ▒▒██  ▀█▄  ▒██░▄▄▄░▒██░  ██▒▓██  ▀█ ██▒▒██░   ▒██  ▀█▄  ░██   █▌ ▒██ ██░"
echo -e "${FgLtRed}${Bold}░▓█▄   ▌▒██▀▀█▄  ░██▄▄▄▄██ ░▓█  ██▓▒██   ██░▓██▒  ▐▌██▒▒██░   ░██▄▄▄▄██ ░▓█▄   ▌ ░ ▐██▓░"
echo -e "${FgLtRed}${Bold}░▒████▓ ░██▓ ▒██▒ ▓█   ▓██▒░▒▓███▀▒░ ████▓▒░▒██░   ▓██░░██████▒▓█   ▓██▒░▒████▓  ░ ██▒▓░"
echo -e "${FgLtRed}${Bold} ▒▒▓  ▒ ░ ▒▓ ░▒▓░ ▒▒   ▓▒█░ ░▒   ▒ ░ ▒░▒░▒░ ░ ▒░   ▒ ▒ ░ ▒░▓  ░▒▒   ▓▒█░ ▒▒▓  ▒   ██▒▒▒ "
echo -e "${FgLtRed}${Bold} ░ ▒  ▒   ░▒ ░ ▒░  ▒   ▒▒ ░  ░   ░   ░ ▒ ▒░ ░ ░░   ░ ▒░░ ░ ▒  ░ ▒   ▒▒ ░ ░ ▒  ▒ ▓██ ░▒░ "
echo -e "${FgLtRed}${Bold} ░ ░  ░   ░░   ░   ░   ▒   ░ ░   ░ ░ ░ ░ ▒     ░   ░ ░   ░ ░    ░   ▒    ░ ░  ░ ▒ ▒ ░░  "
echo -e "${FgLtRed}${Bold}   ░       ░           ░  ░      ░     ░ ░           ░     ░  ░     ░  ░   ░    ░ ░     "
echo -e "${FgLtRed}${Bold} ░                                                                       ░      ░ ░     "

}


function mainmenu() {
clear
options=("${GREEN}1:${NC}${YELLOW} Install full Masternode${NC}" "${GREEN}2:${NC}${YELLOW} Install CLI Staking Wallet Only${NC}" "${GREEN}3:${NC}${YELLOW} Quit and get me out of here${NC}")
echo -e "Welcome to the linux installer for ..."
echo -e "${FgLtGreen}${Bold} ▄▄▌ ▐ ▄▌      ▄▄▄  ▐▄• ▄ "
echo -e " ██· █▌▐█▪     ▀▄ █· █▌█▌▪"
echo -e " ██▪▐█▐▐▌ ▄█▀▄ ▐▀▀▄  ·██· "
echo -e " ▐█▌██▐█▌▐█▌.▐▌▐█•█▌▪▐█·█▌"
echo -e "  ▀▀▀▀ ▀▪ ▀█▄▀▪.▀  ▀•▀▀ ▀▀${Off}"

echo -e "${RED} ${RED}Dragon${FgLtMagenta}Lady${FgLtGreen} Flexi-compile edit $SCRIPTVER${NC}"
 echo -e "${BLUE}================================================================${NC}"
 echo -e "${WHITE}Main Menu"
 echo -e "${BLUE}===================${WHITE}Here are your options${BLUE}========================${NC}"
 echo -e "${GREEN}1:${NC}${FgLtYellow} Install full Masternode${NC}"
 echo -e "${GREEN}2:${NC}${FgLtYellow} Install CLI Staking Wallet Only${NC}"
 echo -e "${GREEN}3:${NC}${FgLtYellow} Quit and get me out of here${NC}"
 echo -e "${BLUE}================================================================${NC}"
}

function mainmenu2 {
#PS3='Please enter your choice: '
#options=("Install full Masternode" "Install CLI Staking Wallet Only" "Quit and get me out of here")
shouldloop=true;
while $shouldloop; do
mainmenu
read -rp "Please select your choice: " opt

    case $opt in
        "1")
            echo "Lets do a masternode!";
	doamasternode
	    echo -e "${Underline}Masternode Setup ${Blink}Complete${Off}${FgLtBlue}$!!!"
            read -rp "Press any key to return to main menu" pause
	    ;;
        "2")
            echo "Staking Wallet only Please...";
	justwalletplz
	    echo -e "${Underline}Staking Wallet Setup ${Blink}Complete${Off}${FgLtBlue}!!!"
            read -rp "Press any key to return to main menu" pause
            ;;
        "3")
            echo "Returning you to the shell";
	shouldloop=false;
	break
	exit
            ;;
	 "jump")
	echo -e "Where do you want to jump to?"
	echo -e "Valid examples are"
	echo -e "logo"
	echo -e "important_information"
	echo -e "configure_systemd"
	echo -e "preflightchecks"
	echo -e ""
	echo -e ""
        read -rp "Jump to what function?: " jump;
        $jump
	read -rp "press any key to continue" pause;
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
}

function syncwaitreboot() {

ISSYNCHED=$($COIN_CLI_COMMAND |grep 'IsBlockchainSynced' |awk ' { print $2 } ')

}

function doamasternode() {

clear
preflightchecks
download_node
configure_systemd
#bootstrap
setup_node
startsystemd
syncwaitreboot
}

function preflightchecks() {
purgeOldInstallation
checks
prepare_system
memorycheck
}

function setup_node() {
  get_ip
  create_config
  create_key
  update_config
  enable_firewall
  important_information
read -rp "Press any key to continue" pause
}


function justwalletplz() {
preflightchecks
download_node
#bootstrap
get_ip
create_config
update_config_wallet
important_information_wallet
read -rp "Press any key to continue" pause
}


##### Main #####
mainmenu2


# bash <(curl https://raw.githubusercontent.com/WorxCoin/WorxInstaller/master/worx_installer)



