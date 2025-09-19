# Projet Jenkins - Déploiement d'Application JavaScript

Ce projet démontre l'utilisation de Jenkins pour déployer une application JavaScript dans un conteneur Docker.

## Structure du projet

```
JENKINS/
├── Jenkinsfile          # Pipeline Jenkins
├── Dockerfile           # Configuration Docker
├── package.json         # Dépendances du projet principal
├── mon-app-js/          # Application JavaScript
│   ├── package.json     # Dépendances de l'application
│   ├── server.js        # Serveur Express
│   └── src/             # Code source
└── tests/               # Tests unitaires
```

## Pipeline Jenkins

Le pipeline comprend les étapes suivantes :
1. **Checkout** : Récupération du code
2. **Install Dependencies** : Installation des dépendances
3. **Run Tests** : Exécution des tests
4. **Build** : Construction de l'application
5. **Prepare Dockerfile** : Vérification de la configuration
6. **Docker Build** : Construction de l'image Docker
7. **Deploy Staging** : Déploiement en staging (port 3001)
8. **Test Staging** : Tests de validation de la staging
9. **Deploy Production** : Déploiement en production (port 3000)
10. **Test Production** : Tests de validation de la production

## Test de l'application

L'application expose deux environnements :

### Staging (Pré-production)
- `http://localhost:3001/` : Page d'accueil
- `http://localhost:3001/health` : Endpoint de santé

### Production
- `http://localhost:3000/` : Page d'accueil
- `http://localhost:3000/health` : Endpoint de santé

**Note** : Dans le pipeline Jenkins, les tests utilisent `host.docker.internal` pour accéder aux conteneurs depuis le conteneur Jenkins.

### Test manuel
```bash
# Test des deux environnements
./test-app.sh 3001 3000
```

## Démarrage manuel

```bash
# Installation des dépendances
npm ci

# Démarrage de l'application
cd mon-app-js
npm start
```

## Build Docker manuel

```bash
# Construction de l'image
docker build -t mon-app-js-image .

# Démarrage du conteneur
docker run -d --name mon-app-js-container -p 3000:3000 mon-app-js-image
```
