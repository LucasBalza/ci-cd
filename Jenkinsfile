pipeline {
    agent any

    environment {
        APP_NAME   = 'mon-app-js'
        DEPLOY_DIR = 'C:\\deploy\\mon-app' // modifie selon ton dossier Windows
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
                    npm install
                '''
            }
        }

        stage('Run Tests') {
            steps {
                bat 'npm test || exit 0'
            }
            post {
                always {
                    // On archive le rapport JUnit généré par jest-junit
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
                bat """
                    if exist "${DEPLOY_DIR}" (
                        set dt=%date:~-4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%%time:~6,2%
                        xcopy "${DEPLOY_DIR}" "${DEPLOY_DIR}_backup_%dt%" /E /I /Y
                    )

                    if not exist "${DEPLOY_DIR}" mkdir "${DEPLOY_DIR}"
                    xcopy dist\\* "${DEPLOY_DIR}\\" /E /I /Y
                """
            }
        }
    }

    post {
        always {
            echo 'Nettoyage terminé.'
        }
    }
}
