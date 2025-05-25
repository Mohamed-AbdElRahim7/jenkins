pipeline {
    agent any

    stages {
        stage('Run Script') {
            steps {
                echo '🚀 Running Python script...'
                sh 'python3 lab2-task1.py'
            }
        }

        stage('Test') {
            steps {
                echo '✅ Running dummy tests...'
                sh 'echo "All tests passed!"'
            }
        }

        stage('Deploy') {
            steps {
                echo '📦 Deploying the application...'
                sh 'echo "App deployed (simulated)!"'
            }
        }
    }
}
