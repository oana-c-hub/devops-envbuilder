# DevOps EnvBuilder 🚀

Sistem automatizat end-to-end pentru provizionarea, validarea și configurarea unui mediu de dezvoltare pe o instanță AWS EC2.

---

## 🛠️ Arhitectură & Tehnologii

- **Infrastructură ca Cod (IaC)**: Terraform & AWS EC2
- **Validare & Izolare**: Python 3.11, PyYAML, Docker, Docker Compose
- **Automatizare & Management Configurație**: Ansible
- **Orchestrare CI/CD**: Jenkins Pipeline
- **Verificare & Scripting**: Bash
- **Versionare & Registru**: Git, Docker Hub

---

## 📂 Structura Proiectului

```text
devops-envbuilder/
├── config/
│   ├── env_config.yaml       # Configurația declarată de utilizator
│   └── vars.json             # Artefact generat automat după validare
├── .gitignore                # Protecție fișiere sensibile și temporare
├── Dockerfile                # Împachetarea validatorului Python
├── docker-compose.yml        # Rularea validatorului cu volum montat
├── Jenkinsfile               # Orchestrator CI/CD în 4 etape
├── main.tf                   # Provizionare AWS (EC2, Security Group, SSH Key)
├── playbook.yml              # Instalare dinamică Ansible
├── README.md                 # Documentația proiectului
├── validator.py              # Script validare schema YAML & versiuni
├── variables.tf              # Variabile de mediu Terraform
└── verify.sh                 # Script Bash de verificare post-instalare