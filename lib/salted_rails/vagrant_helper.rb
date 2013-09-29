# -*- mode: ruby -*-
# vi: set ft=ruby :
#

require 'erb'
require 'yaml'
require 'fileutils'
require "salted_rails_base"

class SaltedRails < SaltedRailsBase
  class VagrantHelper

    def initialize(rails_root, debug = false)
      @logger = if debug
          self
        end

      @rails_root = rails_root
      @rails_root += '/' unless @rails_root =~ /\/$/

      @gem_root = File.dirname(__FILE__) + '/../../'

      @logger.info "RAILS_ROOT = #{@rails_root}" if @logger

    end

    def configure_vagrant(config)
      config.vm.box = 'UbuntuCloud_12.04_32bit'
      config.vm.box_url = 'http://cloud-images.ubuntu.com/precise/current/precise-server-cloudimg-vagrant-i386-disk1.box'
    end

    def configure_ubuntu_mirror(config, mirror = 'mirror://mirrors.ubuntu.com/mirrors.txt')
      config.vm.provision "shell" do |s|
        s.path = @gem_root + 'salt/bin/change_mirror.sh'
        s.args = "'#{mirror}'"
      end
    end

    def configure_digital_ocean(config, private_key_path = '~/.ssh/id_rsa', disable_vagrant_sync = true)
      @logger.info 'Configuring digital ocean provider'  if @logger
      config.vm.provider :digital_ocean do |provider, override|
        override.ssh.username = 'vagrant'
        override.vm.box = 'digital_ocean'
        override.vm.box_url = 'https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box'
        provider.image = 'Ubuntu 12.04 x32'
        provider.region = 'San Francisco 1'
        provider.ca_path = '/etc/ssl/certs/ca-certificates.crt' if File.exist?('/etc/ssl/certs/ca-certificates.crt')
        override.vm.synced_folder '.', '/vagrant', :disabled => true if disable_vagrant_sync
        override.ssh.private_key_path = private_key_path
        @private_key_name = 'Vagrant ' + private_key_path.sub(/~\//, '').sub(/\.ssh\//, '').sub(/^id_/, '').gsub(/\W+/, ' ')
        provider.ssh_key_name = @private_key_name if @private_key_name
        override.ssh.forward_agent = true
      end
    end

    def configure_salt(config)
      pillarize_application_configuration
      config.vm.synced_folder salt_root + 'salt/', '/srv/salt/'
      config.vm.synced_folder salt_root + 'pillar/', '/srv/pillar/'
      # Bootstrap salt
      ## config.vm.provision :shell, :inline => 'salt-call --version || wget -O - http://bootstrap.saltstack.org | sudo sh'
      # Provisioning #2: masterless highstate call
      config.vm.provision :salt do |salt|
        @logger.info 'Configuring salt provisioner'  if @logger
        salt.minion_config = salt_root + 'salt/vagrant/minion'
        salt.run_highstate = true
        salt.verbose = true
      end
    end

    def configure_ports(vm_config)
      vm_config.vm.network :forwarded_port, :guest => 3000, :host => 3000, auto_correct: true
      [ 80, 443 ].each do |port|
        vm_config.vm.network :forwarded_port, :guest => port, :host => 3000+port, auto_correct: true
      end
    end

    def configure_gui(vm_config)
      vm_config.vm.boot_mode == :gui 
      vm_config.vm.provision :salt do |salt|
        salt.minion_config = salt_root + 'salt/vagrant/gui_minion'
      end
    end

    def info(msg)
      puts msg
    end

    private

    def salt_root
      @salt_root ||= @rails_root + (File.directory?(@rails_root + 'salt/salt') ? 'salt/' : 'tmp/')
    end

    # Add ruby version and gemfiles
    
    def pillarize_application_configuration
      salt_dir = @rails_root + 'salt/salt/'
      pillar_dir = @rails_root + 'salt/pillar/'
      copy_in_tmp = ! File.directory?(salt_dir)
      if copy_in_tmp
        salt_dir = @rails_root + 'tmp/salt/'
        pillar_dir = @rails_root + 'tmp/pillar/'
      end
      copy_all = ! File.directory?(salt_dir)

      pillar_app_file = pillar_dir + 'application.sls'
      version_file = @rails_root + '.ruby-version'
      database_file = @rails_root + 'config/database.yml'
      gemfile = @rails_root + 'Gemfile'

      rails_config_changed = ! (File.exist?(pillar_app_file) and File.directory?(salt_dir))
      rails_config_changed ||= (File.mtime(__FILE__) > File.mtime(pillar_app_file))
      files = [ version_file, database_file, gemfile ]
      files <<= "#{gemfile}.lock" if File.exist? "#{gemfile}.lock"
      files.each do |f|
        rails_config_changed ||= (File.mtime(f) > File.mtime(pillar_app_file))
      end
      copy_all ||= rails_config_changed if copy_in_tmp

      if copy_all
        @logger.info "Copying default rules to tmp/salt and tmp/pillar" if @logger
        FileUtils.rm_rf(pillar_dir)
        FileUtils.rm_rf(salt_dir)
        FileUtils.mkdir_p(pillar_dir)
        FileUtils.mkdir_p(salt_dir)

        FileUtils.cp_r(@gem_root + 'pillar/.', pillar_dir)
        FileUtils.cp_r(@gem_root + 'salt/.', salt_dir)
      else
        @logger.info 'skipped creation of salt and pillar (up to date)' if @logger
     end

     if rails_config_changed
        dest = salt_dir + "railsapp/files"
        FileUtils.mkdir_p dest
        files.each do |file|
          @logger.info "Copying #{file} to #{dest}" if @logger
          FileUtils.cp(file, dest)
        end

        File.open(pillar_app_file, 'w') do |f_out|
          ENV['VAGRANT_MACHINE'] = 'true'
          database_conf = YAML.load(ERB.new(IO.read(database_file)).result)
          ruby_version = File.open(version_file, 'r') do |f_in|
            f_in.gets.gsub(/\s/,'')
          end
          app_config = {
            'database' => database_conf,
            'ruby-version' => ruby_version,
            'gems' => { }
            }
          database_conf.each do |key, details|
            app_config['gems'][details['adapter']] = true
          end
          File.foreach(gemfile) do |line|
            app_config['gems'][$1] = true if (line =~ /^\s*gem\s*['"]([^'"]+)/)
          end
          f_out.puts app_config.to_yaml
        end
      else
        @logger.info 'skipped configuration of salt and pillar (up to date)' if @logger
      end

    end

  end

end
