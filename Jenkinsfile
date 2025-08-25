pipeline {
    agent any

    environment {
        APP_NAME   = 'mon-app-js'
        DEPLOY_DIR = '/deploy/mon-app' // chemin Linux dans le container
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

        stage('Deploy to Production') {
            steps {
                sh '''
                    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

                    if [ -d "${DEPLOY_DIR}" ]; then
                        cp -r "${DEPLOY_DIR}" "${DEPLOY_DIR}_backup_$TIMESTAMP"
                    fi

                    mkdir -p "${DEPLOY_DIR}"
                    cp -r dist/* "${DEPLOY_DIR}/"
                '''
            }
        }

        stage('Run Application') {
            steps {
                sh '''
            cd $DEPLOY_DIR
            nohup node index.js > app.log 2>&1 &
            echo "Application lancée en arrière-plan, logs dans app.log"
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
