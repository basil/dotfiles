#
# ~/.zlogout: executed by zsh(1) when login shell exits.
#

#
# Logout script
#
if [[ -x ~/.logout ]]; then
	~/.logout
fi
