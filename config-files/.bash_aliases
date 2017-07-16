# This file was generated by ~/.linux_home_config/install.sh and will be overridden by ~/.linux_home_config/update.sh
# To make permanent changes (e. g. in .bashrc), create the file "A.bashrc" in ~/.linux_home_config/persistent/ and run ~/.linux_home_config/update.sh

# ls aliases
# More fancy when using GNU's ls
ls --version 2>/dev/null | grep -q "GNU"
if [ $? -eq 0 ]
then
	alias ll='ls -lAhF --group-directories-first --time-style="+%H:%M %d.%m.%Y"'
else
	alias ll='ls -lAhF'
fi
alias la='ls -A'
alias l='ls -CFx'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Vim Aliases
alias vim='vim -p'
alias rvi='rvim -p -u ~/.vimrc.lite'
alias rvim='rvim -p -u ~/.vimrc.lite'

# Show the 15 largest files/folder in the current directory
alias show-large-files='du -sh * 2>/dev/null | sort -rh | head -n 15'

# Short ps1
if [ "$UID" -eq 0 ]
then
	alias short-ps1='PS1="\[\033[0;31m\]\w\[\033[00m\]\$ "'
else
	alias short-ps1='PS1="\[\033[01;36m\]\w\[\033[00m\]\$ "'
fi

if [ "$UID" -eq 0 ]
then
	alias long-ps1='PS1="\[\033[0;31m\][\u@\h \w]\[\033[00m\]\$ "'
else
	alias long-ps1='PS1="[\u@\h \[\033[01;36m\]\w\[\033[00m\]]\$ "'
fi

# Git diff
alias gita='git add .'
alias gitc='git commit -m'
alias gitd='git diff --staged'
alias gits='git status'
alias gitr='git reset'
alias gitad='git add . && git diff --staged'

# type
alias type='type -a'
