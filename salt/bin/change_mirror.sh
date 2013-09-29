#!/bin/bash
#
# Changes from the default to given mirror (unable to do it more than once)

case "$1" in
[a-z][a-z]|usa)
    echo "Configuring mirror for region: $1"
    exec sed -i.original -e 's#http://[archivesecurity]*.ubuntu.com/ubuntu#http://'"$1"'.archive.ubuntu.com/ubuntu/#' /etc/apt/sources.list
    ;;
mirror)
    echo "Configuring automatic selection of mirror"
    exec sed -i.original -e 's#http://[archivesecurity]*.ubuntu.com/ubuntu#mirror://mirrors.ubuntu.com/mirrors.txt#' /etc/apt/sources.list
    ;;
internode)
    echo "Configuring mirror for ISP: $1"
    exec sed -i.original -e 's#http://[archivesecurity]*.ubuntu.com/ubuntu#http://mirror.internode.on.net/pub/ubuntu/ubuntu/#' /etc/apt/sources.list
    ;;
[hmf]*://*ubuntu*)
    echo "Configuring mirror for $1"
    exec sed -i.original -e 's#http://[archivesecurity]*.ubuntu.com/ubuntu#'"$1"'#' /etc/apt/sources.list
    ;;
*)
    echo Invalid mirror ignored! >&2
    exit 1
    ;;
esac

