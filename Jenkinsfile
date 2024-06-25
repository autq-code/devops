pipeline {
  agent any

  environment {
    SONARQUBE_URL = 'http://localhost:9000'
    SONARQUBE_TOKEN = credentials('sqp_b5e363e316813eef6bf04a933a3628eca3d71943')
  }

  stages {
    stage('Checkout') {
      steps {
        script {
          git branch: 'main', url: 'https://github.com/autq-code/devops.git'
          sh 'ls -l'
          sh 'ls -l hola-mundo'
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        dir('hola-mundo') {
          script {
            sh 'ls -l'
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
              sudo mv trivy /usr/local/bin/
            fi
          '''
          sh 'trivy image my-nginx-html'
        }
      }
    }

    //stage('SonarQube Analysis') {
    //  steps {
    //    withSonarQubeEnv('SonarQube') {
    //      sh 'sonar-scanner \
    //        -Dsonar.projectKey=my-project-key \
    //        -Dsonar.sources=. \
    //        -Dsonar.host.url=$SONARQUBE_URL \
    //        -Dsonar.login=$SONARQUBE_TOKEN'
    //    }
    //  }
    //}

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
      node {
        cleanWs()
      }
    }
  }
}
