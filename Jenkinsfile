pipeline {
  agent {
    docker {
      image 'docker:24.0.2-git'               
      args '-v /var/run/docker.sock:/var/run/docker.sock' 
    }
  }

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
        sh 'docker build -t $IMAGE_NAME:$IMAGE_TAG .'  
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
