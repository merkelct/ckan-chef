# for development deploys using Vagrant, `[:ckan][:user]` must be 'vagrant' to ensure
# synced_folders have correct permissions
default[:ckan][:user] = "vagrant"
default[:ckan][:project_name] = "default"
default[:ckan][:site_url] = "http://default.ckanhosted.dev/frontdoor"
default[:ckan][:solr_url] = "http://127.0.0.1:8983/solr"
default[:ckan][:sql_password] = "pass"
default[:ckan][:sql_user] = "ckan_#{default[:ckan][:project_name]}"
default[:ckan][:sql_db_name] = "ckan_#{default[:ckan][:project_name]}"
default[:ckan][:virtual_env_dir] = "/usr/lib/ckan/#{default[:ckan][:project_name]}"
default[:ckan][:config_dir] = "/etc/ckan/#{default[:ckan][:project_name]}"
default[:ckan][:config] = "development.ini"

default[:ckan][:file_storage_dir] = "/var/lib/ckan/#{default[:ckan][:project_name]}"


default[:ckan][:datastore][:sql_user] = "datastore_#{default[:ckan][:project_name]}"  # readonly db user
default[:ckan][:datastore][:sql_db_name] = "datastore_#{default[:ckan][:project_name]}"

#extensions
default[:ckan][:extensions] = %w{spatial geoview monsanto pages}
#spatial repo and commit
default[:ckan][:spatial][:url] = "https://github.com/ckan/ckanext-spatial.git"
default[:ckan][:spatial][:commit] = "master"
# The CKAN version to install.
default[:repository][:url] = "https://github.com/ckan/ckan.git"
default[:repository][:commit] = "ckan-2.5.3"

# Apache config for production
default[:apache][:server_name] = "default.ckanhosted.dev/frontdoor"
default[:apache][:server_alias] = "www.default.ckanhosted.dev/frontdoor"
