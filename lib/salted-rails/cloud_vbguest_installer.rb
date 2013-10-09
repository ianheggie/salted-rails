module SaltedRails
  class CloudVbguestInstaller < VagrantVbguest::Installers::Ubuntu
    def install(opts=nil, &block)
      communicate.sudo("apt-get -y -q purge virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11", opts, &block)
      @vb_uninstalled = true
      super
    end

    def running?(opts=nil, &block)
      return false if @vb_uninstalled
      super
    end
  end
end
