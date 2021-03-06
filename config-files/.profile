# This file was generated by ~/.linux_home_config/install.sh and will be overridden by ~/.linux_home_config/update.sh
# To make permanent changes (e. g. in .bashrc), create the file "A.bashrc" in ~/.linux_home_config/persistent/ and run ~/.linux_home_config/update.sh

# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]
then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]
    then
        . "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ]
then
    PATH="$HOME/bin:$PATH"
fi

if command -v screen >/dev/null 2>&1
then
    running_screen=$(screen -ls)
    if [[ ! "$running_screen" =~ "No Sockets found in" ]]
    then
        echo
        echo "$running_screen" | grep -v '/var/run/screen'
    fi
    unset running_screen
fi

# If cowsay and fortunes is installed tux will quote Star Trek when starting bash
greeting=true
if [ -n "$greeting" ] && [ ! -f ~/.hushlogin ]
then
    fortune startrek >/dev/null 2>&1 && fortune=true
    cowsay -f tux foo >/dev/null 2>&1 && cowsay=true

    if [ "$fortune" = "true" ] && [ "$cowsay" = "true" ]
    then
        echo
        fortune startrek | cowsay -f tux
    elif [ "$cowsay" = "true" ]
    then
        echo
        echo "Hi $USER" | cowsay -f tux
    elif [ "$fortune" = "true" ]
    then
        fortune startrek
    fi
    unset fortune cowsay
fi
