#
# Cookbook Name:: app_flask
# Recipe:: default
#
# Copyright 2013, Abine, Inc.
#
# All rights reserved - Do Not Redistribute
#
rightscale_marker :begin

# Set up the LWRP resources
node[:app][:provider] = 'app_flask'

package 'uwsgi'
package 'uwsgi-plugin-python'

# Install the real uwsgi
python_pip 'uwsgi' do
  action :install
end
execute 'service uwsgi stop'
file '/usr/bin/uwsgi' do
  action :delete
end
link '/usr/bin/uwsgi' do
  to '/usr/local/bin/uwsgi'
end

service 'uwsgi' do
  supports :restart => true, :reload => true, :status => false
  action [:enable, :start]
end

node[:app][:destination] = node[:repo][:default][:destination]

rightscale_marker :end
