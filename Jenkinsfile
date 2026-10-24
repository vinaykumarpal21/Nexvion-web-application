
pipeline {
    agent any

    environment {
        IMAGE_NAME     = "static-web-app"
        IMAGE_TAG      = "${env.BUILD_NUMBER}"
        CONTAINER_NAME = "my-static-app"

        DOCKER_HUB_USER = "vinaykumarpal"
        EC2_USER        = "ubuntu"
        EC2_PUBLIC_IP   = "YOUR_EC2_PUBLIC_IP"
    }

    options {
        timestamps()
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    triggers {
        githubPush()
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
                    docker build \
                      -t $IMAGE_NAME:$IMAGE_TAG \
                      -t $IMAGE_NAME:latest .
                '''
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-credentials',
                        usernameVariable: 'DH_USER',
                        passwordVariable: 'DH_PASSWORD'
                    )
                ]) {
                    sh '''
                        echo "$DH_PASSWORD" | docker login \
                          -u "$DH_USER" --password-stdin

                        docker tag $IMAGE_NAME:latest \
                          $DOCKER_HUB_USER/nexvion-web:latest

                        docker push $DOCKER_HUB_USER/nexvion-web:latest

                        docker logout
                    '''
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                sshagent(credentials: ['ec2-ssh-key']) {
                    sh '''
                        ssh -o StrictHostKeyChecking=accept-new \
                          $EC2_USER@$EC2_PUBLIC_IP "
                            # 1. Purana container stop aur remove karein
                            docker stop my-static-app || true
                            docker rm my-static-app || true

                            # 2. Docker Hub se nayi image pull karein
                            docker pull $DOCKER_HUB_USER/nexvion-web:latest

                            # 3. Naya container run karein
                            docker run -d \
                              -p 80:80 \
                              --name my-static-app \
                              -v nexvion_logs:/var/log/nginx \
                              --restart unless-stopped \
                              $DOCKER_HUB_USER/nexvion-web:latest
                        "
                    '''
                }
            }
        }

        stage('Show Status') {
            steps {
                sshagent(credentials: ['ec2-ssh-key']) {
                    sh '''
                        ssh -o StrictHostKeyChecking=accept-new \
                          $EC2_USER@$EC2_PUBLIC_IP \
                          "docker ps --filter name=my-static-app"
                    '''
                }
            }
        }

        stage('Cleanup Old Images') {
            steps {
                sshagent(credentials: ['ec2-ssh-key']) {
                    sh '''
                        ssh -o StrictHostKeyChecking=accept-new \
                          $EC2_USER@$EC2_PUBLIC_IP \
                          "docker image prune -f"
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "SUCCESS: Build #${env.BUILD_NUMBER} EC2 par deploy ho gaya."
            echo "Website: http://${env.EC2_PUBLIC_IP}"
        }

        failure {
            echo "FAILED: Build #${env.BUILD_NUMBER} fail ho gaya. Console Output check karo."
        }

        unstable {
            echo "UNSTABLE: Build #${env.BUILD_NUMBER} unstable hai."
        }

        aborted {
            echo "ABORTED: Build #${env.BUILD_NUMBER} beech mein rok diya gaya."
        }

        always {
            echo "Pipeline khatam hui. Result: ${currentBuild.currentResult}"
        }
    }
}
