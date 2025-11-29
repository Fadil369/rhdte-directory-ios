# BrainSAIT Unified Dashboard - Complete Setup Guide

## 🎯 What You Have Now

A fully functional unified dashboard that displays:
- ✅ PayLinc payment platform overview
- ✅ All 16 BrainSAIT LINC agents
- ✅ Real-time metrics and monitoring
- ✅ Bilingual interface (Arabic/English)
- ✅ Glass morphism design
- ✅ Responsive layout

## 📁 Project Structure

```
~/UnifiedDashboard/
├── src/
│   ├── index.html      # Main dashboard interface
│   └── app.js          # Application logic and data
├── config/
│   └── .env.example    # Configuration template
├── README.md           # Quick reference
├── launch.sh           # Quick launcher script
└── SETUP_GUIDE.md      # This file
```

## 🚀 Quick Start (3 Steps)

### Step 1: Open the Dashboard
```bash
cd ~/UnifiedDashboard
./launch.sh
```

Choose option 1 to open directly in browser, or option 2 for local server.

### Step 2: Explore the Interface
The dashboard has 5 main tabs:
1. **PayLinc** - Payment platform overview
2. **Healthcare** - Medical workflow agents
3. **Business** - Business intelligence agents
4. **Automation** - DevOps and content agents
5. **System** - Infrastructure monitoring

### Step 3: Toggle Language
Click the language button in top-right corner to switch between English and Arabic.

## 🔗 Integrating with Live PayLinc Services

Currently showing demo data. To connect to live services:

### Option A: API Integration (Recommended)

Edit `src/app.js` and add API calls:

```javascript
// Add this method to dashboardApp()
async fetchLiveData() {
    try {
        // Fetch payment data
        const paymentResponse = await fetch('http://localhost:8021/api/v1/metrics');
        const paymentData = await paymentResponse.json();
        this.paymentChannels = paymentData.channels;

        // Fetch transaction data
        const txResponse = await fetch('http://localhost:8021/api/v1/transactions/recent');
        const txData = await txResponse.json();
        this.recentTransactions = txData.transactions;

        // Fetch agent status
        const agentResponse = await fetch('http://localhost:8000/api/v1/agents/status');
        const agentData = await agentResponse.json();
        this.updateAgentStatus(agentData);
    } catch (error) {
        console.error('Error fetching live data:', error);
    }
},

// Call in init()
init() {
    this.updateDateTime();
    this.fetchLiveData(); // Add this line
    setInterval(() => this.fetchLiveData(), 30000); // Refresh every 30s
}
```

### Option B: WebSocket Integration (Real-time)

For real-time updates:

```javascript
// Add WebSocket connection
connectWebSocket() {
    const ws = new WebSocket('ws://localhost:8000/ws');

    ws.onmessage = (event) => {
        const data = JSON.parse(event.data);

        switch(data.type) {
            case 'payment_update':
                this.updatePaymentMetrics(data.payload);
                break;
            case 'agent_status':
                this.updateAgentStatus(data.payload);
                break;
            case 'transaction':
                this.addTransaction(data.payload);
                break;
        }
    };

    ws.onerror = (error) => {
        console.error('WebSocket error:', error);
    };
}
```

## 🏗️ Deploying the Backend Services

### 1. Using Docker Compose (Easiest)

Create `docker-compose.yml` in project root:

```yaml
version: '3.8'

services:
  # PayLinc Service
  paylinc:
    build: ./paylinc
    ports:
      - "8021:8021"
    environment:
      - STRIPE_API_KEY=${STRIPE_API_KEY}
      - PAYPAL_CLIENT_ID=${PAYPAL_CLIENT_ID}
      - DATABASE_URL=${DATABASE_URL}
    depends_on:
      - postgres
      - redis

  # MasterLINC Orchestrator
  masterlinc:
    build: ./agents/masterlinc
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=${DATABASE_URL}
      - REDIS_URL=${REDIS_URL}
    depends_on:
      - postgres
      - redis

  # PostgreSQL Database
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: brainsait_agents
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  # Redis Cache
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

Then start services:
```bash
docker-compose up -d
```

### 2. Manual Deployment

#### Start Database
```bash
# PostgreSQL
brew install postgresql@15
brew services start postgresql@15
createdb brainsait_agents

# Redis
brew install redis
brew services start redis
```

#### Deploy Agents
```bash
# Clone agent repositories (once available)
cd ~/brainsait-agents
git clone https://github.com/brainsait/paylinc
git clone https://github.com/brainsait/masterlinc
# ... clone all 16 agents

# Start each agent
cd paylinc
npm install
npm start  # Runs on port 8021

cd ../masterlinc
pip install -r requirements.txt
python main.py  # Runs on port 8000
```

## 🌐 Production Deployment with Cloudflare

### 1. Setup Cloudflare Tunnel

```bash
# Install cloudflared
brew install cloudflare/cloudflare/cloudflared

# Authenticate
cloudflared tunnel login

