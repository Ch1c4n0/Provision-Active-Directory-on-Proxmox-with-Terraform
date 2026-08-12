# Localiza o template Windows Server 2022 pelo nome
data "proxmox_virtual_environment_vms" "ad_template" {
  filter {
    name   = "name"
    values = [var.template_name]
  }

  filter {
    name   = "template"
    values = [true]
  }
}

# Cópia local do script, só para conferência/depuração
resource "local_file" "install_ad_script" {
  content  = local.cloudbase_userdata
  filename = "${path.module}/generated/install-ad.ps1"
}

# Snippet enviado ao Proxmox: o cloudbase-init lê e executa isso no 1º boot da VM
resource "proxmox_virtual_environment_file" "ad_userdata" {
  content_type = "snippets"
  datastore_id = var.snippets_datastore_id
  node_name    = var.target_node

  source_raw {
    data      = local.cloudbase_userdata
    file_name = "ad-userdata-${var.vm_name}.ps1"
  }
}

resource "proxmox_virtual_environment_vm" "ad" {
  node_name = var.target_node
  vm_id     = var.vm_id
  name      = var.vm_name
  tags      = ["ad", "dc"]

  # Clonagem da VM Template-WinServer2022
  clone {
    vm_id = data.proxmox_virtual_environment_vms.ad_template.vms[0].vm_id
    full  = true
  }

  agent {
    enabled = true
  }

  cpu {
    cores   = var.ad_cores
    sockets = var.ad_sockets
    type    = "host"
  }

  memory {
    dedicated = var.ad_memory
  }

  # disk {
  #   datastore_id = "local-lvm"
  #   size         = var.ad_disksize
  #   interface    = "scsi0"
  # }

  network_device {
    bridge = var.bridge_network
    model  = "virtio"
  }

  # Configuração via cloudbase-init (o template precisa ter o cloudbase-init instalado)
  initialization {
    # user_data_file_id substitui user_account: o script roda sozinho no 1º boot
    user_data_file_id = proxmox_virtual_environment_file.ad_userdata.id

    ip_config {
      ipv4 {
        address = "${cidrhost(var.bridge_cidr_range, var.ad_network_host)}/24"
        gateway = cidrhost(var.bridge_cidr_range, 1)
      }
    }
  }
}
