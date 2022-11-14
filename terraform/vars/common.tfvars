## VSPHERE CONFIGURATIONS, SHOULD BE THE SAME IN YOU install-config.yaml
vsphere_user     = "administrator@openshift.training"
vsphere_password = "Pass123!"
vsphere_server   = "vcenter.openshift.training"

datacenter    = "vSAN Datacenter"
datastore     = "vsanDatastore"
network       = "DSwitch-VM Network-ephemeral"
resource_pool = "Resources"
cluster       = "vSAN Cluster"
host          = "esxi-r630.openshift.training"

ova_name = "https://mirror.openshift.com/pub/openshift-v4/amd64/dependencies/rhcos/4.11/latest/rhcos-4.11.9-x86_64-vmware.x86_64.ova"

## OCP NODES NETWORKING
node_net = {
  netmask    = "255.255.255.0"
  prefix     = 24
  gateway    = "192.168.0.254"
  dns        = "192.168.0.1"
  domain = "openshift.training"
}

cluster_name = "upi"

## WEBSERVER CONTAINING THE IGNINTIO FILES
url_ignition = "http://192.168.0.9"

## NODE INFORMATIOM
node_configs = {
  bootstrap = {
    ip       = "192.168.0.30"
    hostname = "bootstrap"
    cpu      = 4
    memory   = 16384
    disk     = 120
  }
  master = {
    ip       = ["192.168.0.31", "192.168.0.32", "192.168.0.33"]
    hostname = ["master01", "master02", "master03"]
    cpu      = 4
    memory   = 16384
    disk     = 120
  }
  worker = {
    ip       = ["192.168.0.34", "192.168.0.35", "192.168.0.36"]
    hostname = ["worker01", "worker02", "worker03"]
    cpu      = 8
    memory   = 16384
    disk     = 120
  }
  infra = {
    ip       = ["192.168.0.37", "192.168.0.38", "192.168.0.39"]
    hostname = ["infra01", "infra02", "infra03"]
    cpu      = 4
    memory   = 16384
    disk     = 120
  }
  storage = {
    ip       = []
    hostname = []
    cpu      = 4
    memory   = 16384
    disk     = 120
  }
}

