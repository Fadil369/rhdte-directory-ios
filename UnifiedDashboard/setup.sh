#!/bin/bash

# BrainSAIT Unified Dashboard Setup Script
# Initializes all dependencies and services

set -e

echo "🧠 BrainSAIT Unified Dashboard - Setup"
echo "======================================"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "⚠️  Warning: This dashboard is optimized for macOS"
fi

# Create Python virtual environment
echo -e "${BLUE}Setting up Python environment...${NC}"
cd backend
python3 -m venv venv
source venv/bin/activate

# Install Python dependencies
echo -e "${BLUE}Installing Python dependencies...${NC}"
cat > requirements.txt << 'EOF'
fastapi>=0.104.0
uvicorn[standard]>=0.24.0
websockets>=12.0
httpx>=0.25.0
pydantic>=2.5.0
python-dotenv>=1.0.0
sqlite-utils>=3.35
EOF

pip install --upgrade pip
pip install -r requirements.txt

# Setup database
echo -e "${BLUE}Initializing database...${NC}"
python -c "
import sqlite3
conn = sqlite3.connect('dashboard.db')
c = conn.cursor()

# Create tables
c.execute('''CREATE TABLE IF NOT EXISTS payments
             (id TEXT PRIMARY KEY, gateway TEXT, amount REAL, 
              currency TEXT, status TEXT, timestamp DATETIME, metadata TEXT)''')

c.execute('''CREATE TABLE IF NOT EXISTS agent_status
             (agent_id TEXT PRIMARY KEY, name TEXT, status TEXT, 
              health TEXT, last_heartbeat DATETIME, metrics TEXT)''')

c.execute('''CREATE TABLE IF NOT EXISTS workflows
             (id TEXT PRIMARY KEY, name TEXT, status TEXT, agent_id TEXT,
              created_at DATETIME, updated_at DATETIME, data TEXT)''')

# Insert sample data for demonstration
import json
from datetime import datetime

sample_agents = [
    ('masterlinc', 'MasterLINC', 'active', 'healthy', datetime.now().isoformat(), '{}'),
    ('authlinc', 'AuthLINC', 'active', 'healthy', datetime.now().isoformat(), '{}'),
    ('doctorlinc', 'DoctorLINC', 'active', 'healthy', datetime.now().isoformat(), '{}'),
    ('nurslinc', 'NurseLINC', 'active', 'healthy', datetime.now().isoformat(), '{}'),
    ('paylinc', 'PayLINC', 'active', 'healthy', datetime.now().isoformat(), '{}')
]

c.executemany('INSERT OR REPLACE INTO agent_status VALUES (?,?,?,?,?,?)', sample_agents)

conn.commit()
conn.close()
print('✅ Database initialized')
"

# Create environment file
echo -e "${BLUE}Creating environment configuration...${NC}"
cat > .env << 'EOF'
# BrainSAIT Unified Dashboard Configuration

# API Keys
PAYLINC_API_KEY=your_paylinc_api_key_here
STRIPE_API_KEY=your_stripe_key_here
PAYPAL_CLIENT_ID=your_paypal_client_id_here
PAYPAL_CLIENT_SECRET=your_paypal_secret_here

# Database
DATABASE_URL=sqlite:///dashboard.db

# Server
HOST=0.0.0.0
PORT=8080

# Security
JWT_SECRET=your_jwt_secret_here

# Features
ENABLE_WEBSOCKETS=true
ENABLE_PAYLINC=true
ENABLE_AGENTS_MONITORING=true
EOF

echo -e "${GREEN}✅ Backend setup complete${NC}"

cd ..

# SwiftUI macOS app setup
echo -e "${BLUE}Setting up macOS app...${NC}"
if command -v xcodebuild &> /dev/null; then
    echo "✅ Xcode detected"
    
    # Create Xcode project structure if not exists
    mkdir -p frontend/UnifiedDashboard.xcodeproj
    
    echo "ℹ️  To build the macOS app:"
    echo "   1. Open frontend/UnifiedDashboard.xcodeproj in Xcode"
    echo "   2. Select 'My Mac' as destination"
    echo "   3. Press Cmd+B to build"
else
    echo "⚠️  Xcode not found. Install Xcode from App Store to build the macOS app"
fi

# Create run script
cat > run-dashboard.sh << 'EOF'
#!/bin/bash

echo "🚀 Starting BrainSAIT Unified Dashboard"

# Start backend
cd backend
source venv/bin/activate
echo "Starting backend server on http://localhost:8080"
python main.py &
BACKEND_PID=$!

# Wait for backend to be ready
sleep 3

echo "✅ Dashboard is running!"
echo "   Backend API: http://localhost:8080"
echo "   API Docs: http://localhost:8080/docs"
echo "   WebSocket: ws://localhost:8080/ws/dashboard"
echo ""
echo "Press Ctrl+C to stop"

# Cleanup on exit
trap "kill $BACKEND_PID" EXIT

# Keep script running
wait $BACKEND_PID
EOF

chmod +x run-dashboard.sh

echo ""
echo -e "${GREEN}🎉 Setup Complete!${NC}"
echo ""
echo "📝 Next steps:"
echo "   1. Edit backend/.env with your API keys"
echo "   2. Run: ./run-dashboard.sh"
echo "   3. Open http://localhost:8080 in your browser"
echo "   4. (Optional) Build macOS app with Xcode"
echo ""
echo "📚 Documentation: ./docs/"
echo ""
