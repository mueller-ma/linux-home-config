#!/usr/bin/env bash
set -xv

home_path=".linux-home-config"
tempfile="${HOME}/${home_path}/temp"
configfile="${HOME}/${home_path}/config"

function removeGreeting {
	sed -e 's/greeting=true/#greeting=true/' ${HOME}/.bashrc > $tempfile
	cp $tempfile ${HOME}/.bashrc
}

function addAutoSync {
echo -e '# Autoupdate of config file (e.g. this file, .bash_aliases, .vimrc)\n${HOME}/.linux-home-config/update.sh' >> ${HOME}/.bashrc
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
	# go to extracted files
	cd linux-home-config-master/config-files
	# copy all files to ~
	cp -r {.[!.],}* ${HOME} 2>/dev/null
	# copy installer in linux-home-config folder
	cd ..
	cp install.sh ${HOME}/${home_path}/install.sh
	cp update.sh ${HOME}/${home_path}/update.sh
	# remove tar ball
	rm ../master.tar.gz
	# Generate vimrc and vimrc.lite
	cd $HOME
	cat .vimrc.template | grep -v ' " lite-only' | sed --posix -r 's/ " lite//' > ${HOME}/.vimrc
	cat .vimrc.template | grep ' " lite' | sed --posix -r 's/ " lite(.*)//' > ${HOME}/.vimrc.lite
}

cd "${HOME}"
source "$configfile"

#URL_NO_HTTP=${URL#http*://}
#URL_NO_HTTP_AND_PATH=${URL_NO_HTTP%%/*}
#ping -c1 $URL_NO_HTTP_AND_PATH 2>&1 >/dev/null || exit 1

mkdir -p ${home_path}/old-config-files
rm -r ${home_path}/old-config-files/.*
for file in .vimrc .vimrc.lite .vimrc.template .vim .bashrc .bash_aliases .profile .gitconfig .inputrc
do
	if [ -f "$file" ] || [ -d "$file" ]
	then
		cp -r "$file" ${home_path}/old-config-files/${file}
		#echo "Backup of $file under ${home_path}/old-config-files/${file}"
	fi
done
touch "$tempfile"

downloadAll #and install

if [ -n "$removeGreeting" ]
then
	removeGreeting
fi

if [ -n "$AutoSync" ]
then
	addAutoSync
fi

for file in ${HOME}/${home_path}/persistent/A*
do
	name=${file##*/A}
	cat "$file" >> ${HOME}/${name}
done

chmod -R o-rwx ${HOME}/${home_path}/

if [ "$UID" -eq 0 ] && [ -n "$SUDO_USER" ] && [[ "$HOME" != "/root" ]]
then
	chown -R ${SUDO_USER}: ${HOME}/${home_path}/
fi

rm $tempfile
exit
