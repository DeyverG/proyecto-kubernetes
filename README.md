# Proyecto Despliegue en Kubernetes (con HPA y Terraform)

Este proyecto consiste en el despliegue automático de una aplicación Node.js en un clúster de Kubernetes usando **Terraform**, autoescalado **HPA (Horizontal Pod Autoscaler)** y buenas prácticas de configuración as Code.

---

## 🚀 Requisitos y Tecnologías Usadas

- **Docker**: Para crear la imagen de la aplicación (`Dockerfile` provisto con multi-stage optimization).
- **Minikube / Kubernetes**: Como clúster donde corre la aplicación. (`Metrics Server` habilitado para HPA)
- **Terraform / OpenTofu**: Para provisionar la infraestructura.
- **Node.js**: Aplicación base.

---

## 🛠️ Estructura del repositorio

```bash
.
├── Dockerfile                  # Código empaquetado y listo para contenerizar (Node 22)
├── kubernetes/
│   ├── configmap.yaml          # Las configuraciones (APP_ENV, PORT) para the App
│   ├── deployment.yaml         # Deployment, expone variables y configura límites (CPU, RAM)
│   ├── hpa.yaml                # Escalado automático (HPA), configurado a un 50% de CPU target.
│   └── service.yaml            # Exposición con LoadBalancer (Servicio)
├── main.tf                     # Integración IaaC con Terraform equivalente a la carpeta Kubernetes
└── README.md                   # Esta Documentación.
```

---

## 🏗️ Instrucciones de Despliegue (Usando Terraform)

Terraform automatiza todas las configuraciones en el clúster (ConfigMaps, Deployment, Service, HPA). Sigue estos pasos:

1. **Inicializar y Aplicar el proyecto Terraform**
   Diríjete a la raíz del repositorio y corre estos comandos:
   ```bash
   terraform init
   terraform apply -auto-approve
   ```

2. *(Alternativa)*  **Desplegar con comandos nativos de Kubernetes (kubectl)**
   Si no se posee terraform, aplica la carpeta `kubernetes/`:
   ```bash
   kubectl apply -f kubernetes/configmap.yaml
   kubectl apply -f kubernetes/deployment.yaml
   kubectl apply -f kubernetes/service.yaml
   kubectl apply -f kubernetes/hpa.yaml
   ```

---

## ✅ Pruebas Realizadas: Resiliencia y Autoescalado (Evidencias)

Durante el flujo de pruebas garantizamos la disponibilidad y la capacidad de autoescalamiento que pide el requerimiento.

### 1. Estado del clúster (kubectl get pods)

Validamos que los pods inician correctamente por la configuración extraída del `ConfigMap` y los recursos (`cpu memory limits/requests`):

```bash
kubectl get pods
# RESULTADO:
NAME                                             READY   STATUS    RESTARTS   AGE
proyecto-kubernetes-terraform-5bb5bf5675-crj2r   1/1     Running   0          29s
proyecto-kubernetes-terraform-5bb5bf5675-hcfnm   1/1     Running   0          31s
proyecto-kubernetes-terraform-5bb5bf5675-vc6kl   1/1     Running   0          27s
```

### 2. Autoescalado HPA y Métricas en vivo (kubectl get hpa, kubectl top pods)

Minikube necesita el componente de `metrics-server` activo (`minikube addons enable metrics-server`).

```bash
kubectl get hpa
# RESULTADO:
NAME                                REFERENCE                                  TARGETS              MINPODS   MAXPODS   REPLICAS   AGE
proyecto-kubernetes-hpa-terraform   Deployment/proyecto-kubernetes-terraform   cpu: <unknown>/50%   1         5         3          47m
```

*(Si habilitas carga usando `kubectl run -i --tty load-generator --rm --image=busybox -- /bin/sh` y haces requests, los réplicas subirán en este output de 3 hasta maximo 5).*

Verificación de métricas en consumo en vivo (Resource Requests):

```bash
kubectl top pods
# RESULTADO:
NAME                                             CPU(cores)   MEMORY(bytes)   
proyecto-kubernetes-terraform-5bb5bf5675-bq55w   9m           49Mi            
proyecto-kubernetes-terraform-5bb5bf5675-cvbsn   9m           49Mi            
proyecto-kubernetes-terraform-5bb5bf5675-gcxzg   9m           50Mi
```

### 3. Prueba de Resiliencia (Recreación automática de pods al eliminarse un pod viejo)

Procedimos a eliminar directamente los pods y validamos que el ReplicaSet de Kubernetes instantáneamente detectó la ausencia y trajo los 3 pods nuevos en ~8 segundos.

```bash
kubectl delete pod -l app=proyecto-kubernetes-terraform
```
Resultado exitoso, el clúster elimina los pods (`crj2r, hcfnm, vc6kl`). Luego pedimos de vuelta los pods:
```bash
kubectl get pods
```

Resultado exitoso de recuperación:
```bash
NAME                                             READY   STATUS    RESTARTS   AGE
proyecto-kubernetes-terraform-5bb5bf5675-bq55w   1/1     Running   0          8s
proyecto-kubernetes-terraform-5bb5bf5675-cvbsn   1/1     Running   0          8s
proyecto-kubernetes-terraform-5bb5bf5675-gcxzg   1/1     Running   0          8s
```
