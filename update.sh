#!/usr/bin/env bash

home_path=".linux-home-config"
tempfile="${HOME}/${home_path}/temp"
configfile="${HOME}/${home_path}/config"

function removeOpenhab {
	cd $HOME
	rm .vim/{ftdetect,syntax}/openhab.vim
}

function removeGreeting {
	sed -e 's/greeting=true/#greeting=true/' ${HOME}/.bashrc > $tempfile
	cp $tempfile ${HOME}/.bashrc
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
}

cd ${HOME}
mkdir -p ${home_path}/old-config-files
rm -r ${home_path}/old-config-files/.* 2>/dev/null
for file in .vimrc .vim .bashrc .bash_aliases .profile
do
	if [ -f $file ] || [ -d $file ]
	then
		mv -f $file ${home_path}/old-config-files/${file}
		#echo "Backup of $file under ${home_path}/old-config-files/${file}"
	fi
done
touch $tempfile
source $configfile

downloadAll #and install

if [ -n $removeOpenhab ]
then
	removeOpenhab
fi

if [ -n $removeGreeting ]
then
	removeGreeting
fi

rm $tempfile
