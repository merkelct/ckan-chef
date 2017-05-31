# Installs and configures the datastore extension
# Must be run after ckan::ckan_base recipe.

ENV['VIRTUAL_ENV'] = node[:ckan][:virtual_env_dir]
ENV['PATH'] = "#{ENV['VIRTUAL_ENV']}/bin:#{ENV['PATH']}"
SOURCE_DIR = "#{ENV['VIRTUAL_ENV']}/src"
CKAN_DIR = "#{SOURCE_DIR}/ckan"
CKAN_CONFIG_DIR = node[:ckan][:config_dir]

EGIT_TOKEN = node[:egit]
GIT_TOKEN = node[:git]
YAMMERID = node[:yammerid]
HARVESTERID = node[:harvester_clientid]
HARVESTERSECRET = node[:harvester_secret]
SLACKBOT_TOKEN = node[:slackbot_token]
SLACKBOT_ID = node[:slackbot_id]
HARVESTER_PINGI_ENV = node[:harvester_pingi_env]
HARVESTER_PINGI_URL = node[:harvester_pingi_url]
HARVESTER_AKANA_PORTAL_URL = node[:harvester_akana_portal_url]
HAYSTACK_API_URL = node[:haystack_api_url]
HAYSTACK_WEB_URL = node[:haystack_web_url]


