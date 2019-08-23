# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.berkshelf.enabled = true

  config.vm.box = "ubuntu/trusty64"
  # config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true
  config.vm.hostname = 'default.ckanhosted.dev'
  config.vm.network :private_network, ip: '192.168.42.42'

  config.vm.network "forwarded_port", guest: 5432, host: 5432
  config.vm.network "forwarded_port", guest: 8983, host: 8983
  config.vm.network "forwarded_port", guest: 5000, host: 5000  # paster server (development)
  config.omnibus.chef_version = '14.13.11'
  config.vm.provider "virtualbox" do |vb|
    # Customize the amount of memory on the VM:
    vb.memory = "1024"
  end

  config.vm.synced_folder "synced_folders/src", "/usr/lib/ckan/default/src",
                          id: "ckan_src",
                          owner: "vagrant",
                          group: "vagrant",
                          mount_options: ["dmode=775","fmode=664"],
                          create: true
  config.vm.synced_folder "synced_folders/config", "/etc/ckan/default",
                          id: "ckan_config",
                          owner: "vagrant",
                          group: "vagrant",
                          mount_options: ["dmode=775","fmode=664"],
                          create: true
  config.vm.synced_folder "synced_folders/file_storage", "/var/lib/ckan/default",
                          id: "ckan_file_storage",
                          owner: "vagrant",
                          group: "www-data",
                          mount_options: ["dmode=775","fmode=664"],
                          create: true

  config.vm.provision "shell", inline: 'echo ". /usr/lib/ckan/default/bin/activate" > ~/.profile', privileged: false
  config.vm.provision "shell", inline: 'echo "cd /usr/lib/ckan/default/src/ckan" >> ~/.profile', privileged: false

  config.vm.provision :chef_solo do |chef|
    chef.run_list = [
      "recipe[ckan::default]",
    ]
  end
end
