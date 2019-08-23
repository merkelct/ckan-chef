


module Ckan
  module Helper

    def clone(directory,user,repo,commit)
      git directory do
        user user
        group user
        repository repo
        reference commit
        enable_submodules true
        action :sync
      end
    end

    def pip_requirements(file,user,venv)
      python_package file do
        user user
        group user
        virtualenv venv
        options "-r"
        action :install
      end
    end

    def pip_install(source,user,venv)
      python_package source do
        user user
        group user
        virtualenv venv
        options "--exists-action=i -e"
        action :install
      end
    end

  end
end


Chef::Node.send(:include, Ckan::Helper)
Chef::Recipe.send(:include, Ckan::Helper)
Chef::Resource.send(:include, Ckan::Helper)
Chef::Provider.send(:include, Ckan::Helper)
