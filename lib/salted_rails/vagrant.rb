# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'erb'
require 'yaml'
require 'fileutils'

module SaltedRails
  class Vagrant

    def initialize(rails_root = (File.dirname(__FILE__) + '/../'))
      @debug = false

      @rails_root = rails_root
      @rails_root += '/' unless @rails_root =~ /\/$/

      puts "RAILS_ROOT = #{@rails_root}" if @debug

      @conf_file = @rails_root + '.salted_vagrant.conf'

      load_salted_config

      configure_new_machine(@configure) if @configure

      pillarize_application_configuration

      @salted_config[:ENV].each do |key, value|
        ENV[key.to_s] = value.to_s unless value.kind_of? Hash
      end if @salted_config[:ENV]
    end

    def configure_digital_ocean(config)
      unless @configured_digital_ocean
        @configured_digital_ocean = true
        if @salted_config.key? :digital_ocean
          puts 'Configuring digital ocean provider'  if @debug
          config.vm.provider :digital_ocean do |provider, override|
            provider.client_id = @salted_config[:digital_ocean][:client_id]
            provider.api_key = @salted_config[:digital_ocean][:api_key]
            provider.image = @salted_config[:digital_ocean][:image]
            provider.region = @salted_config[:digital_ocean][:region]
            override.ssh.username = 'vagrant'
            override.vm.box = 'digital_ocean'
            override.vm.box_url = 'https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box'
            override.ssh.private_key_path = '~/.ssh/id_rsa' unless (@salted_config[:ssh][:private_key_path] rescue false)
            override.vm.synced_folder '.', '/vagrant', :disabled => true

            [ '/etc/ssl/certs/ca-certificates.crt' ].each do |ca_file|
              provider.ca_path = ca_file if File.exists? ca_file
            end
          end
        end
      end
    end

    def configure_salt(config)
      unless @configured_salt
        @configured_salt = true

        config.vm.synced_folder @rails_root + 'salt/salt/', '/srv/salt/'
        config.vm.synced_folder @rails_root + 'salt/pillar/', '/srv/pillar/'
        # Bootstrap salt
        ## config.vm.provision :shell, :inline => 'salt-call --version || wget -O - http://bootstrap.saltstack.org | sudo sh'
        # Provisioning #2: masterless highstate call
        config.vm.provision :salt do |salt|
          puts 'Configuring salt provisioner'  if @debug
          salt.minion_config = 'salt/salt/vagrant/minion'
          salt.run_highstate = true
          salt.verbose = true
        end
      end
    end

    def configure_machines(config)
      unless @configured_machines
        @configured_machines = true
        @salted_config[:machines].each do |machine, details|
          puts "Configuring machine #{machine}" if @debug
          config.vm.define machine do |vm_config|
            vm_config.vm.network :forwarded_port, :guest => 3000, :host => 3000, auto_correct: true
            vm_config.vm.network :forwarded_port, :guest => 80, :host => 3080, auto_correct: true
            vm_config.vm.network :forwarded_port, :guest => 443, :host => 3443, auto_correct: true
            # config.vm.network :forwarded_port, guest: 80, host: 8080
            #vm_config.vm.provision :shell, :inline => '/bin/bash /vagrant/etc/vagrant/provision.sh dev'
            memory = details['memory'].to_i rescue 0
            if details['gui']
              memory = 1024 if (memory == 0)
              vm_config.vm.provision :salt do |salt|
                salt.minion_config = 'salt/salt/vagrant/gui_minion'
              end
            end
            if memory > 0
              vm_config.vm.customize ['modifyvm', :id, '--memory', memory]
              #vm_config.vm.provider :virtualbox do |vb|
              #  vb.customize ['modifyvm', :id, '--memory', memory]
              #end
            end
            #vm_config.vm.customize ['setextradata', :id, 'VBoxInternal/Devices/mc146818/0/Config/UseUTC', 1]
            vm_config.vm.boot_mode = :gui if details['gui']

          end
        end 
      end 
    end

    def configure_vagrant(config)

      config.vm.box ||= 'UbuntuCloud_12.04_32bit'
      config.vm.box_url ||= 'http://cloud-images.ubuntu.com/precise/current/precise-server-cloudimg-vagrant-i386-disk1.box'

      config.ssh.private_key_path = @salted_config[:ssh][:private_key_path] if (@salted_config[:ssh][:private_key_path] rescue false)
      config.ssh.forward_agent = true if (@salted_config[:ssh][:forwarded_agent] rescue false)

      configure_digital_ocean(config)
      configure_salt(config)

      show_salted_config if @debug

      configure_machines(config)
    end

    def show_salted_config
      puts 'SALTED_CONFIG:', @salted_config.inspect
    end

    private

    def load_salted_config
      @configure = ENV['CONFIGURE'].nil? ? false : ENV['CONFIGURE'].to_sym
      if File.exist?(@conf_file)
        @salted_config = YAML.load_file(@conf_file)
      else
        @salted_config = { :machines => { :default => { } }, :ENV => { } }
        #@configure ||= :default
        save_salted_config
      end
      @salted_config[:ENV] ||= { }
      show_salted_config if @debug
    end

    # Add ruby version and gemfiles
    
    def pillarize_application_configuration
      dest = 'salt/pillar/application.sls'
      version_file = @rails_root + '.ruby-version'
      database_file = @rails_root + 'config/database.yml'
      if ! File.exist?(@rails_root + dest) or (File.mtime(version_file) > File.mtime(@rails_root + dest)) or (File.mtime(database_file) > File.mtime(@rails_root + dest))
        puts "Creating #{dest}" if @debug
        File.open(@rails_root + dest, 'w') do |f_out|
          ENV['VAGRANT_MACHINE'] = 'true'
          database_conf = YAML.load(ERB.new(IO.read(database_file)).result)
          ruby_version = File.open(version_file, 'r') do |f_in|
            f_in.gets.gsub(/\s/,'')
          end
          app_config = {
            'database' => database_conf,
            'ruby-version' => ruby_version
            }
          f_out.puts app_config.to_yaml
        end
      else
        puts 'skipped creation of salt/pillar/application.sls: file is up to date' if @debug
      end

      [ 'Gemfile', 'Gemfile.lock' ].each do |file|
        dest = "salt/salt/railsapp/files/#{file}"
        if ! File.exist?(@rails_root + dest) or ( File.mtime(@rails_root + file) > File.mtime(@rails_root + dest) )
          puts "Linking #{file} to #{dest}" if @debug
          FileUtils.ln(@rails_root + file, @rails_root + dest, :force => true)
        end
      end
    end

    def configure_new_machine(configure)
      print "(C)onfigure or (F)orget #{configure} machine [C/f]? "
      ans = gets
      if ans =~ /^f/i
        @salted_config[:machines].delete(configure)
      else
        # Not yet inplemented
        #print 'Include GUI for #{configure} [N/y]? '
        #ans = '' # gets
        #@salted_config[:machines][configure] = { 'gui' => !!(ans =~ /y/i) }
        @salted_config[:machines][configure] = { }
      end

      print 'Setup digital_ocean provider [N/y]?'
      ans = gets
      if ans =~ /^y/i
        @salted_config[:digital_ocean] ||= { 
          :client_id => 'YOUR digital_ocean CLIENT ID',
          :api_key => 'YOUR API KEY from https://www.digital_ocean.com/api_access',
          :image => 'Ubuntu 12.04 x32',
          :region => 'San Francisco 1'
        }
        @salted_config[:digital_ocean].each do |key,value|
          print "#{key} (default: #{value})? "
          ans = gets.gsub(/\s/,'')
          ans = value if ans == ''
          @salted_config[:digital_ocean][key] = ans
        end
      end

      save_salted_config
    end

    def save_salted_config
      File.open(@conf_file, 'w') { |f| f.puts YAML.dump(@salted_config) }
    end

  end

  # if run via 'ruby lib/salted_vagrant.rb'

  unless defined? Vagrant or defined? Rails
    salted_vagrant = SaltedVagrant.new(File.dirname(__FILE__) + '/../')
    salted_vagrant.show_salted_config
  end
end
