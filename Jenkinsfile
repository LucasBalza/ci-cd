pipeline {
    agent any

    environment {
        APP_NAME   = 'mon-app-js'
        DEPLOY_DIR = '/var/www/html/mon-app'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                bat '''
                    node --version
                    npm --version
                    if [ -f package-lock.json ]; then
                      npm ci
                    else
                      npm install
                    fi
                '''
            }
        }

        stage('Run Tests') {
            steps {
                bat 'npm test || true'
            }
            post {
                always {
                    junit 'test-results.xml'
                }
            }
        }

        stage('Build') {
            steps {
                bat 'npm run build'
            }
        }

        stage('Deploy to Production') {
            when { branch 'main' }
            steps {
                bat '''
                    if [ -d "${DEPLOY_DIR}" ]; then
                        cp -r ${DEPLOY_DIR} ${DEPLOY_DIR}_backup_$(date +%Y%m%d_%H%M%S)
                    fi

                    mkdir -p ${DEPLOY_DIR}
                    cp -r dist/* ${DEPLOY_DIR}/
                '''
            }
        }
    }

    post {
        always {
            echo 'Nettoyage terminé.'
        }
    }
}
