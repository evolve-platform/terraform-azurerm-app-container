variable "name" {
  description = "The name of the container"
  type        = string
}

variable "cpu" {
  description = "The CPU to be used for the container"
  type        = number
  default     = 0.25
}

variable "memory" {
  description = "The memory to be used for the container"
  type        = string
  default     = "0.5Gi"
}

variable "env_vars" {
  description = "Environment variables to be set in the container"
  type        = map(string)
  default     = {}
}

variable "image" {
  description = "The image to be used for the container"
  type        = string
}

variable "proxy_image" {
  type        = string
  default     = ""
  description = "Version of the reverse proxy to deploy"
}

variable "identity_id" {
  description = "The identity to be used for the container registry"
  type        = string
}

variable "registry_username" {
  description = "The username to be used for the container registry"
  type        = string
  default     = ""
}

variable "registry_password" {
  description = "The name of the secret to be used for the container registry password"
  type        = string
  default     = ""
}

variable "container_app_environment_id" {
  description = "The container app environment to be used for the container"
  type        = string
}

variable "resource_group_name" {
  description = "The resource group to be used for the container"
  type        = string
}

variable "key_vault_id" {
  description = "The key vault to be used for the container"
  type        = string
  default     = null
}

variable "secrets" {
  type = list(object({
    secret_id   = string
    secret_name = string
    env_name    = string
  }))
  default = []
}

variable "external_enabled" {
  description = "Whether to enable external access"
  type        = bool
  default     = false
}

variable "min_replicas" {
  description = "The minimum number of instances to run"
  type        = number
  default     = 0
}

variable "max_replicas" {
  description = "The maximum number of instances to run"
  type        = number
  default     = 1
}

variable "container_port" {
  description = "The port the container listens on"
  type        = number
  default     = 4000
}


# Not working currently, see:
# https://github.com/hashicorp/terraform-provider-azurerm/issues/26565
variable "container_additional_ports" {
  description = "Additional ports to expose"
  type = list(object({
    exposedPort = number
    external    = bool
    targetPort  = number
  }))
  default = []
}

variable "healthcheck" {
  type = object({
    path                    = string
    unhealthy_threshold     = number
    timeout                 = number
    interval                = number
    initial_delay_liveness  = number
    initial_delay_readiness = number
    initial_delay_startup   = number
  })
  default = {
    path                = "/"
    unhealthy_threshold = 3
    timeout             = 2
    interval            = 5
    initial_delay       = 10
  }
  description = "Healthcheck configuration"
}

variable "tags" {
  description = "Tags to be set on the container"
  type        = map(string)
  default     = {}
}
