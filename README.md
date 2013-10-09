# Salted-Rails

Salted-Rails: Provision a vagrant machine for rails using salt.

This gem inspects your rails app configuration to work out what needs to be installed in the virtual machine.

THIS GEM IS IN ALPHA STAGE! THINGS MAY CHANGE AND BREAK WITHOUT NOTICE!

It Inspects:
  * .ruby-version / .rvmrc to control the version of ruby installed (using rbenv)
  * config/database.yml to create users and databases
  * Gemfile and Gemfile.lock to preload gems into the system, and trigger the installation of packages required by gems

This configures vagrant in the way that I personally like:
* ubunutu 12.04 (LTS) 32bit from cloud-images.ubuntu.com (up to date packages and more memory free for systems < 4GB memory)
* forward ssh agent
* digital ocean default to 'San Francisco 1'
* salt provisioning based on rails Gemfile[.lock], database.yml and .ruby-version configuration
* forward post 3000, 80, 443

I am intending to add a capistrano helper as well

## Installation

### Vagrant

Add as a vagrant plugin

    vagrant plugin add salted-rails

And then adjust your Vagrantfile as follows (accepting all the defaults, one machine):

  Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    if defined? SaltedRails::Config
      salted_config = SaltedRails::Config.new(File.dirname(__FILE__))
      salted_config.configure_vagrant(config)
    end

    # .... etc ....
  end

Or for a more complicated example:

    Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

      if defined? SaltedRails::Config
        salted_config = SaltedRails::Config.new(File.dirname(__FILE__))

        # On the guest run the following to copy all these files/firectories to vagrant home directory
        # cd /srv/salt/generated/home ; cp -R .[a-z]* ~vagrant
        # note .ssh/known_hosts and .ssh/authorized_hosts are renamed with .copy_from_home appended
        salted_config.copy_from_home = %w{ .vim .vimrc .gitconfig .ssh .tmux .tmux.conf }

        # if you have multiple ssh keys, you can select which one
        salted_config.private_key_path = '~/.ssh/id_rsa_project' if File.exist? '~/.ssh/id_rsa_project'

        # override default domain
        salted_config.domain = 'mydomain.com'

        # Define a machine  dev
        salted_config.define('dev') do |machine_config|
        end
        
        salted_config.define('qa') do |machine_config|
          # use my ISP's mirror 
          salted_config.mirror = 'internode'

          # explicitly specify memory
          machine_config.memory = 1024

          # add extra roles, which will install extra packages and increase teh defsault memory allocation

          # two continuous integration packages
          # browse http://localhost:8111
          machine_config.roles <<= 'teamcity'

          # browse http://localhost:3333
          machine_config.roles <<= 'curisecontrolrb'

          # gui also configures virtualbox for standard rather than headless mode
          machine_config.roles <<= 'gui'
        end
          
        salted_config.configure_vagrant(config)
      end
    end

You can add configuration that applies to all your projects to `~/.vagrant.d/Vagrantfile`, eg:

    Vagrant.configure('2') do |config|
      config.vm.provider :digital_ocean do |provider|
        provider.client_id = 'your id'
        provider.api_key = 'your key'
      end
    end

The mirror value can also be:
* 'mirror' - Configures mirror: option to auto select from http://mirrors.ubuntu.com/mirrors.txt
* 'internode' - an australian ISP (mine ;)
* a country code - eg 'au', 'uk', 'us' etc
* url of mirror - specify the full url (in the same format as mirrors.txt above)

### Capistrano

Add this line to your application's Gemfile:

    gem 'salted-rails'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install salted-rails

TODO: write the helper and then configure capistrano to use it ...

## Usage

TODO: Write usage instructions here

This gem generates pillar and salt files in RAILS_ROOT/tmp/salt and RAILS_ROOT/tmp/pillar respectively from your application configuration files.
The files it generates are based on `.ruby-version`, `config/database.yml` and `Gemfile` as well 

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
