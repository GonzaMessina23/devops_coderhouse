# DevOps Coderhouse — Proyecto Final

Proyecto de implementación de un pipeline DevOps para una aplicación web desarrollada con **Python Flask y PostgreSQL**, utilizando Docker, Terraform, GitHub Actions, Kubernetes, Prometheus y Grafana.

## 1. Objetivo

El objetivo del proyecto es implementar un flujo de integración continua, despliegue automatizado, infraestructura como código, análisis de seguridad y monitoreo de una aplicación web.

La aplicación permite iniciar sesión mediante credenciales de demostración y utiliza PostgreSQL para almacenar la información de usuarios.

El proyecto se ejecuta principalmente en un entorno local Windows con Docker Desktop y Kubernetes, sin requerir servicios cloud pagos.

## 2. Tecnologías utilizadas

| Python y Flask | Aplicación web con autenticación |
| PostgreSQL | Base de datos |
| Docker | Contenedorización |
| Docker Compose | Ejecución local de Flask y PostgreSQL |
| Terraform | Infraestructura como código |
| Kubernetes | Orquestación de contenedores |
| Kind | Clúster Kubernetes local y de pruebas |
| Traefik | Ingress Controller |
| GitHub Actions | Pipelines CI/CD |
| GitHub Container Registry | Registro de imágenes Docker |
| Bandit | Análisis estático de seguridad (SAST) |
| OWASP ZAP | Análisis dinámico de seguridad (DAST) |
| Prometheus | Recolección de métricas |
| Grafana | Visualización de métricas |

## 3. Arquitectura del proyecto

La aplicación está desarrollada con Flask y utiliza PostgreSQL como sistema de base de datos. Ambos componentes se ejecutan en contenedores Docker, lo que permite mantener un entorno de ejecución consistente.

Durante el desarrollo local se utiliza Docker Compose para iniciar la aplicación y la base de datos de manera conjunta, administrar sus conexiones y mantener la persistencia de los datos mediante volúmenes.

El código fuente se almacena en GitHub. Cada vez que se realizan cambios en la rama principal, GitHub Actions ejecuta los procesos de construcción y validación definidos en los workflows. La imagen Docker se publica en GitHub Container Registry (GHCR), desde donde puede ser descargada por Kubernetes.

Para validar el despliegue, el pipeline crea un clúster temporal utilizando Kind, despliega Flask y PostgreSQL y comprueba que la aplicación responda correctamente mediante el endpoint `/health`.

También se ejecutan controles de seguridad mediante Bandit y OWASP ZAP, mientras que Terraform dispone de un workflow independiente para validar su configuración.

### Arquitectura del entorno Kubernetes

En Kubernetes, la aplicación Flask se ejecuta mediante un Deployment, mientras que PostgreSQL utiliza un StatefulSet con almacenamiento persistente.

Los Services permiten la comunicación entre los componentes del clúster. Flask accede a PostgreSQL mediante su nombre de servicio, sin depender de direcciones IP fijas.

Traefik funciona como Ingress Controller y permite acceder a la aplicación mediante una dirección HTTP local. De esta manera, las solicitudes externas llegan al Service de Flask, que las dirige a los Pods correspondientes.

El Horizontal Pod Autoscaler (HPA) ajusta automáticamente la cantidad de réplicas de Flask en función del consumo de CPU.

Finalmente, Prometheus recopila métricas del clúster y Grafana permite visualizarlas mediante dashboards, facilitando el análisis del consumo de recursos y el estado de los servicios.

## 4. Requisitos previos

Para ejecutar el proyecto en Windows se necesitan las siguientes herramientas:

- Git
- Docker Desktop
- Python 3.12, opcional para ejecución sin Docker
- Terraform 1.16
- kubectl
- Helm
- Kind
- Kubernetes habilitado en Docker Desktop para el despliegue principal

## 5. Ejecución local con Docker Compose

Primero, clonar el repositorio:

git clone https://github.com/GonzaMessina23/devops_coderhouse.git
cd devops_coderhouse

Crear un archivo `.env` en la raíz del proyecto con las variables necesarias:

SECRET_KEY=reemplazar-por-una-clave-aleatoria-larga
DEMO_USERNAME=demo
DEMO_PASSWORD=reemplazar-por-una-contrasena-segura
POSTGRES_PASSWORD=reemplazar-por-una-contrasena-segura

El archivo `.env` contiene información sensible y no debe subirse al repositorio.

Construir e iniciar los servicios:

docker compose up -d --build

Verificar que los contenedores estén funcionando:

docker compose ps

Comprobar la aplicación:

curl http://localhost:5000/health

La respuesta esperada es:

{"status":"ok"}

La aplicación también puede abrirse desde el navegador:

http://localhost:5000

Para iniciar sesión se utilizan las credenciales definidas en las variables `DEMO_USERNAME` y `DEMO_PASSWORD`.

Para detener los servicios:

docker compose down

## 6. Dockerfile optimizado

La aplicación utiliza un Dockerfile multi-stage, que permite separar la instalación de dependencias de la ejecución final.

La primera etapa, denominada builder, utiliza Python 3.12 y crea un entorno virtual en el que se instalan las dependencias definidas en `requirements.txt`.

La segunda etapa, denominada runtime, copia el entorno virtual y los archivos necesarios para ejecutar Flask, evitando incluir archivos de construcción innecesarios.

Además, se utiliza una imagen base `python:3.12-slim`, se deshabilita la caché de pip y se configuran variables de entorno para mejorar la ejecución dentro del contenedor.

Para construir la imagen manualmente:

docker build -t devops-login-platform:latest .

La aplicación expone el puerto 5000.

## 7. Infraestructura como código con Terraform

Terraform se utiliza para definir y administrar recursos de Kubernetes de manera declarativa.

La configuración está organizada en módulos que permiten separar la creación de namespaces de los recursos correspondientes a la aplicación.

Entre los recursos administrados se encuentran:

- Namespace `devops-app`.
- ConfigMap con variables de configuración.
- Services de Flask y PostgreSQL.
- Deployment de Flask.
- StatefulSet de PostgreSQL.
- Almacenamiento persistente para la base de datos.
- Ingress de Traefik.
- Horizontal Pod Autoscaler.

Antes de ejecutar Terraform, el clúster Kubernetes debe estar disponible y contar con Traefik, Metrics Server y los secretos necesarios.

Seleccionar el contexto principal:

kubectl config use-context docker-desktop

Crear el namespace si todavía no existe:

kubectl create namespace devops-app

Crear el Secret utilizando las variables del archivo `.env`:

kubectl create secret generic devops-login-secret \
  --namespace devops-app \
  --from-env-file=.env

En Warp con Git Bash sobre Windows, puede ser necesario anteponer `MSYS_NO_PATHCONV=1` para evitar problemas de conversión de rutas.

Ingresar a la carpeta de Terraform:

cd terraform
terraform init
terraform validate
terraform plan
terraform apply

Terraform compara el estado actual de los recursos con la configuración declarada y aplica los cambios necesarios.

Durante las verificaciones del proyecto, `terraform plan` confirmó que la infraestructura coincidía con el código y que no existían cambios pendientes.

También se incorporó una configuración independiente de Terraform para crear un clúster Kind local utilizando Docker.

## 8. Despliegue en Kubernetes

La aplicación se despliega en Kubernetes utilizando un Deployment para Flask y un StatefulSet para PostgreSQL.

El Deployment define la imagen de la aplicación, las variables de entorno, las solicitudes y límites de recursos, y las pruebas de disponibilidad y funcionamiento mediante el endpoint `/health`.

PostgreSQL utiliza almacenamiento persistente para conservar los datos, incluso cuando se recrea el contenedor.

Para verificar el despliegue:

kubectl get pods -n devops-app
kubectl get services -n devops-app
kubectl get ingress -n devops-app

Los Pods deben encontrarse en estado `Running`.

La aplicación puede consultarse mediante Traefik:

http://app.login.localhost

Verificación:

curl http://app.login.localhost/health

La respuesta esperada es:

{"status":"ok"}

## 9. Autoescalado y FinOps

El proyecto incorpora un Horizontal Pod Autoscaler que ajusta automáticamente la cantidad de réplicas de Flask según la utilización de CPU.

Su configuración establece un mínimo de una réplica, un máximo de tres réplicas y un objetivo de utilización del 60 % de CPU.

Para consultar su estado:

kubectl get hpa -n devops-app

Durante las pruebas se generó carga sobre la aplicación y se verificó que Kubernetes aumentara la cantidad de réplicas. Cuando la carga disminuyó, el sistema regresó a una réplica.

Además, los contenedores utilizan solicitudes y límites de CPU y memoria, evitando reservar más recursos de los necesarios y permitiendo controlar el consumo.