node.ckan.extensions.each{ |extension|

  if extension == 'spatial'
    ##################### SPATIAL #####################

    clone("#{SOURCE_DIR}/ckanext-spatial",node[:ckan][:user],node[:ckan][:spatial][:url],node[:ckan][:spatial][:commit])

    # Add spatial_metadata to ckan.plugins
    add_to_list 'add geoview to plugins list' do
      path "#{node[:ckan][:config_dir]}/#{node[:ckan][:config]}"
      pattern 'ckan.plugins ='
      delim [' ']
      entry 'spatial_metadata spatial_query'
    end

    replace_or_add 'pyparsing' do
      path "#{SOURCE_DIR}/ckanext-spatial/pip-requirements.txt"
      pattern '.*pyparsing*.'
      line ''
    end

    pip_requirements("#{SOURCE_DIR}/ckanext-spatial/pip-requirements.txt",node[:ckan][:user],node[:ckan][:virtual_env_dir])
    pip_install("#{SOURCE_DIR}/ckanext-spatial",node[:ckan][:user],node[:ckan][:virtual_env_dir])

  elsif extension == 'geoview'
  ##################### geoview #####################

  clone("#{SOURCE_DIR}/ckanext-geoview", node[:ckan][:user], "https://#{EGIT_TOKEN}:x-oauth-basic@github.platforms.engineering/datasvcs/ckanext-geoview.git", "master")
  pip_requirements("#{SOURCE_DIR}/ckanext-geoview/pip-requirements.txt", node[:ckan][:user], node[:ckan][:virtual_env_dir])
  pip_install("#{SOURCE_DIR}/ckanext-geoview", node[:ckan][:user], node[:ckan][:virtual_env_dir])

  add_to_list 'add geoview to plugins list' do
    path "#{node[:ckan][:config_dir]}/#{node[:ckan][:config]}"
    pattern 'ckan.plugins ='
    delim [' ']
    entry 'geo_view resource_proxy'
  end

  add_to_list 'add geo_view to views list' do
    path "#{node[:ckan][:config_dir]}/#{node[:ckan][:config]}"
    pattern 'ckan.views.default_views ='
    delim [' ']
    entry 'geo_view'
  end
  replace_or_add 'geoview Mon configuration' do
    path "#{node[:ckan][:config_dir]}/#{node[:ckan][:config]}"
    pattern '.*## Site Settings*.'
    line "ckanext.geoview.ol_viewer.formats = wms kml geojson
ckan.geoview.oauth = false
# ckan.geoview.oauth.urls =
## Site Settings"
  end
  elsif extension == 'monsanto'
    ##################### monsanto theme #####################
    clone("#{SOURCE_DIR}/ckanext-monsanto", node[:ckan][:user], "https://#{GIT_TOKEN}:x-oauth-basic@github.com/MonsantoCo/ckanext-monsanto.git", 'mont02')
    pip_install("#{SOURCE_DIR}/ckanext-monsanto", node[:ckan][:user], node[:ckan][:virtual_env_dir])

    add_to_list 'add montheme to plugins list' do
      path "#{node[:ckan][:config_dir]}/#{node[:ckan][:config]}"
      pattern 'ckan.plugins ='
      delim [' ']
      entry 'montheme'
    end
  elsif extension == 'frontpage'
    ##################### frontpage monsanto  #####################
    clone("#{SOURCE_DIR}/ckanext-frontpage", node[:ckan][:user], "https://#{EGIT_TOKEN}:x-oauth-basic@github.platforms.engineering/datasvcs/ckanext-frontpage.git", "master")
    pip_install("#{SOURCE_DIR}/ckanext-frontpage", node[:ckan][:user], node[:ckan][:virtual_env_dir])

    add_to_list 'add montheme to plugins list' do
      path "#{node[:ckan][:config_dir]}/#{node[:ckan][:config]}"
      pattern 'ckan.plugins ='
      delim [' ']
      entry 'frontpage'
    end
    replace_or_add 'add editor style' do
      path "#{node[:ckan][:config_dir]}/#{node[:ckan][:config]}"
      pattern '.*ckan.tracking_enabled = true*.'
      line 'ckan.tracking_enabled = true
ckanext.frontpage.editor = ckeditor'
    end
    replace_or_add 'add html style' do
      path "#{node[:ckan][:config_dir]}/#{node[:ckan][:config]}"
      pattern '.*ckan.tracking_enabled = true*.'
      line 'ckan.tracking_enabled = true
ckanext.frontpage.allow_html = True'
    end
  elsif extension == 'pingi'
    ##################### pingi monsanto  #####################
    clone("#{SOURCE_DIR}/pingi", node[:ckan][:user], "https://#{EGIT_TOKEN}:x-oauth-basic@github.platforms.engineering/location-360/pingi.git", "python2.7")
    pip_install("#{SOURCE_DIR}/pingi", node[:ckan][:user], node[:ckan][:virtual_env_dir])

    replace_or_add 'Pingi hjarvester info' do
      path "#{node[:ckan][:config_dir]}/#{node[:ckan][:config]}"
      pattern '.*## Site Settings*.'
      line "ckan.harvester.id = #{HARVESTERID}
ckan.harvester.secret = #{HARVESTERSECRET}
ckan.harvester.pingi.env = #{HARVESTER_PINGI_ENV}
ckan.harvester.pingi.url = #{HARVESTER_PINGI_URL}
## Site Settings"
    end
  elsif extension == 'akana_harvester'
    ##################### harvester monsanto  #####################
    clone("#{SOURCE_DIR}/ckanext-akanaharvester", node[:ckan][:user], "https://#{GIT_TOKEN}:x-oauth-basic@github.com/merkelct/ckanext-akanaharvester.git", "master")
    pip_install("#{SOURCE_DIR}/ckanext-akanaharvester", node[:ckan][:user], node[:ckan][:virtual_env_dir])

    add_to_list 'add akanaharvester to plugins list' do
      path "#{node[:ckan][:config_dir]}/#{node[:ckan][:config]}"
      pattern 'ckan.plugins ='
      delim [' ']
      entry 'akanaharvester akana_harvester'
    end
  elsif extension == 'harvester'
    ##################### harvester monsanto  #####################
    clone("#{SOURCE_DIR}/ckanext-harvest", node[:ckan][:user], "https://#{GIT_TOKEN}:x-oauth-basic@github.com/merkelct/ckanext-harvest.git", "master")
    pip_requirements("#{SOURCE_DIR}/ckanext-harvest/pip-requirements.txt", node[:ckan][:user], node[:ckan][:virtual_env_dir])
    pip_install("#{SOURCE_DIR}/ckanext-harvest", node[:ckan][:user], node[:ckan][:virtual_env_dir])

    add_to_list 'add montheme to plugins list' do
      path "#{node[:ckan][:config_dir]}/#{node[:ckan][:config]}"
      pattern 'ckan.plugins ='
      delim [' ']
      entry 'harvest ckan_harvester'
    end
    replace_or_add 'redis info' do
      path "#{node[:ckan][:config_dir]}/#{node[:ckan][:config]}"
      pattern '.*## Site Settings*.'
      line "ckan.harvest.mq.type = redis
ckan.harvest.mq.hostname = localhost
ckan.harvest.mq.port = 6379
ckan.harvest.mq.redis_db = 0
ckan.harvester.akana.portal.url = #{HARVESTER_AKANA_PORTAL_URL}
## Site Settings"
    end
    # Create database tables
    execute "create database tables" do
      user node[:ckan][:user]
      cwd CKAN_DIR
      command "paster --plugin=ckanext-harvest harvester initdb -c #{node[:ckan][:config_dir]}/development.ini"
    end
  elsif extension == 'yammer'
    ##################### yammer monsanto  #####################
    clone("#{SOURCE_DIR}/ckanext-yammer", node[:ckan][:user], "https://#{GIT_TOKEN}:x-oauth-basic@github.com/merkelct/ckanext-yammer.git", "master")
    pip_install("#{SOURCE_DIR}/ckanext-yammer", node[:ckan][:user], node[:ckan][:virtual_env_dir])
    pip_requirements("#{SOURCE_DIR}/ckanext-yammer/requirements.txt", node[:ckan][:user], node[:ckan][:virtual_env_dir])


    add_to_list 'add yammer to plugins list' do
      path "#{node[:ckan][:config_dir]}/#{node[:ckan][:config]}"
      pattern 'ckan.plugins ='
      delim [' ']
      entry 'yammer'
    end
    replace_or_add 'yammer ID' do
      path "#{node[:ckan][:config_dir]}/#{node[:ckan][:config]}"
      pattern '.*## Site Settings*.'
      line "ckan.yammer.id = #{YAMMERID}
## Site Settings"
    end
  elsif extension == 'slack'
    ##################### slack monsanto  #####################
    clone("#{SOURCE_DIR}/ckanext-slack", node[:ckan][:user], "https://#{GIT_TOKEN}:x-oauth-basic@github.com/merkelct/ckanext-slack.git", "master")
    pip_install("#{SOURCE_DIR}/ckanext-slack", node[:ckan][:user], node[:ckan][:virtual_env_dir])
    pip_requirements("#{SOURCE_DIR}/ckanext-slack/requirements.txt", node[:ckan][:user], node[:ckan][:virtual_env_dir])

    add_to_list 'add slack to plugins list' do
      path "#{node[:ckan][:config_dir]}/#{node[:ckan][:config]}"
      pattern 'ckan.plugins ='
      delim [' ']
      entry 'slack'
    end
    replace_or_add 'set config options for slack' do
      path "#{node[:ckan][:config_dir]}/#{node[:ckan][:config]}"
      pattern '.*## Site Settings*.'
      line "ckan.slackbot_id = #{SLACKBOT_ID}
ckan.slackbot_token = #{SLACKBOT_TOKEN}
## Site Settings"
    end
  elsif extension == 'docs'
    ##################### slack monsanto  #####################
    clone("#{SOURCE_DIR}/docs", node[:ckan][:user], "https://#{EGIT_TOKEN}:x-oauth-basic@github.platforms.engineering/datasvcs/datacat.git", "ogsdocs")
  elsif extension == 'haystack'
    ##################### slack monsanto  #####################
    clone("#{SOURCE_DIR}/ckanext-haystack", node[:ckan][:user], "https://#{EGIT_TOKEN}:x-oauth-basic@github.platforms.engineering/datasvcs/ckanext-haystack.git", "master")
    pip_install("#{SOURCE_DIR}/ckanext-haystack", node[:ckan][:user], node[:ckan][:virtual_env_dir])

    add_to_list 'add haystack to plugins list' do
      path "#{node[:ckan][:config_dir]}/#{node[:ckan][:config]}"
      pattern 'ckan.plugins ='
      delim [' ']
      entry 'haystack'
    end
    replace_or_add 'set config options for haystack' do
      path "#{node[:ckan][:config_dir]}/#{node[:ckan][:config]}"
      pattern '.*## Site Settings*.'
      line "ckanext.haystack.api.url = #{HAYSTACK_API_URL}
ckanext.haystack.web.url = #{HAYSTACK_WEB_URL}
ckanext.haystack.indexes = 0

## Site Settings"
      end
  end


}

