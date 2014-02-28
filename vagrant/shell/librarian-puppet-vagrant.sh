#!/bin/bash

VAGRANT_CORE_FOLDER=$(cat "/.install/vagrant-core-folder.txt")
CODENAME=precise

# Directory in which librarian-puppet should manage its modules directory
PUPPET_DIR=/etc/puppet/

$(which git > /dev/null 2>&1)
FOUND_GIT=$?

if [ "${FOUND_GIT}" -ne '0' ] && [ ! -f /.install/librarian-puppet-installed ]; then
    echo 'Installing git'
    apt-get -q -y install git-core >/dev/null
    echo 'Finished installing git'
fi

if [[ ! -d "${PUPPET_DIR}" ]]; then
    mkdir -p "${PUPPET_DIR}"
    echo "Created directory ${PUPPET_DIR}"
fi

cp "${VAGRANT_CORE_FOLDER}/puppet/Puppetfile" "${PUPPET_DIR}"
echo "Copied Puppetfile"

if [[ ! -f /.install/librarian-base-packages ]]; then
    echo 'Installing base packages for librarian'
    apt-get install -y build-essential ruby-dev >/dev/null
    echo 'Finished installing base packages for librarian'

    touch /.install/librarian-base-packages
fi

if [[ ! -f /.install/librarian-libgemplugin-ruby ]]; then
    echo 'Updating libgemplugin-ruby (Ubuntu only)'
    apt-get install -y libgemplugin-ruby >/dev/null
    echo 'Finished updating libgemplugin-ruby (Ubuntu only)'

    touch /.install/librarian-libgemplugin-ruby
fi

if [[ ! -f /.install/librarian-puppet-installed ]]; then
    echo 'Installing librarian-puppet'
    gem install librarian-puppet >/dev/null
    echo 'Finished installing librarian-puppet'

    echo 'Running initial librarian-puppet'
    cd "${PUPPET_DIR}" && librarian-puppet install --clean >/dev/null
    echo 'Finished running initial librarian-puppet'

    touch /.install/librarian-puppet-installed
else
    echo 'Running update librarian-puppet'
    cd "${PUPPET_DIR}" && librarian-puppet update >/dev/null
    echo 'Finished running update librarian-puppet'
fi

echo "Replacing puppetlabs-git module with custom"
rm -rf /etc/puppet/modules/git
git clone https://github.com/puphpet/puppetlabs-git.git /etc/puppet/modules/git
echo "Finished replacing puppetlabs-git module with custom"
