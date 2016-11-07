#!/usr/bin/env bash

home_path=".linux-home-config"
tempfile="${HOME}/${home_path}/temp"

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
	# create folder
	mkdir -p ${home_path}/download
	cd ${home_path}/download
	# download from URL
	DL_CMD="${WGET_OR_CURL_CMD} ${URL}"
	$DL_CMD
	# unpack tar ball
	tar -xzf master.tar.gz
	# go to extracted data
	cd linux-home-config-master
	# download git submodules
	downloadGitmodules 
	# cd
	cd config-files
	# copy all files to ~
	cp -r {.[!.],}* ${HOME} 2>/dev/null
	# create folder for vim and change permission
	mkdir ${HOME}/.vim/{undo,backup}
	chmod o-rwx ${HOME}/.vim/{undo,backup}
	# copy installer in linux-home-config folder
	cd ..
	cp install.sh ${HOME}/${home_path}/install.sh
	# remove tar ball
	rm ../master.tar.gz
}

function downloadGitmodules {
	lines=$(cat .gitmodules | grep -v "^$" | grep -v "^#" | wc -l)
	i=1
	while [ $i -le $((lines/3)) ]
	do
		PATH_MODULE=$(cat .gitmodules | grep "path" | cut -d"=" -f 2 | head -n $i | tail -n1)
		NAME_MODULE="${PATH_MODULE##*/}"
		URL_MODULE=$(cat .gitmodules | grep "url" | cut -d"=" -f 2 | head -n $i | tail -n1)
		URL_MODULE_TAR="${URL_MODULE}/archive/master.tar.gz"
		cd $PATH_MODULE
		DL_CMD="${WGET_OR_CURL_CMD} ${URL_MODULE_TAR}"
		$DL_CMD
		tar -xzf master.tar.gz
		cp -r ${NAME_MODULE}-master/{.[!.],}* .
		rm -r master.tar.gz ${NAME_MODULE}-master
		cd - > /dev/null
		let i++
	done
}

function removeGreeting {
	sed -e 's/greeting=true/#greeting=true/' ${HOME}/.bashrc > $tempfile
	cp $tempfile ${HOME}/.bashrc
}

function installRecommendation {
	pkgManCMD
	i=0
	for cmd in vim tree
	do
		command -v $cmd >/dev/null 2>&1
		if [ $? -ne 0 ]
		then
			if [ $PKG_MAN ]
			then
				# update db only once
				if [ $i -eq 0 ]
				then
					$IS_ROOT $PKG_MAN_UPDATE_DB
				fi
				$IS_ROOT $PKG_MAN_INSTALL $cmd
			fi

		fi
		
		let i++
	done
}

function pkgManCMD {
	PKG_MAN=""
	for cmd in apt apt-get yum pacman pkg
	do
		command -v $cmd >/dev/null 2>&1
		if [ $? -eq 0 ]
		then
			PKG_MAN=true
			case "$cmd" in
				"apt")
					PKG_MAN_UPDATE_DB="${IS_ROOT} apt update"
					PKG_MAN_INSTALL="${IS_ROOT} apt install"
					;;
				"apt-get")
					PKG_MAN_UPDATE_DB="${IS_ROOT} apt-get update"
					PKG_MAN_INSTALL="${IS_ROOT} apt-get install"
					;;
				"yum")
					PKG_MAN_UPDATE_DB="${IS_ROOT} yum check-update"
					PKG_MAN_INSTALL="${IS_ROOT} yum install"
					;;
				"pacman")
					PKG_MAN_UPDATE_DB="${IS_ROOT} pacman -Syy"
					PKG_MAN_INSTALL="${IS_ROOT} pacman -S"
					;;
				"pkg")
					PKG_MAN_UPDATE_DB="${IS_ROOT} pkg update"
					PKG_MAN_INSTALL="${IS_ROOT} pkg install"
					;;
			esac
		fi
	done
}

function isRoot {
	if [ $UID -eq 0 ]
	then
		IS_ROOT=
	elif [ $(command -v sudo) ]
	then
		IS_ROOT=sudo
	else
		IS_ROOT=false
	fi
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
for file in .vimrc .vim .bashrc .bash_aliases .profile
do
	if [ -f $file ] || [ -d $file ]
	then
		mv -f $file ${home_path}/old-config-files/${file}
		echo "Backup of $file under ${home_path}/old-config-files/${file}"
	fi
done
touch $tempfile

curlOrWget

echo "Which mirror do you want to use?"
select yn in "Custom" "Github" "Cancel"; do
    case $yn in
	Custom ) customMirrorURLQ; break;;
	Github ) URL="https://github.com/mueller-ma/linux-home-config/archive/master.tar.gz"; break;;
	Cancel ) echo "You don't have the config files in your \$HOME directory now!"; exit;;
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

isRoot
if [[ "$IS_ROOT" != "false" ]]
then
	installRecommendation
fi

echo

if $(isInstalledEditor vim) 2>/dev/null
then
	echo "Your editor is vim"
	echo -e "\n# Use Vim instead of vi\nalias vi='vim'" >> ${HOME}/.bash_aliases
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

echo -e "\n# Use Vim tabs\nalias vim='vim -p'" >> ${HOME}/.bash_aliases

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

rm $tempfile