cron 'update tracker' do
  action :create
  user 'vagrant'
  hour '*'
  minute '0'
  home '/home/vagrant'
  command "/usr/lib/ckan/default/bin/paster --plugin=ckan tracking update -c /etc/ckan/default/development.ini && /usr/lib/ckan/default/bin/paster --plugin=ckan search-index rebuild -r -c /etc/ckan/default/development.ini"
end

cron 'update overall tracker' do
  action :create
  user 'vagrant'
  hour '*'
  minute '0'
  home '/home/vagrant'
  command "/usr/lib/ckan/default/bin/paster --plugin=ckan tracking export /usr/lib/ckan/default/src/pagewiecount30day.csv 2017-01-01 -c /etc/ckan/default/development.ini"
end

##add line to debug=true in the ini'##
replace_or_add 'debug line for dev' do
  path "#{node[:ckan][:config_dir]}/#{node[:ckan][:config]}"
  pattern '.*debug*.'
  line 'debug = true'
end


##add listen to postgresql.conf'##
replace_or_add 'listen line for postgres' do
  path "/etc/postgresql/9.4/main/postgresql.conf"
  pattern '.*listen_addresses*.'
  line "listen_addresses = '*'"
end

##add hosts to pg_hba.conf'##
replace_or_add 'update hosts on pgs' do
  path "/etc/postgresql/9.4/main/pg_hba.conf"
  pattern '.*host    all       all   0.0.0.0/0     md5*.'
  line 'host    all       all   0.0.0.0/0     md5'
end

# restart post to update configs
execute "restart postgis" do
  user 'root'
  command "service postgresql restart"
end