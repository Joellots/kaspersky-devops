variable "instance_type" {
    description = "Тип экземпляра EC2"
    type        = string
    default     = "t3.micro"
}

variable "key_path" {
    description = "Путь к паре ключей экземпляра"
    type        = string
    default     = "~/labsuser.pem"
}

variable "ami" {
    description = "AlmaLinux OS 9 (x86_64)"
    type        = string
    default     = "ami-066279af4a501d501"
}

variable "zone" {
    description = "Зона доступности"
    type        = string
    default     = "us-east-1a"
}

variable "deploy_mode" {
  description = "Режим развертывания микросервиса: 'host' или 'container'"
  type        = string
  default     = "host"

  validation {
    condition     = contains(["host", "container"], var.deploy_mode)
    error_message = "deploy_mode должен быть либо 'host', либо 'container'."
  }
}