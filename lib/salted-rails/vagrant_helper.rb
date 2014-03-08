# -*- mode: ruby -*-
# vi: set ft=ruby :
#

require "salted-rails/helper_base"

module SaltedRails
  class VagrantHelper < HelperBase

    def initialize(config)
      super(config)
    end

    def configure_vagrant(vagrant_config)
      @config.normalize
      port_offset = 0
      configure_virtualbox(vagrant_config)
      configure_vbguest(vagrant_config)
      configure_ubuntu_mirror(vagrant_config)
      configure_digital_ocean(vagrant_config)
      if @config.machines.empty?
        configure_gui(vagrant_config) if @config.gui?
        configure_hostname(vagrant_config)
        configure_ports(vagrant_config, port_offset)
        configure_memory(vagrant_config, @config.memory)
      else
        @config.machines.each do |machine_config|
          machine_config.logger.info "Configuring machine #{machine_config.machine}, hostname: #{machine_config.hostname}"
          vagrant_config.vm.define(machine_config.machine.to_sym) do |vagrant_vm_config|
            configure_gui(vagrant_vm_config) if machine_config.gui?
            configure_hostname(vagrant_vm_config, machine_config)
            configure_ports(vagrant_vm_config, port_offset, machine_config)
            configure_memory(vagrant_vm_config, machine_config.memory, machine_config)
            port_offset += 1
          end
        end
      end
      # create_empty_custom_files
      misc_fixes(vagrant_config)
      configure_salt(vagrant_config)
      pillarize_application_configuration
    end

    def configure_ubuntu_mirror(vagrant_config, config = @config)
      config.logger.info "Configuring ubuntu mirror (#{config.mirror})" 
      vagrant_config.vm.provision "shell" do |s|
        s.path = config.salt_root + 'salt/bin/change_mirror.sh'
        s.args = "'#{config.mirror}'"
      end
    end

    def configure_hostname(vagrant_config, config = @config)
      config.logger.info "Configuring hostname (#{config.hostname})" 
      vagrant_config.vm.hostname = config.hostname
    end

    def misc_fixes(vagrant_config, config = @config)
      vagrant_config.vm.provision "shell" do |s|
        s.path = config.salt_root + 'salt/bin/misc_fixes.sh'
      end
    end

    def configure_vbguest(vagrant_config, config = @config)
      begin
        require 'vagrant-vbguest'
        require 'salted-rails/cloud_vbguest_installer'
        vagrant_config.vbguest.installer = SaltedRails::CloudVbguestInstaller
        #vagrant_config.vbguest.auto_update = false
        config.logger.info 'Configured vbguest installer' 
      rescue LoadError
        config.logger.info 'Skipping vbguest (plugin not available)' 
      end
    end


    def configure_virtualbox(vagrant_config, config = @config)
      config.logger.info "Configuring virtualbox box (#{config.box})" 
      vagrant_config.vm.box = config.box
      if config.box == 'preciseCloud32'
        vagrant_config.vm.box_url = 'http://cloud-images.ubuntu.com/precise/current/precise-server-cloudimg-vagrant-i386-disk1.box'
      elsif config.box == 'precise32'
        vagrant_config.vm.box_url = 'http://files.vagrantup.com/precise32.box'
      end
    end

    def configure_digital_ocean(vagrant_config, config = @config)
      config.logger.info "Configuring digital ocean provider (#{config.machine})" 
      vagrant_config.vm.provider :digital_ocean do |provider, override|
        override.ssh.username = 'vagrant'
        override.vm.box = 'digital_ocean'
        override.vm.box_url = 'https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box'
        provider.image = 'Ubuntu 12.04 x32'
        provider.region = config.region
        provider.ca_path = config.ca_path if config.ca_path
        override.vm.synced_folder '.', '/vagrant', :disabled => true unless config.sync_vagrant
        if config.private_key_path
          override.ssh.private_key_path = config.private_key_path
          private_key_name = 'Vagrant ' + config.private_key_path.sub(/~\//, '').sub(/\.ssh\//, '').sub(/^id_/, '').gsub(/\W+/, ' ')
          provider.ssh_key_name = private_key_name.strip
        end
        override.ssh.forward_agent = config.forward_agent
      end
    end

    def configure_gui(vagrant_config)
      vagrant_config.vm.provider "virtualbox" do |v|
        v.gui = true
      end
    end

    def configure_salt(vagrant_config, config = @config)
      config.logger.info "Configuring saltstack (#{config.machine})"
      vagrant_config.vm.synced_folder config.project_root + 'config/salt/', '/srv/salt/config/'
      vagrant_config.vm.synced_folder config.project_root + 'config/pillar/', '/srv/pillar/config/'
      vagrant_config.vm.synced_folder config.project_root + 'tmp/salt/', '/srv/salt/generated/'
      vagrant_config.vm.synced_folder config.project_root + 'tmp/pillar/', '/srv/pillar/generated/'
      vagrant_config.vm.synced_folder config.salt_root + 'salt/', '/srv/salt/salted-rails/'
      vagrant_config.vm.synced_folder config.salt_root + 'pillar/', '/srv/pillar/salted-rails/'
      # Bootstrap salt
      ## config.vm.provision :shell, :inline => 'salt-call --version || wget -O - http://bootstrap.saltstack.org | sudo sh'
      # Provisioning #2: masterless highstate call
      vagrant_config.vm.provision :salt do |salt|
        config.logger.info 'Configuring salt provisioner'
        minion_file = config.project_root + 'config/salt/vagrant/minion'
        minion_file = config.salt_root + 'salt/vagrant/minion' unless File.exist?(minion_file)
        salt.minion_config = minion_file
        salt.run_highstate = true
        salt.verbose = !! config.logger
        # current package (salt-minion_0.17.0.1-1precise_all.deb) in ppa:saltstack/salt is broken as of Oct 10 2013:
        # Unable to run multiple states and returns unhelpfull messages about list and get
        salt.install_type = 'git'
        #salt.install_args = 'v0.16.4'
        salt.install_args = 'v0.17.1'
      end
    end

    def configure_ports(vagrant_config, port_offset=0, config = @config)
      config.mapped_ports = { }
      config.ports.each do |port|
        host_port = port_offset + port + (port < 3000 ? 3000 : 0)
        config.mapped_ports[port] = host_port
        vagrant_config.vm.network :forwarded_port, :guest => port, :host => host_port, auto_correct: true
      end
    end

    def configure_memory(vagrant_config, memory, config = @config)
      config.logger.info "Configuring memory = %d" % config.memory.to_i
      vagrant_config.vm.provider :virtual_box do |vb|
       vb.customize ["modifyvm", :id, "--memory", config.memory]
      end
      vagrant_config.vm.provider :digital_ocean do |provider, override|
        # configure to closest value
        if config.memory >= 3000
          # 32 bit linux doesn't use anything more than this anyway
          provider.size = '4GB'
        elsif config.memory >= 1500
          provider.size = '2GB'
        elsif config.memory >= 750
          provider.size = '1GB'
        else
          provider.size = '512MB'
        end
      end
    end

  end
end
