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
directory "#{node['nginx']['webroot']}" do
  recursive true
  owner node['user']['new_user']
  group "www-data"
  mode 00644
  action :create
end

# create php test file in the webroot
template "#{node['nginx']['webroot']}/index.php" do
  source "php-test.erb"
  owner node['user']['new_user']
  group "www-data"
  mode 00644
end

# create nginx server block file
template "#{node['nginx']['dir']}/sites-available/webapp" do
  source "webapp.erb"
  owner "root"
  group "root"
  mode 00644
  notifies :reload, 'service[nginx]'
end

# enable the server block we just created
nginx_site 'webapp' do
  enable true
end

