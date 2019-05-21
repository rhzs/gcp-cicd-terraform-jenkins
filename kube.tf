# Creates a GKE cluster with KUBECONFIG

variable "master_user" {}
variable "master_pass" {}

locals {
  kubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    insecure-skip-tls-verify: true
    server: https://${google_container_cluster.kube.endpoint}
  name: kube
contexts:
- context:
    cluster: kube
    user: admin
  name: kube
current-context: kube
kind: Config
preferences: {}
users:
- name: admin
  user:
    username: ${var.master_user}
    password: ${var.master_pass}
KUBECONFIG
}

resource "google_container_cluster" "kube" {
  name               = "kube"
  zone               = "us-central1-a"
  initial_node_count = 2

  additional_zones = [
    "us-central1-b",
  ]

  master_auth {
    username = "${var.master_user}"
    password = "${var.master_pass}"
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}
