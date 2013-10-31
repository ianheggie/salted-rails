# -*- mode: ruby -*-
# vi: set ft=ruby :
#

require 'log4r'

module SaltedRails
  class Config

    attr_accessor :admin_password
    attr_accessor :box
    attr_accessor :ca_path
    attr_accessor :copy_from_home
    attr_accessor :databases
    attr_accessor :domain
    attr_accessor :files
    attr_accessor :forward_agent
    attr_accessor :gems
    attr_accessor :hostname
    attr_accessor :logger
    attr_accessor :machine
    attr_accessor :machines
    attr_accessor :mapped_ports
    attr_accessor :memory
    attr_accessor :mirror
    attr_accessor :packages
    attr_accessor :ports
    attr_accessor :private_key_path
    attr_accessor :project_root
    attr_accessor :region
    attr_accessor :roles
    attr_accessor :salt_root
    attr_accessor :staging_password
    attr_accessor :sync_vagrant
    attr_accessor :versions

    def sanitize_dns_name(name)
      dns_name = name.downcase.gsub(/[^-0-9a-z]+/,'-').sub(/^-+/, '').sub(/-+$/, '')
    end

    # pass vm.ui for the logger if you want debugging info
    def initialize(project_root, machine = 'default')
      @logger = Log4r::Logger.new("vagrant::salted-rails")
      @machine = machine
      @project_root = project_root
      @project_root += '/' unless @project_root =~ /\/$/
      @salt_root = nil
      # see salt/vagrant/top.sls for other roles
      @roles = %w{ app web db }
      @domain = nil
      @admin_password = nil
      @staging_password = nil
      @private_key_path = nil
      @mirror = nil
      @memory = nil
      @ports = [ 80, 443, 880, 3000 ]
      @mapped_ports = { }
      @sync_vagrant = nil
      @box = nil
      @ca_path = nil
      @region = nil
      @forward_agent = true
      @files = [ '.ruby-version', '.java-version', '.php-version', 'config/database.yml', 'Gemfile', 'Gemfile.lock' ].select{ |f| File.exist?(@project_root + f) }
      @packages = nil
      @copy_from_home = [ ]

      ENV['REMOTE_MACHINE'] = 'true'
      database_file = @project_root + 'config/database.yml'
      @databases = YAML.load(ERB.new(IO.read(database_file)).result) rescue { }
      ENV['REMOTE_MACHINE'] = nil

      @gems = { }
      if File.exists? @project_root + 'Gemfile'
        File.foreach(@project_root + 'Gemfile') do |line|
          if line =~ /^\s*gem\s*['"]([^'"]+)['"][,\s]*(['"]([^'"]+)['"])?/
            gem = $1
            version = $3.to_s
            version = true if version == '' or version !~ /\d/
            @gems[gem] = version
          end
        end
      end
      @databases.each do |key, details|
        @gems[details['adapter']] ||= true
      end

      @roles << 'mysql' if @gems.include?('mysql') or @gems.include?('mysql2')

      @versions= { }

      @machines = [ ]
      @hostname = nil
    end

    def gui?
      @roles.include? 'gui'
    end

    def define(machine, &block)
      obj = self.clone
      obj.machine = machine
      obj.machines = [ ]
      obj.logger = @logger
      @machines << obj
      yield(obj) if block_given?
    end

    def provider
      pat = File.join(@project_root, '.vagrant','machines',@machine,'*','id')
      prov = Dir.glob(pat).collect{|path| File.basename(File.dirname(path))}.first
      prov ||= ARGV.select{|a| a =~ /^--provider=/}.collect{|a| a.sub(/.*=/, '')}.first
      prov ||= ENV['VAGRANT_DEFAULT_PROVIDER'] || 'virtualbox'
      prov
    end

    # Clone
    def clone
      obj = self.dup
      obj.roles = @roles.dup
      obj.ports = @ports.dup
      obj.mapped_ports = @mapped_ports.dup
      obj.files = @files.dup
      obj.copy_from_home = @copy_from_home.dup
      obj.databases = @databases.dup
      obj.gems = @gems.dup
      obj
    end

    def to_hash
      {
        'admin_password' => @admin_password,
        'databases' => @databases,
        'disable_vagrant_sync' => @disable_vagrant_sync,
        'domain' => @domain,
        'files' => @files,
        'forward_agent' => @forward_agent,
        'gems' => @gems,
        'hostname' => @hostname,
        'machine' => @machine,
        'mapped_ports' => @mapped_ports,
        'memory' => @memory,
        'mirror' => @mirror,
        'ports' => @ports,
        'region' => @region,
        'roles' => @roles,
        'provider' => provider,
        'staging_password' => @staging_password,
        'versions' => @versions
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

    def normalize
      @versions['mysql'] ||= '5.5' if @roles.include?('mysql')
      @versions['teamcity'] ||= '8.0.4' if @roles.include?('teamcity')
      @versions['rubymine'] ||= '5.4.3' if @roles.include?('rubymine')
      @roles << 'gui' if @roles.include?('rubymine') and not @roles.include?('gui')

      %w{ ruby php java }.each do |lang|
        version = File.open(@project_root + ".#{lang}-version", 'r') do |f_in|
          f_in.gets.gsub(/\s/,'')
        end rescue nil
        @versions[lang] ||= version if version
      end
      unless @versions.include?('ruby')
        File.open(@project_root + '.rvmrc', 'r') do |f_in|
          while (line = f_in.gets) and not @versions.include('ruby')
            @versions['ruby'] = $1 if line =~ /^\s*environment_id=['"]([^"'@]+)/
          end
        end rescue nil
      end

      if @memory.nil?
        @memory = 512
        {
                'gui' => 1536,
                'teamcity' => 1536,
                'cruisecontrolrb' => 512
        }.each do |role, extra|
          @memory += extra if @roles.include?(role)
        end
      end

      if @domain.nil?
        if @hostname
          @domain = @hostname.sub(/^[^.]*\.?/, '')
        else
          @domain = sanitize_dns_name(File.basename(File.expand_path(@project_root).sub(/\/$/, '').sub(/\/(app|site|web|www|website)\d*$/, ''))) + '.test'
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

      @private_key_path ||= '~/.ssh/id_rsa'
      @mirror ||= 'auto'
      @salt_root ||= File.dirname(__FILE__) + '/../../'
      @ca_path ||= '/etc/ssl/certs/ca-certificates.crt'
      @ca_path = nil unless  File.exist?(@ca_path)
      @box ||= 'preciseCloud32'
      @region ||= 'San Francisco 1'

      {
              'teamcity' => 8111,
              'cruisecontrolrb' => 3333
      }.each do |role, port|
        @ports << port if @roles.include?(role) and not @ports.include?(port)
      end

      @sync_vagrant = (provider == 'virtualbox') if @sync_vagrant.nil?

      unless @roles.include?('secure') or @roles.include?('insecure')
        @roles << (provider == 'virtualbox' ? 'insecure' : 'secure')
      end
      @machines.each {|m| m.normalize}
    end

  end
end
