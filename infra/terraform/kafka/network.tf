locals {
  ipsec_peer_cidrs = [
    "109.107.175.116/32", # ndrl
    "193.233.83.45/32",   # ltv
  ]
}

resource "yandex_vpc_network" "vpnctl" {
  name = "vpnctl"
}

resource "yandex_vpc_subnet" "edge" {
  name           = "edge"
  zone           = var.zone
  v4_cidr_blocks = var.edge_subnet_cidr
  network_id     = yandex_vpc_network.vpnctl.id
}

resource "yandex_vpc_subnet" "backend" {
  name           = "backend"
  zone           = var.zone
  v4_cidr_blocks = var.backend_subnet_cidr
  network_id     = yandex_vpc_network.vpnctl.id

  route_table_id = yandex_vpc_route_table.backend_gateway.id
}


# External NIC of lb01.
# SSH + IKE/NAT-T from known IPsec peers.
resource "yandex_vpc_security_group" "lb01" {
  name       = "lb01-sg"
  network_id = yandex_vpc_network.vpnctl.id

  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "UDP"
    port           = 500
    v4_cidr_blocks = local.ipsec_peer_cidrs
  }

  ingress {
    protocol       = "UDP"
    port           = 4500
    v4_cidr_blocks = local.ipsec_peer_cidrs
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}


# Kafka/backend hosts.
#
# 1. Allow communication inside backend subnet.
# 2. Allow original source addresses of IPsec peers.
#
# After lb01 decrypts an IPsec packet it does NOT SNAT it,
# therefore kfk01 sees:
#
# src = 109.107.175.116
# dst = 10.10.20.11
resource "yandex_vpc_security_group" "kfk" {
  name       = "kfk-sg"
  network_id = yandex_vpc_network.vpnctl.id

  ingress {
    protocol       = "ANY"
    v4_cidr_blocks = var.backend_subnet_cidr
  }

  ingress {
    protocol       = "ANY"
    v4_cidr_blocks = local.ipsec_peer_cidrs
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}


# All traffic leaving backend subnet goes through lb01.
resource "yandex_vpc_route_table" "backend_gateway" {
  name       = "backend-gt"
  network_id = yandex_vpc_network.vpnctl.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = var.vms["lb01"].backend_ip
  }
}


# Backend NIC of lb01.
resource "yandex_vpc_security_group" "lb01_backend" {
  name       = "lb01-backend-sg"
  network_id = yandex_vpc_network.vpnctl.id

  ingress {
    protocol       = "ANY"
    v4_cidr_blocks = var.backend_subnet_cidr
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}