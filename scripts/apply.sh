#!/bin/bash -eux

TOP=$(git rev-parse --show-toplevel 2>/dev/null)

if [[ -z $TOP ]]; then
	echo "Must be run inside the Git repository." >&2
	exit 1
fi

ansible-playbook -i 'localhost,' "$TOP/ansible/playbook.yml"
