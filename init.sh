#!/bin/sh

msg='OK: Vagrant has been setup: ready for vagrant up [--provider=digital_ocean]'

if which VirtualBox; then
  echo Found VirtualBox
  VirtualBox --help | line
else
  echo 'ACTION REQUIRED: Please install VirtualBox 4.2.18 or later from https://www.virtualbox.org/wiki/Downloads'
  msg='(PLEASE RERUN SCRIPT AFTERWARDS)'
fi

if which vagrant; then
  echo 'Found vagrant:'
  vagrant -v
  echo 'Checking vagrant plugins are installed ...'

  vagrant plugin list > /tmp/t$$
  for plugin in deep_merge vagrant-digitalocean vagrant-vbguest salted-rails
  do
    if grep $plugin < /tmp/t$$; then
      echo Updating plugin $plugin
      vagrant plugin update $plugin
    else
      echo Installing plugin $plugin
      vagrant plugin install $plugin
    fi
  done

else
  echo 'ACTION REQUIRED: Please install vagrant 1.3.3 (1.3.4 has a bug) from http://www.vagrantup.com/'
  msg='(PLEASE RERUN SCRIPT AFTERWARDS)'
fi

if [ ! -f Vagrantfile ]; then
  if [ -f Vagrantfile.example ]; then
    if [ -f Vagrantfile ]; then
      echo 'Found Vagrantfile (previously copied from example)'
    else
      echo 'Copying Vagrantfile.example to Vagrantfile (so you can customize it)'
      cp Vagrantfile.example Vagrantfile
    fi
  else
    echo WARNING: Vagrantfile.example not found - skipped Vagrantfile setup
    msg='(Please run vagrant init in your rails project directory then edit Vagrantfile)'
  fi
fi

mkdir -p "$HOME/.vagrant.d"

global_Vagrantfile="$HOME/.vagrant.d/Vagrantfile"
if [ -f "$global_Vagrantfile" ]; then
  echo Found global Vagrantfile: $global_Vagrantfile
else
  echo "About to set up $global_Vagrantfile"
  echo -n "Enter your digital ocean client key (defaul none): "
  read client_id
  echo -n "Enter your digital ocean API key (defaul none): "
  read api_key
  if [ -n "$client_id" -a -n "$api_key" ] ; then
  echo "
Vagrant.configure('2') do |config|
  config.vm.provider :digital_ocean do |provider|
    provider.client_id = '$client_id'
    provider.api_key = '$api_key'
  end
end
" > $global_Vagrantfile
  fi
fi
echo
echo "$msg"
exit 0
