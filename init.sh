#!/bin/sh

msg='OK: Vagrant has been setup: ready for vagrant up [--provider=digital_ocean]'

if which VirtualBox; then
  echo Found Virtualbox
else
  echo ACTION REQUIRED: Please install Virtualbox 4.2.18 or later from https://www.virtualbox.org/wiki/Downloads
  msg='(PLEASE RERUN SCRIPT AFTERWARDS)'
fi

if which vagrant; then
  echo Found vagrant
  echo Checking vagrant plugins are installed ...

  vagrant plugin list > /tmp/t$$
  for plugin in deep_merge vagrant-digitalocean vagrant-vbguest # salted-rails
  do
    if grep $plugin < /tmp/t$$; then
      vagrant plugin update $plugin
    else
      vagrant plugin install $plugin
    fi
  done

else
  echo ACTION REQUIRED: Please install vagrant 1.3.4 or later from http://www.vagrantup.com/
  msg='(PLEASE RERUN SCRIPT AFTERWARDS)'
fi

if [ -f Vagrantfile.example ]; then
  if [ -f Vagrantfile ]; then
    echo Found Vagrantfile '(previously copied from example)'
  else
    echo Copying Vagrantfile.example to Vagrantfile '(so you can customize it)'
    cp Vagrantfile.example Vagrantfile
  fi
else
  echo ERROR: setup_vagrant Must be run in rails root directory '(Vagrantfile.example not found)'
  msg='(PLEASE RERUN SCRIPT FROM CORRECT DIRECTORY)'
fi

mkdir -p $HOME/.vagrant.d

if [ -f "$HOME/.vagrant.d/Vagrantfile" ]; then
  echo Found global Vagrantfile
else
  echo "About to set up ~/.vagrant.d/Vagrantfile"
  echo -n "Enter your digital ocean client key (defaul none): "
  read client_id
  echo -n "Enter your digital ocean API key (defaul none): "
  read api_key
  echo "
Vagrant.configure('2') do |config|
  config.vm.provider :digital_ocean do |provider|
    provider.client_id = '$client_id'
    provider.api_key = '$api_key'
  end
end
" > $HOME/.vagrant.d/Vagrantfile
fi
echo
echo "$msg"
exit 0