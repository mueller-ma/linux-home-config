#!/usr/bin/env bash

home_path=".linux-home-config"
tempfile="${HOME}/${home_path}/temp"
configfile="${HOME}/${home_path}/config"

mv "${HOME}/${home_path}/update.sh" "${HOME}/${home_path}/update.old.sh"
chmod +x "${HOME}/${home_path}/update.old.sh"
"${HOME}/${home_path}/update.old.sh"
rm "${HOME}/${home_path}/update.old.sh"
