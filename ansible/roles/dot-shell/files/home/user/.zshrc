#
# ~/.zshrc: executed by zsh(1) for interactive shells.
#

#
# Use vi(1) key bindings.
#
bindkey -v

#
# The following is borrowed from emacs(1) mode.
#
bindkey '^P' up-history
bindkey '^N' down-history
bindkey '^R' history-incremental-search-backward
setopt NO_FLOW_CONTROL # Or the next command won't work
bindkey '^S' history-incremental-search-forward

#
# Set up history.
#
HISTFILE=~/.zsh_history
HISTSIZE=12000 # Larger than SAVEHIST for HIST_EXPIRE_DUPS_FIRST to work
SAVEHIST=10000

#
# Set up shell options.
#
setopt AUTO_CD                # Change to a directory just by typing its name
setopt AUTO_PUSHD             # Make cd push each old directory onto the stack
setopt CDABLE_VARS            # Like AUTO_CD, but for named directories
setopt EXTENDED_HISTORY       # Save time stamps and durations
setopt HIST_EXPIRE_DUPS_FIRST # Expire duplicates first
setopt HIST_IGNORE_DUPS       # Do not enter 2 consecutive duplicates into history
setopt HIST_IGNORE_SPACE      # Ignore command lines with leading spaces
setopt HIST_VERIFY            # Reload results of history expansion before executing
setopt INTERACTIVE_COMMENTS   # Allow comments in interactive mode
setopt PUSHD_IGNORE_DUPS      # Don't push duplicates onto the stack
setopt SHARE_HISTORY          # Constantly share history between shell instances

#
# scmpuff
#
eval "$(scmpuff init -s)"

#
# Alias definitions
#
if [[ -f ~/.aliases ]]; then
	. ~/.aliases
fi

#
# Function definitions
#
if [[ -d ~/.zsh/functions ]]; then
	fpath+=~/.zsh/functions
fi
autoload firefox
autoload google-chrome
autoload scp

#
# Enable programmable completion features.
#
autoload -Uz compinit
compinit

# Menu-style completion
zstyle ':completion:*' menu select

# use the vi navigation keys (hjkl) besides cursor keys in menu completion
zmodload zsh/complist
bindkey -M menuselect 'h' vi-backward-char        # left
bindkey -M menuselect 'k' vi-up-line-or-history   # up
bindkey -M menuselect 'l' vi-forward-char         # right
bindkey -M menuselect 'j' vi-down-line-or-history # bottom

# Use dircolors $LS_COLORS for completion when possible
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

#
# Set up prompt.
#
if [[ -f ~/.zsh/plugins/agkozak-zsh-prompt/agkozak-zsh-prompt.plugin.zsh ]]; then
	AGKOZAK_COLORS_PROMPT_CHAR='magenta'
	AGKOZAK_CUSTOM_SYMBOLS=('⇣⇡' '⇣' '⇡' '+' 'x' '!' '>' '?' 'S')
	AGKOZAK_FORCE_ASYNC_METHOD=none
	AGKOZAK_LEFT_PROMPT_ONLY=1
	AGKOZAK_MULTILINE=0
	AGKOZAK_PROMPT_CHAR=(❯ ❯ ❮)
	AGKOZAK_PROMPT_DIRTRIM=0
	. ~/.zsh/plugins/agkozak-zsh-prompt/agkozak-zsh-prompt.plugin.zsh
fi

