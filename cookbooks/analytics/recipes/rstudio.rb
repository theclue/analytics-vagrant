#########################################################
#
# Install and configure a RStudio Server stack
#
# - install RStudio Server
# - configure the apache proxy
# - create a default user
#

### requirements ###
#-------------------
include_recipe "analytics::default"
include_recipe "apache2::mod_proxy"
include_recipe "apache2::mod_proxy_http"

%w{ libapparmor1 apparmor-utils }.each do |a_package|
  package a_package
end

###### install rstudio server ######
#-----------------------------------
rstudio_remote = value_for_platform(
    %w|ubuntu debian| => {
      'default' => "rstudio-server-#{node['rstudio']['version']}-#{node['kernel']['machine'] =~ /x86_64/ ? 'amd64' : 'i386'}.deb"
    },
    %w|centos redhat amazon scientific| => {
      'default' => "rstudio-server-rhel#{(if node['platform_version'].to_i >= 6 then "" else "5" end)}-#{node['rstudio']['version']}-#{node['kernel']['machine'] =~ /x86_64/ ? 'x86_64' : 'i686'}.rpm"
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
Chef::Log.info('Retrieving RStudio Server file.')
remote_file "#{Chef::Config[:file_cache_path]}/#{rstudio_remote}" do
  source "#{rstudio_url_prefix}/#{rstudio_remote}"
  action :create_if_missing
  not_if { ::File.exists?('/etc/init/shiny-server.conf') }      
  mode 0644
end

case node['platform']
when 'ubuntu', 'debian'
  package "rstudio-server" do
    provider Chef::Provider::Package::Gdebi
    source "#{Chef::Config[:file_cache_path]}/#{rstudio_remote}"
    action :install
  end
when 'centos', 'redhat', 'amazon', 'scientific'
  yum_package 'rstudio-server' do
    source "#{Chef::Config[:file_cache_path]}/#{rstudio_remote}"
    action :install
  end
end

service "rstudio-server" do
    provider Chef::Provider::Service::Upstart
    supports :start => true, :stop => true, :restart => true
    action :restart
 end

template "/etc/rstudio/rserver.conf" do
    source "rstudio/rserver.conf.erb"
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
    source "rstudio/rsession.conf.erb"
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

# create and configure the web app
web_app "rstudio" do
  template 'rstudio.web.conf.erb'
end

# allow rstudio server to use apache proxy
template '/etc/apache2/mods-enabled/proxy.conf' do
  source 'proxy.conf.erb'
  owner 'root'
  group 'root'
  mode 0777
  notifies :restart, "service[apache2]"
end