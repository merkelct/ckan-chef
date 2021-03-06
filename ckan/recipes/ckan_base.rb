# Installs base ckan instance and sets up development.ini.

include_recipe "nodejs::nodejs_from_package"

ENV['VIRTUAL_ENV'] = node[:ckan][:virtual_env_dir]
ENV['PATH'] = "#{ENV['VIRTUAL_ENV']}/bin:#{ENV['PATH']}"
SOURCE_DIR = "#{ENV['VIRTUAL_ENV']}/src"
CKAN_DIR = "#{SOURCE_DIR}/ckan"

ESCAPED_SITE_URL = node[:ckan][:site_url].gsub('/','\\/')
ESCAPED_SOLR_URL = node[:ckan][:solr_url].gsub('/','\\/')
ESCAPED_STORAGE_PATH = node[:ckan][:file_storage_dir].gsub('/','\\/')

EGIT_TOKEN = node[:egit]
GIT_TOKEN = node[:git]

# Create user
user node[:ckan][:user] do
  home "/home/#{node[:ckan][:user]}"
  supports :manage_home => true
end

# Create virtualenv directory
directory ENV['VIRTUAL_ENV'] do
  owner node[:ckan][:user]
  group node[:ckan][:user]
  recursive true
  action :create
end

# Create python virtualenv
python_virtualenv ENV['VIRTUAL_ENV'] do
  interpreter "python2.7"
  owner node[:ckan][:user]
  group node[:ckan][:user]
  options "--no-site-packages"
  action :create
end

# Create source directory
directory SOURCE_DIR do
  owner node[:ckan][:user]
  group node[:ckan][:user]
  recursive true
  action :create
end

# Install CKAN Package
clone("#{CKAN_DIR}", node[:ckan][:user], "https://#{GIT_TOKEN}:x-oauth-basic@#{node[:ckan][:repository][:url]}", node[:ckan][:version])

python_pip CKAN_DIR do
  user node[:ckan][:user]
  group node[:ckan][:user]
  virtualenv ENV['VIRTUAL_ENV']
  options "--exists-action=i -e"
  action :install
end

# Install CKAN's requirements
python_pip "#{CKAN_DIR}/requirements.txt" do
  user node[:ckan][:user]
  group node[:ckan][:user]
  virtualenv ENV['VIRTUAL_ENV']
  options "-r"
  action :install
end

# Install CKAN Package req flask_debugger
python_pip 'flask-debugtoolbar' do
  user node[:ckan][:user]
  group node[:ckan][:user]
  virtualenv ENV['VIRTUAL_ENV']
  action :install
end

# Create Postgres User and Database
postgresql_user node[:ckan][:sql_user] do
  superuser true
  createdb true
  login true
  password node[:ckan][:sql_password]
end
postgresql_database node[:ckan][:sql_db_name] do
  owner node[:ckan][:sql_user]
  encoding "utf8"
end

# Create config directory
directory node[:ckan][:config_dir] do
  owner node[:ckan][:user]
  group node[:ckan][:user]
  recursive true
  action :create
end

# Create configuration file in CKAN directory
execute "make paster's config file" do
  user node[:ckan][:user]
  cwd CKAN_DIR
  command "paster make-config ckan development.ini.tmp --no-interactive"
  creates "#{CKAN_DIR}/development.ini.tmp"
end

# Copy config file to config directory
file "#{node[:ckan][:config_dir]}/development.ini" do
  content lazy { IO.read("#{CKAN_DIR}/development.ini.tmp") }
  action :create
end

replace_or_add 'root url for INI' do
  path "#{node[:ckan][:config_dir]}/#{node[:ckan][:config]}"
  pattern 'port = 5000*'
  line 'port = 5000
[composite:nonroot]
use = egg:Paste#urlmap
/frontdoor = main'
end

replace_or_add 'ckan tracking enable' do
  path "#{node[:ckan][:config_dir]}/#{node[:ckan][:config]}"
  pattern 'beaker.session.key = ckan*'
  line 'beaker.session.key = ckan
ckan.tracking_enabled = true'
end

