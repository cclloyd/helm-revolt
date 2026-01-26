<p align="center">
  <img width="100" src="https://avatars.githubusercontent.com/u/57727799?s=200&v=4" style="vertical-align: middle; margin: 0 1.5rem" />
  <img src="https://github.com/kubernetes/kubernetes/raw/master/logo/logo.png" width="60" style="vertical-align: middle;" />
</p>

# Revolt Helm Chart

This chart provides a means of deploying Revolt to kubernetes.

---

# Minimal Setup

To use the minimal setup, you will require

- A working kubernetes cluster
- Persistent storage for MongoDB, Redis, MinIO, and RabbitMQ
- A valid hostname and the ability to access it via HTTPS (such as [cert-manager](https://cert-manager.io/docs/))

1. Generate required config keys. We provide a script to run in docker to generate it in this repo.
   ```shell
   docker run --entrypoint /bin/ash -v ./:/data alpine/openssl /data/generate_config.sh
   ```
2. Fill out required config
    ```yaml
    global:
      namespace: 'revolt'
      domain: 'revolt.example.com'
      ingress:
        enabled: true
        className: nginx
        annotations:
          # Annotations may differ for other ingress controllers.  Consult your documentation.
          nginx.ingress.kubernetes.io/rewrite-target: /$2
          nginx.ingress.kubernetes.io/force-ssl-redirect: 'true'
          nginx.ingress.kubernetes.io/proxy-body-size: '0'
      # Or GatewayAPI Routes
      route:
        enabled: true
        parentRefs:
          - <Your parent ref here>
      secret:
        vapid_key: ''
        vapid_public_key: ''
        encryption_key: ''
    ```
3. Run `helm install ./ revolt -f my_values.yaml`
4. Once it's done setting itself, up, access it at your external URL. It may take a few minutes to spin up from scratch.

Congrats, you have a minimal working setup. This is NOT production ready however.

- There is no persistence is enabled by default, so everything is lost on restart.
- The external connections such as MongoDB and Redis have no authentication.

## Persistence

Persistence is handled by the subcharts. Consult the subcharts for more information.

- [MongoDB](https://github.com/bitnami/charts/tree/main/bitnami/mongodb#persistence)
- [Redis](https://github.com/bitnami/charts/tree/main/bitnami/redis#persistence)
- [MinIO](https://github.com/bitnami/charts/tree/main/bitnami/minio#persistence)
- [RabbitMQ](https://github.com/bitnami/charts/tree/main/bitnami/rabbitmq#persistence)

## External Subcharts

The subcharts all support external connections, with the option to disable the built-in chart.

```yaml
global:
  subcharts:
    # All but rabbitmq are full connection+auth strings.
    mongo: # mongodb
      enabled: true  # Set to false to use external MongoDB
      connection_url: ''
    redis:
      enabled: true  # Set to false to use external Redis
      connection_url: ''
    minio:
      enabled: true  # Set to false to use external MinIO
      connection_url: ''
    rabbitmq:
      enabled: true  # Set to false to use external RabbitMQ
      host: ''
      port: 5672
      username: 'rabbituser'
      password: 'rabbitpass'
```

---

# Full Configuration

## Global Settings

| Chart Option                                  | Description                                              | Default        |
|-----------------------------------------------|----------------------------------------------------------|----------------|
| `global.namespace`                            | Namespace for the chart services                         | `'revolt'`     |
| `global.domain`  **REQUIRED**                 | Domain name used for access (e.g. ) `revolt.example.com` | `''`           |
| `global.secret.vapid_key` **REQUIRED**        | VAPID private key for push notifications                 | `''`           |
| `global.secret.vapid_public_key` **REQUIRED** | VAPID public key for push notifications                  | `''`           |
| `global.secret.encryption_key` **REQUIRED**   | Encryption key for sensitive data                        | `''`           |
| `global.web.port`                             | Port for the web frontend                                | `5000`         |
| `global.api.port`                             | Port for the API server                                  | `14702`        |
| `global.bonfire.port`                         | Port for the bonfire events service                      | `14703`        |
| `global.autumn.port`                          | Port for the autumn file server                          | `14704`        |
| `global.january.port`                         | Port for the january metadata proxy                      | `14705`        |
| `global.crond.port`                           | Port for the crond scheduler                             | `80`           |
| `global.pushd.port`                           | Port for the pushd notification service                  | `80`           |
| `global.ingress.enabled`                      | Enable Kubernetes Ingress                                | `false`        |
| `global.ingress.className`                    | Ingress class name (e.g., ) `nginx`                      | `''`           |
| `global.ingress.annotations`                  | Additional Ingress annotations (map)                     | `{}`           |
| `global.ingress.extra_hosts`                  | Additional hosts for Ingress (list)                      | `[]`           |
| `global.route.enabled`                        | Enable GatewayAPI Routes                                 | `false`        |
| `global.route.parentRefs`                     | Parent references for route (required)                   | `[]`           |
| `global.route.annotations`                    | Additional annotations for routes                        | `{}`           |
| `global.serviceAccount.create`                | Whether to create a Kubernetes service account           | `true`         |
| `global.serviceAccount.automount`             | Automount service account tokens                         | `true`         |
| `global.serviceAccount.annotations`           | Additional annotations for ServiceAccount                | `{}`           |
| `global.serviceAccount.name`                  | ServiceAccount name override                             | `''`           |
| `global.subcharts.mongo.enabled`              | Enable built-in MongoDB subchart                         | `true`         |
| `global.subcharts.mongo.connection_url`       | MongoDB connection string (if using external)            | `''`           |
| `global.subcharts.redis.enabled`              | Enable built-in Redis subchart                           | `true`         |
| `global.subcharts.redis.connection_url`       | Redis connection string (if using external)              | `''`           |
| `global.subcharts.minio.enabled`              | Enable built-in MinIO subchart                           | `true`         |
| `global.subcharts.minio.connection_url`       | MinIO connection string (if using external)              | `''`           |
| `global.subcharts.rabbitmq.enabled`           | Enable built-in RabbitMQ subhcart                        | `true`         |
| `global.subcharts.rabbitmq.host`              | RabbitMQ hostname (if using external)                    | `''`           |
| `global.subcharts.rabbitmq.port`              | RabbitMQ port (if using external)                        | `5672`         |
| `global.subcharts.rabbitmq.username`          | RabbitMQ username                                        | `'rabbituser'` |
| `global.subcharts.rabbitmq.password`          | RabbitMQ password                                        | `'rabbitpass'` |

## Component Specific Settings

### Subcharts

MongoDB, Redis, MinIO, and RabbitMQ are all subcharts. Consult their respective documentation for more information.

- MongoDB: https://github.com/bitnami/charts/tree/main/bitnami/mongodb#parameters
- Redis: https://github.com/bitnami/charts/tree/main/bitnami/redis#parameters
- MinIO: https://github.com/bitnami/charts/tree/main/bitnami/minio#parameters
- RabbitMQ: https://github.com/bitnami/charts/tree/main/bitnami/rabbitmq#parameters

These are the default values we supply for the subcharts.

#### MongoDB

| config                        | description             | default    |
|-------------------------------|-------------------------|------------|
| `mongodb.architecture`        | MongoDB deployment mode | standalone |
| `mongodb.auth.enabled`        | Enable auth             | false      |
| `mongodb.persistence.enabled` | Enable persistence      | false      |

#### Redis

| config                             | description                   | default    |
|------------------------------------|-------------------------------|------------|
| `redis.architecture`               | Redis deployment mode         | standalone |
| `redis.auth.enabled`               | Enable auth                   | false      |
| `redis.master.persistence.enabled` | Enable persistence for master | false      |

#### RabbitMQ

| config                         | description                 | default    |
|--------------------------------|-----------------------------|------------|
| `rabbitmq.replicaCount`        | Number of RabbitMQ replicas | 1          |
| `rabbitmq.auth.username`       | RabbitMQ username           | rabbituser |
| `rabbitmq.auth.password`       | RabbitMQ password           | rabbitpass |
| `rabbitmq.persistence.enabled` | Enable persistence          | false      |

#### MinIO

| config                      | description                          | default     |
|-----------------------------|--------------------------------------|-------------|
| `minio.mode`                | MinIO deployment mode                | standalone  |
| `minio.rootUser`            | MinIO root user                      | minioautumn |
| `minio.rootPassword`        | MinIO root password                  | minioautumn |
| `minio.persistence.enabled` | Enable persistence                   | false       |
| `minio.auth.rootUser`       | MinIO root user for auth section     | minioautumn |
| `minio.auth.rootPassword`   | MinIO root password for auth section | minioautumn |

### Revolt Services

---

## Web App

| config                   | description                  | default                   |
|--------------------------|------------------------------|---------------------------|
| `web.image.repository`   | Image repository             | ghcr.io/revoltchat/client |
| `web.image.tag`          | Image tag                    | master                    |
| `web.image.pullPolicy`   | Image pull policy            | Always                    |
| `web.annotations`        | Additional pod annotations   | `{}`                      |
| `web.labels`             | Additional pod labels        | `{}`                      |
| `web.nodeSelector`       | Pod nodeSelector             | `{}`                      |
| `web.tolerations`        | Pod tolerations list         | `[]`                      |
| `web.affinity`           | Pod affinity                 | `{}`                      |
| `web.replicaCount`       | Number of replicas           | 1                         |
| `web.resources`          | Resource requests and limits | `{}`                      |
| `web.livenessProbe`      | Liveness probe               |                           |
| `web.readinessProbe`     | Readiness probe              |                           |
| `web.service.type`       | Service type                 | ClusterIP                 |
| `web.extra_volumes`      | Additional pod volumes       | `[]`                      |
| `web.extra_volumeMounts` | Additional pod volumeMounts  | `[]`                      |

## API Server

| config                   | description                  | default                   |
|--------------------------|------------------------------|---------------------------|
| `api.image.repository`   | Image repository             | ghcr.io/revoltchat/server |
| `api.image.tag`          | Image tag                    | 20250210-1                |
| `api.image.pullPolicy`   | Image pull policy            | IfNotPresent              |
| `api.replicaCount`       | Number of replicas           | 1                         |
| `api.annotations`        | Additional pod annotations   | `{}`                      |
| `api.labels`             | Additional pod labels        | `{}`                      |
| `api.nodeSelector`       | Pod nodeSelector             | `{}`                      |
| `api.tolerations`        | Pod tolerations list         | `[]`                      |
| `api.affinity`           | Pod affinity                 | `{}`                      |
| `api.resources`          | Resource requests and limits | `{}`                      |
| `api.livenessProbe`      | Liveness probe               |                           |
| `api.readinessProbe`     | Readiness probe              |                           |
| `api.service.type`       | Service type                 | ClusterIP                 |
| `api.extra_volumes`      | Additional pod volumes       | `[]`                      |
| `api.extra_volumeMounts` | Additional pod volumeMounts  | `[]`                      |
| `api.configMountPath`    | Config mount path in pod     | /Revolt.toml              |

## Bonfire

| config                       | description                  | default                    |
|------------------------------|------------------------------|----------------------------|
| `bonfire.image.repository`   | Image repository             | ghcr.io/revoltchat/bonfire |
| `bonfire.image.tag`          | Image tag                    | 20250210-1                 |
| `bonfire.image.pullPolicy`   | Image pull policy            | IfNotPresent               |
| `bonfire.replicaCount`       | Number of replicas           | 1                          |
| `bonfire.annotations`        | Additional pod annotations   | `{}`                       |
| `bonfire.labels`             | Additional pod labels        | `{}`                       |
| `bonfire.nodeSelector`       | Pod nodeSelector             | `{}`                       |
| `bonfire.tolerations`        | Pod tolerations list         | `[]`                       |
| `bonfire.affinity`           | Pod affinity                 | `{}`                       |
| `bonfire.resources`          | Resource requests and limits | `{}`                       |
| `bonfire.livenessProbe`      | Liveness probe               |                            |
| `bonfire.readinessProbe`     | Readiness probe              |                            |
| `bonfire.service.type`       | Service type                 | ClusterIP                  |
| `bonfire.extra_volumes`      | Additional pod volumes       | `[]`                       |
| `bonfire.extra_volumeMounts` | Additional pod volumeMounts  | `[]`                       |
| `bonfire.configMountPath`    | Config mount path in pod     | /Revolt.toml               |

## Autumn

| config                      | description                  | default                   |
|-----------------------------|------------------------------|---------------------------|
| `autumn.image.repository`   | Image repository             | ghcr.io/revoltchat/autumn |
| `autumn.image.tag`          | Image tag                    | 20250210-1                |
| `autumn.image.pullPolicy`   | Image pull policy            | IfNotPresent              |
| `autumn.replicaCount`       | Number of replicas           | 1                         |
| `autumn.annotations`        | Additional pod annotations   | `{}`                      |
| `autumn.labels`             | Additional pod labels        | `{}`                      |
| `autumn.nodeSelector`       | Pod nodeSelector             | `{}`                      |
| `autumn.tolerations`        | Pod tolerations list         | `[]`                      |
| `autumn.affinity`           | Pod affinity                 | `{}`                      |
| `autumn.resources`          | Resource requests and limits | `{}`                      |
| `autumn.livenessProbe`      | Liveness probe               | `{}` (empty by default)   |
| `autumn.readinessProbe`     | Readiness probe              |                           |
| `autumn.service.type`       | Service type                 | ClusterIP                 |
| `autumn.extra_volumes`      | Additional pod volumes       | `[]`                      |
| `autumn.extra_volumeMounts` | Additional pod volumeMounts  | `[]`                      |
| `autumn.configMountPath`    | Config mount path in pod     | /Revolt.toml              |

## January

| config                       | description                  | default                    |
|------------------------------|------------------------------|----------------------------|
| `january.image.repository`   | Image repository             | ghcr.io/revoltchat/january |
| `january.image.tag`          | Image tag                    | 20250210-1                 |
| `january.image.pullPolicy`   | Image pull policy            | IfNotPresent               |
| `january.replicaCount`       | Number of replicas           | 1                          |
| `january.annotations`        | Additional pod annotations   | `{}`                       |
| `january.labels`             | Additional pod labels        | `{}`                       |
| `january.nodeSelector`       | Pod nodeSelector             | `{}`                       |
| `january.tolerations`        | Pod tolerations list         | `[]`                       |
| `january.affinity`           | Pod affinity                 | `{}`                       |
| `january.resources`          | Resource requests and limits | `{}`                       |
| `january.livenessProbe`      | Liveness probe               |                            |
| `january.readinessProbe`     | Readiness probe              |                            |
| `january.service.type`       | Service type                 | ClusterIP                  |
| `january.extra_volumes`      | Additional pod volumes       | `[]`                       |
| `january.extra_volumeMounts` | Additional pod volumeMounts  | `[]`                       |
| `january.configMountPath`    | Config mount path in pod     | /Revolt.toml               |

## Crond

| config                     | description                  | default                  |
|----------------------------|------------------------------|--------------------------|
| `crond.image.repository`   | Image repository             | ghcr.io/revoltchat/crond |
| `crond.image.tag`          | Image tag                    | 20250210-1-debug         |
| `crond.image.pullPolicy`   | Image pull policy            | IfNotPresent             |
| `crond.replicaCount`       | Number of replicas           | 1                        |
| `crond.annotations`        | Additional pod annotations   | `{}`                     |
| `crond.labels`             | Additional pod labels        | `{}`                     |
| `crond.nodeSelector`       | Pod nodeSelector             | `{}`                     |
| `crond.tolerations`        | Pod tolerations list         | `[]`                     |
| `crond.affinity`           | Pod affinity                 | `{}`                     |
| `crond.resources`          | Resource requests and limits | `{}`                     |
| `crond.livenessProbe`      | Liveness probe               |                          |
| `crond.readinessProbe`     | Readiness probe              |                          |
| `crond.extra_volumes`      | Additional pod volumes       | `[]`                     |
| `crond.extra_volumeMounts` | Additional pod volumeMounts  | `[]`                     |
| `crond.configMountPath`    | Config mount path in pod     | /Revolt.toml             |

## Pushd

| config                     | description                  | default                  |
|----------------------------|------------------------------|--------------------------|
| `pushd.image.repository`   | Image repository             | ghcr.io/revoltchat/pushd |
| `pushd.image.tag`          | Image tag                    | 20250210-1               |
| `pushd.image.pullPolicy`   | Image pull policy            | IfNotPresent             |
| `pushd.replicaCount`       | Number of replicas           | 1                        |
| `pushd.annotations`        | Additional pod annotations   | `{}`                     |
| `pushd.labels`             | Additional pod labels        | `{}`                     |
| `pushd.nodeSelector`       | Pod nodeSelector             | `{}`                     |
| `pushd.tolerations`        | Pod tolerations list         | `[]`                     |
| `pushd.affinity`           | Pod affinity                 | `{}`                     |
| `pushd.resources`          | Resource requests and limits | `{}`                     |
| `pushd.livenessProbe`      | Liveness probe               |                          |
| `pushd.readinessProbe`     | Readiness probe              |                          |
| `pushd.extra_volumes`      | Additional pod volumes       | `[]`                     |
| `pushd.extra_volumeMounts` | Additional pod volumeMounts  | `[]`                     |
| `pushd.configMountPath`    | Config mount path in pod     | /Revolt.toml             |

