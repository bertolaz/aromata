#!/bin/bash

# Script to copy icons from assets/icons to web/icons for PWA
# Run this script after updating icons in assets/icons

SOURCE_DIR="assets/icons"
WEB_DIR="web/icons"

# Create web/icons directory if it doesn't exist
mkdir -p "$WEB_DIR"

# Copy iOS 1024 icon as 512x512 for web
if [ -f "$SOURCE_DIR/ios_1024.png" ]; then
  cp "$SOURCE_DIR/ios_1024.png" "$WEB_DIR/Icon-512.png"
  echo "Copied ios_1024.png to Icon-512.png"
fi

# Copy iOS 60 icon (120x120) as 192x192 for web (or use a different size)
# iOS 60 @2x = 120px, @3x = 180px, so we'll use 1024 and scale, or use 60@3x if available
# For now, let's use ios_1024 and create 192 from it, or copy ios_60
if [ -f "$SOURCE_DIR/ios_60.png" ]; then
  cp "$SOURCE_DIR/ios_60.png" "$WEB_DIR/Icon-192.png"
  echo "Copied ios_60.png to Icon-192.png"
elif [ -f "$SOURCE_DIR/ios_1024.png" ]; then
  # Fallback: copy 1024 and note that it should be resized
  cp "$SOURCE_DIR/ios_1024.png" "$WEB_DIR/Icon-192.png"
  echo "Copied ios_1024.png to Icon-192.png (should be resized to 192x192)"
fi

# For maskable icons, use the same source icons
if [ -f "$SOURCE_DIR/ios_1024.png" ]; then
  cp "$SOURCE_DIR/ios_1024.png" "$WEB_DIR/Icon-maskable-512.png"
  echo "Copied ios_1024.png to Icon-maskable-512.png"
fi

if [ -f "$SOURCE_DIR/ios_60.png" ]; then
  cp "$SOURCE_DIR/ios_60.png" "$WEB_DIR/Icon-maskable-192.png"
  echo "Copied ios_60.png to Icon-maskable-192.png"
elif [ -f "$SOURCE_DIR/ios_1024.png" ]; then
  cp "$SOURCE_DIR/ios_1024.png" "$WEB_DIR/Icon-maskable-192.png"
  echo "Copied ios_1024.png to Icon-maskable-192.png (should be resized to 192x192)"
fi

echo "Icon copying complete!"

