resource "vsphere_virtual_machine" "openshift" {
  count                = length(var.machine_config.ip)
  name                 = "${var.machine_config.hostname[count.index]}.${var.node_net.domain}"
  datacenter_id        = var.datacenter_id
  datastore_id         = var.datastore_id
  host_system_id       = var.host_system_id
  resource_pool_id     = var.resource_pool_id
  folder               = var.folder
  num_cpus             = var.machine_config.cpu
  num_cores_per_socket = var.machine_config.cpu / 2
  memory               = var.machine_config.memory
#  cpu_reservation      = 4200
  memory_reservation   = var.machine_config.memory
#  latency_sensitivity  = "high"
  cpu_hot_add_enabled  = true                  
  cpu_hot_remove_enabled = true   
  memory_hot_add_enabled = true

  enable_disk_uuid            = true
  wait_for_guest_net_timeout  = 0
  wait_for_guest_net_routable = false
  boot_delay                  = 10000

  network_interface {
    network_id = var.network_id
  }

  disk {
    thin_provisioned = true
    label = "disk0"
    size  = var.machine_config.disk
  }

  ovf_deploy {
    allow_unverified_ssl_cert = false
    remote_ovf_url            = var.ova_name
    disk_provisioning         = "thin"
    ip_protocol               = "IPV4"
    ip_allocation_policy      = "STATIC_MANUAL"
  }

  extra_config = {
    "guestinfo.afterburn.initrd.network-kargs" = "ip=${var.machine_config.ip[count.index]}::${var.node_net.gateway}:${var.node_net.netmask}:${var.machine_config.hostname[count.index]}.${var.node_net.domain}:ens192:none nameserver=${var.node_net.dns}",
  }

  vapp {
    properties = {
      "guestinfo.ignition.config.data"           = filebase64("/var/www/html/${var.vm_data}.ign")
      "guestinfo.ignition.config.data.encoding"  = "base64",
    }
  }


}
