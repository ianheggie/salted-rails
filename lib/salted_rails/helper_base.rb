# -*- mode: ruby -*-
# vi: set ft=ruby :
#

require 'erb'
require 'yaml'
require 'fileutils'
require "salted_rails_base"

class SaltedRails < SaltedRailsBase
  class HelperBase

    class DevNullLogger
      def debug(msg)
        puts msg
      end

      def info(msg)
        puts msg
      end
    end

    def initialize(rails_root, logger)
      @logger = logger || DevNullLogger.new

      @rails_root = rails_root
      @rails_root += '/' unless @rails_root =~ /\/$/

      @salt_root = File.dirname(__FILE__) + '/../../'

      @logger.info "RAILS_ROOT = #{@rails_root}"

      @memory = 512  # in MB
    end


    private

    # Add ruby version and gemfiles
    
    def pillarize_application_configuration
      @logger.debug 'Creating pillar application data' 
      # Configuration from:
      version_file = @rails_root + '.ruby-version'
      rvmrc_file = @rails_root + '.rvmrc'
      database_file = @rails_root + 'config/database.yml'
      gemfile = @rails_root + 'Gemfile'
      gemfilelock = @rails_root + 'Gemfile.lock'

      # Destination
      salt_dir = @rails_root + 'config/salt/'
      pillar_dir = @rails_root + 'config/pillar/'
      pillar_app_file = pillar_dir + 'railsapp.sls'
      pillar_custom_file = pillar_dir + 'custom.sls'

      rails_config_changed = true # Whilst still developing
      rails_config_changed ||= ! (File.exist?(pillar_app_file) and File.exist?(salt_app_file))
      rails_config_changed ||= (File.mtime(__FILE__) > File.mtime(pillar_app_file))
      files = [ version_file, database_file, gemfile, gemfilelock ].select{ |f| File.exist?(f) }
      files.each do |f|
        rails_config_changed ||= (File.mtime(f) > File.mtime(pillar_app_file))
      end

     if rails_config_changed
        dest = salt_dir + "railsapp/files"
        FileUtils.mkdir_p dest
        files.each do |file|
          @logger.info "Copying #{file} to #{dest}"
          FileUtils.cp(file, dest)
        end

        FileUtils.mkdir_p @rails_root + "config/pillar"

        unless File.exist? pillar_custom_file
          File.open(pillar_custom_file, 'w') do |f_out|
            f_out.puts '#Add custom pillar data here'
          end
        end

        File.open(pillar_app_file, 'w') do |f_out|
          ENV['VAGRANT_MACHINE'] = 'true'
          database_conf = YAML.load(ERB.new(IO.read(database_file)).result) rescue { }
          ruby_version = File.open(version_file, 'r') do |f_in|
            f_in.gets.gsub(/\s/,'')
          end rescue nil
          ruby_version ||= File.open(rvmrc_file, 'r') do |f_in|
            while !ruby_version && (line = f_in.gets) 
              ruby_version = $1 if line =~ /^\s*environment_id=['"]([^"'@]+)/
            end
          end
          ruby_version ||= '1.9.3'

          app_config = {
            'database' => database_conf,
            'ruby-version' => ruby_version,
            'gems' => { }
            }
          database_conf.each do |key, details|
            app_config['gems'][details['adapter']] = true
          end
          if File.exists? gemfile
            File.foreach(gemfile) do |line|
              app_config['gems'][$1] = true if (line =~ /^\s*gem\s*['"]([^'"]+)/)
            end
          end
          f_out.puts app_config.to_yaml
        end
      else
        @logger.info 'skipped configuration of salt and pillar (up to date)'
      end

    end
  end
end
