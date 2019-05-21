# Build server - Jenkins Docker container on GCP VM

variable "app_repo" {}
variable "size" {}
variable "public_key" {}
variable "private_key" {}

locals {
  yum   = "sudo yum -y -d 1 install"
  image = "centos-7"
  user  = "centos"
}

resource "google_compute_instance" "build" {
  name         = "build"
  machine_type = "${var.size}"

  boot_disk {
    initialize_params {
      image = "${local.image}"
    }
  }

  network_interface {
    network       = "${data.google_compute_network.net.name}"
    access_config = {}
  }

  metadata {
    sshKeys = "${local.user}:${file(var.public_key)}"
  }

  connection {
    user        = "${local.user}"
    private_key = "${file(var.private_key)}"
  }

  provisioner "file" {
    source      = "jenkins"
    destination = "~"
  }

  provisioner "file" {
    content     = "${local.kubeconfig}"
    destination = "config"
  }

  provisioner "remote-exec" {
    inline = [
      "${local.yum} docker git mc",
      "sudo systemctl start docker",
      "sudo git clone ${var.app_repo} && cd cicd-tools-gcp-terraform/jenkins",
      "sudo docker build -t jenkins . && cd ~",
      "sudo chmod 777 /var/run/docker.sock",
      "sudo docker run -d -p 8080:8080 -v /var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock --privileged jenkins",
      "sudo docker exec jenkins kubectl config set-cluster kube",
      "sudo docker cp config jenkins:/var/jenkins_home/.kube",
    ]
  }

}

output "build" {
  value = "${google_compute_instance.build.network_interface.0.access_config.0.assigned_nat_ip}:8080"
}
