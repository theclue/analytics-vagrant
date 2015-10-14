#########################################################
#
# Install and configure a PAM module for authenticating
# RStudio Server without the need of a local account with
# SSH grants
#
# from: https://github.com/sprintly/rstudio-chef/blob/master/recipes/pam.rb
#
include_recipe 'rstudio::server'

package "libpam-pwdfile" do
    action :install
end

if Chef::Config[:solo]
  Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
else
  users = search(:users, 'groups:rstudio')

  template "/etc/rstudio/passwd" do
    source "rstudio/passwd.erb"
    owner 'rstudio-server'
    group 'rstudio-server'
    mode 0640
    variables(
      :users => users
    )
    notifies :restart, "service[rstudio-server]"
  end

  cookbook_file "/etc/pam.d/rstudio" do
    source "pam/rstudio"
    owner "root"
    group "root"
    mode 0644
  end
end