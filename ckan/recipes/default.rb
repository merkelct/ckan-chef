# Install and configure ckan instance and dependencies.
include_recipe "runit"
include_recipe "apt"
include_recipe "git"
include_recipe "python"
include_recipe "postgresql::server"
include_recipe "postgresql::libpq"
include_recipe "postgresql::client"
#include_recipe "redis"
include_recipe "redis::install_from_package"
include_recipe "java"
include_recipe "ckan::ckan_base"
include_recipe "ckan::ckan_datastore"
#include_recipe "ckan::ckan_ext"

# include_recipe "ckan::ckan_production"
# include_recipe "ckan::ckan_tests" # uncomment to set up tests