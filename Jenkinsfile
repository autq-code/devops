pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git 'http://localhost:7990/projects/ngin/repos/nginx.git'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build('my-nginx-html', 'nginx/hola-mundo/')
                }
            }
        }
        stage('Deploy') {
            steps {
                script {
                    // Stop and remove the existing container if it exists
                    def containerExists = sh(script: "docker ps -q -f name=my-nginx-container", returnStdout: true).trim()
                    if (containerExists) {
                        sh 'docker stop my-nginx-container'
                        sh 'docker rm my-nginx-container'
                    }

                    // Run the new container
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

