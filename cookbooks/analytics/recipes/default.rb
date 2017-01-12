#########################################################
#
# Prepare the server with some preliminary installations
#
# - install Apache Web Server
# - install a JDK
# - install PHP
# - install gcc
# - install and update Revolution R Open
# - add users
#

### requirements ###
#-------------------
include_recipe "apt"
include_recipe "build-essential"
include_recipe "java"
include_recipe "openssl"
include_recipe "apache2"
include_recipe "apache2::mod_rewrite"
include_recipe "apache2::mod_ssl"
include_recipe "php"
include_recipe "php::module_mysql"
include_recipe "php::module_apc"
include_recipe "php::module_curl"
include_recipe "apache2::mod_php5"
include_recipe "ark"

# Install some useful packages
%w{ vim screen tmux mc subversion curl make g++ libsqlite3-dev graphviz libxml2-utils links git wget libgfortran3 libtcl8.6 libtk8.6 gdebi apt-file texlive-binaries libgdal1-dev gdal-bin libgdal-doc expat libxml2-dev gfortran libcurl4-openssl-dev ruby-shadow r-base-dev}.each do |a_package|
  package a_package
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

##### install revolution r stack ######
#--------------------------------------
rro_remote = value_for_platform(
    %w|ubuntu debian| => {
      'default' => "MRO-#{node['rro']['version']}-Ubuntu-#{node['platform_version'].to_i}.4.x86_64.deb"
    },
    %w|centos redhat amazon scientific| => {
      'default' => "MRO-#{node['rro']['version']}.el#{node['platform_version'].to_i}.x86_64.rpm"
    }
  )

remote_file "#{Chef::Config[:file_cache_path]}/#{rro_remote}" do
  source "https://mran.revolutionanalytics.com/install/mro/#{node['rro']['version']}/#{rro_remote}"
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
package "r-base-dev"

if node['rro']['version'] < "3.3.1"
  revomath_remote = "RevoMath-#{node['rro']['version']}.tar.gz"
  ark 'download_revomath' do
   url "https://mran.revolutionanalytics.com/install/mro/#{node['rro']['version']}/#{revomath_remote}"
   version node['rro']['version']
   path "#{Chef::Config[:file_cache_path]}/RevoMath-#{node['rro']['version']}"
   owner 'root'
   action :put
  end
end

# install some system packages useful for development and perform a general update
bash 'init_rro_system_packages' do
    code <<-EOH
    R -e "update.packages(checkBuilt = TRUE, ask = FALSE)"
    R -e "install.packages(c('testthat', 'roxygen2', 'devtools', 'packrat'), dependencies = TRUE)"
    EOH
end