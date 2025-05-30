pipeline {
  agent {
    docker {
      image 'docker:24.0.2-cli'
      args '-v /var/run/docker.sock:/var/run/docker.sock -u root'
    }
  }

  environment {
    HOME = "${env.WORKSPACE}" // ✅ So Docker writes config to a writable location
    IMAGE_NAME = "mohamedelgarhy/jenkins"
    TAG = "${BUILD_NUMBER}"
  }

  stages {
    stage('Build Docker Image') {
      steps {
        sh '''
          mkdir -p $HOME/.docker
          docker --config $HOME/.docker build -t $IMAGE_NAME:$TAG .
        '''
      }
    }

    stage('Login to DockerHub') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh '''
            docker --config $HOME/.docker login -u $DOCKER_USER -p $DOCKER_PASS
          '''
        }
      }
    }

    stage('Push Docker Image') {
      steps {
        sh '''
          docker --config $HOME/.docker push $IMAGE_NAME:$TAG
        '''
      }
    }
  }

  post {
    always {
      echo 'Build and push completed (or failed).'
    }
  }
}
