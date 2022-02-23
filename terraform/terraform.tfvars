
# terraform.tfvars

# First we define how many controller nodes and worker nodes we want to deploy
control-count = "3"
worker-count = "3"

# VM Configuration
vm-prefix = "k8s"
vm-template-name = "Ubuntu2004-Packer"
vm-cpu = "2"
vm-ram = "2048"
vm-guest-id = "ubuntu64Guest"
vm-datastore = "<your datastore name>"
vm-network = "VM Network"
vm-domain = "vsphere.local"

# vSphere configuration
vsphere-vcenter = "192.168.0.31"
vsphere-unverified-ssl = "true"
vsphere-datacenter = "<your datacenter name>"
vsphere-cluster = "<your cluster name>"
vsphere-user = "administrator@<your vsphere domain>"
vsphere-pass = "<your vsphere password>"
