# --- Conexão com o Proxmox ---

variable "proxmox_endpoint" {
  type        = string
  description = "URL da API do Proxmox VE (ex: https://192.168.200.107:8006/)"
}

variable "proxmox_api_token" {
  type        = string
  description = "API Token do Proxmox no formato user@realm!tokenid=uuid"
  sensitive   = true
}

variable "proxmox_insecure" {
  type        = bool
  default     = true
  description = "Ignora a validação do certificado TLS do Proxmox (certificados autoassinados)"
}

# --- SSH para o node Proxmox (exigido apenas para upload de snippets) ---

variable "ssh_username" {
  type        = string
  default     = "root"
  description = "Usuário SSH do node Proxmox usado para upload de snippets"
}

variable "ssh_agent" {
  type        = bool
  default     = true
  description = "Usar o ssh-agent local para autenticar no node Proxmox (chave já carregada)"
}

variable "ssh_password" {
  type        = string
  default     = ""
  sensitive   = true
  description = "Senha SSH do node Proxmox, caso não use ssh-agent/chave"
}

variable "ssh_private_key_path" {
  type        = string
  default     = ""
  description = "Caminho local do arquivo de chave privada SSH (sem senha), ex: C:/Users/voce/.ssh/proxmox_terraform"
}

# --- VM do Active Directory ---

variable "target_node" {
  type        = string
  description = "Nó do cluster Proxmox onde a VM do AD será criada"
}

variable "template_name" {
  type        = string
  default     = "temp-ws2022-cloudbaseinit-v2"
  description = "Nome do template Windows Server 2022 (com Cloudbase-Init instalado) usado para clonar a VM"
}

variable "snippets_datastore_id" {
  type        = string
  default     = "local"
  description = "Datastore com o content type 'Snippets' habilitado (Datacenter > Storage > <id> > Content), usado para o script do cloudbase-init"
}

variable "vm_id" {
  type        = number
  description = "ID da VM do Active Directory no Proxmox"
}

variable "vm_name" {
  type        = string
  default     = "AD-DC01-CloudInFocus"
  description = "Nome da VM do Active Directory"
}

variable "ad_cores" {
  type    = number
  default = 2
}

variable "ad_sockets" {
  type    = number
  default = 2
}

variable "ad_memory" {
  type    = number
  default = 8192
}

variable "ad_disksize" {
  type    = number
  default = 60
}

# --- Rede ---

variable "bridge_network" {
  type        = string
  default     = "vmbr0"
  description = "Bridge de rede do Proxmox usada pela VM"
}

variable "bridge_cidr_range" {
  type        = string
  description = "CIDR da rede onde a VM receberá o IP fixo (ex: 192.168.200.0/24)"
}

variable "ad_network_host" {
  type        = number
  description = "Último octeto do IP fixo da VM dentro do CIDR informado (ex: 10 para .10)"
}
