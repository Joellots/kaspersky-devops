#!/usr/bin/env python3
import os
import time
from prometheus_client import start_http_server, Gauge, Info, Counter

def detect_host_type() -> str:
    """
    Определяет, запущен ли микросервис внутри контейнера, на виртуальной машине или на "голом железе".
    Порядок обнаружения:
      1. Контейнер – наличие /.dockerenv ИЛИ 'docker'/'lxc' в /proc/1/cgroup
      2. Название продукта VM – DMI содержит известную строку гипервизора
      3. Физический резервный вариант
    """
    
    if os.path.exists("/.dockerenv"):
        return "контейнер"

    try:
        with open("/proc/1/cgroup", "r") as f:
            cgroup_content = f.read().lower()
        if "docker" in cgroup_content or "lxc" in cgroup_content or "containerd" in cgroup_content:
            return "контейнер"
    except OSError:
        pass

    
    dmi_paths = [
        "/sys/class/dmi/id/product_name",
        "/sys/class/dmi/id/sys_vendor",
        "/sys/class/dmi/id/board_vendor",
    ]
    vm_signatures = [
        "kvm", "qemu", "vmware", "virtualbox",
        "xen", "hyper-v", "microsoft corporation",
        "amazon ec2", "amazon", 
        "bochs", "innotek",
    ]
    for dmi_path in dmi_paths:
        try:
            with open(dmi_path, "r") as f:
                value = f.read().strip().lower()
            if any(sig in value for sig in vm_signatures):
                return "виртуальная_машина"
        except OSError:
            continue

    return "голый_металл"



HOST_TYPE = detect_host_type()

# Информационная метрика: указывает host_type в качестве метки (значение всегда равно 1)
host_info = Info(
    "microservice_host",
    "Информация о хосте, на котором запущен этот микросервис"
)
host_info.info({"host_type": HOST_TYPE})

# Измерительный показатель: числовое представление для типа хоста микросервиса
HOST_TYPE_MAP = {"виртуальная_машина": 1, "контейнер": 2, "голый_металл": 0}

host_type_gauge = Gauge(
    "microservice_host_type",
    "Тип хоста: 0=голый_металл, 1=виртуальная машина, 2=контейнер"
)
host_type_gauge.set(HOST_TYPE_MAP.get(HOST_TYPE, -1))


start_time = time.time()
uptime_gauge = Gauge(
    "microservice_uptime_seconds",
    "Секунды с момента запуска микросервиса"
)


def update_uptime():
    uptime_gauge.set(time.time() - start_time)


if __name__ == "__main__":
    print(f"[микросервис] Обнаруженный тип хоста: {HOST_TYPE}")
    print("[микросервис] Запуск HTTP-сервера на порту 8080...")
    start_http_server(8080)
    print("[микросервиса] Показатели доступны по адресу http://localhost:8080/metrics")

    while True:
        update_uptime()
        time.sleep(5)