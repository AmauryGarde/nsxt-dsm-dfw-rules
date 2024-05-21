terraform {
  required_providers {
    nsxt = {
      source  = "vmware/nsxt"
      version = "3.6.1"
    }
  }
}

provider "nsxt" {
  host                = var.nsx_manager_hostname
  username            = var.nsx_manager_username
  password            = var.nsx_manager_password
  allow_unverified_ssl = true
}

data "nsxt_policy_service" "ssh" {
  display_name = "SSH"
}

data "nsxt_policy_service" "https" {
  display_name = "HTTPS"
}

data "nsxt_policy_service" "http" {
  display_name = "HTTP"
}

data "nsxt_policy_service" "postgresql" {
  display_name = "PostgreSQL"
}

data "nsxt_policy_service" "mysql" {
  display_name = "MySQL"
}

# Define the inventory groups
resource "nsxt_policy_group" "provider_vm" {
  display_name = "Provider_VM_Group"
  criteria {
    ipaddress_expression {
      ip_addresses = [var.provider_vm_ip]
    }
  }
}

resource "nsxt_policy_group" "database" {
  display_name = "Database_Segment_Group"
  criteria {
    ipaddress_expression {
      ip_addresses = var.database_segment_ranges
    }
  }
}

resource "nsxt_policy_group" "app_segment" {
  display_name = "App_Segment_Group"
  criteria {
    ipaddress_expression {
      ip_addresses = var.app_segment_ranges
    }
  }
}

resource "nsxt_policy_group" "s3_storage" {
  display_name = "S3_Storage_Group"
  criteria {
    ipaddress_expression {
      ip_addresses = var.s3_ips
    }
  }
}

resource "nsxt_policy_group" "end_user" {
  display_name = "End_User_Group"
  criteria {
    ipaddress_expression {
      ip_addresses = var.end_user_ranges
    }
  }
}

resource "nsxt_policy_group" "database_client" {
  display_name = "Database_Client_Group"
  criteria {
    ipaddress_expression {
      ip_addresses = var.database_client_ranges
    }
  }
}

resource "nsxt_policy_service" "service_https_6443" {
  description  = "Kubernetes API servers secure communication service"
  display_name = "HTTPS6443"

  l4_port_set_entry {
    display_name      = "TCP6443"
    description       = "TCP port 6443 entry"
    protocol          = "TCP"
    destination_ports = ["6443"]
  }
}

# Define the security policy with custom name
resource "nsxt_policy_security_policy" "dsm_security_policy" {
  display_name = "DSM_Security_Policy"
  category    = "Application"

  rule {
    display_name        = "Provider VM to S3-compatible Provider storage"
    source_groups       = [nsxt_policy_group.provider_vm.path]
    destination_groups  = [nsxt_policy_group.s3_storage.path]
    services            = [data.nsxt_policy_service.http.path, data.nsxt_policy_service.https.path]
    action              = "ALLOW"
  }

  # Conditionally create the outbound HTTPS rule based on air_gapped_deployment variable
  dynamic "rule" {
    for_each = var.air_gapped_deployment ? [] : [1]
    content {
      display_name        = "Provider VM to outbound HTTPS"
      source_groups       = [nsxt_policy_group.provider_vm.path]
      services            = [data.nsxt_policy_service.https.path]
      action              = "ALLOW"
    }
  }

  rule {
    display_name        = "Provider VM to Database"
    source_groups       = [nsxt_policy_group.provider_vm.path]
    destination_groups  = [nsxt_policy_group.database.path]
    services            = [nsxt_policy_service.service_https_6443.path]
    action              = "ALLOW"
  }

  rule {
    display_name        = "Database to S3-compatible storage"
    source_groups       = [nsxt_policy_group.database.path]
    destination_groups  = [nsxt_policy_group.s3_storage.path]
    services            = [data.nsxt_policy_service.http.path, data.nsxt_policy_service.https.path]
    action              = "ALLOW"
  }

  rule {
    display_name        = "VMware Data Services Manager Console Client to Provider VM"
    source_groups       = [nsxt_policy_group.database_client.path]
    destination_groups  = [nsxt_policy_group.provider_vm.path]
    services            = [data.nsxt_policy_service.https.path]
    action              = "ALLOW"
  }

  rule {
    display_name        = "End User to Provider VM"
    source_groups       = [nsxt_policy_group.end_user.path]
    destination_groups  = [nsxt_policy_group.provider_vm.path]
    services            = [data.nsxt_policy_service.ssh.path]
    action              = "ALLOW"
  }

  rule {
    display_name        = "End User to Database"
    source_groups       = [nsxt_policy_group.end_user.path]
    destination_groups  = [nsxt_policy_group.database.path]
    services            = [data.nsxt_policy_service.ssh.path, data.nsxt_policy_service.https.path]
    action              = "ALLOW"
  }

  rule {
    display_name        = "Database Client to Database (PostgreSQL)"
    source_groups       = [nsxt_policy_group.database_client.path]
    destination_groups  = [nsxt_policy_group.database.path]
    services            = [data.nsxt_policy_service.postgresql.path]
    action              = "ALLOW"
  }

  rule {
    display_name        = "Database Client to Database (MySQL)"
    source_groups       = [nsxt_policy_group.database_client.path]
    destination_groups  = [nsxt_policy_group.database.path]
    services            = [data.nsxt_policy_service.mysql.path]
    action              = "ALLOW"
  }
}
