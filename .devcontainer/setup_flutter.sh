#!/bin/bash
set -e

# Install dependencies
sudo apt-get update
sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa

# Install Flutter
git clone https://github.com/flutter/flutter.git -b stable $HOME/flutter

# Add to PATH
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> $HOME/.bashrc

# Activate web support
$HOME/flutter/bin/flutter config --enable-web
$HOME/flutter/bin/flutter doctor
