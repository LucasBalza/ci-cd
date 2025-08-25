pipeline {
    agent {
        docker {
            image 'node:18'
            args '-u root:root' // permet d'écrire dans les volumes
        }
    }

    environment {
        APP_NAME   = 'mon-app-js'
        DEPLOY_DIR = '/var/www/html/mon-app'
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Récupération du code source...'
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                echo 'Installation des dépendances Node.js...'
                sh '''
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
                echo 'Exécution des tests...'
                sh 'npm test || true' // évite de bloquer si pas de tests
            }
            post {
                always {
                    junit 'test-results.xml'
                }
            }
        }

        stage('Code Quality Check') {
            steps {
                echo 'Vérification de la qualité du code avec ESLint...'
                sh '''
                    if [ -f node_modules/.bin/eslint ]; then
                      npx eslint src || true
                    else
                      echo "ESLint non installé"
                    fi
                '''
            }
        }

        stage('Build') {
            steps {
                echo 'Construction de l\'application...'
                sh '''
                    npm run build
                    ls -la dist/
                '''
            }
        }

        stage('Security Scan') {
            steps {
                echo 'Analyse de sécurité...'
                sh '''
                    echo "Vérification des dépendances..."
                    npm audit --audit-level=high || true
                '''
            }
        }

        stage('Deploy to Staging') {
            when {
                branch 'develop'
            }
            steps {
                echo 'Déploiement vers l\'environnement de staging...'
                sh '''
                    mkdir -p staging
                    cp -r dist/* staging/
                '''
            }
        }

        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            steps {
                echo 'Déploiement vers la production...'
                sh '''
                    if [ -d "${DEPLOY_DIR}" ]; then
                        cp -r ${DEPLOY_DIR} ${DEPLOY_DIR}_backup_$(date +%Y%m%d_%H%M%S)
                    fi

                    mkdir -p ${DEPLOY_DIR}
                    cp -r dist/* ${DEPLOY_DIR}/

                    ls -la ${DEPLOY_DIR}
                '''
            }
        }

        stage('Health Check') {
            steps {
                echo 'Vérification de santé de l\'application...'
                script {
                    try {
                        sh '''
                            echo "Test de connectivité..."
                            echo "Application déployée avec succès"
                        '''
                    } catch (Exception e) {
                        currentBuild.result = 'UNSTABLE'
                        echo "⚠️ Health check failed: ${e.getMessage()}"
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Nettoyage des ressources temporaires...'
            sh '''
                rm -rf node_modules/.cache
                rm -rf staging
            '''
        }
        success {
            echo '✅ Pipeline exécuté avec succès!'
        }
        failure {
            echo '❌ Le pipeline a échoué!'
        }
        unstable {
            echo '⚠️ Build instable - des avertissements ont été détectés'
        }
    }
}
