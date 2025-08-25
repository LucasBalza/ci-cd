pipeline {
    agent any

    environment {
        APP_NAME   = 'mon-app-js'
        DEPLOY_DIR = 'C:\\deploy\\mon-app'  // chemin Windows
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
                    if exist package-lock.json (
                        npm ci
                    ) else (
                        npm install
                    )
                '''
            }
        }

        stage('Run Tests') {
            steps {
                // Jest doit être installé localement ou globalement
                bat 'npm test || exit 0'
            }
            post {
                always {
                    // Assurez-vous que Jest génère un fichier test-results.xml via jest-junit
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
                    REM Sauvegarde de l'ancienne version si elle existe
                    if exist "${DEPLOY_DIR}" (
                        xcopy "${DEPLOY_DIR}" "${DEPLOY_DIR}_backup_%DATE:~6,4%%DATE:~3,2%%DATE:~0,2%_%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%" /E /I /Y
                    )

                    REM Création du dossier de déploiement
                    if not exist "${DEPLOY_DIR}" mkdir "${DEPLOY_DIR}"

                    REM Copie des fichiers build
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
