# -*- mode: ruby -*-
# vi: set ft=ruby :
#

require 'erb'
require 'yaml'
require 'fileutils'
require "salted_rails_base"

class SaltedRails < SaltedRailsBase
  class CapistranoHelper < HelperBase

    def initialize(rails_root, logger = Log4r::Logger.new("salted_rails::capistrano_helper"))
      super(rail_root, logger)
    end

#    def configure_vagrant(config)
#      config.vm.box = 'UbuntuCloud_12.04_32bit'
#      config.vm.box_url = 'http://cloud-images.ubuntu.com/precise/current/precise-server-cloudimg-vagrant-i386-disk1.box'
#    end
#
#    def configure_ubuntu_mirror(config, mirror = 'mirror://mirrors.ubuntu.com/mirrors.txt')
#      config.vm.provision "shell" do |s|
#        s.path = @salt_root + 'salt/bin/change_mirror.sh'
#        s.args = "'#{mirror}'"
#      end
#    end
#
#    def configure_digital_ocean(config, private_key_path = '~/.ssh/id_rsa', disable_vagrant_sync = true)
#      @logger.info 'Configuring digital ocean provider'  if @logger
#      @has_digital_ocean = 1
#      config.vm.provider :digital_ocean do |provider, override|
#        override.ssh.username = 'vagrant'
#        override.vm.box = 'digital_ocean'
#        override.vm.box_url = 'https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box'
#        provider.image = 'Ubuntu 12.04 x32'
#        provider.region = 'San Francisco 1'
#        provider.ca_path = '/etc/ssl/certs/ca-certificates.crt' if File.exist?('/etc/ssl/certs/ca-certificates.crt')
#        override.vm.synced_folder '.', '/vagrant', :disabled => true if disable_vagrant_sync
#        override.ssh.private_key_path = private_key_path
#        @private_key_name = 'Vagrant ' + private_key_path.sub(/~\//, '').sub(/\.ssh\//, '').sub(/^id_/, '').gsub(/\W+/, ' ')
#        provider.ssh_key_name = @private_key_name if @private_key_name
#        override.ssh.forward_agent = true
#      end
#    end
#
#    def configure_salt(config)
#      pillarize_application_configuration
#      config.vm.synced_folder @salt_root + 'config/salt/', '/srv/salt/config/'
#      config.vm.synced_folder @salt_root + 'config/pillar/', '/srv/pillar/config/'
#      config.vm.synced_folder @salt_root + 'salt/', '/srv/salt/salted-rails/'
#      config.vm.synced_folder @salt_root + 'pillar/', '/srv/pillar/salted-rails/'
#      # Bootstrap salt
#      ## config.vm.provision :shell, :inline => 'salt-call --version || wget -O - http://bootstrap.saltstack.org | sudo sh'
#      # Provisioning #2: masterless highstate call
#      config.vm.provision :salt do |salt|
#        @logger.info 'Configuring salt provisioner'  if @logger
#        minion_file = @rails_root + 'config/salt/vagrant/minion'
#        minion_file = @salt_root + 'salt/vagrant/minion' unless File.exists? minion_file
#        salt.minion_config = minion_file
#        salt.run_highstate = true
#        salt.verbose = !! @logger
#      end
#    end
#
#    def configure_ports(vm_config, port_offset=0)
#      vm_config.vm.network :forwarded_port, :guest => 3000 + port_offset, :host => 3000, auto_correct: true
#      [ 80, 443, 880 ].each do |port|
#        vm_config.vm.network :forwarded_port, :guest => port, :host => 3000+port + port_offset, auto_correct: true
#      end
#    end
#
#    def configure_gui(vm_config, memory = 1024)
#      @gui = true
#      configure_memory(memory)
#      vm_config.vm.boot_mode == :gui 
#      vm_config.vm.provision :salt do |salt|
#        minion_file = @rails_root + 'config/salt/vagrant/gui_minion'
#        minion_file = @salt_root + 'salt/vagrant/gui_minion' unless File.exists? minion_file
#        salt.minion_config = minion_file
#      end
#    end
#
#    def configure_memory(memory = 1024)
#      config.vm.provider :virtualbox do |vb|
#       vb.customize ["modifyvm", :id, "--memory", memory]
#      end
#      config.vm.provider :digital_ocean do |provider, override|
#        if memory >= 8000
#          provider.size = '8GB'
#        elsif memory >= 4000
#          provider.size = '4GB'
#        elsif memory >= 2000
#          provider.size = '2GB'
#        elsif memory >= 1000
#          provider.size = '1GB'
#        else
#          provider.size = '512MB'
#        end
#      end
#    end


  end

end
