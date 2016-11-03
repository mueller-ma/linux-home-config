#!/usr/bin/env bash

home_path=".linux-home-config"
tempfile="${HOME}/${home_path}/temp"
touch $tempfile

function curlOrWget {
	if hash curl 2>/dev/null
	then
		WGET_OR_CURL="curl"
		WGET_OR_CURL_CMD="curl -s -L -o master.tar.gz"
	elif hash wget 2>/dev/null
	then
		WGET_OR_CURL="wget"
		WGET_OR_CURL_CMD="wget --quiet -O master.tar.gz"
	else
		echo "wget or curl needed"
		exit 1
	fi
}

function removeAutoSync {
	sed -e 's/${HOME}\/\.linux-home-config\/update\.sh/#${HOME}\/\.linux-home-config\/update\.sh/' ${HOME}/.bashrc > $tempfile
	cp $tempfile ${HOME}/.bashrc
}

function removeOpenhab {
	cd $HOME
	rm .vim/{ftdetect,syntax}/openhab.vim
}

function downloadAll {
	mkdir -p ${home_path}/download
	cd ${home_path}/download
	DL_CMD="${WGET_OR_CURL_CMD} ${URL}"
	$DL_CMD
	tar -xzf master.tar.gz
	cd linux-home-config-master/config-files
	cp -r {.[!.],}* ${HOME} 2>/dev/null
	mkdir ${HOME}/.vim/{undo,backup}
	chmod o-rwx ${HOME}/.vim/{undo,backup}
}

function removeGreeting {
	sed -e 's/greeting=true/#greeting=true/' ${HOME}/.bashrc > $tempfile
	cp $tempfile ${HOME}/.bashrc
}

function installRecommendation {
	for cmd in vim tree
	do
		command -v $cmd >/dev/null 2>&1 || echo "$cmd not installed"
	done
}

function isInstalledEditor {
	if command -v $1 >/dev/null 2>&1
	then
		echo -e "\n# Editor\nexport EDITOR=$1" >> ${HOME}/.bashrc
		return 0
	else
		echo "$1 not installed"
		return 1
	fi
}

#Questions
function customMirrorURLQ {
	echo "Enter the URL (\"/archive/master.tar.gz\" will be added): "
	read input_var
	URL=${input_var}/archive/master.tar.gz
	unset input_var
}

cd ${HOME}
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

if $(isInstalledEditor vim 2>/dev/null)
then
	echo "Your editor is vim"
else
	echo "What is your favorite editor?"
	select editor in "vi" "vim" "emacs" "nano" "ed" "Cancel"; do
	    case $editor in
		vi ) isInstalledEditor vi && break;;
		vim ) isInstalledEditor vim && break;;
		emacs ) isInstalledEditor emacs && break;;
		nano ) isInstalledEditor nano && break;;
		ed ) isInstalledEditor ed && break;;
		Cancel ) exit;;
	    esac
	done
	unset editor
fi

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
        Yes ) echo ":)"; break;;
        No ) removeGreeting; echo ":("; break;;
	Cancel ) exit;;
    esac
done

echo

installRecommendation

rm $tempfile
