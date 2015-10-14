name             "analytics"
maintainer       "Gabriele Baldassarre"
maintainer_email "gabriele@gabrielebaldassarre.com"
license          "MIT"
description      "Provide a full stack of applications for data analysis"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.1"

%w{ ubuntu debian redhat centos fedora scientific amazon}.each do |os|
  supports os
end

depends          "ark"
depends          "java"
depends          "openssl"
depends          "mysql"
depends          "mysql2_chef_gem"
depends          "database"
depends          "apache2"
depends          "php"
depends          "gdebi"
depends          "user"
depends          "chef-solo-search"

provides "rstudio"