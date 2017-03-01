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
    replace_or_add 'add spatial to plugins list' do
      path "#{node[:ckan][:config_dir]}/#{node[:ckan][:config]}"
      pattern '.*ckan.plugins*.'
      line 'ckan.plugins = stats text_view image_view recline_view datastore spatial_metadata spatial_query'
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
  elsif extension == 'pages'
    ##################### frontpage monsanto theme #####################

    clone("#{SOURCE_DIR}/ckanext-frontpage", node[:ckan][:user], "https://github.com/merkelct/ckanext-frontpage.git", "master"
    pip_install("#{SOURCE_DIR}/ckanext-frontpage", node[:ckan][:user], node[:ckan][:virtual_env_dir])

    add_to_list 'add montheme to plugins list' do
      path "#{node[:ckan][:config_dir]}/#{node[:ckan][:config]}"
      pattern 'ckan.plugins ='
      delim [' ']
      entry 'pages'
    end
    replace_or_add 'add editor style' do
      path "#{node[:ckan][:config_dir]}/#{node[:ckan][:config]}"
      pattern '.*ckan.pages.*.'
      line 'ckanext.pages.editor = ckeditor'
    end
end


}

cron 'update tracker' do
  action :create
  user 'vagrant'
  hour '*'
  home '/home/vagrant'
  command " /usr/lib/ckan/default/bin/paster --plugin=ckan tracking update -c /etc/ckan/default/development.ini && /usr/lib/ckan/default/bin/paster --plugin=ckan search-index rebuild -r -c /etc/ckan/default/develpment.ini"
end

##add line to debug=true in the ini'##
replace_or_add 'debug line for dev' do
  path "#{node[:ckan][:config_dir]}/#{node[:ckan][:config]}"
  pattern '.*debug*.'
  line 'debug = true'
end