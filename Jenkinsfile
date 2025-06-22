pipeline {
    // Run this pipeline on any available Jenkins agent
    agent any

    // Environment variables available to all stages
    environment {
        DOCKER_HUB_CREDENTIALS_ID = 'dockerhub-credentials'
        DOCKER_IMAGE_NAME         = 'ayoubdev29/backend-service'
        KUBECONFIG_CREDENTIAL_ID  = 'kubeconfig-aws'
    }

    stages {
        stage('1. Checkout') {
            steps {
                // This step checks out the code from the repository configured in the Jenkins job
                checkout scm
            }
        }

        stage('2. Build Docker Image') {
            steps {
                script {
                    // Build the image and tag it with the unique Jenkins build number
                    def builtImage = docker.build("${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}", ".")
                    // Also tag the same image as 'latest'
                    builtImage.tag("latest")
                }
            }
        }

        stage('3. Push to Docker Hub') {
            steps {
                script {
                    // Use the 'dockerhub-credentials' we stored in Jenkins to log in
                    docker.withRegistry('https://registry.hub.docker.com', DOCKER_HUB_CREDENTIALS_ID) {
                        // Push the tag with the build number
                        docker.image("${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}").push()

                        // Push the 'latest' tag
                        docker.image("${DOCKER_IMAGE_NAME}:latest").push()
                    }
                }
            }
        }

        stage('4. Deploy to Kubernetes') {
            steps {
                // This block securely loads the AWS credentials and sets the region
                withAWS(credentials: 'aws-credentials', region: 'eu-west-3') {
                    // This block loads the kubeconfig file
                    withKubeConfig([credentialsId: KUBECONFIG_CREDENTIAL_ID]) {
                        script {
                            echo "Applying Kubernetes manifests..."
                            sh "kubectl apply -f k8s/"

                            echo "Updating deployment with new image..."
                            sh "kubectl set image deployment/backend-service-deployment backend-service-container=${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}"

                            echo "Waiting for rollout to complete..."
                            sh "kubectl rollout status deployment/backend-service-deployment"
                        }
                    }
                }
            }
        }
    }
}