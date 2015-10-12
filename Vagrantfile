# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

# Configuration parameters
ram = 2048                            # Ram in MB 

# Do not edit below this line
# --------------------------------------------------------------

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.define "analytics" do |master|
    master.vm.network :public_network, :bridge => 'eth0'
    master.vm.hostname = "analytics"

    master.vm.provider "vmware_fusion" do |v|
      v.vmx["memsize"]  = "#{ram}"
    end
    master.vm.provider :virtualbox do |v|
      v.name = master.vm.hostname.to_s
      v.customize ["modifyvm", :id, "--memory", "#{ram}"]
    end
    
    # Disable tty for sudoers
    #master.vm.provision :shell, :inline => "sed -i 's/Defaults\ \ \ \ requiretty/#Defaults\ \ \ \ requiretty/g' /etc/sudoers"
    
    # Chef-solo
    master.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = "cookbooks"
      chef.roles_path = "roles"
      chef.add_role "analytics"
    end
  end

end