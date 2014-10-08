#! /bin/sh
if [ -z $1 ] ; then
  echo "usage: sh ./vagrant-box-add.sh <vagrant-base-box>"
  exit 1
fi

set -x
export box=$1
box_pathsafe=${box//\//-}
output="local-${box_pathsafe}.box"
vagrantfile="./local-${box_pathsafe}-Vagrantfile"
vagrant up && vagrant package --output $output --vagrantfile $vagrantfile && vagrant box add --name local/${box_pathsafe} local-${box_pathsafe}.box
