FROM node:22-alpine

WORKDIR /app

# Copier les fichiers de dépendances de l'application
COPY mon-app-js/package*.json ./

# Installer les dépendances de production
RUN npm install --omit=dev

# Copier le code source
COPY mon-app-js/server.js ./
COPY mon-app-js/src/ ./src/

# Exposer le port
EXPOSE 3000

# Commande de démarrage
CMD ["node", "server.js"] 