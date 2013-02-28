#
# Cookbook Name:: nginx-php-fpm
# Recipe:: default
# Author:: Shen DeShayne <shennyg@gmail.com>
#

# create new user
user_account node['user']['new_user'] do
  ssh_keys node['user']['authorized_keys']
end

# add user to www-data group
group "www-data" do
  action :modify
  members node['user']['new_user']
  append true
end

# install nginx
include_recipe 'nginx'

# create webroot
directory node['nginx']['webroot'] do
  recursive true
  owner node['user']['new_user']
  group "www-data"
  mode 00755
  action :create
end

# create php test file in the webroot
template "#{node['nginx']['webroot']}/index.php" do
  source "php-test.erb"
  owner node['user']['new_user']
  group "www-data"
  mode 00755
  only_if { node['show_phpinfo_as_index'] }
end

package "php5-mysql" do
  action :install
end

package "php-apc" do
  action :install
end

package "php5-curl" do
  action :install
  notifies :reload, 'service[php5-fpm]'
end

# create nginx server block file
template "#{node['nginx']['dir']}/sites-available/webapp" do
  source "webapp.erb"
  owner "root"
  group "root"
  mode 00755
end

# enable the server block we just created
nginx_site 'webapp' do
  enable true
  notifies :reload, 'service[nginx]'
end

