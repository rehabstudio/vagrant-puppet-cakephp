#!/bin/bash

CODENAME=precise

if [[ ! -f /.install/update-puppet ]]; then
    echo "Downloading http://apt.puppetlabs.com/puppetlabs-release-${CODENAME}.deb"
    wget --quiet --tries=5 --connect-timeout=10 -O "/.install/puppetlabs-release-${CODENAME}.deb" "http://apt.puppetlabs.com/puppetlabs-release-${CODENAME}.deb"
    echo "Finished downloading http://apt.puppetlabs.com/puppetlabs-release-${CODENAME}.deb"

    dpkg -i "/.install/puppetlabs-release-${CODENAME}.deb" >/dev/null

    echo "Running update-puppet apt-get update"
    apt-get update >/dev/null
    echo "Finished running update-puppet apt-get update"

    echo "Updating Puppet to latest version"
    apt-get -y install puppet >/dev/null
    PUPPET_VERSION=$(puppet help | grep 'Puppet v')
    echo "Finished updating puppet to latest version: ${PUPPET_VERSION}"

    touch /.install/update-puppet
    echo "Created empty file /.install/update-puppet"
fi