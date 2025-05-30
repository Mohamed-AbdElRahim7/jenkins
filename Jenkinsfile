pipeline {
  agent any

  environment {
    IMAGE_NAME = 'mohamedelgarhy/jenkins'
    IMAGE_TAG = "${BUILD_NUMBER}"
  }

  stages {
    stage('Clone Repo') {
      steps {
        git url: 'https://github.com/Mohamed-AbdElRahim7/jenkins.git', branch: 'master'
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          sh 'docker build -t $IMAGE_NAME:$IMAGE_TAG .'
        }
      }
    }

    stage('Push to Docker Hub') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh '''
            echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
            docker push $IMAGE_NAME:$IMAGE_TAG
          '''
        }
      }
    }
  }
}
