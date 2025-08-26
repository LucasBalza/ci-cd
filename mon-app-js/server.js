const express = require('express');
const path = require('path');
const app = express();
const port = process.env.PORT || 3000;
const nodeEnv = process.env.NODE_ENV || 'development';

// Servir les fichiers statiques
app.use(express.static(path.join(__dirname, 'src')));

app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'src', 'index.html'));
});

app.get('/health', (req, res) => {
    res.json({ 
        status: 'OK', 
        timestamp: new Date().toISOString(),
        version: '1.0.0',
        environment: nodeEnv,
        port: port
    });
});

app.listen(port, () => {
    console.log(`Serveur démarré sur le port ${port} en mode ${nodeEnv}`);
});