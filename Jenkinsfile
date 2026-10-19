pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t static-web-app:latest .'
            }
        }

        stage('Run Container') {
            steps {
                sh 'docker stop my-static-app || true'
                sh 'docker rm my-static-app || true'
                sh 'docker run -d --name my-static-app -p 80:80 static-web-app:latest'
            }
        }
    }
}