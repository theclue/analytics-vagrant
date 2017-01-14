#########################################################
#
# Prepare the server with some preliminary installations
#
# - install Apache Web Server
# - install a JDK
# - install PHP
# - install gcc
# - install R
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
include_recipe "php::module_curl"
include_recipe "php-mcrypt"
include_recipe "apache2::mod_php5"
include_recipe "ark"
include_recipe "r"

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

# install some system packages useful for development and perform a general update
bash 'init_r_system_packages' do
    code <<-EOH
    R -e "update.packages(checkBuilt = TRUE, ask = FALSE)"
    EOH
end

%w{ testthat roxygen2 devtools packrat}.each do |a_package|
  r_package a_package
end