# Edit configuration file
# solr_url and ckan.site_id
execute "edit configuration file to setup ckan.site_url and ckan.site_id" do
  user node[:ckan][:user]
  cwd node[:ckan][:config_dir]
  command "sed -i -e 's/^ckan.site_id.*/ckan.site_id=#{node[:ckan][:project_name]}/;s/.*ckan.site_url.*/ckan.site_url=#{ESCAPED_SITE_URL}/' development.ini"
end

# Configure database variables
execute "edit configuration file to setup database urls" do
  user node[:ckan][:user]
  cwd node[:ckan][:config_dir]
  command "sed -i -e 's/.*sqlalchemy.url.*/sqlalchemy.url=postgresql:\\/\\/#{node[:ckan][:sql_user]}:#{node[:ckan][:sql_password]}@localhost\\/#{node[:ckan][:sql_db_name]}/' development.ini"
end

# Install andP OSTGIS
package 'postgresql-9.4-postgis-2.3' do
  action :install
end

# Configure postgis ckan tables
execute 'write the tables for postgis ckan' do
  user 'root'
  command "sudo -u postgres psql -d ckan_default -f /usr/share/postgresql/9.4/contrib/postgis-2.3/postgis.sql"
end

# Configure postgis populate spatial ref
execute 'populate spatial ref table' do
  user 'root'
  command "sudo -u postgres psql -d ckan_default -f /usr/share/postgresql/9.4/contrib/postgis-2.3/spatial_ref_sys.sql"
end

# Configure postgis chnage owner
execute 'change owners' do
  user 'root'
  command "sudo -u postgres psql -d ckan_default -c 'ALTER VIEW geometry_columns OWNER TO ckan_default;' && sudo -u postgres psql -d ckan_default -c 'ALTER TABLE spatial_ref_sys OWNER TO ckan_default;'"
end

# Install and python-dev
package "python-dev" do
  action :install
end

# Install and python-dev
package "libxml2-dev" do
  action :install
end

#move file
cookbook_file "#{SOURCE_DIR}/tracking.py" do
  source 'tracking.py'
  user "vagrant"
  group "vagrant"
  mode '0644'
end

# Install and python-dev
package "libxslt1-dev" do
  action :install
end

# Install and python-dev
package "libgeos-c1" do
  action :install
end

# Install and configure Solr
package "solr-jetty"
template "/etc/default/jetty" do
  variables({
    :java_home => node["java"]["java_home"]
  })
end
link "/etc/solr/conf/schema.xml" do
  to "#{CKAN_DIR}/ckan/config/solr/schema.xml"
  action :create
end
# Configure solr url
execute "edit configuration file to setup solr url" do
  user node[:ckan][:user]
  cwd node[:ckan][:config_dir]
  command "sed -i -e 's/.*solr_url.*/solr_url=#{ESCAPED_SOLR_URL}/' development.ini"
end
service "jetty" do
  supports :status => true, :restart => true, :reload => true
  action [:enable, :start]
end

# Create database tables
execute "create database tables" do
  user node[:ckan][:user]
  cwd CKAN_DIR
  command "paster db init -c #{node[:ckan][:config_dir]}/development.ini"
end

# Link who.ini
link "#{node[:ckan][:config_dir]}/who.ini" do
  owner node[:ckan][:user]
  group node[:ckan][:user]
  to "#{SOURCE_DIR}/ckan/ckan/config/who.ini"
  action :create
end

# Create file storage directory
directory node[:ckan][:file_storage_dir] do
  owner node[:ckan][:user]
  group node[:ckan][:user]
  recursive true
  action :create
end
# Set storage path in config file
execute "set storage path in config file" do
  user node[:ckan][:user]
  cwd node[:ckan][:config_dir]
  command "sed -i -e 's/.*ckan.storage_path.*/ckan.storage_path=#{ESCAPED_STORAGE_PATH}/' development.ini"
end

execute "install less and nodewatch" do
  cwd "#{CKAN_DIR}"
  command "sudo npm install less@1.7.5 nodewatch"
end

