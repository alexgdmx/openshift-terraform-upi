#  instalacion ocp4 infrastructure to vmware
terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = ">= 2.1.1"
    }
  }
}

variable "vsphere_user" {}
variable "vsphere_password" {}
variable "vsphere_server" {}
variable "cluster_name" {}
variable "full_path" {}
variable "datacenter" {}
variable "datastore" {}
variable "network" {}
variable "resource_pool" {}
variable "host" {}
variable "cluster" {}
variable "ova_name" {}
variable "node_net" {}
variable "url_ignition" {}
variable "node_configs" {}

provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server

  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = var.datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "rp" {
  name          = var.resource_pool
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_host" "esxi" {
  name          = var.host
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_folder" "cluster" {
  path          = var.cluster_name
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

module "bootstrap" {
  source           = "./modules/bootstrap"
  folder           = "/${var.datacenter}/vm/${var.cluster_name}"
  datacenter_id    = data.vsphere_datacenter.dc.id
  resource_pool_id = data.vsphere_resource_pool.rp.id
  host_system_id   = data.vsphere_host.esxi.id
  datastore_id     = data.vsphere_datastore.datastore.id
  network_id       = data.vsphere_network.network.id
  ova_name         = var.ova_name
  vm_data          = "bootstrap"
  node_net         = var.node_net
  url_ignition     = var.url_ignition
  machine_config   = var.node_configs.bootstrap

  depends_on = [
    vsphere_folder.cluster,
  ]
}

module "master" {
  source           = "./modules/nodes-master"
  folder           = "/${var.datacenter}/vm/${var.cluster_name}"
  datacenter_id    = data.vsphere_datacenter.dc.id
  resource_pool_id = data.vsphere_resource_pool.rp.id
  host_system_id   = data.vsphere_host.esxi.id
  datastore_id     = data.vsphere_datastore.datastore.id
  network_id       = data.vsphere_network.network.id
  ova_name         = var.ova_name
  vm_data          = "master"
  node_net         = var.node_net
  url_ignition     = var.url_ignition
  machine_config   = var.node_configs.master

  depends_on = [
    vsphere_folder.cluster,
  ]
}

module "worker" {
  source           = "./modules/nodes"
  folder           = "/${var.datacenter}/vm/${var.cluster_name}"
  datacenter_id    = data.vsphere_datacenter.dc.id
  resource_pool_id = data.vsphere_resource_pool.rp.id
  host_system_id   = data.vsphere_host.esxi.id
  datastore_id     = data.vsphere_datastore.datastore.id
  network_id       = data.vsphere_network.network.id
  ova_name         = var.ova_name
  vm_data          = "worker"
  node_net         = var.node_net
  url_ignition     = var.url_ignition
  machine_config   = var.node_configs.worker

  depends_on = [
    vsphere_folder.cluster,
  ]
}

module "infra" {
  source           = "./modules/nodes"
  folder           = "/${var.datacenter}/vm/${var.cluster_name}"
  datacenter_id    = data.vsphere_datacenter.dc.id
  resource_pool_id = data.vsphere_resource_pool.rp.id
  host_system_id   = data.vsphere_host.esxi.id
  datastore_id     = data.vsphere_datastore.datastore.id
  network_id       = data.vsphere_network.network.id
  ova_name         = var.ova_name
  vm_data          = "worker"
  node_net         = var.node_net
  url_ignition     = var.url_ignition
  machine_config   = var.node_configs.infra

  depends_on = [
    vsphere_folder.cluster,
  ]
}

module "storage" {
  source           = "./modules/nodes-storage"
  folder           = "/${var.datacenter}/vm/${var.cluster_name}"
  datacenter_id    = data.vsphere_datacenter.dc.id
  resource_pool_id = data.vsphere_resource_pool.rp.id
  host_system_id   = data.vsphere_host.esxi.id
  datastore_id     = data.vsphere_datastore.datastore.id
  network_id       = data.vsphere_network.network.id
  ova_name         = var.ova_name
  vm_data          = "worker"
  node_net         = var.node_net
  url_ignition     = var.url_ignition
  machine_config   = var.node_configs.storage

  depends_on = [
    vsphere_folder.cluster,
  ]
}
