require 'yaml'

# Import base configuration from YAML file
dir = File.dirname(File.expand_path(__FILE__))
data = YAML::load(File.open("#{dir}/vagrant/config.yaml"))

Vagrant.require_version ">= 1.4.0"
Vagrant.configure("2") do |config|

    # Hostmanager plugin configuration.
    config.hostmanager.enabled = true
    config.hostmanager.ignore_private_ip = false
    config.hostmanager.include_offline = true
    config.hostmanager.manage_host = true

    config.vbguest.auto_update = false

    # Every Vagrant virtual environment requires a box to build off of.
    # We're supplying the url from where the box will be fetched if it
    # doesn't already exist on the users system.
    config.vm.box = "#{data['vm']['box']}"
    config.vm.box_url = "#{data['vm']['box_url']}"

    if data['vm']['hostname'].to_s != ''
      config.vm.hostname = "#{data['vm']['hostname']}"
    end

    if data['vm']['network']['private_network'].to_s != ''
      config.vm.network "private_network", ip: "#{data['vm']['network']['private_network']}"
    end

    data['vm']['network']['forwarded_port'].each do |i, port|
      if port['guest'] != '' && port['host'] != ''
        config.vm.network :forwarded_port, guest: port['guest'].to_i, host: port['host'].to_i
      end
    end

    data['vm']['synced_folder'].each do |i, folder|
      if folder['source'] != '' && folder['target'] != '' && folder['id'] != ''
        nfs = (folder['nfs'] == "true") ? "nfs" : nil
        mount_options = !folder['mount_options'].empty? ? folder['mount_options'] : nil
        config.vm.synced_folder "#{folder['source']}", "#{folder['target']}",
                                id: "#{folder['id']}", type: nfs, mount_options: mount_options
      end
    end

    if !data['vm']['provider']['virtualbox'].empty?
      config.vm.provider :virtualbox do |virtualbox|
        data['vm']['provider']['virtualbox']['modifyvm'].each do |key, value|
          if key == "natdnshostresolver1"
            value = value ? "on" : "off"
          end
          virtualbox.customize ["modifyvm", :id, "--#{key}", "#{value}"]
        end
      end
    end

    # Before puppet provisioner (to update packages).
    config.vm.provision "shell" do |s|
      s.path = "vagrant/shell/initial-setup.sh"
      s.args = "/vagrant/vagrant"
    end
    config.vm.provision :shell, :path => "vagrant/shell/update-puppet.sh"
    config.vm.provision :shell, :path => "vagrant/shell/librarian-puppet-vagrant.sh"

    config.vm.provision :puppet do |puppet|
      ssh_username = !data['ssh']['username'].nil? ? data['ssh']['username'] : "vagrant"
      puppet.facter = {
        "ssh_username" => "#{ssh_username}"
      }
      puppet.manifests_path = "#{data['vm']['provision']['puppet']['manifests_path']}"
      puppet.manifest_file = "#{data['vm']['provision']['puppet']['manifest_file']}"

      if !data['vm']['provision']['puppet']['options'].empty?
        puppet.options = data['vm']['provision']['puppet']['options']
      end
    end

    if !data['ssh']['host'].nil?
      config.ssh.host = "#{data['ssh']['host']}"
    end
    if !data['ssh']['port'].nil?
      config.ssh.port = "#{data['ssh']['port']}"
    end
    if !data['ssh']['private_key_path'].nil?
      config.ssh.private_key_path = "#{data['ssh']['private_key_path']}"
    end
    if !data['ssh']['username'].nil?
      config.ssh.username = "#{data['ssh']['username']}"
    end
    if !data['ssh']['guest_port'].nil?
      config.ssh.guest_port = data['ssh']['guest_port']
    end
    if !data['ssh']['shell'].nil?
      config.ssh.shell = "#{data['ssh']['shell']}"
    end
    if !data['ssh']['keep_alive'].nil?
      config.ssh.keep_alive = data['ssh']['keep_alive']
    end
    if !data['ssh']['forward_agent'].nil?
      config.ssh.forward_agent = data['ssh']['forward_agent']
    end
    if !data['ssh']['forward_x11'].nil?
      config.ssh.forward_x11 = data['ssh']['forward_x11']
    end
    if !data['vagrant']['host'].nil?
      config.vagrant.host = data['vagrant']['host'].gsub(":", "").intern
    end
end
