# ��� Projet Jenkins - CI/CD avec Docker

Ce projet démontre une **pipeline CI/CD complète** utilisant Jenkins pour déployer une application JavaScript dans des conteneurs Docker. Il implémente une stratégie de déploiement **blue-green** avec validation automatique.

## ���️ Architecture du Projet

### Vue d'ensemble
```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Jenkins       │    │   Docker Host    │    │   Application   │
│   (Container)   │───▶│   (Host)         │───▶│   (Containers)   │
│                 │    │                  │    │                 │
│ • Pipeline      │    │ • Docker Daemon  │    │ • Staging:3001  │
│ • Tests         │    │ • Images         │    │ • Production:3000│
│ • Build         │    │ • Containers     │    │ • Health Checks │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

### Structure du projet
```
JENKINS/
├── Jenkinsfile              # Pipeline Jenkins (10 étapes)
├── Dockerfile               # Configuration Docker
├── package.json             # Dépendances du projet principal
├── test-app.sh              # Script de test manuel
├── jest.config.js           # Configuration Jest
├── mon-app-js/              # Application JavaScript
│   ├── package.json         # Dépendances de l'application
│   ├── server.js            # Serveur Express
│   ├── src/                 # Code source
│   │   ├── index.html       # Interface utilisateur
│   │   ├── app.js           # Logique métier
│   │   ├── styles.css       # Styles CSS
│   │   └── utils.js         # Utilitaires
│   └── tests/               # Tests unitaires
│       └── app.test.js      # Tests Jest
└── node_modules/            # Dépendances installées
```

## �� Pipeline Jenkins - Fonctionnement Détaillé

### Phase 1 : Préparation (Étapes 1-4)
```mermaid
graph LR
    A[Checkout] --> B[Install Dependencies]
    B --> C[Run Tests]
    C --> D[Build]
```

1. **Checkout** : Récupération du code source depuis le repository Git
2. **Install Dependencies** : Installation des dépendances npm avec `npm ci`
3. **Run Tests** : Exécution des tests unitaires Jest avec génération de rapports JUnit
4. **Build** : Construction de l'application (copie des fichiers dans `dist/`)

### Phase 2 : Containerisation (Étapes 5-6)
```mermaid
graph LR
    A[Prepare Dockerfile] --> B[Docker Build]
```

5. **Prepare Dockerfile** : Vérification de la configuration Docker
6. **Docker Build** : Construction de l'image Docker `mon-app-js-image`

### Phase 3 : Déploiement Staging (Étapes 7-8)
```mermaid
graph LR
    A[Cleanup Previous] --> B[Deploy Staging]
    B --> C[Test Staging]
```

7. **Cleanup Previous Deployments** : Nettoyage des anciens conteneurs
8. **Deploy Staging** : Déploiement sur le port 3001 avec `NODE_ENV=staging`
9. **Test Staging** : Validation complète de l'environnement staging

### Phase 4 : Déploiement Production (Étapes 9-10)
```mermaid
graph LR
    A[Deploy Production] --> B[Test Production]
```

10. **Deploy Production** : Déploiement sur le port 3000 avec `NODE_ENV=production`
11. **Test Production** : Validation complète de l'environnement production

## ��� Configuration Docker

### Dockerfile
```dockerfile
FROM node:22-alpine                    # Image de base légère
WORKDIR /app                          # Répertoire de travail
COPY mon-app-js/package*.json ./      # Copie des dépendances
RUN npm install --omit=dev            # Installation production uniquement
COPY mon-app-js/server.js ./          # Copie du serveur
COPY mon-app-js/src/ ./src/           # Copie du code source
EXPOSE 3000                           # Port exposé
CMD ["node", "server.js"]             # Commande de démarrage
```

### Communication Docker
- **Jenkins → Docker Host** : `DOCKER_HOST=tcp://host.docker.internal:2375`
- **Tests → Application** : `http://host.docker.internal:PORT`
- **Utilisateur → Application** : `http://localhost:PORT`

## ��� Tests et Validation

### Tests Automatiques
1. **Tests Unitaires** : Jest avec rapports JUnit
2. **Tests d'Intégration** : Validation des endpoints `/` et `/health`
3. **Tests de Charge** : 5 requêtes consécutives pour valider la stabilité
4. **Tests de Santé** : Vérification de la disponibilité des services

### Endpoints de l'Application
- **Page d'accueil** : `GET /` → Interface utilisateur
- **Health Check** : `GET /health` → Statut de l'application
  ```json
  {
    "status": "OK",
    "timestamp": "2024-01-15T10:30:00.000Z",
    "version": "1.0.0",
    "environment": "production",
    "port": 3000
  }
  ```

## ��� Démarrage du Projet

