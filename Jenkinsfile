pipeline {
  agent {
    docker {
      image 'docker:24.0.2-cli'
      args '-v /var/run/docker.sock:/var/run/docker.sock -u root'
    }
  }

  environment {
    HOME = "${env.WORKSPACE}"
    IMAGE_NAME = "mohamedelgarhy/jenkins"
    TAG = "${BUILD_NUMBER}"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build Docker Image') {
      steps {
        sh '''
          mkdir -p $HOME/.docker
          docker --config $HOME/.docker build -t $IMAGE_NAME:$TAG .
        '''
      }
    }

    // مراحل أخرى ...
  }
}
