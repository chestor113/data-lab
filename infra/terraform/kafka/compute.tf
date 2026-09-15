

resource "yandex_compute_instance" "vm" {
  for_each    = var.vms
  name        = each.key
  hostname    = each.value.hostname
  platform_id = var.platform_id
  zone        = var.zone

  resources {
    cores         = var.vm_cores
    memory        = var.vm_memory
    core_fraction = var.vm_core_fraction
  }

  scheduling_policy {
    preemptible = true
  }

  boot_disk {
    initialize_params {
      image_id = var.debian_image_id
      size     = 10
      type     = "network-hdd"
    }
  }


  metadata = {
    user-data = <<-EOF
    #cloud-config

    users:
      - name: ${var.admin_user}
        groups: sudo
        shell: /bin/bash
        sudo: ALL=(ALL) NOPASSWD:ALL
        ssh_authorized_keys:
          - ${file(var.ssh_public_key_path)}
  EOF
  }

  network_interface {
    index          = 0
    subnet_id      = each.value.subnet == "edge" ? yandex_vpc_subnet.edge.id : yandex_vpc_subnet.backend.id
    ip_address     = each.value.private_ip
    nat            = each.value.nat
    nat_ip_address = each.value.public_ip

    security_group_ids = each.key == "lb01" ? [
      yandex_vpc_security_group.lb01.id
      ] : [
      yandex_vpc_security_group.kfk.id
    ]
  }

  dynamic "network_interface" {
    for_each = each.value.backend_ip != null ? [1] : []

    content {
      index              = 1
      subnet_id          = yandex_vpc_subnet.backend.id
      ip_address         = each.value.backend_ip
      security_group_ids = [yandex_vpc_security_group.lb01_backend.id]
    }
  }

}