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

default[:app][:database_name] = ""
default[:app][:database_user] = ""
default[:app][:database_password] = ""
default[:app][:database_sever_fqdn] = ""
