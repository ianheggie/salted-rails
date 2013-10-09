#!/bin/bash
#
# Removes domain from /etc/hostname

sed -i "s@\..*\$@@" /etc/hostname
hostname -F /etc/hostname
