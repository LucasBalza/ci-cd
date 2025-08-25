pipeline {
    agent any

    environment {
        APP_NAME   = 'mon-app-js'
        IMAGE_NAME = 'mon-app-js-image'
        CONTAINER_NAME = 'mon-app-js-container'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                    node --version
                    npm --version
                    npm install
                '''
            }
        }

        stage('Run Tests') {
            steps {
                sh '''
                    echo "Running tests..."
                    npx jest --ci || true
                    ls -l test-reports
                '''
            }
            post {
                always {
                    junit 'test-reports/test-results.xml'
                }
            }
        }

        stage('Build') {
            steps {
                sh 'npm run build'
            }
        }

        stage('Prepare Dockerfile') {
            steps {
                sh '''
                    cat > Dockerfile <<EOF
                    FROM node:22-alpine
                    WORKDIR /app
                    COPY package*.json ./
                    RUN npm install --production
                    COPY dist/ ./dist/
                    EXPOSE 3000
                    CMD ["node", "dist/index.js"]
                    EOF
                '''
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
            # Utiliser le Docker TCP exposé par Docker Desktop
            export DOCKER_HOST=tcp://host.docker.internal:2375
            docker build -t ${IMAGE_NAME} .
        '''
            }
        }

        stage('Docker Run') {
            steps {
                sh '''
            export DOCKER_HOST=tcp://host.docker.internal:2375
            # Supprime le container existant si présent
            docker rm -f ${CONTAINER_NAME} || true
            # Lance le container
            docker run -d --name ${CONTAINER_NAME} -p 3000:3000 ${IMAGE_NAME}
        '''
            }
        }
    }

    post {
        always {
            echo 'Pipeline terminé.'
        }
    }
}
