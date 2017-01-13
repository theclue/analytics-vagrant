name             "analytics"
maintainer       "Gabriele Baldassarre"
maintainer_email "gabriele@gabrielebaldassarre.com"
license          "MIT"
description      "Provide a full stack of applications for data analysis in a server suitable for production environments"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.2.0"

%w{ ubuntu debian redhat centos fedora scientific amazon}.each do |os|
  supports os
end

depends          "r"
depends          "ark"
depends          "java"
depends          "openssl"
depends          "mysql"
depends          "mysql2_chef_gem"
depends          "database"
depends          "apache2"
depends          "php"
depends          "gdebi"
depends          "chef-solo-search"
depends          "chef-solo"
depends          "cron"
depends          "dmg"
depends          "hostsfile"

provides "analytics::default"
provides "analytics::mysql"
provides "analytics::rstudio"
provides "analytics::pam"