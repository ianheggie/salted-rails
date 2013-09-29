# Allows this gem to be used both within and outside of Vagrant
if defined? Vagrant
  class SaltedRailsBase < Vagrant.plugin("2")
  end
else
  class SaltedRailsBase
  end
end


