#!/bin/bash

VAGRANT_CORE_FOLDER=$(echo "$1")

if [[ ! -d /.install ]]; then
    mkdir /.install

    echo "${VAGRANT_CORE_FOLDER}" > "/.install/vagrant-core-folder.txt"

    cat "${VAGRANT_CORE_FOLDER}/files/welcome.txt"
    echo "Created directory /.install"
fi

if [[ ! -f /.install/initial-setup-repo-update ]]; then
    echo "Running initial-setup apt-get update"
    apt-get update >/dev/null
    touch /.install/initial-setup-repo-update
    echo "Finished running initial-setup apt-get update"
fi

if [[ ! -f /.install/ubuntu-required-libraries ]]; then
    echo 'Installing basic curl packages (Ubuntu only)'
    apt-get install -y libcurl3 libcurl4-gnutls-dev curl >/dev/null
    echo 'Finished installing basic curl packages (Ubuntu only)'

    touch /.install/ubuntu-required-libraries
fi
