#########################################################
#
# Install and configure a mySql stack
#
# - install mySql Server
# - configure an instance
# - create the databases enlisted in data_bags/databases
# - install phpmyadmin
#

### requirements ###
#-------------------
include_recipe "analytics::default"

%w{ debconf libmysql-java }.each do |a_package|
  package a_package
end

mysql2_chef_gem 'default' do
  action :install
end


##### install mysql databases and clients #####
#----------------------------------------------
mysql_service 'default' do
  port node['mysql']['port']
  version node['mysql']['version']
  socket node['mysql']['socket']
  initial_root_password node['mysql']['initial_root_password']
  action [:create, :start]
end

mysql_client 'default' do
  action :create
end

mysql_config 'analytics-optimizations' do
  instance 'default'
  source 'analytics-optimizations.cnf.erb'
  cookbook 'analytics'
  variables :config => {
    'name' => "default",
    'mysqld_options' => node['mysql']['options']
    }
  notifies :restart, 'mysql_service[default]'
  action :create
end

# install phpmyadmin
template '/tmp/phpmyadmin.deb.conf' do
  source 'phpmyadmin.deb.conf.erb'
  owner 'root'
  group 'root'
  mode 0644
  variables :config => {
    'initial_root_password' => node['mysql']['initial_root_password']
    }
end
bash "debconf_for_phpmyadmin" do
  code "debconf-set-selections /tmp/phpmyadmin.deb.conf"
end
package "phpmyadmin"

# install DBI/RMySQL implementations
bash 'init_rro_system_packages' do
    code <<-EOH
    R -e "install.packages(c('DBI', 'RMySQL'), dependencies = TRUE)"
    EOH
end
