#########################################################
#
# Install and configure a mariaDB stack
#
# - install mariaDB Server
# - configure an instance
# - install phpmyadmin
#

### requirements ###
#-------------------
include_recipe "analytics::default"
include_recipe "mariadb::server"

%w{ debconf libmysql-java }.each do |a_package|
  package a_package
end

# install phpmyadmin
template '/tmp/phpmyadmin.deb.conf' do
  source 'phpmyadmin.deb.conf.erb'
  owner 'root'
  group 'root'
  mode 0644
  variables :config => {
    'initial_root_password' => node['mariadb']['server_root_password']
    }
end
bash "debconf_for_phpmyadmin" do
  code "debconf-set-selections /tmp/phpmyadmin.deb.conf"
end
package "phpmyadmin"

# install DBI/RMySQL implementations
%w{ DBI RMySQL }.each do |a_package|
  r_package a_package
end
