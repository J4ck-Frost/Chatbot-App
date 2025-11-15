#!/bin/bash
set -e
cd ./environments/dev
terraform init
terraform apply -auto-approve
cd ../../ansible
ansible-playbook -i inventory.yaml playbook.yaml