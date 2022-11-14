#!/bin/bash
set -xe
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

rm -fr deployment
mkdir deployment

cp install-config.yaml deployment/

PULL_SECRET=$(cat ../.pull-secret | tr -d '\n\r\t ')
sed -i "s/PULL_SECRET/${PULL_SECRET}/" deployment/install-config.yaml

SSH_KEY=$(cat ~/.ssh/id_rsa.pub | tr -d '\n\r\t' | sed -r 's/\//\\\//g')
sed -i "s/SSH_KEY/${SSH_KEY}/" deployment/install-config.yaml

openshift-install create manifests --dir=deployment

sed -i 's/true/false/g' deployment/manifests/cluster-scheduler-02-config.yml
rm -f deployment/openshift/99_openshift-cluster-api_master-machines-*.yaml deployment/openshift/99_openshift-cluster-api_worker-machineset-*.yaml

openshift-install create ignition-configs --dir=deployment

sudo cp -f deployment/*.ign /var/www/html/

sudo chmod 755 /var/www/html/*
sudo chcon -R -t httpd_sys_content_t /var/www/html
sudo restorecon -R -v /var/www/html

export KUBECONFIG="${DIR}/deployment/auth/kubeconfig"
