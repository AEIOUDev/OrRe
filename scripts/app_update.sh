#!/bin/bash

echo -e "Starting web update process...\n"

# 현재 작업 중인 경로 확인
echo -e "Current directory: $(pwd)\n"

# 만약 현재 작업 중인 경로가 프로젝트 루트가 아니라면 프로젝트 루트로 이동
if [ ! -f "pubspec.yaml" ]; then
  echo "Moving to project root..."
  cd ..
fi

# license 업데이트
echo -e "Updating licenses...\n"
flutter pub run flutter_oss_licenses:generate.dart

# Read current version and build number from pubspec.yaml
current_version=$(grep 'version: ' pubspec.yaml | sed 's/version: //')
major=$(echo $current_version | cut -d '.' -f1)
sub=$(echo $current_version | cut -d '.' -f2)
minor=$(echo $current_version | cut -d '.' -f3 | cut -d '+' -f1)
build=$(echo $current_version | cut -d '+' -f2)

# Prompt user for version update choice
echo -e "\nSelect the version update type(Now Version: $current_version):"
echo "1: Main Version Update (+1.x.x)"
echo "2: Sub Version Update (x.+1.x)"
echo "3: Minor Version Update (x.x.+1)"
echo "4: No Update Version"
read -p "Enter choice (1-4): " choice


# Update version based on user input
case $choice in
  1) # Main version update
    let major+=1
    sub=0
    minor=0
    ;;
  2) # Sub version update
    let sub+=1
    minor=0
    ;;
  3) # Minor version update
    let minor+=1
    ;;
  4) # No version update
    echo "No version update."
    let build-=1
    ;;
  *)
    echo "Invalid choice."
    exit 1
    ;;
esac

# Increment build number
let build+=1

# New version and build string
new_version="${major}.${sub}.${minor}+${build}"

# Update pubspec.yaml with new version
sed -i '' "s/version: .*/version: ${new_version}/" pubspec.yaml

# Encrypt the web/index.html file
echo -e "\nEnter password for encryption:"
read -s password
openssl aes-256-cbc -pbkdf2 -in .env -out .env.enc -k $password

# Check if openssl command was successful
if [ $? -ne 0 ]; then
  echo "Encryption failed."
  exit 2
fi

# Commit Message
read -p "Enter commit message: " commit_message

# Git commit and push
git add .
echo "[${new_version}] ${commit_message}" > .git/COMMIT_EDITMSG
git commit -F .git/COMMIT_EDITMSG
git push origin myknow

# Confirm completion
echo -e "\nVersion updated to ${new_version} and changes pushed to branch 'myknow'."
