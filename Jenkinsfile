pipeline {
    agent any

    environment {
        SONARQUBE_URL = 'http://localhost:9000'
        SONARQUBE_TOKEN = credentials('sqp_b5e363e316813eef6bf04a933a3628eca3d71943')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Build Docker Image') {
            steps {
                dir('hola-mundo') {
                    script {
                        docker.build('my-nginx-html', '.')
                    }
                }
            }
        }
        stage('Scan Docker Image') {
            steps {
                script {
                    sh '''
                    if ! command -v trivy &> /dev/null
                    then
                        wget https://github.com/aquasecurity/trivy/releases/download/v0.40.0/trivy_0.40.0_Linux-64bit.tar.gz
                        tar zxvf trivy_0.40.0_Linux-64bit.tar.gz
                        mv trivy /usr/local/bin/
                    fi
                    '''
                    sh 'pwd'
                    sh 'trivy image my-nginx-html'
                }
            }
        }
        stage('Deploy') {
            steps {
                script {
                    def containerExists = sh(script: "docker ps -q -f name=my-nginx-container", returnStdout: true).trim()
                    if (containerExists) {
                        sh 'docker stop my-nginx-container'
                        sh 'docker rm my-nginx-container'
                    }
                    sh 'docker run -d -p 80:80 --name my-nginx-container my-nginx-html'
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
