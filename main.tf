provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_config_map" "proyecto-kubernetes-config" {
  metadata {
    name = "proyecto-kubernetes-config"
  }

  data = {
    APP_ENV = "production"
    PORT    = "3000"
  }
}

resource "kubernetes_deployment_v1" "proyecto-kubernetes-terraform" {
  metadata {
    name = "proyecto-kubernetes-terraform"
    labels = {
      app = "proyecto-kubernetes-terraform"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "proyecto-kubernetes-terraform"
      }
    }

    template {
      metadata {
        labels = {
          app = "proyecto-kubernetes-terraform"
        }
      }

      spec {
        container {
          image = "deyverg/proyecto-kubernetes:latest"
          name  = "proyecto-kubernetes-terraform"

          port {
            container_port = 3000
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.proyecto-kubernetes-config.metadata[0].name
            }
          }

          resources {
            limits = {
              cpu    = "250m"
              memory = "256Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "proyecto-kubernetes-service-terraform" {
  metadata {
    name = "proyecto-kubernetes-service-terraform"
  }
  spec {
    selector = {
      app = kubernetes_deployment_v1.proyecto-kubernetes-terraform.metadata[0].labels.app
    }
    port {
      port        = 80
      target_port = 3000
    }
    type = "LoadBalancer"
  }
}

resource "kubernetes_horizontal_pod_autoscaler_v2" "proyecto-kubernetes-hpa-terraform" {
  metadata {
    name = "proyecto-kubernetes-hpa-terraform"
  }

  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment_v1.proyecto-kubernetes-terraform.metadata[0].name
    }

    min_replicas = 1
    max_replicas = 5

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type = "Utilization"
          average_utilization = 50
        }
      }
    }
  }
}