# Revolution R
node.default['rro']['version'] = '3.2.2'

# RStudio Server
node.default['rstudio']['version'] = '0.99'
node.default['rstudio']['rserver']['listen-address'] = '127.0.0.1'
node.default['rstudio']['rserver']['port'] = '8787'
node.default['rstudio']['rsession']['session-timeout'] = 20

# Apache Web Server
node.default['apache']['default_site_enabled'] = false
node.default['apache']['prefork']['startservers'] = 2
node.default['apache']['prefork']['serverlimit'] = 4
node.default['apache']['prefork']['maxclients'] = 6

# Ark
node.default['ark']['prefix_home'] = '/home/vagrant'

# Build essential
node.default['build-essential']['compile_time'] = true

# MySql
node.default['mysql']['version'] = '5.5'
node.default['mysql']['port'] = '3306'
node.default['mysql']['data_dir'] = '/var/lib/mysql'
node.default['mysql']['socket'] = '/var/run/mysqld/mysqld.sock'
node.default['mysql']['initial_root_password'] = 'youreallyshouldchangeme'

