# main.tf
# Configure the vSphere provider
provider "vsphere" {
    user = var.vsphere-user
    password = var.vsphere-pass
    vsphere_server = var.vsphere-vcenter
    allow_unverified_ssl = var.vsphere-unverified-ssl
}

data "vsphere_datacenter" "dc" {
    name = var.vsphere-datacenter
}

data "vsphere_datastore" "datastore" {
    name = var.vm-datastore
    datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "cluster" {
    name = var.vsphere-cluster
    datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
    name = var.vm-network
    datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
    name = var.vm-template-name
    datacenter_id = data.vsphere_datacenter.dc.id
}

# Create VM Folder
resource "vsphere_folder" "folder" {
  path          = "k8s"
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Create Control VMs
resource "vsphere_virtual_machine" "control" {
    count = var.control-count
    name = "${var.vm-prefix}-controller-${count.index + 1}"
    resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
    datastore_id = data.vsphere_datastore.datastore.id
    folder = vsphere_folder.folder.path
    
    num_cpus = var.vm-cpu
    memory = var.vm-ram
    guest_id = var.vm-guest-id

    
    network_interface {
        network_id = data.vsphere_network.network.id
    }

    disk {
        label = "${var.vm-prefix}-${count.index + 1}-disk"
        size  = 25
    }

    clone {
        template_uuid = data.vsphere_virtual_machine.template.id
        customize {
            timeout = 0
            
            linux_options {
            host_name = "${var.vm-prefix}-controller-${count.index + 1}"
            domain = var.vm-domain
            }
            
            network_interface {
            ipv4_address = "192.168.0.4${count.index + 1}"
            ipv4_netmask = 24
            }

            ipv4_gateway = "192.168.0.1"
            dns_server_list = [ "192.168.0.18" ]

        }
    }
}

# Create Worker VMs
resource "vsphere_virtual_machine" "worker" {
    count = var.worker-count
    name = "${var.vm-prefix}-worker-${count.index + 1}"
    resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
    datastore_id = data.vsphere_datastore.datastore.id
    folder = vsphere_folder.folder.path
    
    num_cpus = var.vm-cpu
    memory = var.vm-ram
    guest_id = var.vm-guest-id
    
    network_interface {
        network_id = data.vsphere_network.network.id
    }

    disk {
        label = "${var.vm-prefix}-${count.index + 1}-disk"
        size  = 25
    }

    clone {
        template_uuid = data.vsphere_virtual_machine.template.id
        customize {
            timeout = 0
            
            linux_options {
            host_name = "${var.vm-prefix}-worker-${count.index + 1}"
            domain = var.vm-domain
            }
            
            network_interface {
            ipv4_address = "192.168.0.5${count.index + 1}"
            ipv4_netmask = 24
            }

            ipv4_gateway = "192.168.0.1"
            dns_server_list = [ "192.168.0.18" ]
        }
    }
}

output "control_ip_addresses" {
 value = vsphere_virtual_machine.control.*.default_ip_address
}

output "worker_ip_addresses" {
 value = vsphere_virtual_machine.worker.*.default_ip_address
}
