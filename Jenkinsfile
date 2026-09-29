pipeline {
    agent any

    environment {
        DOCKER_HUB_REPO = 'oanacalitoiu1985/devops-validator:latest'
    }

    stages {
        // Stage 1: Validare izolată prin Docker Compose
        stage('1. Validare Configurare (Docker)') {
            steps {
                echo '=== Pasul 1: Validare fișier YAML și generare vars.json ==='
                sh 'docker compose up --build validator'
            }
        }

        // Stage 2: Provizionare Infrastructură AWS EC2 cu Terraform
        stage('2. Provizionare Infrastructură (Terraform AWS)') {
            steps {
                echo '=== Pasul 2: Creare instanță EC2 și Security Group în AWS ==='
                withCredentials([
                    string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh '''
                        rm -rf .terraform .terraform.lock.hcl
                        terraform init -input=false -force-copy -reconfigure
                        terraform apply -auto-approve
                    '''
                }
            }
        }

        // Stage 3: Instalare dinamică prin Ansible pe EC2 în AWS
        stage('3. Instalare Ansible pe AWS EC2') {
            steps {
                echo '=== Pasul 3: Instalare tehnologii pe serverul AWS prin Ansible Playbook ==='
                script {
                    echo 'Așteptăm 20 de secunde pentru ca serviciul SSH de pe EC2 să pornească complet...'
                    sh 'sleep 20'
                    
                    // Preluăm automat IP-ul public creat de Terraform în pasul anterior
                    def instanceIp = sh(script: "terraform output -raw public_ip", returnStdout: true).trim()
                    
                    // Rulăm Ansible direct pe instanța EC2 din AWS folosind cheia SSH
                    sh """
                        ansible-playbook -i "${instanceIp}," \
                        -u ubuntu \
                        --private-key envbuilder-key.pem \
                        playbook.yml \
                        --ssh-common-args='-o StrictHostKeyChecking=no'
                    """
                }
            }
        }

        // Stage 4: Verificare post-instalare
        stage('4. Verificare Tehnologii') {
            steps {
                echo '=== Pasul 4: Rulare script Bash de verificare ==='
                sh 'chmod +x verify.sh'
                sh './verify.sh'
            }
        }

        // Stage 5: Publicare imagine pe Docker Hub
        stage('5. Docker Build & Push') {
            steps {
                echo '=== Pasul 5: Construire și publicare imagine pe Docker Hub ==='
                sh "docker build -t ${DOCKER_HUB_REPO} ."
                sh "docker push ${DOCKER_HUB_REPO}"
            }
        }
    }

    post {
        always {
            echo 'Pipeline-ul s-a finalizat! Începe curățarea containerelor locale...'
            sh 'docker compose down'
        }
        success {
            echo 'SUCCES: Toate etapele de validare, provizionare AWS, instalare Ansible și verificare au trecut cu succes!'
        }
        failure {
            echo 'EȘEC: Pipeline-ul a eșuat. Verifică logurile fiecărei etape.'
        }
    }
}