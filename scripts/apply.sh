#!/bin/bash -eux

TOP=$(git rev-parse --show-toplevel 2>/dev/null)

if [[ -z $TOP ]]; then
	echo "Must be run inside the Git repsitory." >&2
	exit 1
fi

ansible-playbook -i 'localhost,' ansible/playbook.yml
