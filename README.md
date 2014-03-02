# PHP/Nginx/MySQL vagrant box

Be patient with the `vagrant up` as it can take up to an hour depending on your connection.

Simple vagrant build for a general php/mysql setup on nginx. This will boot up an nginx/php/mysql ubuntu box for a single instance. It uses host manager for easy local DNS configuration.

This particular box also installs some [CakePHP](https://github.com/cakephp/cakephp) dependencies.

Requirements
------------

- [Virtualbox 4.3](https://www.virtualbox.org)
- [Vagrant 1.4](http://www.vagrantup.com)
- [Vagrant Vbguest Plugin](https://github.com/dotless-de/vagrant-vbguest)
- [Vagrant Hostmanager Plugin](https://github.com/smdahlen/vagrant-hostmanager)

Installation
-------

1. Navigate inside the vagrant folder and create the guest machine
`vagrant up`

2. After the installation finishes, visit the chosen domain:
`http://app.dev`

Customisation
------------

All settings can be found in `vagrant/config.yaml`.


Adding Modules
--------------

Puppet modules are managed by [Librarian-Puppet](https://github.com/rodjek/librarian-puppet)
Add any extra modules to the [Puppetfile](vagrant/puppet/Puppetfile)


## MySQL Access

MySQL can be accessed internally on the box by SSHing into it using `vagrant ssh`, or, by using a desktop client (or command-line) from your host machine. The MySQL server package has been pre-configured to allow access from your remote machine using a combination of the private IP address from vagrant and the generated users credentials. You can connect using a command (from your host machine) like the following:

``` bash
mysql --host=192.168.99.16 --user=username --password=password
```

### Connecting to MySQL via SequelPro or MySQL Workbench  

Create a new SSH connection with the following settings


__MySQL Host:__ 192.168.99.16  
__Username:__ root  
__Password:__ 123456  


__SSH Host:__ 192.168.99.16  
__SSH User:__ vagrant  
__SSH password:__ vagrant



## Node Dependencies

There is a statement included in the puppet files to search your `$siteRoot` for a `package.json` file. If one is found, then the command `npm install` will be run on your behalf. The longer a project runs the more likely its dependencies will change. If you add or remove packages from your `package.json` file, simply run `vagrant provision` to have it re-run the `npm install` command.

## Troubleshooting

Please note that running `vagrant up` for the first time can come with some issues to fix up. If you run into any issues please refer to the [troubleshooting documentation](https://github.com/rehabstudio/vagrant-puppet-cakephp/wiki/Troubleshooting) and if you have anything to add to this please do.


