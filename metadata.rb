maintainer       "Abine, Inc."
maintainer_email "cloud@abine.com"
license          "All rights reserved"
description      "Installs/Configures app_flask"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.1"

depends "rightscale"
depends "python"
depends "repo"
depends "app"
depends "nginx"

recipe "app_flask::default", "Install basic requirements for a flask app before the code exists"
recipe "app_flask::setup_db_connection", "Create database permissions file"
recipe "app_flask::enable_cron", "Enable periodic running of a cron.py file"
recipe "app_flask::disable_cron", "Disable periodic running of a cron.py file"

attribute "app_flask/module",
  :display_name => "Python module name",
  :description => "Name of python module to import the callable from. Example: myapp",
  :recipes => [ 'app_flask::default' ],
  :required => "required"

attribute "app_flask/callable",
  :display_name => "uWSGI callable",
  :description => "Name of Python object that can handle requests. Example: app",
  :recipes => ['app_flask::default'],
  :default => 'app',
  :required => 'optional'

attribute "app_flask/database_user",
  :display_name => "Database Application Username",
  :description => "The username of the database user that has 'user' privileges (e.g., cred:DBAPPLICATION_USER).",
  :required => "required",
  :recipes => ["app_flask::setup_db_connection"]

attribute "app_flask/database_password",
  :display_name => "Database Application Password",
  :description => "The password of the database user that has 'user' privileges (e.g., cred:DBAPPLICATION_PASSWORD).",
  :required => "required",
  :recipes => ["app_flask::setup_db_connection"]

attribute "app_flask/database_server_fqdn",
  :display_name => "Database Master FQDN",
  :description => "The fully qualified domain name for the master database server. Example: db-master.example.com",
  :required => "required",
  :recipes => ["app_flask::setup_db_connection"]

attribute "app_flask/database_name",
  :display_name => "Database Schema Name",
  :description => "Enter the name of the database schema to which applications will connect to. The database schema should have been created when the initial database was first set up. This input will be used to set the application server's database configuration file so that applications can connect to the correct schema within the database.  This input is also used for database dump backups in order to determine which schema will be backed up.  Example: mydbschema",
  :required => "required",
  :recipes => ["app_flask::setup_db_connection"]