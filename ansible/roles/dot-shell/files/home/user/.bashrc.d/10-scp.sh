#!/bin/bash

#
# Fix a common error.
#
function scp() {
	if [[ $* =~ : ]]; then
		command scp "$@"
	else
		echo 'You forgot the colon, dumbass!' >&2
		return 1
	fi
}
