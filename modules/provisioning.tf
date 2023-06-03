resource "null_resource" "docker-swarm-manager" {
  count = var.managers
  depends_on = [yandex_compute_instance.vm1]
  connection {
    user        = var.ssh_credentials.user
    private_key = file(var.ssh_credentials.private_key)
    host        = yandex_compute_instance.vm1[count.index].network_interface.0.nat_ip_address
  }

  provisioner "file" {
    source      = "docker-compose/docker-compose.yml"
    destination = "docker-compose.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt install -y docker docker-compose > /dev/null",
      "sudo docker swarm init",
      "sleep 10",
      "echo COMPLETED"
    ]
  }
}

resource "null_resource" "docker-swarm-manager-join" {
  count = var.managers
  depends_on = [yandex_compute_instance.vm1, null_resource.docker-swarm-manager]
  connection {
    user        = var.ssh_credentials.user
    private_key = file(var.ssh_credentials.private_key)
    host        = yandex_compute_instance.vm1[count.index].network_interface.0.nat_ip_address
  }

  provisioner "local-exec" {
    command = "TOKEN=$(ssh -i ${var.ssh_credentials.private_key} -o StrictHostKeyChecking=no ${var.ssh_credentials.user}@${yandex_compute_instance.vm1[count.index].network_interface.0.nat_ip_address} sudo docker swarm join-token -q worker); echo \"#!/usr/bin/env bash\nsudo docker swarm join --token $TOKEN ${yandex_compute_instance.vm1[count.index].network_interface.0.nat_ip_address}:2377\nexit 0\" >| join.sh"
  }
}

resource "null_resource" "docker-swarm-worker" {
  count = var.workers
  depends_on = [yandex_compute_instance.vm2, null_resource.docker-swarm-manager-join]
  connection {
    user        = var.ssh_credentials.user
    private_key = file(var.ssh_credentials.private_key)
    host        = yandex_compute_instance.vm2[count.index].network_interface.0.nat_ip_address
  }

  provisioner "file" {
    source      = "join.sh"
    destination = "join.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt install -y docker docker-compose > /dev/null",
      "sudo chmod +x join.sh",
      "sudo ./join.sh"
    ]
  }
}

resource "null_resource" "docker-swarm-manager-start" {
  depends_on = [yandex_compute_instance.vm1, null_resource.docker-swarm-manager-join]
  connection {
    user        = var.ssh_credentials.user
    private_key = file(var.ssh_credentials.private_key)
    host        = yandex_compute_instance.vm1[0].network_interface.0.nat_ip_address
  }

  provisioner "remote-exec" {
    inline = [
        "sudo docker stack deploy --compose-file docker-compose.yml noski-shop-swarm"
    ]
  }

  provisioner "local-exec" {
    command = "rm join.sh"
  }
}