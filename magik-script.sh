#!/bin/sh
#Launch the packer build of the ubuntu template.
cd packer && packer build -force Ubuntu2004-Packer.json
#Init the Terraform project
cd ../terraform && terraform init
#Check the execution plan synthax
terraform plan
#Apply the plan to VSphere
echo "yes" | terraform apply
#Remove ssh known hosts
rm ~/.ssh/known_hosts
#Install needed Ansible collection
ansible-galaxy collection install ansible.posix
#Launch the Ansible playbook
cd ansible && ansible-playbook -i hosts deploy-cluster.yml -v
