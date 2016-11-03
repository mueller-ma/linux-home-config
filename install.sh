#!/usr/bin/env bash

home_path="~/.linux-home-config"

function wgetOrCurl {
	if hash curl 2>/dev/null
	then
		WGET_OR_CURL="curl"
		WGET_OR_CURL_CMD="curl -s -L"
	elif hash wget 2>/dev/null
	then
		WGET_OR_CURL="wget"
		WGET_OR_CURL_CMD="wget --quiet"
	else
		echo "wget or curl needed"
		exit 1
	fi
}

function setAutoSync {
	mkdir -p ${home_path}/download
	cd ${home_path}/download
	DL_CMD="${WGET_OR_CURL_CMD} ${URL}"
	$DL_CMD
}


#Questions
function localMirrorQ {
	echo "Do you have a local mirror?"
	select yn in "Yes" "No" "Cancel"; do
	    case $yn in
		Yes ) localMirrorURLQ; break;;
		No ) URL="https://github.com/mueller-ma/linux-home-config/archive/master.tar.gz"; break;;
		Cancel ) exit;;
	    esac
	done
}

function localMirrorURLQ {
	echo "Enter the URL (\"/archive/master.tar.gz\" will be added): "
	read input_var
	URL=${input_var}/archive/master.tar.gz
	unset input_var
}

#cd ~
#mkdir -p ${home_path}/old-config-files
#mv -t ${home_path}/old-config-files .vimrc .vim .bashrc .bash_aliases

wgetOrCurl

echo "Do you want to set up auto sync?"
select yn in "Yes" "No" "Cancel"; do
    case $yn in
        Yes ) localMirrorQ; break;;
        No ) break;;
	Cancel ) exit;;
    esac
done


echo foo

