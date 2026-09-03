FROM python:3.11-slim

WORKDIR /app

# Instalăm dependența YAML
RUN pip install --no-cache-dir pyyaml

# Copiem scriptul de validare
COPY validator.py .

# Comanda de rulare
CMD ["python", "validator.py"]