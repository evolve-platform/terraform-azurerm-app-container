# Azure App Container Terraform module

Terraform module to manage an Azure App Container.
<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.38.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_container_app.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_container_additional_ports"></a> [container\_additional\_ports](#input\_container\_additional\_ports) | Additional ports to expose | <pre>list(object({<br/>    exposedPort = number<br/>    external    = bool<br/>    targetPort  = number<br/>  }))</pre> | `[]` | no |
| <a name="input_container_app_environment_id"></a> [container\_app\_environment\_id](#input\_container\_app\_environment\_id) | The container app environment to be used for the container | `string` | n/a | yes |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | The port the container listens on | `number` | `4000` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | The CPU to be used for the container | `number` | `0.25` | no |
| <a name="input_cpu_scale_rule"></a> [cpu\_scale\_rule](#input\_cpu\_scale\_rule) | CPU scale rules to be set on the container | <pre>object({<br/>    threshold = optional(number, 50)<br/>    type = optional(string, "Utilization")<br/>  })</pre> | <pre>{<br/>  "threshold": 50,<br/>  "type": "Utilization"<br/>}</pre> | no |
| <a name="input_env_vars"></a> [env\_vars](#input\_env\_vars) | Environment variables to be set in the container | `map(string)` | `{}` | no |
| <a name="input_external_enabled"></a> [external\_enabled](#input\_external\_enabled) | Whether to enable external access | `bool` | `false` | no |
| <a name="input_healthcheck"></a> [healthcheck](#input\_healthcheck) | Healthcheck Readiness configuration | <pre>object({<br/>    path = string<br/>    unhealthy_threshold = optional(number, 3)<br/>    healthy_threshold = optional(number, 1)<br/>    timeout = optional(number, 5)<br/>    interval = optional(number, 60)<br/>    initial_delay = optional(number, 60)<br/>  })</pre> | `null` | no |
| <a name="input_healthcheck_liveness"></a> [healthcheck\_liveness](#input\_healthcheck\_liveness) | Healthcheck Liveliness configuration | <pre>object({<br/>    path = string<br/>    unhealthy_threshold = optional(number, 3)<br/>    timeout = optional(number, 2)<br/>    interval = optional(number, 10)<br/>    initial_delay = optional(number, 30)<br/>  })</pre> | `null` | no |
| <a name="input_healthcheck_startup"></a> [healthcheck\_startup](#input\_healthcheck\_startup) | Healthcheck startup configuration | <pre>object({<br/>    path = string<br/>    unhealthy_threshold = optional(number, 30)<br/>    timeout = optional(number, 2)<br/>    interval = optional(number, 10)<br/>    initial_delay = optional(number, 0)<br/>  })</pre> | `null` | no |
| <a name="input_http_scale_rule"></a> [http\_scale\_rule](#input\_http\_scale\_rule) | HTTP scale rules to be set on the container | <pre>object({<br/>    concurrent_requests = optional(number, 50)<br/>  })</pre> | <pre>{<br/>  "concurrent_requests": 50<br/>}</pre> | no |
| <a name="input_identity_id"></a> [identity\_id](#input\_identity\_id) | The identity to be used for the container registry | `string` | n/a | yes |
| <a name="input_image"></a> [image](#input\_image) | The image to be used for the container | `string` | n/a | yes |
| <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id) | The key vault to be used for the container | `string` | `null` | no |
| <a name="input_max_replicas"></a> [max\_replicas](#input\_max\_replicas) | The maximum number of instances to run | `number` | `1` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | The memory to be used for the container | `string` | `"0.5Gi"` | no |
| <a name="input_memory_scale_rule"></a> [memory\_scale\_rule](#input\_memory\_scale\_rule) | Memory scale rules to be set on the container | <pre>object({<br/>    threshold = optional(number, 75)<br/>    type = optional(string, "Utilization")<br/>  })</pre> | <pre>{<br/>  "threshold": 75,<br/>  "type": "Utilization"<br/>}</pre> | no |
| <a name="input_min_replicas"></a> [min\_replicas](#input\_min\_replicas) | The minimum number of instances to run | `number` | `0` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the container | `string` | n/a | yes |
| <a name="input_proxy_image"></a> [proxy\_image](#input\_proxy\_image) | Version of the reverse proxy to deploy | `string` | `""` | no |
| <a name="input_registry_password"></a> [registry\_password](#input\_registry\_password) | The name of the secret to be used for the container registry password | `string` | `""` | no |
| <a name="input_registry_username"></a> [registry\_username](#input\_registry\_username) | The username to be used for the container registry | `string` | `""` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The resource group to be used for the container | `string` | n/a | yes |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | n/a | <pre>list(object({<br/>    secret_id   = string<br/>    secret_name = string<br/>    env_name    = string<br/>  }))</pre> | `[]` | no |
| <a name="input_sidecars"></a> [sidecars](#input\_sidecars) | List of side containers to run alongside the main container. | <pre>list(object({<br/>    name   = string<br/>    container_port = number<br/>    image  = string<br/>    cpu    = number<br/>    memory = string<br/>    env_vars = map(string)<br/>    secrets = list(object({<br/>      env_name    = string<br/>      secret_name = string<br/>    }))<br/>    healthcheck = optional(object({<br/>      path = string<br/>      unhealthy_threshold = optional(number, 3)<br/>      timeout = optional(number, 5)<br/>      interval = optional(number, 60)<br/>      initial_delay = optional(number, 60)<br/>    }), null)<br/>    healthcheck_liveness = optional(object({<br/>      path = string<br/>      unhealthy_threshold = optional(number, 3)<br/>      timeout = optional(number, 2)<br/>      interval = optional(number, 10)<br/>      initial_delay = optional(number, 30)<br/>    }), null)<br/>    healthcheck_startup = optional(object({<br/>      path = string<br/>      unhealthy_threshold = optional(number, 30)<br/>      timeout = optional(number, 2)<br/>      interval = optional(number, 10)<br/>      initial_delay = optional(number, 0)<br/>    }), null)<br/>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be set on the container | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | n/a |
| <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id) | n/a |
<!-- END_TF_DOCS -->