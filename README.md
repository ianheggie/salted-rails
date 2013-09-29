# Salted-Rails

Salted-Rails: Provision rails using salt to vagrant or capistrano controlled systems

This gem inspects .ruby-version, config/database.yml, Gemfile and Gemfile.lock to generate salt pillar files to control the configuration of the system. 

THIS GEM IS IN THE EXPERIMENTAL STAGE (pre pre alpha)! EXPECT THINGS TO CHANGE AND BREAK WITHOUT NOTICE!

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

And then adjust your Vagrantfile as follows:

    require 'salted_rails/vagrant_helper'
    vagrant_helper = SaltedRails::VagrantHelper.new(File.dirname(__FILE__))
    Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
      vagrant_helper.configure_vagrant(config)
      vagrant_helper.configure_ubuntu_mirror(config, 'mirror')  # best (ping not bandwidth?) mirror
      vagrant_helper.configure_digital_ocean(config)
      vagrant_helper.configure_salt(config)
      vagrant_helper.configure_ports(config)
      # example - override default key
      # config.ssh.private_key_path = '~/.ssh/id_rsa_Another'
    end

You can add configuration that applies to all your projects to `~/.vagrant.d/Vagrantfile`, eg:

    Vagrant.configure('2') do |config|
      config.vm.provider :digital_ocean do |provider|
        provider.client_id = 'your id'
        provider.api_key = 'your key'
      end
    end

The ubuntu_mirror value can also be:
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

Salt rules are copied into RAILS_ROOT/tmp/salt and pillar info into RAILS_ROOT/tmp/pillar by the `configure_salt` method.
It also (re)creates `pillar/application.sls` based on `.ruby-version`, `config/database.yml` and `Gemfile` ehenever they change.
The configuration files are also copied to `salt/railsapp/files/`.

If you move `RAILS_ROOT/tmp/salt` and `RAILS_ROOT/tmp/pillar` into a RAILS_ROOT/salt directory then you can adjust the other files as desired.
In that case only the `pillar/application.sls` and `salt/railsapp/files/*` files will be refreshed when they become stale (rather than all files).

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
