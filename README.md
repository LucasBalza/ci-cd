# 📚 Documentation Complète du Projet Jenkins

Cette documentation décrit **l’architecture**, **le pipeline complet** (avec commandes et captures d’écran), puis la **configuration de Jenkins** et la **gestion des conteneurs**.

---

## 🗂️ Table des matières
1. [Architecture du projet](#️-1-architecture-du-projet)
2. [Pipeline complet de l’application](#-2-pipeline-complet-de-lapplication)
3. [Configuration et utilisation de Jenkins](#-3-configuration-et-utilisation-de-jenkins)
4. [Gestion et dépannage](#-4-gestion-et-dépannage)

---

## ️1. Architecture du Projet

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

---

## 2. 🚀 Pipeline complet de l’application

Chaque étape correspond à un stage du pipeline CI/CD, avec commandes et captures.

### 2.1 Nettoyage complet
```bash
docker stop mon-app-js-staging mon-app-js-production mon-app-js-container 2>/dev/null || true
docker rm mon-app-js-staging mon-app-js-production mon-app-js-container 2>/dev/null || true
docker ps -a
```
✅ Résultat attendu : aucun conteneur en cours d’exécution.

---

### 2.2 Vérification des prérequis
```bash
docker --version
node --version
npm --version
git --version
```
![Vérification des prérequis](image/README/Capture%20d'écran%202025-09-19%20164312.png)

---

### 2.3 Installation des dépendances
```bash
npm ci
```
![Installation des dépendances](image/README/Capture%20d'écran%202025-09-19%20164725.png)

---

### 2.4 Tests unitaires
```bash
npm test
```
![Tests unitaires](image/README/Capture%20d'écran%202025-09-19%20164443.png)

---

### 2.5 Build de l’application
```bash
npm run build
```
![Build de l'application](image/README/Capture%20d'écran%202025-09-19%20164842.png)

---

### 2.6 Construction de l’image Docker
```bash
docker build -t mon-app-js-image .
```
![Construction Docker](image/README/Capture%20d'écran%202025-09-19%20164842.png)

---

### 2.7 Déploiement des conteneurs
```bash
docker run -d --name mon-app-js-staging -p 3001:3000 -e NODE_ENV=staging mon-app-js-image
docker run -d --name mon-app-js-production -p 3000:3000 -e NODE_ENV=production mon-app-js-image
```
![Déploiement des conteneurs](image/README/Capture%20d'écran%202025-09-19%20165248.png)

---

### 2.8 Tests des applications
```bash
./test-app.sh 3001 3000
```
✅ Attendus :
- Staging /health OK et /
- Production /health OK et /

---

### 2.9 Vérification des conteneurs
```bash
docker ps
docker logs mon-app-js-staging
docker logs mon-app-js-production
```
![Vérification des conteneurs](image/README/Capture%20d'écran%202025-09-19%20165358.png)

---

### 2.10 Accès aux applications
- Staging : [http://localhost:3001](http://localhost:3001)
- Production : [http://localhost:3000](http://localhost:3000)
- Health checks : `/health` sur les deux ports.

---

### 2.11 Commandes de gestion
```bash
# Arrêter
docker stop mon-app-js-staging mon-app-js-production

# Redémarrer
docker start mon-app-js-staging mon-app-js-production

# Logs
docker logs mon-app-js-staging
docker logs mon-app-js-production

# Nettoyage complet
docker stop mon-app-js-staging mon-app-js-production
docker rm mon-app-js-staging mon-app-js-production
docker rmi mon-app-js-image
```

---

### ✅ Récapitulatif du pipeline
1. Nettoyage
2. Vérification des prérequis
3. Installation des dépendances
4. Tests unitaires
5. Build de l’application
6. Construction de l’image Docker
7. Déploiement des conteneurs
8. Tests et validation
9. Vérification des conteneurs
10. Accès aux applications

---

## 3. ⚙️ Configuration et utilisation de Jenkins

### Accès rapide
- Jenkins : [http://localhost:8080](http://localhost:8080)

### 3.1 Installation des plugins
Plugins recommandés :
- Pipeline
- Git plugin
- NodeJS plugin
- Email Extension plugin
- Workspace Cleanup plugin
- Build Timeout plugin

> Gérer depuis `Manage Jenkins > Manage Plugins`.

### 3.2 Configuration globale
- **Node.js** : `Manage Jenkins > Global Tool Configuration`  
  - Name : `NodeJS-22`  
  - Version : `22.x.x`  
  - Installation automatique : ✅  
- **Git** : vérifier la configuration.

### 3.3 Création du job pipeline
1. Dashboard → **New Item**
2. Nom : `mon-app-js-pipeline`
3. Type : **Pipeline**
4. Définition : **Pipeline script from SCM**
   - SCM : `Git`
   - Repository URL : `https://github.com/LucasBalza/ci-cd.git`
   - Branch : `*/main`
   - Script Path : `Jenkinsfile`

![Build du pipeline](image/README/Capture%20d'écran%202025-09-19%20173900.png)
---

## 4. 🛠️ Gestion et dépannage

### Commandes Docker Compose
```bash
docker-compose up -d      # Démarrer Jenkins
docker-compose down       # Arrêter
docker-compose restart    # Redémarrer
docker-compose logs jenkins
docker-compose ps         # Vérifier le statut
```

Nettoyage complet :
```bash
docker-compose down -v --rmi all
```

### Problèmes courants
| Problème | Solution |
|----------|---------|
| Port 8080 occupé | Modifier le port dans `docker-compose.yml` |
| Permissions Docker | Vérifier Docker Desktop |
| Plugins manquants | Installer via Manage Plugins |
| Node.js non trouvé | Vérifier la configuration globale |

---

✅ **En résumé** :  
- Jenkins tourne dans un conteneur Docker.  
- Le pipeline CI/CD construit, teste, package et déploie automatiquement l’application en staging et production.  
- Toutes les commandes essentielles (build, logs, nettoyage) sont centralisées dans ce document.
