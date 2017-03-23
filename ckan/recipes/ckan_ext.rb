# Installs and configures the datastore extension
# Must be run after ckan::ckan_base recipe.

ENV['VIRTUAL_ENV'] = node[:ckan][:virtual_env_dir]
ENV['PATH'] = "#{ENV['VIRTUAL_ENV']}/bin:#{ENV['PATH']}"
SOURCE_DIR = "#{ENV['VIRTUAL_ENV']}/src"
CKAN_DIR = "#{SOURCE_DIR}/ckan"
CKAN_CONFIG_DIR = node[:ckan][:config_dir]



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

  clone("#{SOURCE_DIR}/ckanext-geoview", node[:ckan][:user], "https://github.com/ckan/ckanext-geoview.git", "master")
  pip_requirements("#{SOURCE_DIR}/ckanext-geoview/pip-requirements.txt", node[:ckan][:user], node[:ckan][:virtual_env_dir])
  pip_install("#{SOURCE_DIR}/ckanext-geoview", node[:ckan][:user], node[:ckan][:virtual_env_dir])

  add_to_list 'add geoview to plugins list' do
    path "#{node[:ckan][:config_dir]}/#{node[:ckan][:config]}"
    pattern 'ckan.plugins ='
    delim [' ']
    entry 'geo_view'
  end

  add_to_list 'add geo_view to views list' do
    path "#{node[:ckan][:config_dir]}/#{node[:ckan][:config]}"
    pattern 'ckan.views.default_views ='
    delim [' ']
    entry 'geo_view'
  end
  elsif extension == 'monsanto'
    ##################### monsanto theme #####################
    #not cloning from Monsanto source for local dev will have to put all changes back into Monsanto Private repo
    #clone("#{SOURCE_DIR}/ckanext-monsanto", node[:ckan][:user], "https://#{gdc_git_password}:x-oauth-basic@github.com/MonsantoCo/ckanext-monsanto.git", node[:monsanto][:commit])
    pip_install("#{SOURCE_DIR}/ckanext-monsanto", node[:ckan][:user], node[:ckan][:virtual_env_dir])

    add_to_list 'add montheme to plugins list' do
      path "#{node[:ckan][:config_dir]}/#{node[:ckan][:config]}"
      pattern 'ckan.plugins ='
      delim [' ']
      entry 'montheme'
    end
  elsif extension == 'frontpage'
    ##################### frontpage monsanto  #####################
    clone("#{SOURCE_DIR}/ckanext-frontpage", node[:ckan][:user], "https://github.com/merkelct/ckanext-frontpage.git", "master")
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
  elsif extension == 'harvester'
    ##################### harvester monsanto  #####################
    clone("#{SOURCE_DIR}/ckanext-harvest", node[:ckan][:user], "https://github.com/ckan/ckanext-harvest.git", "v0.0.5")
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
      line 'ckan.harvest.mq.type = redis
ckan.harvest.mq.hostname = localhost
ckan.harvest.mq.port = 6379
ckan.harvest.mq.redis_db = 0
## Site Settings'
    end
    # Create database tables
    execute "create database tables" do
      user node[:ckan][:user]
      cwd CKAN_DIR
      command "paster --plugin=ckanext-harvest harvester initdb -c #{node[:ckan][:config_dir]}/development.ini"
    end
end


}

cron 'update tracker' do
  action :create
  user 'vagrant'
  hour '*'
  home '/home/vagrant'
  command "/usr/lib/ckan/default/bin/paster --plugin=ckan tracking update -c /etc/ckan/default/development.ini && /usr/lib/ckan/default/bin/paster --plugin=ckan search-index rebuild -r -c /etc/ckan/default/development.ini"
end

cron 'update overall tracker' do
  action :create
  user 'vagrant'
  hour '*'
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