#
# Cookbook Name:: app_flask
# Recipe:: default
#
# Copyright 2013, Abine, Inc.
#
# All rights reserved - Do Not Redistribute
#
rightscale_marker :begin

flask_cron 'python' do
  enable true
  deploy_dir node[:app][:destination]
end
rightscale_marker :end
