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
            when { branch 'main' }
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
            when { branch 'main' }
            steps {
                sh '''
            echo "Lancement de l'application..."
            cd $DEPLOY_DIR
            npm install --production
            node index.js
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
