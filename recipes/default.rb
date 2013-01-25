#
# Cookbook Name:: nginx-php-fpm
# Recipe:: default
# Author:: Shen DeShayne <shennyg@gmail.com>
#

# create new user
user_account node['user']['new_user'] do
  ssh_keys node['user']['authorized_keys']
end

# install nginx
include_recipe 'nginx'

# create webroot
execute "make-webroot" do
  command "mkdir -p #{node['nginx']['webroot']}"
  action :run
end

# create php test file in the webroot
template "#{node['nginx']['webroot']}/index.php" do
  source "php-test.erb"
  owner "root"
  group "root"
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

