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

# Initialize databases data bag
databases = []
begin
  databases = data_bag("databases")
rescue
  puts "Unable to load databases data bag."
end

# configure initial databases
databases.each do |name|
  database = data_bag_item("databases", name)

  # databases
  mysql_database database['id'] do
    connection(
      :host     => '127.0.0.1',
      :username => 'root',
      :socket   => node['mysql']['socket'],
      :password => node['mysql']['initial_root_password']
    )
    action :create
  end
  
  # users
  database["users"].each do |user, properties|
    mysql_database_user user do
      connection(
        :host     => '127.0.0.1',
        :username => 'root',
        :socket   => node['mysql']['socket'],
        :password => node['mysql']['initial_root_password']
        )
      password properties['password']
      database_name database['id']
      privileges [:all]
      action :grant
    end
  end
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
