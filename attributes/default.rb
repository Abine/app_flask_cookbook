#
# Cookbook Name:: app_flask
# Recipe:: default
#
# Copyright 2013, Abine, Inc.
#
# All rights reserved - Do Not Redistribute
#

default[:app_flask][:module] = "myapp"
default[:app_flask][:callable] = "app"

default[:app_flask][:database_name] = ""
default[:app_flask][:database_user] = ""
default[:app_flask][:database_password] = ""
default[:app_flask][:database_server_fqdn] = ""
