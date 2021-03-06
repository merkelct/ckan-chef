# for development deploys using Vagrant, `[:ckan][:user]` must be 'vagrant' to ensure
# synced_folders have correct permissions
require 'json'

file = File.read(File.dirname(File.expand_path(__FILE__)) + '/../config.json')
data_hash = JSON.parse(file)

default[:egit] = data_hash['egit']
default[:git] = data_hash['git']
default[:yammerid] = data_hash['yammerid']
default[:harvester_clientid] = data_hash['harvester_clientid']
default[:harvester_secret] = data_hash['harvester_secret']
default[:harvester_pingi_env] = data_hash['harvester_pingi_env']
default[:harvester_pingi_url] = data_hash['harvester_pingi_url']
default[:harvester_akana_portal_url] = data_hash['harvester_akana_portal_url']
default[:haystack_api_url] = data_hash['haystack_api_url']
default[:haystack_web_url] = data_hash['haystack_web_url']
default[:geoview_bing_key] = data_hash['geoview_bing_key']


default[:slackbot_token] = data_hash['slackbot_token']
default[:slackbot_id] = data_hash['slackbot_id']
default[:slack_client] = data_hash['slack_client']
default[:slack_secret] = data_hash['slack_secret']

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

default[:ckan][:version] = 'release-v2.5.5'
default[:ckan][:repository][:url] = 'github.com/MonsantoCo/ckan.git'
default[:ckan][:file_storage_dir] = "/var/lib/ckan/#{default[:ckan][:project_name]}"


default[:ckan][:datastore][:sql_user] = "datastore_#{default[:ckan][:project_name]}"  # readonly db user
default[:ckan][:datastore][:sql_db_name] = "datastore_#{default[:ckan][:project_name]}"

#extensions
default[:ckan][:extensions] = %w{spatial geoview haystack monsanto frontpage pingi akana_harvester harvester slack yammer docs}
#spatial repo and commit
default[:ckan][:spatial][:url] = "https://github.com/ckan/ckanext-spatial.git"
default[:ckan][:spatial][:commit] = "master"
# The CKAN version to install.
default[:repository][:url] = "https://github.com/ckan/ckan.git"
default[:repository][:commit] = "ckan-2.5.3"

# Apache config for production
default[:apache][:server_name] = "default.ckanhosted.dev/frontdoor"
default[:apache][:server_alias] = "www.default.ckanhosted.dev/frontdoor"


