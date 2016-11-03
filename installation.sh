#!/usr/bin/env bash

function wgetOrCurl {
	if hash curl 2>/dev/null
	then
		WGET_OR_CURL=curl
	elif hash wget 2>/dev/null
	then
		WGET_OR_CURL=wget
	else
		echo "wget or curl need." && exit 1
	fi
}

function setAutoSync {
}


#Questions
function localMirrorQ {
	echo "Do you have a local mirror?"
	select yn in "Yes" "No" "Cancel"; do
	    case $yn in
		Yes ) localMirrorURLQ; break;;
		No ) URL="https://github.com/mueller-ma/linux-home-config"; break;;
		Cancel ) exit;;
	    esac
	done
}

function localMirrorURLQ {
	echo "Enter the URL: "
	read URL
}

#cd ~
#mkdir -p .linux-home-config/old-config-files
#mv -t .linux-home-config/old-config-files .vimrc .vim .bashrc .bash_aliases

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

