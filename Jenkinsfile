pipeline {
    agent any

    environment {
        SONARQUBE_URL = 'http://172.24.0.4:9000'
        SONARQUBE_TOKEN = credentials('sqp_b5e363e316813eef6bf04a933a3628eca3d71943')
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    // Clona el repositorio y muestra la estructura de directorios para depuración
                    git branch: 'main', url: 'https://github.com/autq-code/devops.git'
                    sh 'ls -l'
                    sh 'ls -l hola-mundo'
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                dir('hola-mundo') {  // Ajustar la ruta según la estructura de tu repositorio
                    script {
                        // Muestra la estructura del directorio actual para depuración
                        sh 'ls -l'
                        docker.build('my-nginx-html', '.')  // Construye desde la ruta actual (donde se encuentra el Dockerfile)
                    }
                }
            }
        }
        stage('Scan Docker Image') {
            steps {
                script {
                    // Instalar Trivy si no está instalado (opcional, solo para entornos efímeros)
                    sh '''
                    if ! command -v trivy &> /dev/null
                    then
                        wget https://github.com/aquasecurity/trivy/releases/download/v0.40.0/trivy_0.40.0_Linux-64bit.tar.gz
                        tar zxvf trivy_0.40.0_Linux-64bit.tar.gz
                        sudo mv trivy /usr/local/bin/
                    fi
                    '''

                    // Escanear la imagen Docker con Trivy
                    sh 'trivy image my-nginx-html'
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh 'sonar-scanner \
                        -Dsonar.projectKey=my-project-key \
                        -Dsonar.sources=. \
                        -Dsonar.host.url=$SONARQUBE_URL \
                        -Dsonar.login=$SONARQUBE_TOKEN'
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
