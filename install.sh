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

function removeAutoSync {
	sed -i '/~\/\.linux-home-config\/update\.sh/d' ~/.bashrc
}

function removeOpenhab {
	cd ~
	rm .vim/{ftdetect,syntax}/openhab.vim
}

function downloadAll {
	mkdir -p ${home_path}/download
	cd ${home_path}/download
	DL_CMD="${WGET_OR_CURL_CMD} ${URL}"
	$DL_CMD
	tar -xzf master.tar.gz
	cd linux-home-config-master/config-files
	cp -r .* ~
}

function removeGreeting {
	sed -i 's/greeting=true/#greeting=true/' ~/.bashrc
}

function installRecommendation {
	for cmd in vim tree
	do
		command -v $cmd >/dev/null 2>&1 || echo "$cmd not installed"
	done
}


#Questions
function customMirrorURLQ {
	echo "Enter the URL (\"/archive/master.tar.gz\" will be added): "
	read input_var
	URL=${input_var}/archive/master.tar.gz
	unset input_var
}

cd ~
mkdir -p ${home_path}/old-config-files
rm -r ${home_path}/old-config-files/.* 2>/dev/null
mv -f -t ${home_path}/old-config-files .vimrc .vim .bashrc .bash_aliases

curlOrWget

echo "Which mirror do you want to use?"
select yn in "Custom" "Github" "Cancel"; do
    case $yn in
	Custom ) customMirrorURLQ; break;;
	Github ) URL="https://github.com/mueller-ma/linux-home-config/archive/master.tar.gz"; break;;
	Cancel ) exit;;
    esac
done

downloadAll #and install

echo

echo "Do you want to set up auto sync?"
select yn in "Yes" "No" "Cancel"; do
    case $yn in
        Yes ) break;;
        No ) removeAutoSync; break;;
	Cancel ) exit;;
    esac
done

echo

echo "Do you want openHAB support in VIM?"
select yn in "Yes" "No" "Cancel"; do
    case $yn in
        Yes ) break;;
        No ) removeOpenhab; break;;
	Cancel ) exit;;
    esac
done

echo

echo "Do you like Tux?"
select yn in "Yes" "No" "Cancel"; do
    case $yn in
        Yes ) break;;
        No ) removeGreeting; echo ":("; break;;
	Cancel ) exit;;
    esac
done

echo

installRecommendation
