require "vagrant"

module VagrantPlugins
  module SaltedRails
    class Plugin < Vagrant.plugin("2")
      name "Salted Rails"
    end
  end
end
