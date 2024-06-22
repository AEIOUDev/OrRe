# Decrypts the encrypted files in the project

echo -e "Decrypting dependencies...\n"

# Prompt user for password
echo -e "\nEnter password for decryption GOOGLE_SERVICES_PASSWORD:"
read -s GOOGLE_SERVICES_PASSWORD

echo -e "\nEnter password for decryption ORRE_KEY_PASSWORD:"
read -s ORRE_KEY_PASSWORD

echo -e "\nEnter password for decryption ORRE_PROPERTIES_PASSWORD:"
read -s ORRE_PROPERTIES_PASSWORD

echo -e "\nEnter password for decryption FASTLANE_PASSWORD:"
read -s FASTLANE_PASSWORD

echo -e "\nEnter password for decryption FIREBASE_PASSWORD:"
read -s FIREBASE_PASSWORD

echo -e "\nEnter password for decryption ENV_PASSWORD:"
read -s ENV_PASSWORD


cd ..
openssl aes-256-cbc -d -pbkdf2 -in android/app/google-services.json.enc -out android/app/google-services.json -k $GOOGLE_SERVICES_PASSWORD
openssl aes-256-cbc -d -pbkdf2 -in android/app/orre_key.jks.enc -out android/app/orre_key.jks -k $ORRE_KEY_PASSWORD
openssl aes-256-cbc -d -pbkdf2 -in android/key.properties.enc -out android/key.properties -k $ORRE_PROPERTIES_PASSWORD
openssl aes-256-cbc -d -pbkdf2 -in android/fastlane/fastlane.json.enc -out android/fastlane/fastlane.json -k $FASTLANE_PASSWORD
openssl aes-256-cbc -d -pbkdf2 -in ios/Runner/GoogleService-Info.plist.enc -out ios/Runner/GoogleService-Info.plist -k $GOOGLE_SERVICES_PASSWORD
openssl aes-256-cbc -d -pbkdf2 -in ios/firebase_app_id_file.json.enc -out ios/firebase_app_id_file.json -k $FIREBASE_PASSWORD
openssl aes-256-cbc -d -pbkdf2 -in .env.enc -out .env -k $ENV_PASSWORD

# Check if openssl command was successful
if [ $? -ne 0 ]; then
  echo "Decryption failed."
  exit 2
fi