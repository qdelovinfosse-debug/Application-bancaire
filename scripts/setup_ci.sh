#!/bin/bash
# ============================================================
# Script de configuration initiale pour le déploiement CI/CD
# À exécuter UNE SEULE FOIS sur votre Mac
# ============================================================

set -e

echo "🚀 Configuration du déploiement automatique vers TestFlight"
echo "============================================================"

# 1. Vérifications préalables
echo ""
echo "📋 Vérification des prérequis..."

if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter non trouvé. Assurez-vous que Flutter est dans votre PATH."
    exit 1
fi
echo "✅ Flutter trouvé"

if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode non trouvé. Installez Xcode depuis l'App Store."
    exit 1
fi
echo "✅ Xcode trouvé"

# 2. Installation de Fastlane
echo ""
echo "📦 Installation de Fastlane..."
if ! command -v fastlane &> /dev/null; then
    brew install fastlane
fi
echo "✅ Fastlane prêt"

# 3. Génération du projet iOS Flutter
echo ""
echo "📱 Génération du projet iOS..."
flutter create --platforms=ios --project-name expense_tracker .
cd ios && pod install && cd ..
echo "✅ Projet iOS créé"

# 4. Configuration de l'identifiant de l'app
echo ""
read -p "🔑 Entrez votre Bundle ID (ex: com.votrenom.expensetracker): " APP_ID
read -p "📧 Entrez votre Apple ID (email): " APPLE_EMAIL

# Met à jour le Bundle ID dans Xcode
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $APP_ID" ios/Runner/Info.plist
sed -i '' "s/com.example.expenseTracker/$APP_ID/g" ios/Runner.xcodeproj/project.pbxproj

echo "✅ Bundle ID configuré : $APP_ID"

# 5. Configuration de Fastlane Match (gestion des certificats)
echo ""
echo "🔐 Configuration des certificats..."
echo ""
echo "Fastlane Match stocke vos certificats dans un repo Git privé."
read -p "📁 URL de votre repo privé pour les certificats (ex: git@github.com:user/certs.git): " MATCH_URL

fastlane match init --storage-mode git --git_url "$MATCH_URL"
fastlane match appstore --app_identifier "$APP_ID"

# 6. Mise à jour des fichiers Fastlane
sed -i '' "s/com.votrenom.expensetracker/$APP_ID/g" fastlane/Appfile
sed -i '' "s/votre@email.com/$APPLE_EMAIL/g" fastlane/Appfile

echo ""
echo "✅ Configuration terminée !"
echo ""
echo "============================================================"
echo "📋 PROCHAINES ÉTAPES - Configurez ces secrets dans GitHub :"
echo "   Repo GitHub → Settings → Secrets → Actions"
echo ""
echo "   APP_IDENTIFIER       = $APP_ID"
echo "   APPLE_ID             = $APPLE_EMAIL"
echo "   MATCH_GIT_URL        = $MATCH_URL"
echo "   MATCH_PASSWORD       = (mot de passe choisi pour les certificats)"
echo "   APP_STORE_CONNECT_API_KEY = (clé JSON de App Store Connect)"
echo "   TEAM_ID              = (votre Team ID Apple Developer)"
echo "   ITC_TEAM_ID          = (votre ITC Team ID)"
echo "   GIT_PRIVATE_KEY      = (clé SSH pour accéder au repo des certs)"
echo "============================================================"
echo ""
echo "📖 Guide complet : README.md section Déploiement"
