#!/usr/bin/env bash

home_path=".linux-home-config"
tempfile="${HOME}/${home_path}/temp"
configfile="${HOME}/${home_path}/config"

function curlOrWget {
	if hash curl 2>/dev/null
	then
		WGET_OR_CURL="curl"
		WGET_OR_CURL_CMD="curl -s -L -o master.tar.gz"
		echo 'WGET_OR_CURL="curl"' >> $configfile
		echo 'WGET_OR_CURL_CMD="curl -s -L -o master.tar.gz"' >> $configfile
	elif hash wget 2>/dev/null
	then
		WGET_OR_CURL="wget"
		WGET_OR_CURL_CMD="wget --quiet -O master.tar.gz"
		echo 'WGET_OR_CURL="wget"' >> $configfile
		echo 'WGET_OR_CURL_CMD="wget --quiet -O master.tar.gz"' >> $configfile
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
	echo 'removeOpenhab="true"' >> $configfile
	cd $HOME
	rm .vim/{ftdetect,syntax}/openhab.vim
}

function downloadAll {
	# create folder
	mkdir -p ${home_path}/download
	cd ${home_path}/download
	# download from URL
	DL_CMD="${WGET_OR_CURL_CMD} ${URL}"
	echo 'DL_CMD="${WGET_OR_CURL_CMD} ${URL}"' >> $configfile
	$DL_CMD
	# unpack tar ball
	tar -xzf master.tar.gz
	# go to extracted files
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
	cp update.sh ${HOME}/${home_path}/update.sh
	# remove tar ball
	rm ../master.tar.gz
	vi -c ':Helptags' -c ':q' 2>&1 > /dev/null
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
	echo 'removeGreeting="true"' >> $configfile
	sed -e 's/greeting=true/#greeting=true/' ${HOME}/.bashrc > $tempfile
	cp $tempfile ${HOME}/.bashrc
}

function installRecommendation {
	echo "Do you want to install some software?"
	select yn in "Yes" "No" "Cancel"; do
	    case $yn in
		Yes ) break;;
		No )  return 0;;
		Cancel ) exit;;
	    esac
	done
	pkgManCMD
	DB_UPDATED=0
	for cmd in $VIM_PKG_NAME tree
	do
		command -v $cmd >/dev/null 2>&1
		if [ $? -ne 0 ]
		then
			if [ $PKG_MAN ]
			then
				# update db only once
				if [ $DB_UPDATED -eq 0 ]
				then
					$IS_ROOT $PKG_MAN_UPDATE_DB
					let DB_UPDATED++
				fi
				$IS_ROOT $PKG_MAN_INSTALL $cmd
			fi

		fi
		
	done
}

function pkgManCMD {
	PKG_MAN=""
	VIM_PKG_NAME="vim"
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
					break
					;;
				"yum")
					PKG_MAN_UPDATE_DB="${IS_ROOT} yum check-update"
					PKG_MAN_INSTALL="${IS_ROOT} yum install"
					#VIM_PKG_NAME="vim-common"
					break
					;;
				"pacman")
					PKG_MAN_UPDATE_DB="${IS_ROOT} pacman -Syy"
					PKG_MAN_INSTALL="${IS_ROOT} pacman -S"
					break
					;;
				"pkg")
					PKG_MAN_UPDATE_DB="${IS_ROOT} pkg update"
					PKG_MAN_INSTALL="${IS_ROOT} pkg install"
					VIM_PKG_NAME="vim-lite"
					break
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
		echo -e "\n# Editor\nexport EDITOR=$1" >> ${HOME}/${home_path}/persistent/A.bashrc
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
mkdir -p ${home_path}/{old-config-files,persistent}
rm -r ${home_path}/{old-config-files,persistent}/{.[!.],}* $configfile 2>/dev/null
for file in .vimrc .vim .bashrc .bash_aliases .profile
do
	if [ -f $file ] || [ -d $file ]
	then
		mv -f $file ${home_path}/old-config-files/${file}
		#echo "Backup of $file under ${home_path}/old-config-files/${file}"
	fi
done
touch $tempfile
touch $configfile

curlOrWget

echo "Which mirror do you want to use?"
select yn in "Custom" "Github" "Cancel"; do
    case $yn in
	Custom ) customMirrorURLQ; break;;
	Github ) URL="https://github.com/mueller-ma/linux-home-config/archive/master.tar.gz"; break;;
	Cancel ) echo "You don't have the config files in your \$HOME directory now!"; exit;;
    esac
done

echo "URL=$URL" >> $configfile

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
	echo -e "\n# Use Vim instead of vi\nalias vi='vim'" >> ${HOME}/${home_path}/persistent/A.bash_aliases
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

chmod -R o-rwx ${HOME}/${home_path}/

rm $tempfile
