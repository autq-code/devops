pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                script {
                    // Clona el repositorio y muestra la estructura de directorios para depuración
                    git branch: 'main', url: 'https://github.com/autq-code/devops.git'
                    sh 'ls -l'
                    sh 'ls -l nginx/hola-mundo'
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                dir('nginx/hola-mundo') {  // Ajustar la ruta según la estructura de tu repositorio
                    script {
                        // Muestra la estructura del directorio actual para depuración
                        sh 'ls -l'
                        docker.build('my-nginx-html', '.')  // Construye desde la ruta actual (donde se encuentra el Dockerfile)
                    }
                }
            }
        }
        stage('Deploy') {
            steps {
                script {
                    // Detén y elimina el contenedor existente si existe
                    def containerExists = sh(script: "docker ps -q -f name=my-nginx-container", returnStdout: true).trim()
                    if (containerExists) {
                        sh 'docker stop my-nginx-container'
                        sh 'docker rm my-nginx-container'
                    }

                    // Ejecuta el nuevo contenedor
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
