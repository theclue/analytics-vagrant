#########################################################
#
# Install and configure a PAM module for authenticating
# RStudio Server without the need of a local account with
# SSH grants
#
# from: https://github.com/sprintly/rstudio-chef/blob/master/recipes/pam.rb
#
include_recipe "analytics::rstudio"

package "libpam-pwdfile" do
    action :install
end

  # The search is performed using chef-solo-search
  # Migrating to Chef-ZERO will be considered sooner or later...
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
    source "pam/etc/pam.d/rstudio"
    owner "root"
    group "root"
    mode 0644
  end
