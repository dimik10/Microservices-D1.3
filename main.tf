terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.61.0"
    }

  }
}

provider "yandex" {
  token     = "token"
  cloud_id  = "id"
  folder_id = "id"
  zone      = "ru-central1-b"
}


resource "yandex_vpc_network" "network" {
  name = "network_kuber"
}

#Создание подсети
resource "yandex_vpc_subnet" "subnet_kuber" {
  name           = "subnet_kuber"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.12.0/24"]
}

module "swarm_cluster" {
  source                = "./modules"
  instance_family_image = "ubuntu-2204-lts"
  vpc_subnet_id         = yandex_vpc_subnet.subnet_kuber.id
  managers      = 1
  workers       = 2
}