Estas configuraciones representan prácticas básicas de FinOps aplicadas a un entorno local.

## 10. Pipeline CI/CD con GitHub Actions

Los workflows se encuentran definidos en `.github/workflows/`.

### Pipeline de integración y despliegue

El archivo `ci.yml` automatiza las siguientes tareas:

1. Descarga del código desde GitHub.
2. Construcción de la imagen Docker.
3. Publicación de la imagen en GitHub Container Registry.
4. Creación de un clúster temporal Kind.
5. Despliegue de PostgreSQL y Flask.
6. Verificación del estado de los componentes.
7. Prueba del endpoint `/health`.

Las imágenes se publican utilizando las etiquetas `latest` y el identificador SHA del commit.

Imagen utilizada:

ghcr.io/gonzamessina23/devops_coderhouse:latest

El despliegue automatizado de este workflow se realiza en un clúster temporal del runner de GitHub Actions.

### Validación de Terraform

El archivo `terraform.yml` ejecuta automáticamente las verificaciones de inicialización, formato y validación:

terraform init -backend=false
terraform fmt -check -recursive
terraform validate

Este workflow permite detectar errores de configuración antes de aplicar cambios a la infraestructura.

### Análisis de seguridad

El archivo `security.yml` incluye dos tipos de análisis:

**SAST con Bandit:** examina el código Python para detectar posibles problemas de seguridad.

**DAST con OWASP ZAP:** inicia temporalmente la aplicación mediante Docker Compose y realiza un análisis dinámico sobre el servicio HTTP.

Los reportes generados por OWASP ZAP se almacenan como artifacts de GitHub Actions.

Las ejecuciones pueden consultarse en:

https://github.com/GonzaMessina23/devops_coderhouse/actions

## 11. Monitoreo con Prometheus y Grafana

El proyecto utiliza Prometheus para recopilar métricas de Kubernetes y Grafana para visualizarlas mediante dashboards.

El monitoreo se instaló mediante Helm utilizando el chart `kube-prometheus-stack`, con una configuración personalizada definida en `monitoring/values.yaml`.

Para instalarlo en un clúster previamente preparado:

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
kubectl create namespace monitoring

Si el namespace ya existe, se omite su creación.

Instalar el monitoreo:

helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  --version 92.11.0 \
  --namespace monitoring \
  -f monitoring/values.yaml \
  --wait --timeout 10m

Verificar los componentes:

kubectl get pods -n monitoring

Para acceder a Grafana:

kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80

Abrir:

http://localhost:3000

El dashboard del proyecto permite analizar métricas como el consumo de CPU, la memoria utilizada y la cantidad de réplicas disponibles.

La configuración exportada del dashboard se encuentra en `monitoring/dashboards/devops-dashboard.json`.

Las consultas del dashboard exportado utilizan originalmente el namespace `default`; para visualizar específicamente el despliegue `devops-app`, deben ajustarse los filtros de namespace.

## 12. Verificación y resultados

Para comprobar el funcionamiento del proyecto se ejecutaron pruebas sobre los diferentes componentes.

**Aplicación:** se verificó que Flask respondiera correctamente mediante el endpoint `/health`, obteniendo HTTP 200.

**Base de datos:** se comprobó el funcionamiento de PostgreSQL y la persistencia de información.

**Terraform:** se ejecutó `terraform plan`, obteniendo un resultado sin cambios pendientes.

**Kubernetes:** se verificó que los Pods de Flask y PostgreSQL estuvieran en estado `Running`.

**Autoescalado:** se generó carga sobre Flask y se comprobó el aumento y posterior reducción de réplicas.

**Monitoreo:** se verificó el funcionamiento de Prometheus y Grafana y la visualización de métricas.

**CI/CD:** los workflows de construcción, despliegue de pruebas, validación Terraform y seguridad completaron sus ejecuciones correctamente.

Comandos de verificación:

kubectl get pods -n devops-app
kubectl get ingress,hpa -n devops-app
kubectl get pods -n monitoring
kubectl top pods -n devops-app
curl -i http://app.login.localhost/health

## 13. Evidencias del proyecto

Las evidencias de ejecución se incorporan mediante capturas de pantalla de GitHub Actions, Terraform, Kubernetes, el endpoint de salud y los dashboards de Grafana.

Estas capturas permiten verificar visualmente el funcionamiento de los componentes y los resultados de las pruebas realizadas.

## 14. Repositorio

**Repositorio:** https://github.com/GonzaMessina23/devops_coderhouse