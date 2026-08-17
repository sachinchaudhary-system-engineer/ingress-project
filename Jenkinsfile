pipeline {
    agent any

    environment {
        APP_NAME  = "my-app"
        IMAGE_TAG = "${BUILD_NUMBER}"
        USER_DOCKER = "chaudharysachin"
    }

    stages {

        stage("Checkout") {
            steps {
                git branch: 'main',
                    url: 'https://github.com/sachinchaudhary-system-engineer/ingress-project.git'
            }
        }

        stage("SonarQube Analysis") {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh 'sonar-scanner'
                }
            }
        }

        stage("Quality Gate") {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage("Build Docker Image") {
            steps {
                sh '''
                    docker build -t ${APP_NAME}:${IMAGE_TAG} .
                '''
            }
        }

        stage("Push to Docker Hub") {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-cred',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )
                ]) {
                    sh '''
                        echo "${DOCKER_PASS}" | docker login \
                            -u "${DOCKER_USER}" \
                            --password-stdin

                        docker tag ${APP_NAME}:${IMAGE_TAG} \
                            ${USER_DOCKER}/${APP_NAME}:${IMAGE_TAG}

                        docker push \
                            ${DOCKER_USER}/${APP_NAME}:${IMAGE_TAG}
                    '''
                }
            }
        }

        stage("Deploy") {
            steps {
                sh '''
                    kubectl apply -f K8s/namespace.yaml
                    kubectl apply -f K8s/

                    kubectl set image deployment/images-deployment \
                        images-container=${USER_DOCKER}/${APP_NAME}:${IMAGE_TAG}

                    kubectl rollout status deployment/images-deployment
                '''
            }
        }
    }

    post {
        success {
            echo "Deployment successful"
        }

        failure {
            echo "Deployment failed"
        }

        always {
            sh 'docker logout || true'
        }
    }
}