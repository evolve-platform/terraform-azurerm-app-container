resource "azurerm_container_app" "this" {
  name                         = var.name
  container_app_environment_id = var.container_app_environment_id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"
  workload_profile_name        = "Consumption"

  identity {
    type = "UserAssigned"
    identity_ids = [
      var.identity_id
    ]
  }
  tags = var.tags

  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas


    dynamic "http_scale_rule" {
      for_each = var.http_scale_rule != null ? [var.http_scale_rule] : []
      content {
        name                = "http-scaler"
        concurrent_requests = var.http_scale_rule.concurrent_requests
      }
    }

    dynamic "custom_scale_rule" {
      for_each = var.cpu_scale_rule != null ? [var.cpu_scale_rule] : []
      content {
        custom_rule_type = "cpu"
        metadata = {
          "type" : var.cpu_scale_rule.type,
          "value" : var.cpu_scale_rule.threshold
        }
        name = "cpu-scaler"
      }
    }


    dynamic "custom_scale_rule" {
      for_each = var.memory_scale_rule != null ? [var.memory_scale_rule] : []
      content {
        custom_rule_type = "memory"
        metadata = {
          "type" : var.memory_scale_rule.type,
          "value" : var.memory_scale_rule.threshold
        }
        name = "memory-scaler"
      }
    }

    container {
      name   = "main"
      image  = var.image
      cpu    = var.cpu
      memory = var.memory

      readiness_probe {
        path                    = var.healthcheck_readiness.path # Checks for status code 200 - 399
        port                    = var.container_port
        success_count_threshold = 1
        failure_count_threshold = var.healthcheck_readiness.unhealthy_threshold
        interval_seconds        = var.healthcheck_readiness.interval
        timeout                 = var.healthcheck_readiness.timeout
        transport               = "HTTP"
        initial_delay           = var.healthcheck_readiness.initial_delay
      }

      liveness_probe {
        path                    = var.healthcheck_liveness.path # Checks for status code 200 - 399
        port                    = var.container_port
        failure_count_threshold = var.healthcheck_liveness.unhealthy_threshold
        interval_seconds        = var.healthcheck_liveness.interval
        timeout                 = var.healthcheck_liveness.timeout
        transport               = "HTTP"
        initial_delay           = var.healthcheck_liveness.initial_delay
      }

      startup_probe {
        port                    = var.container_port
        path                    = var.healthcheck_startup.path # Checks for status code 200 - 399
        failure_count_threshold = var.healthcheck_startup.unhealthy_threshold
        interval_seconds        = var.healthcheck_startup.interval
        timeout                 = var.healthcheck_startup.timeout
        transport               = "HTTP"
        initial_delay           = var.healthcheck_startup.initial_delay
      }

      dynamic "env" {
        for_each = var.env_vars

        content {
          name  = env.key
          value = env.value
        }
      }

      dynamic "env" {
        for_each = var.secrets

        content {
          name        = env.value.env_name
          secret_name = env.value.secret_name
        }
      }
    }

    # Reverse proxy container
    dynamic "container" {
      for_each = var.proxy_image != "" ? [var.proxy_image] : []
      content {
        name   = "reverse-proxy"
        image  = var.proxy_image
        cpu    = 0.25
        memory = "0.5Gi"

        // This will hit the same healthcheck as the main container, but then
        // via the proxy. Results in duplicate healthchecks on the main
        // container but is necessary to make sure we are 'ready'
        dynamic "readiness_probe" {
          for_each = var.healthcheck_readiness != null ? [var.healthcheck_readiness] : []
          content {
            port                    = 8080
            path                    = var.healthcheck_readiness.path # Checks for status code 200 - 399
            success_count_threshold = 1
            failure_count_threshold = var.healthcheck_readiness.unhealthy_threshold
            interval_seconds        = var.healthcheck_readiness.interval
            timeout                 = var.healthcheck_readiness.timeout
            transport               = "HTTP"
            initial_delay           = var.healthcheck_readiness.initial_delay
          }
        }
        dynamic "liveness_probe" {
          for_each = var.healthcheck_liveness != null ? [var.healthcheck_liveness] : []
          content {
            path                    = var.healthcheck_liveness.path # Checks for status code 200 - 399
            port                    = 8080
            failure_count_threshold = var.healthcheck_liveness.unhealthy_threshold
            interval_seconds        = var.healthcheck_liveness.interval
            timeout                 = var.healthcheck_liveness.timeout
            transport               = "HTTP"
            initial_delay           = var.healthcheck_liveness.initial_delay
          }
        }

        dynamic "startup_probe" {
          for_each = var.healthcheck_startup != null ? [var.healthcheck_startup] : []
          content {
            port                    = 8080
            path                    = var.healthcheck_startup.path # Checks for status code 200 - 399
            failure_count_threshold = var.healthcheck_startup.unhealthy_threshold
            interval_seconds        = var.healthcheck_startup.interval
            timeout                 = var.healthcheck_startup.timeout
            transport               = "HTTP"
            initial_delay           = var.healthcheck_startup.initial_delay
          }
        }
      }
    }

  }

  dynamic "secret" {
    for_each = var.secrets

    content {
      identity            = var.identity_id
      key_vault_secret_id = secret.value.secret_id
      name                = secret.value.secret_name
    }
  }

  dynamic "registry" {
    for_each = var.registry_username != "" && var.registry_password != "" ? [] : [1]
    content {
      server   = split("/", var.image)[0]
      identity = var.identity_id
    }
  }

  dynamic "secret" {
    for_each = var.registry_username != "" && var.registry_password != "" ? [1] : []
    content {
      name  = "registry-password"
      value = var.registry_password
    }
  }

  dynamic "registry" {
    for_each = var.registry_username != "" && var.registry_password != "" ? [1] : []
    content {
      server               = split("/", var.image)[0]
      username             = var.registry_username
      password_secret_name = "registry-password"
    }
  }

  ingress {
    allow_insecure_connections = false
    external_enabled           = var.external_enabled
    target_port                = var.proxy_image != "" ? 8080 : var.container_port
    transport                  = "http"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}
