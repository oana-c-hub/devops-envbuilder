pipeline {
    agent any

    stages {
        stage('1. Validare Configurare') {
            steps {
                sh 'python3 validator.py'
            }
        }

        stage('2. Instalare Ansible') {
            steps {
                sh 'ansible-playbook playbook.yml'
            }
        }

        stage('3. Verificare Tehnologii') {
            steps {
                sh './verify.sh'
            }
        }

        stage('4. Docker Push Registry') {
            steps {
                sh 'docker build -t oanacalitoiu1985/devops-validator:latest .'
                sh 'docker push oanacalitoiu1985/devops-validator:latest'
            }
        }
    }

    post {
        always {
            echo 'Pipeline-ul s-a finalizat!'
        }
    }
}