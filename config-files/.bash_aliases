# This file was generated by ~/.linux_home_config/install.sh and will be overridden by ~/.linux_home_config/update.sh
# To make permanent changes (e. g. in .bashrc), create the file "A.bashrc" in ~/.linux_home_config/persistent/ and run ~/.linux_home_config/update.sh

# This file is sourced by .bashrc

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

# Vim aliases
alias vim='vim -p'
alias rvi='rvim -p -u ~/.vimrc.lite'
alias rvim='rvim -p -u ~/.vimrc.lite'

# Show the 15 largest files/folder in the current directory
alias show-large-files='du -sh * 2>/dev/null | sort -rh | head -n 15'

# Switch between long and short $PS1
alias short-ps1='PS1="$PS1_SHORT"'
alias long-ps1='PS1="$PS1_LONG"'

# Git aliases
alias gita='git add .'
alias gitc='git commit -m'
alias gitd='git diff --staged'
alias gits='git status'
alias gitr='git reset'
alias gitad='git add . && git diff --staged'

# Type alias
alias type='type -a'

# DF alias
alias df='df -h'

# PS alias
alias mps='ps auxfww'

# Show svg files with `feh` if `convert` (supplied by ImageMagick) is installed
if command -v "feh" >/dev/null 2>&1 && command -v "convert" >/dev/null 2>&1
then
    alias feh='feh --magick-timeout 10'
fi

# Show active internet connections (only servers)
alias netstat-tulpen='sudo netstat -tulpen'
alias mnetstat='sudo netstat -tulpen'

# Remove orphaned packages
if command -v "pacman" >/dev/null 2>&1
then
    alias pacman-autoremove='sudo pacman -Rns $(pacman -Qtdq)'
fi

alias linux-home-config-update='cd && .linux-home-config/start-update.sh && source .bashrc .bash_aliases .bash_functions && cd -'
