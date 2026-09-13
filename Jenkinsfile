pipeline {
    agent any

    environment {
        DOCKER_HUB_REPO = 'oanacalitoiu1985/devops-validator:latest'
    }

    stages {
        // Stage 1: Validare izolată prin Docker Compose (Cerință Pasul 2 & 3)
        stage('1. Validare Configurare (Docker)') {
            steps {
                sh 'docker compose up --build validator'
            }
        }

        // Stage 2: Instalare dinamică prin Ansible (Cerință Pasul 3)
        stage('2. Instalare Ansible') {
            steps {
                sh 'ansible-playbook playbook.yml'
            }
        }

        // Stage 3: Verificare post-instalare (Cerință Pasul 1 & 3)
        stage('3. Verificare Tehnologii') {
            steps {
                sh 'chmod +x verify.sh'
                sh './verify.sh'
            }
        }

        // Stage 4: Publicare imagine pe Docker Hub (Cerință Pasul 2 & 3)
        stage('4. Docker Build & Push') {
            steps {
                sh "docker build -t ${DOCKER_HUB_REPO} ."
                sh "docker push ${DOCKER_HUB_REPO}"
            }
        }
    }

    post {
        always {
            echo 'Pipeline-ul s-a finalizat! Începe curățarea containerelor...'
            sh 'docker compose down'
        }
        success {
            echo '✅ SUCCES: Toate etapele de validare, instalare și verificare au trecut.'
        }
        failure {
            echo '❌ EȘEC: Pipeline-ul a eșuat. Verifică logurile.'
        }
    }
}