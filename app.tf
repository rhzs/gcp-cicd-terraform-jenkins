# Defining pod & policy for a node.js hellow-world app

locals {
  port = "5000"
  app  = "app"
}

resource "kubernetes_deployment" "app" {
  metadata {
    name = "${local.app}"

    labels {
      app = "${local.app}"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels {
        app = "${local.app}"
      }
    }

    template {
      metadata {
        labels {
          app = "${local.app}"
        }
      }

      spec {
        container {
          image = "malferov/app:3" # temporary "gcr.io/google-samples/node-hello:1.0"
          name  = "${local.app}"
        }
      }
    }
  }
}

resource "kubernetes_service" "app" {
  metadata {
    name = "${local.app}"
  }

  spec {
    selector {
      app = "${kubernetes_deployment.app.metadata.0.labels.app}"
    }

    session_affinity = "ClientIP"

    port {
      port = "${local.port}"
    }

    type = "LoadBalancer"
  }
}

output "app" {
  value = "${kubernetes_service.app.load_balancer_ingress.0.ip}:${local.port}"
}