### Prérequis
- Docker installé et en cours d'exécution
- Jenkins configuré avec Docker
- Node.js 18+ (pour le développement local)
- Git (pour le versioning)

### 1. Configuration Jenkins
```bash
# Vérifier que Docker est accessible depuis Jenkins
docker --version
docker ps

# Configurer le DOCKER_HOST si nécessaire
export DOCKER_HOST=tcp://host.docker.internal:2375
```

### 2. Démarrage Manuel (Développement)
```bash
# Installation des dépendances
npm ci

# Démarrage de l'application en mode développement
cd mon-app-js
npm start
```

### 3. Build et Déploiement Docker Manuel
```bash
# Construction de l'image
docker build -t mon-app-js-image .

# Déploiement staging
docker run -d --name mon-app-js-staging -p 3001:3000 -e NODE_ENV=staging mon-app-js-image

# Déploiement production
docker run -d --name mon-app-js-production -p 3000:3000 -e NODE_ENV=production mon-app-js-image
```

### 4. Tests Manuels
```bash
# Test des deux environnements
./test-app.sh 3001 3000

# Test individuel
curl http://localhost:3001/health  # Staging
curl http://localhost:3000/health  # Production
```

## ��� Environnements

### Staging (Pré-production)
- **URL** : `http://localhost:3001`
- **Health** : `http://localhost:3001/health`
- **Environnement** : `NODE_ENV=staging`
- **Usage** : Tests et validation avant production

### Production
- **URL** : `http://localhost:3000`
- **Health** : `http://localhost:3000/health`
- **Environnement** : `NODE_ENV=production`
- **Usage** : Application finale pour les utilisateurs

## ��� Commandes Utiles

### Gestion des Conteneurs
```bash
# Voir les conteneurs en cours
docker ps

# Voir les logs d'un conteneur
docker logs mon-app-js-staging
docker logs mon-app-js-production

# Arrêter les conteneurs
docker stop mon-app-js-staging mon-app-js-production

# Supprimer les conteneurs
docker rm mon-app-js-staging mon-app-js-production

# Nettoyer les images
docker rmi mon-app-js-image
```

### Tests et Debugging
```bash
# Tests unitaires
npm test

# Tests avec couverture
npm run test -- --coverage

# Build de l'application
npm run build

# Nettoyage
npm run clean
```

## ��� Monitoring et Logs

### Logs Jenkins
- **Pipeline** : Logs détaillés de chaque étape
- **Tests** : Rapports JUnit et Jest
- **Docker** : Logs de construction et déploiement

### Logs Application
- **Démarrage** : Confirmation du port et environnement
- **Requêtes** : Logs des accès aux endpoints
- **Erreurs** : Gestion des erreurs et stack traces

## ���️ Dépannage

### Problèmes Courants
1. **Docker non accessible** : Vérifier `DOCKER_HOST`
2. **Ports occupés** : Changer les ports ou arrêter les conteneurs
3. **Tests échoués** : Vérifier les logs des conteneurs
4. **Build échoué** : Vérifier les dépendances et le Dockerfile

### Commandes de Debug
```bash
# Vérifier les conteneurs
docker ps -a

# Vérifier les images
docker images

# Vérifier les ports
netstat -tulpn | grep :300

# Tester la connectivité
curl -v http://localhost:3001/health
```

## ��� Points Clés du Projet

- ✅ **CI/CD Complète** : Pipeline Jenkins automatisé
- ✅ **Containerisation** : Docker pour la portabilité
- ✅ **Blue-Green Deployment** : Déploiement sans interruption
- ✅ **Tests Automatisés** : Validation à chaque étape
- ✅ **Monitoring** : Health checks et logs
- ✅ **Environnements Multiples** : Staging et Production
- ✅ **Nettoyage Automatique** : Gestion des ressources

Ce projet démontre une maîtrise complète des technologies DevOps modernes et des bonnes pratiques de déploiement continu.

## ��� Documentation avec Images

Une documentation complète avec captures d'écran est disponible dans le fichier `DOCUMENTATION_AVEC_IMAGES.md`.

### Images Disponibles
- `image/README/Capture d'écran 2025-09-19 162236.png` - Vérification des prérequis
- `image/README/Capture d'écran 2025-09-19 162523.png` - Installation des dépendances
- `image/README/Capture d'écran 2025-09-19 162624.png` - Tests unitaires
- `image/README/Capture d'écran 2025-09-19 163506.png` - Build de l'application
- `image/README/Capture d'écran 2025-09-19 163541.png` - Construction Docker
- `image/README/Capture d'écran 2025-09-19 163555.png` - Déploiement des conteneurs

### Documentation Complète
Consultez `DOCUMENTATION_AVEC_IMAGES.md` pour une documentation détaillée avec captures d'écran de chaque étape.