# Create tunnel
cloudflared tunnel create brainsait-linc

# Configure tunnel
cat > ~/.cloudflared/config.yml << EOF
tunnel: <TUNNEL_ID>
credentials-file: /Users/fadil369/.cloudflared/<TUNNEL_ID>.json

ingress:
  - hostname: pay.brainsait.io
    service: http://localhost:8021
  - hostname: doctor.brainsait.io
    service: http://localhost:8010
  - hostname: master.brainsait.io
    service: http://localhost:8000
  # ... add all 16 agents
  - service: http_status:404
EOF

# Run tunnel
cloudflared tunnel run brainsait-linc
```

### 2. DNS Configuration

In Cloudflare dashboard, add CNAME records:
```
pay.brainsait.io     CNAME <TUNNEL_ID>.cfargotunnel.com
doctor.brainsait.io  CNAME <TUNNEL_ID>.cfargotunnel.com
master.brainsait.io  CNAME <TUNNEL_ID>.cfargotunnel.com
# ... for all 16 agents
```

## 📱 Creating Native macOS App

### Using Electron

```bash
cd ~/UnifiedDashboard
npm init -y
npm install electron --save-dev

# Create main.js
cat > main.js << 'EOF'
const { app, BrowserWindow } = require('electron')
const path = require('path')

function createWindow () {
  const win = new BrowserWindow({
    width: 1400,
    height: 900,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true
    },
    titleBarStyle: 'hiddenInset',
    icon: path.join(__dirname, 'icon.png')
  })

  win.loadFile('src/index.html')

  // Open DevTools in development
  if (process.env.NODE_ENV === 'development') {
    win.webContents.openDevTools()
  }
}

app.whenReady().then(createWindow)

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit()
  }
})

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow()
  }
})
EOF

# Update package.json
npm pkg set 'main'='main.js'
npm pkg set 'scripts.start'='electron .'
npm pkg set 'scripts.package'='electron-packager . BrainSAIT --platform=darwin --arch=x64 --out=dist'

# Run app
npm start

# Package for distribution
npm install electron-packager --save-dev
npm run package
```

## 🔒 Security Considerations

### 1. Environment Variables
Never commit `.env` files with real credentials. Use:
```bash
cp config/.env.example .env
# Edit .env with real values
echo ".env" >> .gitignore
```

### 2. HTTPS in Production
Always use HTTPS for production:
- Cloudflare provides free SSL certificates
- Use Let's Encrypt for custom domains

### 3. API Key Management
Store sensitive keys in:
- macOS Keychain
- HashiCorp Vault
- AWS Secrets Manager
- Environment variables (never in code)

## 📊 Monitoring & Analytics

### Add Google Analytics (Optional)

Add to `src/index.html` before `</head>`:

```html
<!-- Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-XXXXXXXXXX');
</script>
```

### Custom Event Tracking

```javascript
// Track agent opens
openAgentDetails(agent) {
    this.selectedAgent = agent;
    this.showAgentModal = true;

    // Track event
    if (typeof gtag !== 'undefined') {
        gtag('event', 'agent_open', {
            'agent_name': agent.name,
            'agent_id': agent.id
        });
    }
}
```

## 🐛 Troubleshooting

### Dashboard Won't Load
1. Check browser console (F12) for errors
2. Verify all CDN resources loaded:
   - Tailwind CSS
   - Alpine.js
   - Chart.js
   - Font Awesome

### Agents Show Offline
1. Verify agent services are running:
   ```bash
   lsof -i :8000  # Check if MasterLINC is running
   lsof -i :8021  # Check if PayLINC is running
   ```

2. Check agent logs:
   ```bash
   tail -f ~/brainsait-agents/masterlinc/logs/app.log
   ```

### Payment Integration Issues
1. Verify API keys in `.env`
2. Check Stripe/PayPal dashboard for webhooks
3. Review payment gateway logs

## 📚 Next Steps

1. **Deploy Backend Services**
   - Set up PostgreSQL and Redis
   - Deploy all 16 agents
   - Configure environment variables

2. **Integrate Payment Gateways**
   - Create Stripe account and get API keys
   - Set up PayPal business account
   - Register for SARIE access (Saudi Arabia)

3. **Healthcare Integration**
   - Register with NPHIES platform
   - Set up FHIR server
   - Configure Saudi MOH compliance

4. **Production Deployment**
   - Set up Cloudflare Tunnels
   - Configure DNS records
   - Enable SSL certificates
   - Set up monitoring and alerts

5. **Mobile Apps**
   - Build iOS app using Capacitor
   - Create Android version
   - Publish to App Store/Play Store

## 📞 Support

Need help? Contact:
- Email: fadil@brainsait.io
- Documentation: brainsait.io/docs
- GitHub Issues: github.com/brainsait/unified-dashboard

## 🎉 You're All Set!

Your unified dashboard is ready to use. Start by running `./launch.sh` and exploring the interface.

Happy monitoring! 🚀
