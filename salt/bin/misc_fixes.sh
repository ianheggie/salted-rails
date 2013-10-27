#!/bin/bash
#

old=`cat /etc/hostname`
case "$old" in
*.*)
  echo "Removing domain from /etc/hostname (was $old)"
  sed -i "s@\..*\$@@" /etc/hostname
  hostname -F /etc/hostname
  new=`cat /etc/hostname`
  echo "(now $new)"
  if [ -z "`grep "$old" /etc/hosts`" ]; then
    echo "Adding '127.0.1.1         $old $new' entry to /etc/hosts"
    echo "127.0.1.1         $old $new" >> /etc/hosts
  fi
  ;;
esac

for f in bootstrap-salt.log bootstrap_salt.sh
do
  rm -f /tmp/$f.old
  if [ -f /tmp/$f ]; then
    echo Renaming /tmp/$f as /tmp/$f.old
    mv /tmp/$f /tmp/$f.old
  fi
done
