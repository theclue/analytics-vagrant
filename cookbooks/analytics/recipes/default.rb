include_recipe "users"
include_recipe "apt"
include_recipe "build-essential"
include_recipe "java"
include_recipe "openssl"
include_recipe "apache2"
include_recipe "apache2::mod_rewrite"
include_recipe "apache2::mod_ssl"
include_recipe "apache2::mod_proxy"
include_recipe "apache2::mod_proxy_http"
include_recipe "php"
include_recipe "php::module_mysql"
include_recipe "php::module_apc"
include_recipe "php::module_curl"
include_recipe "apache2::mod_php5"
include_recipe "ark"

# Install some useful packages
%w{ debconf vim screen tmux mc subversion curl make g++ libsqlite3-dev graphviz libxml2-utils links git wget libmysql-java libgfortran3 libtcl8.6 libtk8.6 gdebi-core libapparmor1 apt-file texlive-binaries libgdal1-dev gdal-bin libgdal-doc expat apparmor-utils libxml2-dev gfortran libcurl4-openssl-dev }.each do |a_package|
  package a_package
end

# Install some required gems
mysql2_chef_gem 'default' do
  action :install
end

### web server configuration ###
#--------------------------------
apache_module "mpm_event" do
  enable false
end

apache_module "mpm_prefork" do
  enable true
end
    
    
service "apache2" do
  action :restart
end

### install mysql databases and clients    ###
#---------------------------------------------
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

# Configure sites
databases.each do |name|
  database = data_bag_item("databases", name)

  # databases
  mysql_database database['name'] do
    connection(
      :host     => '127.0.0.1',
      :username => 'root',
      :socket   => node['mysql']['socket'],
      :password => node['mysql']['initial_root_password']
    )
    action :create
  end
  
  # users
  mysql_database_user database['user'] do
    connection(
      :host     => '127.0.0.1',
      :username => 'root',
      :socket   => node['mysql']['socket'],
      :password => node['mysql']['initial_root_password']
      )
    password database['password']
    database_name database['name']
    privileges [:all]
    action :grant
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
# end of database-related provisioning

##### install revolution r stack ######
#--------------------------------------
rro_remote = value_for_platform(
    %w|ubuntu debian| => {
      'default' => "RRO-#{node['rro']['version']}-Ubuntu-#{node['platform_version'].to_i}.4.x86_64.deb"
    },
    %w|centos redhat amazon scientific| => {
      'default' => "RRO-#{node['rro']['version']}.el#{node['platform_version'].to_i}.x86_64.rpm"
    }
  )

remote_file "#{Chef::Config[:file_cache_path]}/#{rro_remote}" do
  source "https://mran.revolutionanalytics.com/install/#{rro_remote}"
  mode 0644
end

case node['platform']
when 'ubuntu', 'debian'
  dpkg_package "rro" do
    source "#{Chef::Config[:file_cache_path]}/#{rro_remote}"
    action :install
  end
when 'centos', 'redhat', 'amazon', 'scientific'
  yum_package 'rro' do
    source "#{Chef::Config[:file_cache_path]}/#{rro_remote}"
    action :install
  end
end

revomath_remote = "RevoMath-#{node['rro']['version']}.tar.gz"
ark 'download_revomath' do
   url "https://mran.revolutionanalytics.com/install/#{revomath_remote}"
   version node['rro']['version']
   path "#{Chef::Config[:file_cache_path]}/RevoMath-#{node['rro']['version']}"
   owner 'root'
   action :put
end

# force the path for R_HOME because of a bug in 3.2.2
# cfr: https://github.com/RevolutionAnalytics/RRO/issues/241
if node['rro']['version'] == "3.2.2"
  template "/usr/lib64/RRO-#{node['rro']['version']}/R-#{node['rro']['version']}/lib/R/bin/R" do
    source "R.erb"
    mode 0755
    owner "root"
    group "root"
    notifies :restart, "service[rstudio-server]"
    variables :version => {
      'full' => node['rro']['version']
    }
  end
end

# initial rro configuration
bash 'init_rro' do
    code <<-EOH
    R -e "update.packages(checkBuilt = TRUE, ask = FALSE)"
    R -e "install.packages(c('testthat', 'roxygen2', 'devtools'), dependencies = TRUE)"
    EOH
end
# end of revolution r stack

###### install rstudio server ######
#-----------------------------------
rstudio_remote = value_for_platform(
    %w|ubuntu debian| => {
      'default' => "rstudio-server-#{node['rstudio']['version']}.486-amd64.deb"
    },
    %w|centos redhat amazon scientific| => {
      'default' => "rstudio-server-rhel#{(if node['platform_version'].to_i >= 6 then "" else "5" end)}-#{node['rstudio']['version']}.486-x86_64.rpm"
    }
  )
  
rstudio_url_prefix = value_for_platform(
    %w|ubuntu debian| => {
      'default' => "https://download2.rstudio.org"
    },
    %w|centos redhat amazon scientific| => {
      'default' => (if node['platform_version'].to_i >= 6 then "https://download2.rstudio.org/" else "https://s3.amazonaws.com/rstudio-server" end)
    }
  )

remote_file "#{Chef::Config[:file_cache_path]}/#{rstudio_remote}" do
  source "#{rstudio_url_prefix}/#{rstudio_remote}"
  mode 0644
end

case node['platform']
when 'ubuntu', 'debian'
  dpkg_package "rstudio" do
    source "#{Chef::Config[:file_cache_path]}/#{rstudio_remote}"
    action :install
  end
when 'centos', 'redhat', 'amazon', 'scientific'
  yum_package 'rstudio' do
    source "#{Chef::Config[:file_cache_path]}/#{rstudio_remote}"
    action :install
  end
end

service "rstudio-server" do
    provider Chef::Provider::Service::Upstart
    supports :start => true, :stop => true, :restart => true
    action :start
 end

# TODO register rstudio as a service to get the automatic restart working
template "/etc/rstudio/rserver.conf" do
    source "rserver.conf.erb"
    mode 0644
    owner "root"
    group "root"
    notifies :restart, "service[rstudio-server]"
    variables :rserver => {
      'group' => node['rstudio']['rserver']['group'],
      'listen-address' => node['rstudio']['rserver']['listen-address'],
      'port' => node['rstudio']['rserver']['port'],
      'ld-library-path' => node['rstudio']['rserver']['ld-library-path'],
      'r-binary-path' => node['rstudio']['rserver']['r-binary-path']
    }
end

template "/etc/rstudio/rsession.conf" do
    source "rsession.conf.erb"
    mode 0644
    owner "root"
    group "root"
    notifies :restart, "service[rstudio-server]"
    variables :rsession => {
      'session-timeout' => node['rstudio']['rsession']['session-timeout'],
      'package-path' => node['rstudio']['rsession']['package-path'],
      'cran-repo' => node['rstudio']['rsession']['cran-repo']
    }
end

user "rstudio" do
  comment "Application execution user"
  uid 2000
  group [ "users", "rstudio" ]
  shell "/bin/false"
  home "/home/rstudio"
end

directory "/home/rstudio" do
  owner "rstudio"
  group "users"
  mode 0755
  action :create
end

# add additional users from the data_bag
users_manage "rstudio" do
  data_bag "users"
  group_name "rstudio"
  
end

web_app "rstudio" do
  template 'rstudio.web.conf.erb'
end

# allow rstudio to use apache proxy
template '/etc/apache2/mods-enabled/proxy.conf' do
  source 'proxy.conf.erb'
  owner 'root'
  group 'root'
  mode 0777
  notifies :restart, "service[apache2]"
end
# end of revolution rstudio stack