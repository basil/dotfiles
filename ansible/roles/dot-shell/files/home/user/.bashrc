#
# ~/.bashrc: executed by bash(1) for non-login shells.
#

#
# Source local exports.
#
if [[ -f ~/.exports ]]; then
	. ~/.exports
fi

#
# If not running interactively, don't do anything.
#
case $- in
*i*) ;;
*) return ;;
esac

#
# Source global definitions.
#
if [[ -f /etc/bashrc ]]; then
	. /etc/bashrc
fi

#
# Don't put duplicate lines or lines starting with space in the history. See
# bash(1) for more options.
#
export HISTCONTROL=ignoreboth
export HISTFILESIZE=20000
export HISTIGNORE='history*'
export HISTSIZE=10000

#
# Automatically correct mistyped directory names on cd.
#
shopt -s cdspell

#
# Check the window size after each command and, if necessary, update the values
# of LINES and COLUMNS.
#
shopt -s checkwinsize

#
# Attempt to save all lines of a multiple-line command in the same history
# entry. This allows easy re-editing of multi-line commands.
#
shopt -s cmdhist

#
# The history list is appended to the file when the shell exits (rather than
# overwriting the file). To enforce this aggressively, one could use:
#
#   chattr +a .bash_history
#
# or:
#
#   chflags uappnd ~/.bash_history
#
shopt -s histappend

#
# Alias definitions
#
if [[ -f ~/.aliases ]]; then
	. ~/.aliases
fi

alias rehash='. ~/.bashrc ; . ~/.bash_profile ; . ~/.bash_alias'

# Functions
function calc() {
	echo "$@" | bc -l
}

function myip() {
	/sbin/ifconfig -a | grep -v inet6 | grep inet | grep -v tunnel | grep -v "127.0.0.1" | awk '{print $2}' | cut -d : -f 2
}

function server() {
	host "$@" | grep "has address" | awk '{ print $4 }' | xargs host | awk '{ print $5 }'
}

if [[ $BASIL_DOTFILES_KERNEL == "Darwin" ]]; then
	function pdfman() {
		man -t "$@" | open -f -a Preview
	}
elif [[ $BASIL_DOTFILES_KERNEL == "Linux" ]]; then
	function c() {
		command google-chrome "$@" &
		disown
	}
	function f() {
		command firefox "$@" &
		disown
	}
	function svg2pdf() {
		inkscape --verb EditSelectAll --verb ObjectToPath -A "$*.pdf" "$@"
	}
fi

#
# Enable programmable completion features.
#
if [[ -f /etc/bash_completion ]]; then
	. /etc/bash_completion
elif [[ -f /usr/local/etc/bash_completion ]]; then
	. /usr/local/etc/bash_completion
elif [[ -f /etc/bash/bash_completion ]]; then
	. /etc/bash/bash_completion
elif [[ -f /opt/local/etc/bash_completion ]]; then
	. /opt/local/etc/bash_completion
fi

#
# Load any additional files found in the ".bashrc.d" directory.
#
if [[ -d ~/.bashrc.d ]]; then
	for rc in ~/.bashrc.d/*; do
		if [[ -f $rc ]]; then
			. "$rc"
		fi
	done
fi
unset rc
