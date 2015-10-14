# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

# Configuration parameters
ram = 4096                            # Ram in MB 
hostname = "analytics"                # The hostname for the box
machineName = "Open Analytics Stack"  # The machine name (for VirtualBox only)
cpus = 4                              # Number of cores

# Do not edit below this line
# --------------------------------------------------------------

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.define "analytics" do |master|
    #master.vm.network "private_network", type: "dhcp"
    master.vm.network "forwarded_port", guest: 80, host: 8080
    master.vm.hostname = hostname

    master.vm.provider "vmware_fusion" do |v|
      v.vmx["memsize"]  = ram.to_s
    end
    master.vm.provider :virtualbox do |v|
      v.name = machineName
      v.customize ["modifyvm", :id, "--memory", ram.to_s]
      v.customize ["modifyvm", :id, "--cpus", cpus.to_s]
    end
    
    # Disable tty for sudoers
    #master.vm.provision :shell, :inline => "sed -i 's/Defaults\ \ \ \ requiretty/#Defaults\ \ \ \ requiretty/g' /etc/sudoers"
    
    # Chef-solo
    master.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = "cookbooks"
      chef.roles_path = "roles"
      chef.data_bags_path = "data_bags"
      chef.add_role "analytics"
    end
  end
end
