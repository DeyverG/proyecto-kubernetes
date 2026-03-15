provider "kubernetes" { 

  config_path = "~/.kube/config" 

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

        } 

      } 

    } 

  } 

} 