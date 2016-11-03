#!/usr/bin/env bash

home_path=".linux-home-config"

function curlOrWget {
	if hash curl 2>/dev/null
	then
		WGET_OR_CURL="curl"
		WGET_OR_CURL_CMD="curl -s -L -o master.tar.gz"
	elif hash wget 2>/dev/null
	then
		WGET_OR_CURL="wget"
		WGET_OR_CURL_CMD="wget --quieti -O master.tar.gz"
	else
		echo "wget or curl needed"
		exit 1
	fi
}

function setAutoSync {
}

function downloadAll {
	mkdir -p ${home_path}/download
	cd ${home_path}/download
	DL_CMD="${WGET_OR_CURL_CMD} ${URL}"
	$DL_CMD
	tar -xvzf master.tar.gz
	cd linux-home-config-master/config-files
	cp -r .* ~
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

cd ~
mkdir -p ${home_path}/old-config-files
mv -t ${home_path}/old-config-files .vimrc .vim .bashrc .bash_aliases

curlOrWget
localMirrorQ

echo "Do you want to set up auto sync?"
select yn in "Yes" "No" "Cancel"; do
    case $yn in
        Yes ) setAutoSync; break;;
        No ) break;;
	Cancel ) exit;;
    esac
done

downloadAll
