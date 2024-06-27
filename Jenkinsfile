pipeline {
    agent any

    environment {
        JAVA_HOME = "/usr/lib/jvm/java-17-openjdk-amd64"
        PATH = "${JAVA_HOME}/bin:${env.PATH}"
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
                dir('hola-mundo') {  // Ajusta la ruta según la estructura de tu repositorio
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
                        apt-get install wget apt-transport-https gnupg
                        wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | tee /usr/share/keyrings/trivy.gpg > /dev/null
                        echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | tee -a /etc/apt/sources.list.d/trivy.list
                        apt-get update
                        apt-get install trivy
                    fi
                    '''
                    // Escanear la imagen Docker con Trivy
                    sh 'trivy image --vuln-type os my-nginx-html'
                }
            }
        }
        stage('Scan with SonarQube') {
            steps {
                script {
                    // Escanear los archivos HTML con SonarQube
                    withSonarQubeEnv('SonarQube') { // 'SonarQube' es el nombre del servidor SonarQube configurado en Jenkins
                        sh '''
                        sonar-scanner -X \
                          -Dsonar.projectKey=my-nginx-html \
                          -Dsonar.sources=hola-mundo \
                          -Dsonar.host.url=http://172.25.0.4:9000 \
                          -Dsonar.login=sqp_55d92808ff7e8f6e0bfcec5976f644e100c9d93e \
                          -Dsonar.ws.timeout=60
                        '''
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
