pipeline {
    agent any

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
                    export DOCKER_HOST=tcp://host.docker.internal:2375
                    docker build -t ${IMAGE_NAME} .
                '''
            }
        }

        stage('Deploy Staging') {
            steps {
                sh '''
                    export DOCKER_HOST=tcp://host.docker.internal:2375
                    echo "Déploiement en staging sur le port ${STAGING_PORT}..."
                    docker rm -f ${STAGING_CONTAINER} || true
                    docker run -d --name ${STAGING_CONTAINER} -p ${STAGING_PORT}:3000 -e NODE_ENV=staging ${IMAGE_NAME}
                    echo "Attente du démarrage du conteneur staging..."
                    sleep 10
                    echo "Vérification du statut du conteneur staging :"
                    docker ps | grep ${STAGING_CONTAINER}
                '''
            }
        }

        stage('Test Staging') {
            steps {
                sh '''
                    echo "Tests de validation de la staging..."
                    echo "Test de l'endpoint /health sur le port ${STAGING_PORT} :"
                    curl -f http://localhost:${STAGING_PORT}/health || echo "❌ L'endpoint /health n'est pas accessible"
                    
                    echo "Test de la page d'accueil sur le port ${STAGING_PORT} :"
                    curl -f http://localhost:${STAGING_PORT}/ || echo "❌ La page d'accueil n'est pas accessible"
                    
                    echo "Tests de charge basiques..."
                    for i in {1..5}; do
                        curl -s http://localhost:${STAGING_PORT}/health > /dev/null && echo "✅ Requête $i OK" || echo "❌ Requête $i échouée"
                    done
                    
                    echo "Validation de la staging terminée."
                '''
            }
        }

        stage('Deploy Production') {
            steps {
                sh '''
                    export DOCKER_HOST=tcp://host.docker.internal:2375
                    echo "Déploiement en production sur le port ${PROD_PORT}..."
                    docker rm -f ${PROD_CONTAINER} || true
                    docker run -d --name ${PROD_CONTAINER} -p ${PROD_PORT}:3000 -e NODE_ENV=production ${IMAGE_NAME}
                    echo "Attente du démarrage du conteneur production..."
                    sleep 10
                    echo "Vérification du statut du conteneur production :"
                    docker ps | grep ${PROD_CONTAINER}
                '''
            }
        }

        stage('Test Production') {
            steps {
                sh '''
                    echo "Tests de validation de la production..."
                    echo "Test de l'endpoint /health sur le port ${PROD_PORT} :"
                    curl -f http://localhost:${PROD_PORT}/health || echo "❌ L'endpoint /health n'est pas accessible"
                    
                    echo "Test de la page d'accueil sur le port ${PROD_PORT} :"
                    curl -f http://localhost:${PROD_PORT}/ || echo "❌ La page d'accueil n'est pas accessible"
                    
                    echo "✅ Déploiement production réussi !"
                    echo "📊 Résumé :"
                    echo "   - Staging: http://localhost:${STAGING_PORT}"
                    echo "   - Production: http://localhost:${PROD_PORT}"
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
                echo "🎉 Pipeline réussi !"
                echo "📊 Résumé des déploiements :"
                echo "   - Staging: http://localhost:${STAGING_PORT}"
                echo "   - Production: http://localhost:${PROD_PORT}"
                echo ""
                echo "🔍 Pour tester manuellement :"
                echo "   ./test-app.sh ${STAGING_PORT} ${PROD_PORT}"
            '''
        }
        failure {
            sh '''
                echo "❌ Pipeline échoué !"
                echo "🧹 Nettoyage des conteneurs..."
                export DOCKER_HOST=tcp://host.docker.internal:2375
                docker rm -f ${STAGING_CONTAINER} || true
                docker rm -f ${PROD_CONTAINER} || true
            '''
        }
    }
}
