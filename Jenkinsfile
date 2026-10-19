pipeline {
    agent any

    environment {
        IMAGE_NAME     = "static-web-app"
        IMAGE_TAG      = "${env.BUILD_NUMBER}"
        CONTAINER_NAME = "my-static-app"
    }

    options {
        timestamps()
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    triggers {
        githubPush()   // GitHub webhook se push hote hi auto build
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $IMAGE_NAME:$IMAGE_TAG -t $IMAGE_NAME:latest .'
            }
        }

        stage('Run Container') {
            steps {
                sh 'docker stop $CONTAINER_NAME || true'
                sh 'docker rm $CONTAINER_NAME || true'
                sh 'docker run -d --name $CONTAINER_NAME -p 80:80 -v nexvion_logs:/var/log/nginx --restart unless-stopped $IMAGE_NAME:latest'
            }
        }

        stage('Show Status') {
            steps {
                sh 'docker ps --filter name=$CONTAINER_NAME'
            }
        }

        stage('Cleanup Old Images') {
            steps {
                sh 'docker image prune -f'
            }
        }
    }

    post {
        success {
            echo "SUCCESS: Build #${env.BUILD_NUMBER} deploy ho gaya. Website live hai (EC2 IP, port 80)."
        }
        failure {
            echo "FAILED: Build #${env.BUILD_NUMBER} fail ho gaya. Console Output check karo."
        }
        unstable {
            echo "UNSTABLE: Build #${env.BUILD_NUMBER} unstable hai."
        }
        aborted {
            echo "ABORTED: Build #${env.BUILD_NUMBER} beech me rok diya gaya."
        }
        always {
            echo "Pipeline khatam hui. Result: ${currentBuild.currentResult}"
        }
    }
}