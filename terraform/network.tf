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

resource "yandex_vpc_security_group" "lb01" {
  name       = "lb01-sg"
  network_id = yandex_vpc_network.vpnctl.id
  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "yandex_vpc_security_group" "kfk" {
  name       = "kfk-sg"
  network_id = yandex_vpc_network.vpnctl.id
  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = var.backend_subnet_cidr
  }

  ingress {
    protocol       = "ICMP"
    v4_cidr_blocks = var.backend_subnet_cidr
  }


  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
  protocol       = "TCP"
  port           = 2181
  v4_cidr_blocks = var.backend_subnet_cidr
}

ingress {
  protocol       = "TCP"
  port           = 2888
  v4_cidr_blocks = var.backend_subnet_cidr
}

ingress {
  protocol       = "TCP"
  port           = 3888
  v4_cidr_blocks = var.backend_subnet_cidr
}

}

resource "yandex_vpc_route_table" "backend_gateway" {
  name       = "backend-gt"
  network_id = yandex_vpc_network.vpnctl.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = var.vms["lb01"].backend_ip
  }
}

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


