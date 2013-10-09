# -*- mode: ruby -*-
# vi: set ft=ruby :
#

require 'log4r'

module SaltedRails
  class Config

    attr_accessor :private_key_path
    attr_accessor :machine
    attr_accessor :hostname
    attr_accessor :domain
    attr_accessor :rails_root
    attr_accessor :salt_root
    attr_accessor :mirror
    attr_accessor :logger
    attr_accessor :memory
    attr_accessor :ports
    attr_accessor :disable_vagrant_sync
    attr_accessor :ca_path
    attr_accessor :region
    attr_accessor :forward_agent
    attr_accessor :files
    attr_accessor :databases
    attr_accessor :roles
    attr_accessor :gems
    attr_accessor :ruby_version
    attr_accessor :java_version
    attr_accessor :php_version
    attr_accessor :machines
    attr_accessor :copy_from_home

    def sanitize_dns_name(name)
      dns_name = name.downcase.gsub(/[^-0-9a-z]+/,'-').sub(/^-+/, '').sub(/-+$/, '')
    end

    # pass vm.ui for the logger if you want debugging info
    def initialize(rails_root, machine = 'default')
      @logger = Log4r::Logger.new("vagrant::salted-rails")
      @machine = machine
      @rails_root = rails_root
      @rails_root += '/' unless @rails_root =~ /\/$/
      @salt_root = nil
      # see salt/vagrant/top.sls for other roles
      @roles = %w{ app web db }
      @domain = nil
      @private_key_path = nil
      @mirror = nil
      @memory = nil
      @ports = [ 80, 443, 880, 3000 ]
      @disable_vagrant_sync = true
      @ca_path = nil
      @region = nil
      @forward_agent = true
      @files = [ '.ruby-version', '.java-version', '.php-version', '.rvmrc', 'config/database.yml', 'Gemfile', 'Gemfile.lock' ].select{ |f| File.exist?(@rails_root + f) }
      @copy_from_home = [ ]

      ENV['REMOTE_MACHINE'] = 'true'
      database_file = @rails_root + 'config/database.yml'
      @databases = YAML.load(ERB.new(IO.read(database_file)).result) rescue { }
      ENV['REMOTE_MACHINE'] = nil

      @gems = { }
      if File.exists? @rails_root + 'Gemfile'
        File.foreach(@rails_root + 'Gemfile') do |line|
          if line =~ /^\s*gem\s*['"]([^'"]+)['"][,\s]*(['"]([^'"]+)['"])?/
            gem = $1
            version = $3.to_s
            version = true if version == '' or version !~ /\d/
            @gems[gem] = version
          end
        end
      end
      @databases.each do |key, details|
        @gems[details['adapter']] = true
      end

      @ruby_version = nil
      @java_version = nil
      @php_version = nil

      @machines = [ ]
      @hostname = nil
    end

    def gui?
      @roles.include? 'gui'
    end

    def normalize
      unless @memory
        @memory = 512
        {
                'gui' => 1536,
                'teamcity' => 1536,
                'cruisecontrolrb' => 512
        }.each do |role, extra|
          @memory += extra if @roles.include?(role)
        end
      end
      unless @domain
        if @hostname
          @domain = @hostname.sub(/^[^.]*\.?/, '')
        else
          @domain = sanitize_dns_name(File.basename(File.expand_path(@rails_root).sub(/\/$/, '').sub(/\/(app|site|web|www|website)\d*$/, ''))) + '.test'
          @domain = 'railsapp.test' if @domain == '.test'
        end
      end
      if @hostname.nil? or @hostname == ''
        if @machine == 'default'
          @hostname = @domain
        else
          @hostname = sanitize_dns_name(@machine.to_s)
          if @hostname == ''
            @hostname = @domain
          else
            @hostname <<= '.' + @domain
          end
        end
      end
      @ruby_version ||= File.open(@rails_root + '.ruby-version', 'r') do |f_in|
        f_in.gets.gsub(/\s/,'')
      end rescue nil
      @ruby_version ||= File.open(@rails_root + '.rvmrc', 'r') do |f_in|
        while !ruby_version && (line = f_in.gets) 
          ruby_version = $1 if line =~ /^\s*environment_id=['"]([^"'@]+)/
        end
      end rescue nil
      @ruby_version ||= '1.9.3'

      @java_version ||= File.open(@rails_root + '.java-version', 'r') do |f_in|
        f_in.gets.gsub(/\s/,'')
      end rescue nil

      @php_version ||= File.open(@rails_root + '.php-version', 'r') do |f_in|
        f_in.gets.gsub(/\s/,'')
      end rescue nil

      @private_key_path ||= '~/.ssh/id_rsa'
      @mirror ||= 'auto'
      @salt_root ||= File.dirname(__FILE__) + '/../../'
      @ca_path ||= '/etc/ssl/certs/ca-certificates.crt'
      @ca_path = nil unless File.exist?(@ca_path)
      @region ||= 'San Francisco 1'

      @machines.each {|m| m.normalize}

      {
              'teamcity' => 8111,
              'cruisecontrolrb' => 3333
      }.each do |role, port|
        @ports << port if @roles.include?(role) and not @ports.include?(port)
      end

    end

    def define(machine, &block)
      obj = self.clone
      obj.machine = machine
      obj.machines = [ ]
      obj.logger = @logger
      @machines << obj
      yield(obj) if block_given?
    end

    # Clone
    def clone
      obj = self.dup
      obj.roles = @roles.dup
      obj.ports = @ports.dup
      obj.files = @files.dup
      obj.copy_from_home = @copy_from_home.dup
      obj.databases = @databases.dup
      obj.gems = @gems.dup
      obj
    end

    def to_hash
      {
        'domain' => @domain,
        'mirror' => @mirror,
        'machine' => @machine,
        'hostname' => @hostname,
        'memory' => @memory,
        'disable_vagrant_sync' => @disable_vagrant_sync,
        'region' => @region,
        'forward_agent' => @forward_agent,
        'files' => @files,
        'databases' => @databases,
        'gems' => @gems,
        'ruby_version' => @ruby_version,
        'java_version' => @java_version,
        'php_version' => @php_version,
        'roles' => @roles
      }
    end

    def to_yaml
      normalize
      self.to_hash.to_yaml
    end

    def configure_vagrant(config)
      require 'salted-rails/vagrant_helper'
      normalize
      helper = SaltedRails::VagrantHelper.new(self)
      helper.configure_vagrant(config)
    end

  end
end
