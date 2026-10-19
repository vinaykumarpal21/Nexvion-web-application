pipeline {
    agent any

    environment {
        IMAGE_NAME   = "YOUR_DOCKERHUB_USERNAME/nexvion-web"   // <-- apna Docker Hub username daalo
        IMAGE_TAG    = "${env.BUILD_NUMBER}"
        EC2_HOST     = credentials('nexvion-ec2-host')    // Secret text: EC2 public IP/DNS
        EC2_USER     = "ubuntu"                           // ec2-user for Amazon Linux
        APP_DIR      = "/home/ubuntu/nexvion"
    }

    options {
        timestamps()
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    triggers {
        githubPush()   // GitHub webhook -> auto build on every push
    }

    stages {
        stage('Checkout') {
            steps { checkout scm }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                  docker build -t $IMAGE_NAME:$IMAGE_TAG -t $IMAGE_NAME:latest .
                '''
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DH_USER', passwordVariable: 'DH_PASS')]) {
                    sh '''
                      echo "$DH_PASS" | docker login -u "$DH_USER" --password-stdin
                      docker push $IMAGE_NAME:$IMAGE_TAG
                      docker push $IMAGE_NAME:latest
                    '''
                }
            }
        }

        stage('Deploy to AWS EC2') {
            steps {
                sshagent(credentials: ['nexvion-ec2-ssh']) {
                    sh '''
                      ssh -o StrictHostKeyChecking=no $EC2_USER@$EC2_HOST "mkdir -p $APP_DIR"
                      scp -o StrictHostKeyChecking=no docker-compose.yml $EC2_USER@$EC2_HOST:$APP_DIR/docker-compose.yml
                      ssh -o StrictHostKeyChecking=no $EC2_USER@$EC2_HOST "
                        cd $APP_DIR &&
                        export IMAGE_NAME=$IMAGE_NAME IMAGE_TAG=$IMAGE_TAG &&
                        docker compose pull &&
                        docker compose up -d --remove-orphans &&
                        docker image prune -f
                      "
                    '''
                }
            }
        }
    }

    post {
        success { echo "Deployed build #${env.BUILD_NUMBER} -> http://${env.EC2_HOST}" }
        failure { echo "Pipeline failed - check console output" }
        always  { sh 'docker logout || true' }
    }
}
