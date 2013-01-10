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

service 'uwsgi' do
  supports :restart => true, :reload => true, :status => false
  action :enable
end

node[:app][:destination] = node[:repo][:default][:destination]

rightscale_marker :end
