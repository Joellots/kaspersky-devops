# Тестовое задание DevOps 

<aside>

**ФИО:** ОКОРЕ ДЖОЭЛЬ ЧИДИКЕ

</aside>

## 1. Обзор решения

Краткое описание архитектуры: 
Terraform (AWS EC2 - AlmaLinux 9) → Ansible Playbook → Role: geerlingguy.docker (container mode) → Role: microservice (host / container mode) → микросервис запущен

## 2. Стек технологий и источники

- Terraform ~> 5.0 (hashicorp/aws provider)
- Ansible Core 2.20, Galaxy role: geerlingguy.docker 7.4.0
- Python 3.9, библиотека prometheus_client
- AlmaLinux 9 (AMI: ami-066279af4a501d501, us-east-1)
- Docker CE (установлен через geerlingguy.docker)

## 3. Структура проекта

```
.
├── README.md
├── ansible.cfg                        # локальный конфиг Ansible (таймауты, SSH)
├── ansible/
│   ├── inventory/
│   │   └── hosts.ini                  # адрес VM, SSH-ключ, пользователь
│   ├── playbook.yml                   # точка входа
│   ├── requirements.yml               # Galaxy role + collections
│   └── roles/
│       └── microservice/
│           ├── defaults/main.yml      # значения по умолчанию для переменных
│           ├── files/
│           │   ├── microservice.py    # исходный код микросервиса
│           │   └── Dockerfile         # образ для container mode
│           ├── handlers/main.yml      # перезапуск systemd
│           ├── meta/main.yml
│           ├── tasks/main.yml         # основная логика роли
│           └── templates/
│               └── microservice.service.j2   # systemd unit
├── microservice/
│   └── microservice.py                # копия для справки
└── terraform/
├── main.tf                        # EC2, Security Group
├── outputs.tf                     # IP, SSH-команда, URL метрик
├── providers.tf                   # AWS provider, версии
└── variables.tf                   # тип инстанса, AMI, ключи
```

## 4. Микросервис

Описание логики detect_host_type():

- `/.dockerenv` → контейнер
- `/proc/1/cgroup` → контейнер
- `/sys/class/dmi/id/*` → виртуальная_машина
- Запасной → голый_металл

Метрики:

- `microservice_host` — тип хоста: Информация о хосте, на котором запущен этот микросервис
- `microservice_host_type` — числовое представление для типа хоста микросервиса: 0=голый_металл, 1=виртуальная машина, 2=контейнер
- `microservice_uptime_seconds` — аптайм

## 5. Terraform — подготовка инфраструктуры

Команды:

```bash
terraform init
terraform plan
terraform apply
terraform output instance_public_ip
```

Что создаётся: Security Group (22, 8080), EC2 t3.micro, key pair.

## 6. Ansible — развёртывание микросервиса

### 6.1 Установка зависимостей

```bash
ansible-galaxy install -r ansible/requirements.yml
```

### 6.2 Режим host

```bash
ansible-playbook -i ansible/inventory/hosts.ini ansible/playbook.yml \
-e deploy_mode=host -e deploy_action=start
```

Что происходит: 

- `dnf install python3`
- `pip install prometheus_client`
- деплой `systemd unit`
- `systemctl enable --now microservice`.

### 6.3 Режим container (Бонус 1)

```bash
ansible-playbook -i ansible/inventory/hosts.ini ansible/playbook.yml \
-e deploy_mode=container -e deploy_action=start
```

Что происходит: 

- geerlingguy.docker устанавливает Docker CE
- копируется Dockerfile, docker build, `docker run -p 8080:8080`.

### 6.4 Удаление сервиса

```bash
ansible-playbook -i ansible/inventory/hosts.ini ansible/playbook.yml \
-e deploy_mode=host -e deploy_action=remove

ansible-playbook -i ansible/inventory/hosts.ini ansible/playbook.yml \
-e deploy_mode=container -e deploy_action=remove
```

## 7. Бонусное задание 2 — Terraform IaC

Terraform охватывает все три требуемых этапа автоматизации:

1. **Создание VM** — ресурс `aws_instance` с заданными параметрами
2. **Установка ОС** — через выбор AMI (AlmaLinux 9 готов к работе сразу после запуска, дополнительная установка ОС не требуется)
3. **Настройка ОС** — сеть и доступ настроены через Security Group; дальнейшая конфигурация ОС делегирована Ansible

## 8. Проверка работоспособности

```bash
curl http://<domain>:8080/metrics
```

## 9. Источники

- [Документация Ansible](https://docs.ansible.com/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws)
- [Роль Docker для Ansible (geerlingguy)](https://github.com/geerlingguy/ansible-role-docker)
- [Prometheus Python Client](https://prometheus.github.io/client_python)
- [Модель данных Prometheus](https://prometheus.io/docs/concepts/data_model/)