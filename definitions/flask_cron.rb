#
# Cookbook Name:: app_flask
# Definition:: flask_cron
#
# Copyright 2013, Abine, Inc.
#
# All rights reserved - Do Not Redistribute
#

define :flask_cron, :enable => true, :deploy_dir => nil do
  if params[:enable]
    cron "flask_cron" do
      command "#{params[:deploy_dir]}/venv/bin/python #{params[:deploy_dir]}/cron.py"
      only_if { ::File.exists?("#{params[:deploy_dir]}/cron.py") }
    end
  else
    cron "flask_cron" do
      action :delete
    end
  end
end
