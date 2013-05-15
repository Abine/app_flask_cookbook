#
# Cookbook Name:: app_flask
# Recipe:: default
#
# Copyright 2013, Abine, Inc.
#
# All rights reserved - Do Not Redistribute
#

# nop and unsupported actions
action :reload do
  raise "Action not available: reload"
end
action :setup_monitoring do
  raise "Monitoring not supported by CherryPy"
end

action :setup_vhost do
  project_root = new_resource.destination
  port = new_resource.port
  name = node[:app_flask][:module]

  #disabling default nginx site and generate our own
  nginx_site 'default' do
    enable false
  end

  #now for uwsgi
  template "/etc/uwsgi/apps-available/#{name}.ini" do
    source 'uwsgi.erb'
    cookbook 'app_flask'
    mode '0444'
    owner 'root'
    group 'www-data'
    variables({
      :deploy_dir => project_root,
      :app_name => name,
      :callable => node[:app_flask][:callable]
    })
  end

  link "/etc/uwsgi/apps-enabled/#{name}.ini" do
    to "/etc/uwsgi/apps-available/#{name}.ini"
    notifies :restart, "service[uwsgi]"
  end

  template "#{node[:nginx][:dir]}/sites-available/#{name}" do
    source 'nginx.erb'
    cookbook 'app_flask'
    mode '0444'
    owner "root"
    group "www-data"
    variables({
      :port => port,
      :deploy_dir => project_root,
      :app_name => name,
    })
  end

  nginx_site name do
    enable true
  end

  log "Configured!"
end

action :setup_db_connection do
  template "#{node[:app][:destination]}/#{node[:app_flask][:module]}/db.py" do
    source 'db.erb'
    cookbook 'app_flask'
    mode '0440'
    user node[:app][:user]
    group 'www-data'
    variables({
      :db_host => new_resource.database_server_fqdn,
      :db_user => new_resource.database_user,
      :db_pwd => new_resource.database_password,
      :db_name => new_resource.database_name
    })
  end
end

# Lifecycle control
action :stop do
  service "nginx" do
    action :stop
  end
  service "uwsgi" do
    action :stop
  end
end

action :start do
  service "uwsgi" do
    action :start
  end
  service "nginx" do
    action :start
  end
end

# Restart
action :restart do
  action_stop
  sleep 5
  action_start
end

# Installing required packages to system
action :install do
  execute "#{node[:app][:destination]}/venv/bin/pip install -r #{node[:app][:destination]}/requirements.txt" do
    only_if { ::File.exists?("#{node[:app][:destination]}/requirements.txt") }
  end
end


# Download/Update application repository
action :code_update do
  deploy_dir = new_resource.destination

  log "  Starting code update sequence"
  log "  Current project doc root is set to #{deploy_dir}"

  log "Removing old venv"
  action_stop

  python_virtualenv "#{deploy_dir}/venv" do
    action :delete
  end

  log "  Starting source code download sequence..."
  # Calling "repo" LWRP to download remote project repository
  repo "default" do
    destination deploy_dir
    action node[:repo][:default][:perform_action].to_sym
    app_user node[:app][:user]
    repository node[:repo][:default][:repository]
    persist false
  end

  # Removing log directory, preparing to symlink
  directory "#{deploy_dir}/log" do
    action :delete
    recursive true
  end

  # Creating new flask application log directory on ephemeral volume
  directory "/mnt/ephemeral/log/flask" do
    owner node[:app][:user]
    group 'www-data'
    mode "0775"
    action :create
    recursive true
  end

  # Symlinking application log directory to ephemeral volume
  link "#{deploy_dir}/log" do
    to "/mnt/ephemeral/log/flask"
  end

  log "  Generating new logrotate config for rails application"
  rightscale_logrotate_app "app_flask" do
    cookbook "rightscale"
    template "logrotate.erb"
    path ["#{deploy_dir}/log/*.log"]
    frequency "size 10M"
    rotate 4
    create "660 #{node[:app][:user]} www-data"
  end

  log " Creating new venv"
  # Create a virtual environment in the app destination

  python_virtualenv "#{deploy_dir}/venv" do
    interpreter 'python2.7'
    action :create
    group 'www-data'
    owner node[:app][:user]
  end

  # Restart the server
  action_stop
  action_install
  action_start

end
