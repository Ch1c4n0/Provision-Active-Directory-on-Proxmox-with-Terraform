terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.66.0" # ou versão mais recente
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox_endpoint

  # Autenticação via API Token
  api_token = var.proxmox_api_token

  insecure = var.proxmox_insecure # Para certificados autoassinados

  # Necessário apenas para upload de snippets (o script do AD roda via cloudbase-init user_data)
  ssh {
    username    = var.ssh_username
    agent       = var.ssh_agent
    password    = var.ssh_password == "" ? null : var.ssh_password
    private_key = var.ssh_private_key_path == "" ? null : file(var.ssh_private_key_path)
  }
}
