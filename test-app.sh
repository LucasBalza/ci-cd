#!/bin/bash

# Variables
STAGING_PORT=${1:-3001}
PROD_PORT=${2:-3000}

echo "🧪 Tests de l'application mon-app-js..."

# Test de la staging
echo "📋 Tests de la STAGING (port $STAGING_PORT):"
echo "----------------------------------------"
curl -f http://localhost:$STAGING_PORT/health && echo "✅ Staging /health OK" || echo "❌ Staging /health échoué"
curl -f http://localhost:$STAGING_PORT/ && echo "✅ Staging / OK" || echo "❌ Staging / échoué"

echo ""
echo "🚀 Tests de la PRODUCTION (port $PROD_PORT):"
echo "----------------------------------------"
curl -f http://localhost:$PROD_PORT/health && echo "✅ Production /health OK" || echo "❌ Production /health échoué"
curl -f http://localhost:$PROD_PORT/ && echo "✅ Production / OK" || echo "❌ Production / échoué"

echo ""
echo "📊 Résumé des environnements :"
echo "   - Staging: http://localhost:$STAGING_PORT"
echo "   - Production: http://localhost:$PROD_PORT"
echo ""
echo "✅ Tests terminés." 