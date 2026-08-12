# --- Parâmetros do domínio Active Directory ---

variable "domain_name" {
  type    = string
  default = "cloudinfocus.corp"
}

variable "dc_name" {
  type    = string
  default = "ntdc01"
}

variable "domain_netbios_name" {
  type    = string
  default = "cloudinfocus"
}

variable "domain_mode" {
  type    = string
  default = "WinThreshold" # Windows Server 2016 mode
}

variable "vm_admin_username" {
  type    = string
  default = "Administrator"
}

variable "domain_admin_password" {
  type      = string
  default   = "HabemusPapam123@"
  sensitive = true
}

variable "database_path" {
  type    = string
  default = "C:/Windows/NTDS"
}

variable "sysvol_path" {
  type    = string
  default = "C:/Windows/SYSVOL"
}

variable "log_path" {
  type    = string
  default = "C:/Windows/NTDS"
}

variable "safe_mode_administrator_password" {
  type      = string
  default   = "HabemusPapam123@"
  sensitive = true
}

locals {
  cmd01 = "Install-WindowsFeature AD-Domain-Services -IncludeAllSubFeature -IncludeManagementTools"
  cmd02 = "Install-WindowsFeature DNS -IncludeAllSubFeature -IncludeManagementTools"
  cmd03 = "Import-Module ADDSDeployment, DnsServer"
  # Valores entre aspas simples para suportar senhas com caracteres especiais (&, %, espaços)
  cmd04      = "Install-ADDSForest -DomainName '${var.domain_name}' -DomainNetbiosName '${var.domain_netbios_name}' -DomainMode '${var.domain_mode}' -ForestMode '${var.domain_mode}' -DatabasePath '${var.database_path}' -SysvolPath '${var.sysvol_path}' -LogPath '${var.log_path}' -NoRebootOnCompletion:$false -Force:$true -SafeModeAdministratorPassword (ConvertTo-SecureString '${var.safe_mode_administrator_password}' -AsPlainText -Force)"
  powershell = "${local.cmd01}; ${local.cmd02}; ${local.cmd03}; ${local.cmd04}"

  # Script executado pelo Cloudbase-Init (UserDataPlugin) no 1º boot da VM
  guest_script = <<-EOT
    net user "${var.vm_admin_username}" "${var.domain_admin_password}"

    # Remove o usuário "Admin" que o Cloudbase-Init cria por padrão (senha aleatória, não usado por nós)
    net user Admin /delete

    $adapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | Select-Object -First 1
    if ($adapter) {
      New-NetIPAddress -InterfaceIndex $adapter.ifIndex -IPAddress "${cidrhost(var.bridge_cidr_range, var.ad_network_host)}" -PrefixLength 24 -DefaultGateway "${cidrhost(var.bridge_cidr_range, 1)}" -ErrorAction SilentlyContinue
      Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ServerAddresses ("127.0.0.1","${cidrhost(var.bridge_cidr_range, 1)}")
    }

    ${local.cmd01}
    ${local.cmd02}
    ${local.cmd03}
    ${local.cmd04}
  EOT

  # "#ps1_sysnative" faz o cloudbase-init executar este script automaticamente no 1º boot
  cloudbase_userdata = <<-EOT
    #ps1_sysnative
    ${local.guest_script}
  EOT
}
