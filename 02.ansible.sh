#!/bin/bash

if [ $UID != '0' ] ; then
  echo "You should run it as superuser"
  exit 1
fi

apt install ansible -y
ansible-galaxy collection install community.general
