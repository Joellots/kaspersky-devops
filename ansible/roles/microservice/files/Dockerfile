FROM python:3.12-slim

LABEL maintainer="okorejoellots@gmail.com"
LABEL description="Prometheus metrics microservice"

WORKDIR /app

RUN pip install --no-cache-dir prometheus_client

COPY microservice.py .

EXPOSE 8080

RUN useradd -m -u 1001 serviceuser
USER serviceuser

ENTRYPOINT ["python3", "microservice.py"]