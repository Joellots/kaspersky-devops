output "instance_id" {
  description = "Идентификатор экземпляра EC2"
  value       = aws_instance.microservice.id
}

output "instance_public_ip" {
  description = "IP-адрес экземпляра EC2 (общедоступный)"
  value       = aws_instance.microservice.public_ip
}

output "instance_dns" {
  description = "DNS экземпляра EC2"
  value       = aws_instance.microservice.public_dns
}

output "metrics_url" {
  description = "URL-адрес для доступа к метрикам Prometheus"
  value       = "http://${aws_instance.microservice.public_ip}:8080/metrics"
}

output "ssh_command" {
  description = "Команда SSH для подключения к экземпляру"
  value       = "ssh -i ${var.key_path} ec2-user@${aws_instance.microservice.public_ip}"
}

output "ami_used" {
  description = "Идентификатор AMI для AlmaLinux 9"
  value       = "${var.ami}"
}

output "hosts_file_entry" {
  description = "Строка для добавления в файл /etc/hosts"
  value       = "${aws_instance.microservice.public_ip} kaspersky.microservice.host"
}