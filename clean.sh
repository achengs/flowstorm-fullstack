#!/bin/bash

echo "🧹 Cleaning all generated files and compilation products..."

# Kill any running processes first
./kill-dev.sh

# Remove shadow-cljs compilation artifacts
echo "Removing shadow-cljs compilation artifacts..."
rm -rf public/js/cljs-runtime/
rm -rf public/js/main.js
rm -rf public/js/manifest.edn

# Remove Clojure cache
echo "Removing Clojure cache..."
rm -rf .cpcache/

# Remove node modules (will need npm install after)
echo "Removing node_modules..."
rm -rf node_modules/
rm -rf package-lock.json

# Remove shadow-cljs cache
echo "Removing shadow-cljs cache..."
rm -rf .shadow-cljs/

# Remove repl client debug files
echo "Removing REPL debug files..."
rm -rf repl-client-debug

echo "✅ All generated files cleaned!"
echo ""
echo "To restore dependencies and start development:"
echo "  npm install"
echo "  ./start-dev.sh"