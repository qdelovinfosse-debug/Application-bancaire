# expense_tracker

Application de suivi des dépenses pour iOS et Android

## 🚀 Fonctionnalités

- ✅ Ajouter des dépenses manuellement (montant, catégorie, date, description)
- ✅ Liste complète de toutes les dépenses
- ✅ Modifier ou supprimer des dépenses
- ✅ Statistiques avec graphique en camembert
- ✅ 6 catégories prédéfinies : Alimentation, Transport, Logement, Loisirs, Santé, Autres
- ✅ Stockage local avec SQLite
- ✅ Interface en français
- ✅ Design moderne et intuitif

## 📱 Installation

### Prérequis

1. **Installer Flutter** : [https://docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install)
2. **Xcode** (pour iOS) : Disponible sur le Mac App Store
3. **Configurer Xcode** :
   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   sudo xcodebuild -runFirstLaunch
   ```

### Étapes d'installation

1. **Installer les dépendances** :
   ```bash
   flutter pub get
   ```

2. **Vérifier que tout est prêt** :
   ```bash
   flutter doctor
   ```

3. **Lancer sur simulateur iOS** :
   ```bash
   flutter run
   ```

4. **Ou lancer sur votre iPhone** :
   - Connectez votre iPhone via USB
   - Activez le mode développeur sur votre iPhone (Réglages > Confidentialité et sécurité > Mode développeur)
   - Exécutez :
   ```bash
   flutter run
   ```

## 🏗️ Structure du projet

```
lib/
├── main.dart                    # Point d'entrée
├── models/
│   └── expense.dart            # Modèle de données
├── screens/
│   ├── home_screen.dart        # Écran principal
│   ├── add_expense_screen.dart # Formulaire d'ajout/modification
│   └── statistics_screen.dart  # Page des statistiques
└── utils/
    ├── database_helper.dart    # Gestion SQLite
    └── constants.dart          # Constantes (catégories, couleurs)
```

## 🎨 Captures d'écran

### Écran principal
- Vue de toutes les dépenses
- Total des dépenses en haut
- Bouton + pour ajouter une dépense

### Ajouter une dépense
- Montant en euros
- Sélection de catégorie avec icône
- Description
- Sélection de date

### Statistiques
- Graphique en camembert
- Liste détaillée par catégorie
- Pourcentages et montants

## 🛠️ Technologies utilisées

- **Flutter** : Framework UI
- **SQLite** : Base de données locale
- **fl_chart** : Graphiques
- **intl** : Formatage des dates et nombres
- **Material Design 3** : Design system

## 📝 Utilisation

1. **Ajouter une dépense** : Appuyez sur le bouton + en bas à droite
2. **Modifier** : Appuyez sur une dépense dans la liste
3. **Supprimer** : Appuyez longuement sur une dépense
4. **Voir les stats** : Appuyez sur l'icône graphique en haut à droite

## 🔧 Personnalisation

### Ajouter une catégorie

Modifiez [lib/utils/constants.dart](lib/utils/constants.dart) :

```dart
static const List<String> categories = [
  'Alimentation',
  'Transport',
  // Ajoutez votre catégorie ici
  'Ma Nouvelle Catégorie',
];
```

## 📦 Build pour production

### iOS

```bash
flutter build ios
```

Ensuite, ouvrez Xcode et archivez l'application pour la publier sur l'App Store.

### Android

```bash
flutter build apk
```

## 🐛 Dépannage

Si vous rencontrez des problèmes :

1. Nettoyez le projet :
   ```bash
   flutter clean
   flutter pub get
   ```

2. Vérifiez les outils installés :
   ```bash
   flutter doctor -v
   ```

3. Pour iOS, réinstallez les pods :
   ```bash
   cd ios
   pod install
   cd ..
   ```

## 📄 Licence

Projet personnel - Libre d'utilisation
