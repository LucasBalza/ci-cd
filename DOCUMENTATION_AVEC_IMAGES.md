# Documentation Complète du Projet Jenkins

Cette documentation présente chaque étape du projet avec les captures d'écran correspondantes.

## ️ Architecture du Projet

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

##  Étapes du Projet avec Images

### 1.  Nettoyage Complet

**Commandes :**
```bash
# Arrêter tous les conteneurs
docker stop mon-app-js-staging mon-app-js-production mon-app-js-container 2>/dev/null || true

# Supprimer tous les conteneurs
docker rm mon-app-js-staging mon-app-js-production mon-app-js-container 2>/dev/null || true

# Vérifier que tout est nettoyé
docker ps -a
```

**Résultat attendu :** Aucun conteneur en cours d'exécution

---

### 2. ✅ Vérification des Prérequis

**Commandes :**
```bash
# Vérifier Docker
docker --version

# Vérifier Node.js
node --version

# Vérifier npm
npm --version

# Vérifier Git
git --version
```

**Image associée :** `image/README/Capture d'écran 2025-09-19 162236.png`
![Vérification des prérequis](image/README/Capture%20d'écran%202025-09-19%20164312.png)

---

### 3.  Installation des Dépendances

**Commandes :**
```bash
# Installation des dépendances
npm ci
```

**Image associée :** `image/README/Capture d'écran 2025-09-19 162523.png`
![Installation des dépendances](image/README/Capture%20d'écran%202025-09-19%20164725.png)

---

### 4. Tests Unitaires

**Commandes :**
```bash
# Tests unitaires
npm test
```

**Image associée :** `image/README/Capture d'écran 2025-09-19 162624.png`
![Tests unitaires](image/README/Capture%20d'écran%202025-09-19%20164443.png)

---

### 5. ️ Build de l'Application

**Commandes :**
```bash
# Build de l'application
npm run build
```

**Image associée :** `image/README/Capture d'écran 2025-09-19 164842.png`
![Build de l'application](image/README/Capture%20d'écran%202025-09-19%20163506.png)

---

### 6.  Construction de l'Image Docker

**Commandes :**
```bash
# Construction de l'image
docker build -t mon-app-js-image .
```

**Image associée :** `image/README/Capture d'écran 2025-09-19 163541.png`
![Construction Docker](image/README/Capture%20d'écran%202025-09-19%20163541.png)

---

### 7.  Déploiement des Conteneurs

**Commandes :**
```bash
# Déploiement staging
docker run -d --name mon-app-js-staging -p 3001:3000 -e NODE_ENV=staging mon-app-js-image

# Déploiement production
docker run -d --name mon-app-js-production -p 3000:3000 -e NODE_ENV=production mon-app-js-image
```

**Image associée :** `image/README/Capture d'écran 2025-09-19 163555.png`
![Déploiement des conteneurs](image/README/Capture%20d'écran%202025-09-19%20163555.png)

---

### 8.  Tests des Applications

**Commandes :**
```bash
# Test des deux environnements
./test-app.sh 3001 3000
```

**Résultat attendu :**
- ✅ Staging /health OK
- ✅ Staging / OK
- ✅ Production /health OK
- ✅ Production / OK

---

### 9.  Vérification des Conteneurs

**Commandes :**
```bash
# Voir les conteneurs en cours
docker ps

# Voir les logs
docker logs mon-app-js-staging
docker logs mon-app-js-production
```

---

### 10.  Accès aux Applications

**URLs d'accès :**
- **Staging** : http://localhost:3001
- **Production** : http://localhost:3000
- **Health Checks** : 
  - http://localhost:3001/health
  - http://localhost:3000/health

---

##  Commandes de Gestion

### Arrêter les Conteneurs
```bash
docker stop mon-app-js-staging mon-app-js-production
```

### Redémarrer les Conteneurs
```bash
docker start mon-app-js-staging mon-app-js-production
```

### Voir les Logs
```bash
docker logs mon-app-js-staging
docker logs mon-app-js-production
```

### Nettoyage Complet
```bash
docker stop mon-app-js-staging mon-app-js-production
docker rm mon-app-js-staging mon-app-js-production
docker rmi mon-app-js-image
```

---

##  Images Anciennes (Référence)

### Images de Référence
- `image/README/1756113968891.png` - Image de référence 1
- `image/README/1756114127836.png` - Image de référence 2  
- `image/README/1756114176121.png` - Image de référence 3

---

## ✅ Résumé des Étapes

1. **Nettoyage** ✅ - Suppression des anciens conteneurs
2. **Prérequis** ✅ - Vérification des outils
3. **Dépendances** ✅ - Installation npm
4. **Tests** ✅ - Tests unitaires Jest
5. **Build** ✅ - Construction de l'application
6. **Docker** ✅ - Image Docker créée
7. **Déploiement** ✅ - Conteneurs staging et production
8. **Validation** ✅ - Tests des applications
9. **Vérification** ✅ - Conteneurs en cours
10. **Accès** ✅ - Applications accessibles

Cette documentation présente chaque étape avec les captures d'écran correspondantes pour faciliter la compréhension et la reproduction du projet.
