#!/usr/bin/env bash
set -xv

home_path=".linux-home-config"
tempfile="${HOME}/${home_path}/temp"
configfile="${HOME}/${home_path}/config"

function curlOrWget {
	if command -v curl >/dev/null 2>&1
	then
		WGET_OR_CURL="curl"
		WGET_OR_CURL_CMD="curl -s -L -o master.tar.gz"
		echo 'WGET_OR_CURL="curl"' >> $configfile
		echo 'WGET_OR_CURL_CMD="curl -s -L -o master.tar.gz"' >> $configfile
	elif command -v wget >/dev/null 2>&1
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

function addAutoSync {
	echo -e '# Autoupdate of config file (e.g. this file, .bash_aliases, .vimrc)\n${HOME}/.linux-home-config/update.sh' >> ${HOME}/.bashrc
	echo 'AutoSync=true' >> $configfile
}

function downloadAll {
	# Create folder
	mkdir -p ${home_path}/download
	cd ${home_path}/download
	# Download from URL
	DL_CMD="${WGET_OR_CURL_CMD} ${URL}"
	echo 'DL_CMD="${WGET_OR_CURL_CMD} ${URL}"' >> $configfile
	$DL_CMD
	# Unpack tar ball
	tar -xzf master.tar.gz
	# go to extracted files
	cd linux-home-config-master
	# Download git submodules
	downloadGitmodules 
	# cd
	cd config-files
	# copy all files to ~
	cp -r {.[!.],}* ${HOME} 2>/dev/null
	# Create folder for vim and change permission
	mkdir ${HOME}/.vim/{undo,backup}
	chmod o-rwx ${HOME}/.vim/{undo,backup}
	# Copy installer in linux-home-config folder
	cd ..
	cp install.sh ${HOME}/${home_path}/install.sh
	cp update.sh ${HOME}/${home_path}/update.sh
	cp start-update.sh ${HOME}/${home_path}/start-update.sh
	# Remove tar ball
	rm ../master.tar.gz
	# Generate vimrc and vimrc.lite
	cd $HOME
	cat .vimrc.template | grep -v ' " lite-only' | sed -r 's/ " lite//' > ${HOME}/.vimrc
	cat .vimrc.template | grep ' " lite' | sed -r 's/ " lite(.*)//' > ${HOME}/.vimrc.lite
	# Generate Helptags
	vim -u NONE -c 'Helptags' -c q
	# Restore .vim/backup and .vim/undo
	cp "${HOME}/${home_path}/old-config-files/.vim/backup/"* ${HOME}/.vim/backup/
	cp "${HOME}/${home_path}/old-config-files/.vim/undo/"* ${HOME}/.vim/undo/
}

function downloadGitmodules {
	lines=$(cat .gitmodules | grep -v "^$" | grep -v "^#" | wc -l)
	i=1
	while [ "$i" -le "$((lines/3))" ]
	do
		PATH_MODULE=$(cat .gitmodules | grep "path" | cut -d"=" -f 2 | head -n "$i" | tail -n1)
		NAME_MODULE="${PATH_MODULE##*/}"
		URL_MODULE=$(cat .gitmodules | grep "url" | cut -d"=" -f 2 | head -n "$i" | tail -n1)
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
	echo 'removeGreeting="true"' >> "$configfile"
	sed -e 's/greeting=true/#greeting=true/' ${HOME}/.profile > "$tempfile"
	cp $tempfile ${HOME}/.profile
}

function installRecommendation {
	if [ -z "$LINUX_HOME_CONFIG_INSTALL" ]
	then
		echo "Do you want to install some software?"
		select LINUX_HOME_CONFIG_INSTALL in "Yes" "No"; do
			case $LINUX_HOME_CONFIG_INSTALL in
			"Yes"|"yes"|"No"|"no" ) break;;
			esac
		done
	fi
	case $LINUX_HOME_CONFIG_INSTALL in
	"No"|"no" )  return 0;;
	esac

		pkgManCMD
		DB_UPDATED=0
		for cmd in "$VIM_PKG_NAME" tree curl wget screen git htop
		do
			command -v "$cmd" >/dev/null 2>&1
			if [ "$?" -ne 0 ]
			then
				if [ "$PKG_MAN" ]
				then
					# update db only once
					if [ "$DB_UPDATED" -eq 0 ]
					then
						$PKG_MAN_UPDATE_DB
						let DB_UPDATED++
					fi
					$PKG_MAN_INSTALL $cmd
				fi
			fi
		done
}

