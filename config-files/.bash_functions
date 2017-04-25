# This file was generated by ~/.linux_home_config/install.sh and will be overridden by ~/.linux_home_config/update.sh
# To make permanent changes (e. g. in .bashrc), create the file "A.bashrc" in ~/.linux_home_config/persistent/ and run ~/.linux_home_config/update.sh

# This file is sourced by .bashrc

# some cd commands
function -() { cd -; }
function --() { cd --; }

function ..() { cd ..; }
function ...() { cd ../..; }
function ....() { cd ../../..; }
function .....() { cd ../../../..; }
function ......() { cd ../../../../..; }
function .......() { cd ../../../../../..; }

# show line numbers except in pipelines
function grep() { 
    if [ -t 1 ] && [ -t 0 ]; then 
        command grep -n "$@"
    else 
        command grep "$@"
    fi
}

function search-in-file() {
	find . -type f -exec grep -i -q "$@" {} \; -printf '%h/%f\n'
}

if [ ! -f /usr/share/bash-completion/completions/apt ]
then
	# Debian apt(8) completion                             -*- shell-script -*-
	echo "source apt bash-completion"

	_apt()
	{
		local sourcesdir="/etc/apt/sources.list.d"
		local cur prev words cword
		_init_completion || return

		# see if the user selected a command already
		local COMMANDS=("install" "remove" "purge" "show" "list"
						"update" "upgrade" "full-upgrade" "dist-upgrade"
						"edit-sources" "help" "search")

		local command i
		for (( i=0; i < ${#words[@]}-1; i++ )); do
			if [[ ${COMMANDS[@]} =~ ${words[i]} ]]; then
				command=${words[i]}
				break
			fi
		done

		# supported options per command
		if [[ "$cur" == -* ]]; then
			case $command in
				install|remove|purge|upgrade|full-upgrade)
					COMPREPLY=( $( compgen -W '--show-progress
					--fix-broken --purge --verbose-versions --auto-remove
					--simulate --dry-run
					--download
					--fix-missing
					--fix-policy
					--ignore-hold
					--force-yes
					--trivial-only
					--reinstall --solver' -- "$cur" ) )
					return 0
					;;
				update)
					COMPREPLY=( $( compgen -W '--list-cleanup 
					' -- "$cur" ) )
					return 0
					;;
				list)
					COMPREPLY=( $( compgen -W '--installed --upgradable 
					--manual-installed
					-v --verbose
					-a --all-versions
					' -- "$cur" ) )
					return 0
					;;
				show)
					COMPREPLY=( $( compgen -W '-a --all-versions
					' -- "$cur" ) )
					return 0
					;;
				search)
					COMPREPLY=( $( compgen -W '-a' -- "$cur" ) )
					return 0
					;;
			esac
		fi

		# specific command arguments
		if [[ -n $command ]]; then
			case $command in
				remove|purge)
					if [[ -f /etc/debian_version ]]; then
						# Debian system
						COMPREPLY=( $( \
							_xfunc dpkg _comp_dpkg_installed_packages $cur ) )
					else
						# assume RPM based
						_xfunc rpm _rpm_installed_packages
					fi
					return 0
					;;
				install|show|list|search)
					COMPREPLY=( $( apt-cache --no-generate pkgnames "$cur" \
						2> /dev/null ) )
					return 0
					;;
				edit-sources)
					COMPREPLY=( $( compgen -W '$( command ls $sourcesdir )' \
						-- "$cur" ) )
					return 0
					;;
			esac
		fi

		# no command yet, show what commands we have
		if [ "$command" = "" ]; then
			COMPREPLY=( $( compgen -W '${COMMANDS[@]}' -- "$cur" ) )
		fi

		return 0
	} &&
	complete -F _apt apt
fi
