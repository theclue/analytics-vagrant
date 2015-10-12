# encoding: UTF-8
#
# Cookbook Name:: system
# Attributes:: system
#
# Copyright 2012-2014, Chris Fordham
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

default['system']['timezone'] = 'Etc/UTC'

# just in case the node/image fails to have a proper hostname
if node['hostname']
  default['system']['short_hostname'] = node['hostname']
else
  default['system']['short_hostname'] = 'localhost'
end

default['system']['domain_name'] = 'localdomain'
default['system']['netbios_name'] = node['system']['short_hostname'].upcase
default['system']['workgroup'] = 'WORKGROUP'
default['system']['static_hosts'] = {}
default['system']['manage_hostsfile'] = true
default['system']['upgrade_packages'] = true
default['system']['permanent_ip'] = true
default['system']['primary_interface'] = node['network']['default_interface']
default['system']['enable_cron'] = true
default['system']['packages']['install'] = []
default['system']['packages']['install_compile_time'] = []

default['system']['packages']['uninstall'] = []
default['system']['packages']['uninstall_compile_time'] = []

default['system']['environment']['extra'] = {}
default['system']['profile']['path'] = []
default['system']['profile']['path_append'] = true
default['system']['profile']['append_scripts'] = []

# RightScale doesn't support boolean attributes in metadata
node.override['system']['permanent_ip'] = false if node['system']['permanent_ip'] == 'false'
node.override['system']['permanent_ip'] = true if node['system']['permanent_ip'] == 'true'