# Write iso file to sd card
function iso-to-drive() {
	if [[ $# -ne 2 ]]; then
		echo "Usage: iso-to-drive <input_file> <device>"
		echo "Example: iso-to-drive ~/Downloads/ubuntu-25.04-desktop-amd64.iso /dev/sda"
		echo -e "\nAvailable drives:"
		lsblk -d -o NAME,SIZE | grep -E '^sd[a-z]' | awk '{print "/dev/" $1 " " $2}'
	else
		sudo dd bs=4M status=progress oflag=sync if="$1" of="$2"
		sudo eject $2
	fi
}

# Format an entire drive for a single partition using exFAT
function format-drive() {
	if [[ $# -ne 2 ]]; then
		echo "Usage: format-drive <device> <name>"
		echo "Example: format-drive /dev/sda 'My Stuff'"
		echo -e "\nAvailable drives:"
		lsblk -d -o NAME,SIZE | grep -E '^sd[a-z]' | awk '{print "/dev/" $1 " " $2}'
	else
		echo "WARNING: This will completely erase all data on $1 and label it '$2'."
		read -rp "Are you sure you want to continue? (y/N): " confirm

		if [[ $confirm =~ ^[Yy]$ ]]; then
			sudo wipefs -a "$1"
			sudo dd if=/dev/zero of="$1" bs=1M count=100 status=progress oflag=sync
			sudo parted -s "$1" mklabel gpt
			sudo parted -s "$1" mkpart primary 1MiB 100%

			partition="$([[ $1 == *"nvme"* ]] && echo "${1}p1" || echo "${1}1")"
			sudo partprobe "$1" || true
			sudo udevadm settle || true

			sudo mkfs.exfat -n "$2" "$partition"

			echo "Drive $1 formatted as exFAT and labeled '$2'."
		fi
	fi
}

#
# Required for $langinfo
#
zmodload zsh/langinfo

#
# Attempt to create a writable file descriptor to the TTY so that we can print
# to the TTY later even when STDOUT is redirected. This code is fairly subtle.
#
# - It's tempting to do `[[ -t 1 ]] && exec {_tty_fd}>&1` but we cannot do this
#   because it'll create a file descriptor >= 10 without O_CLOEXEC. This file
#   descriptor will leak to child processes.
# - Zsh doesn't expose dup3, which would have allowed us to copy STDOUT with
#   O_CLOEXEC. The only way to create a file descriptor with O_CLOEXEC is via
#   sysopen.
#
if [[ -z $_tty_fd ]]; then
	if zmodload zsh/system 2>/dev/null; then
		if [[ -w $TTY ]]; then
			sysopen -o cloexec -wu _tty_fd -- $TTY
		elif [[ -w /dev/tty ]]; then
			sysopen -o cloexec -wu _tty_fd -- /dev/tty
		fi
	fi
	if [[ -z $_tty_fd ]] && [[ -t 1 ]]; then
		_tty_fd=1
	fi
fi

#
# URL-encode a string (taken from oh-my-zsh)
#
# Encodes a string using RFC 2396 URL-encoding (%-escaped).
# See: https://www.ietf.org/rfc/rfc2396.txt
#
# By default, reserved characters and unreserved "mark" characters are
# not escaped by this function. This allows the common usage of passing
# an entire URL in, and encoding just special characters in it, with
# the expectation that reserved and mark characters are used appropriately.
# The -r and -m options turn on escaping of the reserved and mark characters,
# respectively, which allows arbitrary strings to be fully escaped for
# embedding inside URLs, where reserved characters might be misinterpreted.
#
# Prints the encoded string on stdout.
# Returns nonzero if encoding failed.
#
# Usage:
#  prompt_urlencode [-r] [-m] [-P] <string> [<string> ...]
#
#    -r causes reserved characters (;/?:@&=+$,) to be escaped
#
#    -m causes "mark" characters (_.!~*''()-) to be escaped
#
#    -P causes spaces to be encoded as '%20' instead of '+'
#
function prompt_urlencode() {
	emulate -L zsh
	setopt norematchpcre

	local -a opts
	zparseopts -D -E -a opts r m P

	local in_str="$@"
	local spaces_as_plus
	if [[ -z $opts[(r)-P] ]]; then spaces_as_plus=1; fi
	local str="$in_str"

	# URLs must use UTF-8 encoding; convert str to UTF-8 if required
	local encoding=$langinfo[CODESET]
	local safe_encodings
	safe_encodings=(UTF-8 utf8 US-ASCII)
	if [[ -z ${safe_encodings[(r)$encoding]} ]]; then
		str=$(echo -E "$str" | iconv -f $encoding -t UTF-8)
		if [[ $? != 0 ]]; then
			echo "Error converting string from $encoding to UTF-8" >&2
			return 1
		fi
	fi

	# Use LC_CTYPE=C to process text byte-by-byte
	# Note that this doesn't work in Termux, as it only has UTF-8 locale.
	# Characters will be processed as UTF-8, which is fine for URLs.
	local i byte ord LC_ALL=C
	export LC_ALL
	local reserved=';/?:@&=+$,'
	local mark='_.!~*''()-'
	local dont_escape="[A-Za-z0-9"
	if [[ -z $opts[(r)-r] ]]; then
		dont_escape+=$reserved
	fi
	# $mark must be last because of the "-"
	if [[ -z $opts[(r)-m] ]]; then
		dont_escape+=$mark
	fi
	dont_escape+="]"

	# Implemented to use a single printf call and avoid subshells in the loop,
	# for performance (primarily on Windows).
	local url_str=""
	for ((i = 1; i <= ${#str}; ++i)); do
		byte="$str[i]"
		if [[ $byte =~ $dont_escape ]]; then
			url_str+="$byte"
		else
			if [[ $byte == " " && -n $spaces_as_plus ]]; then
				url_str+="+"
			elif [[ $PREFIX == *com.termux* ]]; then
				# Termux does not have non-UTF8 locales, so just send the UTF-8 character directly
				url_str+="$byte"
			else
				printf -v ord '%02X' "'$byte"
				url_str+="%$ord"
			fi
		fi
	done
	echo -E "$url_str"
}

#
# Emits the control sequence to notify many terminal emulators
# of the cwd (taken from oh-my-zsh).
#
# Identifies the directory using a file: URI scheme, including
# the host name to disambiguate local vs. remote paths.
#
# See:
#
#     https://bugs.kde.org/show_bug.cgi?id=327720
#     https://bugs.kde.org/show_bug.cgi?id=336618
#
function set_osc7() {
	setopt localoptions unset

	# Ghostty has its own zsh integration
	[[ -z $GHOSTTY_RESOURCES_DIR ]] || return

	# Percent-encode the host and path names.
	local url_host url_path
	url_host="$(prompt_urlencode -P $HOST)" || return 1
	url_path="$(prompt_urlencode -P $PWD)" || return 1

	# Konsole errors if the HOST is provided
	[[ -z $KONSOLE_PROFILE_NAME && -z $KONSOLE_DBUS_SESSION ]] || url_host=""

	# common control sequence (OSC 7) to set current host and path
	if [[ -n $_tty_fd ]]; then
		print -nu $_tty_fd "\e]7;file://${url_host}${url_path}\a"
	fi
}

#
# Hook set_osc7 to report CWD changes.
#
if [[ -z $_osc7_initialized ]]; then
	_osc7_initialized=1
	chpwd_functions+=(set_osc7)
	# An executed program could change cwd and report the changed cwd, so also
	# report cwd at each new prompt, as chpwd_functions is insufficient.
	# chpwd_functions is still needed for things like: cd x && something
	precmd_functions+=(set_osc7)
fi
set_osc7

#
# Set the terminal title (OSC 2) for user-friendly display.
#
# In precmd: shows the abbreviated working directory.
# In preexec: shows the command being executed.
#
if [[ -n $_tty_fd ]] && [[ -z $GHOSTTY_RESOURCES_DIR ]] && [[ -z $_title_initialized ]]; then
	_title_initialized=1

	_title_precmd() {
		print -rnu $_tty_fd $'\e]2;'"${(%):-%(4~|…/%3~|%~)}"$'\a'
	}
	precmd_functions+=(_title_precmd)

	_title_preexec() {
		print -rnu $_tty_fd $'\e]2;'"${1//[[:cntrl:]]/}"$'\a'
	}
	preexec_functions+=(_title_preexec)
fi

#
# bun completions
#
[[ -s "${HOME}/.bun/_bun" ]] && source "${HOME}/.bun/_bun"
