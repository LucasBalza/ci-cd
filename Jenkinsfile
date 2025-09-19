pipeline {
    agent any

    tools {
        nodejs 'NodeJS-22'
    }

    environment {
        APP_NAME           = 'mon-app-js'
        IMAGE_NAME         = 'mon-app-js-image'
        STAGING_CONTAINER  = 'mon-app-js-staging'
        PROD_CONTAINER     = 'mon-app-js-production'
        STAGING_PORT       = '3001'
        PROD_PORT          = '3000'
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
                    npm ci
                    echo "Dépendances installées :"
                    npm list --depth=0
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
                sh '''
                    npm run build
                '''
            }
        }

        stage('Prepare Dockerfile') {
            steps {
                sh '''
                    echo "Vérification du Dockerfile..."
                    cat Dockerfile
                    echo "Vérification des fichiers package.json..."
                    cat package.json
                '''
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    echo "Docker Build simulé..."
                    echo "Image: mon-app-js-image"
                    echo "Build réussi (simulation)"
                '''
            }
        }

        stage('Deploy Staging') {
            steps {
                sh '''
                    echo "Déploiement staging simulé..."
                    echo "Conteneur: mon-app-js-staging"
                    echo "Port: 3001"
                    echo "Déploiement réussi (simulation)"
                '''
            }
        }

        stage('Test Staging') {
            steps {
                sh '''
                    echo "Tests staging simulés..."
                    echo "Endpoint /health: OK (simulation)"
                    echo "Page d'accueil: OK (simulation)"
                    echo "Tests de charge: OK (simulation)"
                '''
            }
        }

        stage('Deploy Production') {
            steps {
                sh '''
                    echo "Déploiement production simulé..."
                    echo "Conteneur: mon-app-js-production"
                    echo "Port: 3000"
                    echo "Déploiement réussi (simulation)"
                '''
            }
        }

        stage('Test Production') {
            steps {
                sh '''
                    echo "Tests production simulés..."
                    echo "Endpoint /health: OK (simulation)"
                    echo "Page d'accueil: OK (simulation)"
                    echo "Tests de charge: OK (simulation)"
                '''
            }
        }
    }

    post {
        always {
            echo 'Pipeline terminé.'
        }
        success {
            sh '''
                echo "Pipeline réussi !"
                echo "Résumé des déploiements :"
                echo "   - Staging: http://localhost:3001"
                echo "   - Production: http://localhost:3000"
            '''
        }
        failure {
            sh '''
                echo "Pipeline échoué !"
            '''
        }
    }
}
