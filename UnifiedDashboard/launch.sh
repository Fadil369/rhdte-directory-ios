#!/bin/bash

# BrainSAIT Unified Dashboard Launcher
# Quick launch script for macOS

echo "🧠 BrainSAIT Unified Dashboard"
echo "================================"
echo ""

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DASHBOARD_DIR="$SCRIPT_DIR/src"

# Check if src directory exists
if [ ! -d "$DASHBOARD_DIR" ]; then
    echo "❌ Dashboard directory not found!"
    echo "   Expected: $DASHBOARD_DIR"
    exit 1
fi

echo "📁 Dashboard location: $DASHBOARD_DIR"
echo ""

# Function to open in browser
open_in_browser() {
    local html_file="$DASHBOARD_DIR/index.html"
    
    if [ -f "$html_file" ]; then
        echo "🌐 Opening dashboard in browser..."
        open "$html_file"
        echo "✅ Dashboard opened!"
    else
        echo "❌ index.html not found!"
        exit 1
    fi
}

# Function to start local server
start_server() {
    echo "🚀 Starting local development server..."
    echo "   URL: http://localhost:8080"
    echo ""
    echo "📝 Press Ctrl+C to stop the server"
    echo ""
    
    cd "$DASHBOARD_DIR"
    
    # Try python3 first
    if command -v python3 &> /dev/null; then
        python3 -m http.server 8080
    # Fall back to python2
    elif command -v python &> /dev/null; then
        python -m SimpleHTTPServer 8080
    # Try php if available
    elif command -v php &> /dev/null; then
        php -S localhost:8080
    else
        echo "❌ No suitable server found!"
        echo "   Please install Python 3 or use the file:// option"
        exit 1
    fi
}

# Menu
echo "Choose launch method:"
echo "  1) Open directly in browser (file://)"
echo "  2) Start local server (http://localhost:8080)"
echo ""
read -p "Enter choice [1-2]: " choice

case $choice in
    1)
        open_in_browser
        ;;
    2)
        start_server
        ;;
    *)
        echo "❌ Invalid choice"
        exit 1
        ;;
esac
