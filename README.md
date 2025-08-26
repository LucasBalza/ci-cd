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

## Problème résolu

L'erreur `Cannot find module 'express'` était causée par :
1. `express` était dans `devDependencies` au lieu de `dependencies`
2. Le Dockerfile utilisait `npm install --production` qui n'installe que les `dependencies`

## Solutions appliquées

1. **Correction du package.json** : Déplacé `express` vers `dependencies`
2. **Création d'un package.json spécifique** : Dans `mon-app-js/` pour l'application
3. **Amélioration du Dockerfile** : Utilisation de `npm ci --only=production`
4. **Ajout de tests** : Script de test pour vérifier le déploiement

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
