#!/bin/sh

# Fail this script if any subcommand fails.
set -e

# Change working directory to the root of your cloned repo.
cd $CI_PRIMARY_REPOSITORY_PATH

# Restore Flutter and CocoaPods caches
echo "Restoring caches..."
if [ -d "$HOME/flutter_cache" ]; then
  cp -r $HOME/flutter_cache $HOME/.pub-cache
fi
if [ -d "$HOME/cocoapods_cache" ]; then
  cp -r $HOME/cocoapods_cache ~/.cocoapods
fi

# Install Flutter using git.
if [ ! -d "$HOME/flutter" ]; then
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter
fi
export PATH="$PATH:$HOME/flutter/bin"

# Precache Flutter artifacts for iOS.
flutter precache --ios

# Install Flutter dependencies.
flutter pub get

# Cache Flutter dependencies
echo "Caching Flutter dependencies..."
mkdir -p $HOME/flutter_cache
cp -r $HOME/.pub-cache $HOME/flutter_cache

# Install CocoaPods using Homebrew.
HOMEBREW_NO_AUTO_UPDATE=1
brew install cocoapods

# Decrypt configuration files
openssl aes-256-cbc -d -pbkdf2 -in ios/Runner/GoogleService-Info.plist.enc -out ios/Runner/GoogleService-Info.plist -k $GOOGLE_SERVICES_PASSWORD
openssl aes-256-cbc -d -pbkdf2 -in .env.enc -out .env -k $ENV_PASSWORD

# Install CocoaPods dependencies.
cd ios
pod install

# Cache CocoaPods dependencies
echo "Caching CocoaPods dependencies..."
mkdir -p $HOME/cocoapods_cache
cp -r ~/.cocoapods $HOME/cocoapods_cache

exit 0
