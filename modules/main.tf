terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.61.0"
    }
  }
}
data "yandex_compute_image" "my_image" {
  family = var.instance_family_image
}


resource "yandex_compute_instance" "vm1" {
  name = "d1-3-manager-${count.index}"
  count    = var.managers
  hostname = "manager-${count.index}"
  
  resources {
    cores         = 4
    memory        = 8
    core_fraction = 100 # Выделение загрузки CPU. Это дешевле. (для проверки)
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.my_image.id
      size = "${var.instance_root_disk}"
    }
  }

  network_interface {
    subnet_id = var.vpc_subnet_id
    nat       = true
  }

  metadata = {
#    ssh-keys = "ubuntu:${file("~/.ssh/yandex.pub")}"
    ssh-keys = "${var.ssh_credentials.user}:${file(var.ssh_credentials.pub_key)}"
  }

  scheduling_policy {
    preemptible = false # ВМ прирываема. Это дешевле. (для проверки). Не прод.
  }
}

resource "yandex_compute_instance" "vm2" {
  name = "d1-3-worker-${count.index}"
  count    = var.workers
  hostname = "worker-${count.index}"
  
  resources {
    cores         = 4
    memory        = 8
    core_fraction = 100 # Выделение загрузки CPU. Это дешевле. (для проверки)
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.my_image.id
      size = "${var.instance_root_disk}"
    }
  }

  network_interface {
    subnet_id = var.vpc_subnet_id
    nat       = true
  }

  metadata = {
#    ssh-keys = "ubuntu:${file("~/.ssh/yandex.pub")}"
    ssh-keys = "${var.ssh_credentials.user}:${file(var.ssh_credentials.pub_key)}"
  }

  scheduling_policy {
    preemptible = false # ВМ прирываема. Это дешевле. (для проверки). Не прод.
  }
}


