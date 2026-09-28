# Imagine de baza oficială Python optimizată (slim)
FROM python:3.11-slim

# Setarea directorului de lucru în container
WORKDIR /app

# Instalarea dependenței necesare pentru parsarea fișierului YAML
RUN pip install --no-cache-dir pyyaml

# Copierea folderului config și a scriptului de validare in container, inclusiv in folderul config
COPY config/ ./config/
COPY validator.py .

# Comanda implicită care execută validarea la pornirea containerului
CMD ["python", "validator.py"]