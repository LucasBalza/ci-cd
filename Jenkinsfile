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

        stage('Cleanup Previous Deployments') {
            steps {
                sh '''
                    export DOCKER_HOST=tcp://host.docker.internal:2375
                    echo "🧹 Nettoyage des déploiements précédents..."
                    docker rm -f ${STAGING_CONTAINER} || true
                    docker rm -f ${PROD_CONTAINER} || true
                    docker rm -f mon-app-js-container || true
                    echo "✅ Nettoyage terminé"
                '''
            }
        }

        stage('Deploy Staging') {
            steps {
                sh '''
                    export DOCKER_HOST=tcp://host.docker.internal:2375
                    echo "🚀 Déploiement en staging sur le port ${STAGING_PORT}..."
                    docker run -d --name ${STAGING_CONTAINER} -p ${STAGING_PORT}:3000 -e NODE_ENV=staging ${IMAGE_NAME}
                    echo "⏳ Attente du démarrage du conteneur staging..."
                    sleep 15
                    echo "📊 Vérification du statut du conteneur staging :"
                    docker ps | grep ${STAGING_CONTAINER}
                    echo "📋 Logs du conteneur staging :"
                    docker logs ${STAGING_CONTAINER} --tail 10
                '''
            }
        }

        stage('Test Staging') {
            steps {
                sh '''
                    echo "🧪 Tests de validation de la staging..."
                    
                    # Attendre un peu plus pour s'assurer que l'app est prête
                    sleep 5
                    
                    echo "🔍 Test de l'endpoint /health sur le port ${STAGING_PORT} :"
                    if curl -f http://host.docker.internal:${STAGING_PORT}/health; then
                        echo "✅ Endpoint /health accessible"
                    else
                        echo "❌ L'endpoint /health n'est pas accessible"
                        echo "📋 Vérification des logs du conteneur :"
                        docker logs ${STAGING_CONTAINER} --tail 20
                        exit 1
                    fi
                    
                    echo "🔍 Test de la page d'accueil sur le port ${STAGING_PORT} :"
                    if curl -f http://host.docker.internal:${STAGING_PORT}/; then
                        echo "✅ Page d'accueil accessible"
                    else
                        echo "❌ La page d'accueil n'est pas accessible"
                        exit 1
                    fi
                    
                    echo "📊 Tests de charge basiques..."
                    success_count=0
                    for i in 1 2 3 4 5; do
                        if curl -s http://host.docker.internal:${STAGING_PORT}/health > /dev/null; then
                            echo "✅ Requête $i OK"
                            ((success_count++))
                        else
                            echo "❌ Requête $i échouée"
                        fi
                    done
                    
                    echo "📈 Résultat des tests de charge : $success_count/5 succès"
                    if [ $success_count -lt 3 ]; then
                        echo "❌ Trop d'échecs dans les tests de charge"
                        exit 1
                    fi
                    
                    echo "✅ Validation de la staging terminée avec succès."
                '''
            }
        }

        stage('Deploy Production') {
            steps {
                sh '''
                    export DOCKER_HOST=tcp://host.docker.internal:2375
                    echo "🚀 Déploiement en production sur le port ${PROD_PORT}..."
                    docker run -d --name ${PROD_CONTAINER} -p ${PROD_PORT}:3000 -e NODE_ENV=production ${IMAGE_NAME}
                    echo "⏳ Attente du démarrage du conteneur production..."
                    sleep 15
                    echo "📊 Vérification du statut du conteneur production :"
                    docker ps | grep ${PROD_CONTAINER}
                    echo "📋 Logs du conteneur production :"
                    docker logs ${PROD_CONTAINER} --tail 10
                '''
            }
        }

        stage('Test Production') {
            steps {
                sh '''
                    echo "🧪 Tests de validation de la production..."
                    
                    # Attendre un peu plus pour s'assurer que l'app est prête
                    sleep 5
                    
                    echo "🔍 Test de l'endpoint /health sur le port ${PROD_PORT} :"
                    if curl -f http://host.docker.internal:${PROD_PORT}/health; then
                        echo "✅ Endpoint /health accessible"
                    else
                        echo "❌ L'endpoint /health n'est pas accessible"
                        echo "📋 Vérification des logs du conteneur :"
                        docker logs ${PROD_CONTAINER} --tail 20
                        exit 1
                    fi
                    
                    echo "🔍 Test de la page d'accueil sur le port ${PROD_PORT} :"
                    if curl -f http://host.docker.internal:${PROD_PORT}/; then
                        echo "✅ Page d'accueil accessible"
                    else
                        echo "❌ La page d'accueil n'est pas accessible"
                        exit 1
                    fi
                    
                    echo "📊 Tests de charge basiques..."
                    success_count=0
                    for i in 1 2 3 4 5; do
                        if curl -s http://host.docker.internal:${PROD_PORT}/health > /dev/null; then
                            echo "✅ Requête $i OK"
                            ((success_count++))
                        else
                            echo "❌ Requête $i échouée"
                        fi
                    done
                    
                    echo "📈 Résultat des tests de charge : $success_count/5 succès"
                    if [ $success_count -lt 3 ]; then
                        echo "❌ Trop d'échecs dans les tests de charge"
                        exit 1
                    fi
                    
                    echo "🎉 Déploiement production réussi !"
                    echo "📊 Résumé des environnements :"
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
