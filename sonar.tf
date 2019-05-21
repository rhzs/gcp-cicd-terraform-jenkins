# Defining pod & policy for sonar

resource "kubernetes_deployment" "sonar" {
  metadata {
    name = "sonar"

    labels {
      app = "sonar"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels {
        app = "sonar"
      }
    }

    template {
      metadata {
        labels {
          app = "sonar"
        }
      }

      spec {
        container {
          image = "sonarqube:lts"
          name  = "sonar"
        }
      }
    }
  }
}

resource "kubernetes_service" "sonar" {
  metadata {
    name = "sonar"
  }

  spec {
    selector {
      app = "${kubernetes_deployment.sonar.metadata.0.labels.app}"
    }

    session_affinity = "ClientIP"

    port {
      name = "sonar"
      port = "9000"
    }

    type = "LoadBalancer"
  }
}

output "sonar" {
  value = "${kubernetes_service.sonar.load_balancer_ingress.0.ip}:9000"
}
