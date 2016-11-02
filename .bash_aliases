# ls aliases
alias ll='ls -lAhF --group-directories-first --time-style="+%H:%M %d.%m.%Y"'
alias la='ls -A'
alias l='ls -CFx'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Vim Tabs
alias vi='vim -p'
