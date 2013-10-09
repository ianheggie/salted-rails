# -*- mode: ruby -*-
# vi: set ft=ruby :
#

require 'erb'
require 'yaml'
require 'fileutils'

module SaltedRails
  class HelperBase

    attr_accessor :config

    def initialize(config)
      @config = config
      @config.logger.info "SaltedRails: Helper created with config.rails_root = #{@config.rails_root}"
    end

    private

    # Add ruby version and gemfiles
    
#    def create_empty_custom_files
#      @config.logger.info 'SaltedRails: Checking stubbed custom files exist' 
#
#      # Create custom files
#      [ 'pillar/vagrant', 'pillar/capistrano', 'salt/vagrant', 'salt/capistrano'].each do |custom|
#        file = @config.rails_root + 'config/' + custom + '.sls'
#        dir = File.dirname(file)
#        unless File.directory? dir
#          FileUtils.mkdir_p dir
#        end
#        unless File.exists? file
#          @config.logger.info "SaltedRails: Creating empty #{file}"
#          File.open(file, 'w') do |f_out|
#            f_out.puts '# Custom data'
#          end
#        end
#      end
#    end

    def pillarize_application_configuration
      @config.logger.info 'SaltedRails: Creating pillar application data' 

      # Destination
      salt_dir = @config.rails_root + 'tmp/salt/'
      FileUtils.rm_rf salt_dir if File.directory? salt_dir
      FileUtils.mkdir_p salt_dir unless File.directory? salt_dir
      pillar_dir = @config.rails_root + 'tmp/pillar/'
      FileUtils.rm_rf pillar_dir if File.directory? pillar_dir
      FileUtils.mkdir_p pillar_dir unless File.directory? pillar_dir
      pillar_app_file = pillar_dir + 'railsapp.sls'
      @config.files.each do |f|
        basename = File.basename(f)
        dest = salt_dir + "files/" + basename
        dir = File.dirname(dest)
        unless File.directory? dir
          FileUtils.mkdir_p dir
        end
        FileUtils.cp(@config.rails_root + f, dest)
      end
      @config.copy_from_home.each do |f|
        dest = salt_dir + "home/" + f
        dir = File.dirname(dest)
        unless File.directory? dir
          FileUtils.mkdir_p dir
        end
        if !File.exist?(dest) or (File.mtime(ENV['HOME'] + '/' + f) > File.mtime(dest))
          @config.logger.info "SaltedRails: Copying #{f} to #{dest}"
          FileUtils.cp_r(ENV['HOME'] + '/' + f, dest)
        end
      end
      %w{ authorized_keys known_hosts }.each do |f|
        file = salt_dir + "home/.ssh/" + f
        FileUtils.mv(file, file + '.from_home') if File.exist? file
      end
      File.open(pillar_app_file, 'w') do |f_out|
        if_command = 'if'
        @config.machines.each do |machine_config|
          f_out.puts "{% #{if_command} grains['fqdn'] == '#{machine_config.hostname}' %}"
          if_command = 'elif'
          f_out.puts machine_config.to_yaml
        end
        f_out.puts "{% else %}" unless @config.machines.empty?
        f_out.puts @config.to_yaml
        f_out.puts "{% endif %}" unless @config.machines.empty?
      end
    end
  end
end