function pkgManCMD {
	PKG_MAN=""
	VIM_PKG_NAME="vim"
	for cmd in apt-get yum pacman pkg
	do
		command -v "$cmd" >/dev/null 2>&1
		if [ "$?" -eq 0 ]
		then
			PKG_MAN=true
			case "$cmd" in
				"apt-get")
					PKG_MAN_UPDATE_DB="${IS_ROOT} apt-get update"
					PKG_MAN_INSTALL="${IS_ROOT} apt-get -y install"
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
	if [ "$UID" -eq 0 ]
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
	if command -v "$1" >/dev/null 2>&1
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

cd "${HOME}"
mkdir -p ${home_path}/{old-config-files,persistent}
rm -r ${home_path}/{old-config-files,persistent}/{.[!.],}* "$configfile"
for file in .vimrc .vimrc.lite .vimrc.template .vim .bashrc .bash_aliases .profile .gitconfig .inputrc
do
	if [ -f "$file" ] || [ -d "$file" ]
	then
		mv -f "$file" ${home_path}/old-config-files/${file}
		echo "Backup of $file under ${home_path}/old-config-files/${file}"
	fi
done
touch "$tempfile"
touch "$configfile"

curlOrWget

if [ -z "$LINUX_HOME_CONFIG_MIRROR" ]
then
	echo "Which mirror do you want to use?"
	select LINUX_HOME_CONFIG_MIRROR in "Custom" "Github"; do
		case $LINUX_HOME_CONFIG_MIRROR in
		"Custom"|"Github" ) break;;
		esac
	done
fi
case $LINUX_HOME_CONFIG_MIRROR in
Custom ) customMirrorURLQ; break;;
Github ) URL="https://github.com/mueller-ma/linux-home-config/archive/master.tar.gz"; break;;
Cancel ) echo "You don't have the config files in your \$HOME directory now!"; exit;;
esac

echo "URL="$URL"" >> "$configfile"

downloadAll

echo

if [ -z "$LINUX_HOME_CONFIG_AUTOSYNC" ]
then
	echo "Do you want to set up auto sync?"
	select LINUX_HOME_CONFIG_AUTOSYNC in "Yes" "No"; do
		case $LINUX_HOME_CONFIG_AUTOSYNC in
			"Yes"|"yes"|"No"|"no" ) break;;
		esac
	done
fi
case $LINUX_HOME_CONFIG_AUTOSYNC in
	"Yes"|"yes" ) addAutoSync;
esac

echo

isRoot
if [[ "$IS_ROOT" != "false" ]]
then
	installRecommendation
fi

echo

if $(isInstalledEditor vim) 2>/dev/null
then
	if [ "$UID" -eq 0 ]
	then
		echo "Your editor is rvim"
		echo -e "\n# Use rVIM instead of VI\nalias vi='rvim -p -u ~/.vimrc.lite'" >> ${HOME}/.bash_aliases
		echo -e "\n# Use rVIM instead of VI\nalias vi='rvim -p -u ~/.vimrc.lite'" >> ${HOME}/${home_path}/persistent/A.bash_aliases
		echo -e "\n# Use rVIM instead of VIM\nalias vim='rvim -p -u ~/.vimrc.lite'" >> ${HOME}/.bash_aliases
		echo -e "\n# Use rVIM instead of VIM\nalias vim='rvim -p -u ~/.vimrc.lite'" >> ${HOME}/${home_path}/persistent/A.bash_aliases
	else
		echo "Your editor is vim"
		echo -e "\n# Use VIM instead of VI\nalias vi='vim'" >> ${HOME}/.bash_aliases
		echo -e "\n# Use VIM instead of VI\nalias vi='vim'" >> ${HOME}/${home_path}/persistent/A.bash_aliases
	fi
else
	echo "What is your favorite editor?"
	select editor in "vi" "vim" "rvim" "emacs" "nano" "ed" "Cancel"; do
		case $editor in
		vi ) isInstalledEditor vi && break;;
		vim ) isInstalledEditor vim && break;;
		rvim ) isInstalledEditor rvim && break;;
		emacs ) isInstalledEditor emacs && break;;
		nano ) isInstalledEditor nano && break;;
		ed ) isInstalledEditor ed && break;;
		Cancel ) exit;;
		esac
	done
	unset editor
fi

echo

if [ -z "$LINUX_HOME_CONFIG_TUX" ]
then
	echo "Do you like Tux?"
	select LINUX_HOME_CONFIG_TUX in "Yes" "No"; do
		case $LINUX_HOME_CONFIG_TUX in
			"Yes"|"yes"|"No"|"no" ) break;;
		esac
	done
fi
case $yn in
	Yes ) echo ':)';;
	No ) removeGreeting; echo ':(';;
esac

chmod -R o-rwx,g-rwx ${HOME}/${home_path}/

rm "$tempfile"
