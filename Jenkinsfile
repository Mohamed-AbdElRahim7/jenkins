pipeline {
    agent {
        docker {
            image 'python:3.10'
        }
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Run Script') {
            steps {
                echo '🚀 Running Python script...'
                sh 'python lab2-task1.py'
            }
        }

        stage('Test') {
            steps {
                echo '🧪 Running dummy tests...'
                sh 'echo "✅ All tests passed!"'
            }
        }

        stage('Deploy') {
            steps {
                echo '📦 Deploying...'
                sh 'echo "🚀 Deployed!"'
            }
        }
    }
}
