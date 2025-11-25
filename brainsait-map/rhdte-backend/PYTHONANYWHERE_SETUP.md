# 🐍 BrainSAIT RHDTE - PythonAnywhere Deployment Guide

## Deploy at: https://maplinc.pythonanywhere.com

---

## ✅ Complete Setup Instructions

### Step 1: Create PythonAnywhere Account

1. Go to https://www.pythonanywhere.com
2. Sign up for **FREE** account with username: `maplinc`
3. Confirm your email address

### Step 2: Upload Backend Files

**Option A: Using Git (Recommended)**

Open a **Bash console** on PythonAnywhere:

```bash
cd ~
git clone https://github.com/Fadil369/rhdte-directory-ios.git
cd rhdte-directory-ios/brainsait-map/rhdte-backend
```

**Option B: Manual Upload**

1. Go to **Files** tab on PythonAnywhere
2. Create directory: `/home/maplinc/rhdte-backend/`
3. Upload these files:
   - `main.py`
   - `wsgi.py`
   - `requirements.txt`
   - `utils/` (folder with `__init__.py` and `config.py`)
   - `data/` (folder with `facility_analysis.json`)
   - `static/` (folder with `index.html`)

### Step 3: Create Virtual Environment

In PythonAnywhere **Bash console**:

```bash
cd ~/rhdte-backend  # or ~/rhdte-directory-ios/brainsait-map/rhdte-backend if using git
python3.11 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

Wait for installation to complete (~2-3 minutes).

### Step 4: Create Environment File

```bash
nano .env
```

Add this content:
```env
# Google Maps API Key
GOOGLE_MAPS_API_KEY=AIzaSyDhRh6vGKGsxGDa4w96OSp4_NOGhdF0PJw

# Environment
ENVIRONMENT=production
LOG_LEVEL=INFO

# Security (change this!)
JWT_SECRET_KEY=brainsait-rhdte-production-secret-key-change-me

# Database (optional - using JSON for now)
DATABASE_URL=sqlite:///./rhdte.db
```

Save: Press `Ctrl+X`, then `Y`, then `Enter`

### Step 5: Configure Web App

1. Go to **Web** tab
2. Click **"Add a new web app"**
3. Choose domain: `maplinc.pythonanywhere.com`
4. Select **"Manual configuration"**
5. Choose **"Python 3.11"**
6. Click **"Next"**

### Step 6: Configure WSGI File

1. In **Web** tab, find the **"Code"** section
2. Click on the WSGI configuration file link  
   (Example: `/var/www/maplinc_pythonanywhere_com_wsgi.py`)
3. **Delete all existing content**
4. Replace with:

```python
import sys
import os

# Add your project directory to sys.path
project_home = '/home/maplinc/rhdte-backend'
if project_home not in sys.path:
    sys.path.insert(0, project_home)

# Load environment variables
from dotenv import load_dotenv
env_path = os.path.join(project_home, '.env')
load_dotenv(env_path)

# Import FastAPI app
from main import app

# For ASGI support (if you have Hacker plan)
# application = app

# For free tier, use WSGI adapter
from asgiref.wsgi import WsgiToAsgi
application = WsgiToAsgi(app)
```

5. Click **"Save"**

### Step 7: Set Virtual Environment Path

1. Still in **Web** tab
2. Find **"Virtualenv"** section
3. Enter: `/home/maplinc/rhdte-backend/venv`
4. Click the checkmark ✓

### Step 8: Reload Web App

1. Scroll to top of **Web** tab
2. Click the big green **"Reload maplinc.pythonanywhere.com"** button
3. Wait 10-15 seconds

### Step 9: Test Your Deployment

Open these URLs in your browser:

✅ **Homepage**: https://maplinc.pythonanywhere.com/  
✅ **API Docs**: https://maplinc.pythonanywhere.com/docs  
✅ **Facilities**: https://maplinc.pythonanywhere.com/api/facilities  
✅ **Dashboard**: https://maplinc.pythonanywhere.com/api/dashboard/stats  

**Expected Results:**
- Homepage shows beautiful web interface with live stats
- `/api/facilities` returns JSON array of 20 facilities
- `/docs` shows interactive API documentation

---

## 🧪 Testing from Terminal

```bash
# Health check
curl https://maplinc.pythonanywhere.com/

# Get facilities
curl https://maplinc.pythonanywhere.com/api/facilities | jq

# Get stats
curl https://maplinc.pythonanywhere.com/api/dashboard/stats | jq

# Search via Google Maps
curl -X POST https://maplinc.pythonanywhere.com/api/map/search \
  -H "Content-Type: application/json" \
  -d '{"query": "hospital in riyadh", "radius": 5000}'
```

---

## 📱 Update iOS App

Your iOS app is already configured! Just build and run:

```swift
// Already set in Services/APIService.swift:
private let baseURL = "https://maplinc.pythonanywhere.com/api"
```

Open Xcode → Build → Run on your device → You'll see 20 facilities!

---

## 🐛 Troubleshooting

### Error: "ImportError: No module named 'main'"

**Solution:**
```bash
cd ~/rhdte-backend
source venv/bin/activate
pip install -r requirements.txt --force-reinstall
# Then reload web app in Web tab
```

### Error: "Application failed to load"

**Check error logs:**
```bash
tail -100 /var/log/maplinc.pythonanywhere.com.error.log
```

Common fixes:
- Verify virtualenv path: `/home/maplinc/rhdte-backend/venv`
- Check WSGI file has correct project path
- Ensure all files uploaded correctly

### Error: "No such file or directory: data/facility_analysis.json"

**Solution:**
```bash
# Verify data file exists
ls -la ~/rhdte-backend/data/
# Should show: facility_analysis.json

# If missing, upload from local machine
```

### Web app shows blank page

**Check:**
1. Error logs (see above)
2. WSGI configuration is saved
3. Virtualenv path is correct
4. All dependencies installed

### Can't see logs

```bash
# Access log
tail -50 /var/log/maplinc.pythonanywhere.com.access.log

# Error log
tail -50 /var/log/maplinc.pythonanywhere.com.error.log

# Server log
tail -50 /var/log/maplinc.pythonanywhere.com.server.log
```

---

## 🔄 Updating Your App

When you make code changes:

```bash
# In PythonAnywhere Bash console
cd ~/rhdte-backend

# If using Git:
git pull origin main

# If manually uploading:
# Use Files tab to upload changed files

# Reinstall dependencies if requirements.txt changed
source venv/bin/activate
pip install -r requirements.txt

# Reload web app
# Go to Web tab → Click green "Reload" button
```

---

## 📊 File Structure on PythonAnywhere

```
/home/maplinc/
└── rhdte-backend/
    ├── main.py                  ⭐ FastAPI application
    ├── wsgi.py                  ⭐ PythonAnywhere WSGI config
    ├── requirements.txt         ⭐ Python dependencies
    ├── .env                     ⭐ Environment variables (YOU CREATE)
    ├── venv/                    ⭐ Virtual environment (AUTO-CREATED)
    ├── data/
    │   └── facility_analysis.json
    ├── static/
    │   └── index.html           ⭐ Web interface
    └── utils/
        ├── __init__.py
        └── config.py
```

---

## ✅ Deployment Checklist

- [ ] PythonAnywhere account created (username: `maplinc`)
- [ ] Files uploaded to `/home/maplinc/rhdte-backend/`
- [ ] Virtual environment created (`python3.11 -m venv venv`)
- [ ] Dependencies installed (`pip install -r requirements.txt`)
- [ ] `.env` file created with `GOOGLE_MAPS_API_KEY`
- [ ] WSGI file configured in Web tab
- [ ] Virtualenv path set: `/home/maplinc/rhdte-backend/venv`
- [ ] Web app reloaded (green button)
- [ ] Homepage works: https://maplinc.pythonanywhere.com/
- [ ] API works: https://maplinc.pythonanywhere.com/api/facilities
- [ ] iOS app connects successfully
- [ ] Seeing 20 facilities (not 2 demo ones)

---

## 🎯 Success Criteria

Your deployment is successful when:

1. ✅ https://maplinc.pythonanywhere.com/ shows web interface
2. ✅ https://maplinc.pythonanywhere.com/api/facilities returns 20 facilities
3. ✅ https://maplinc.pythonanywhere.com/docs shows API documentation
4. ✅ iOS app displays facilities on map
5. ✅ Dashboard shows real statistics

---

## 💡 Upgrade to Hacker Plan

**Free Tier Limitations:**
- 100 CPU seconds/day
- MySQL only (no PostgreSQL)
- No SSH access
- Limited ASGI support

**Hacker Plan ($5/month) Benefits:**
- ✅ Unlimited CPU seconds
- ✅ PostgreSQL database
- ✅ SSH access
- ✅ Full ASGI support (better FastAPI performance)
- ✅ 2 web apps
- ✅ More disk space

To upgrade: Dashboard → Account → Upgrade

---

## 🔒 Security Best Practices

### Change JWT Secret

Edit `.env` file:
```env
JWT_SECRET_KEY=your-very-long-random-secret-key-here-use-openssl-rand-hex-32
```

### Generate secure secret:
```bash
python3 -c "import secrets; print(secrets.token_hex(32))"
```

### Restrict CORS (Optional)

Edit `main.py`:
```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://yourdomain.com"],  # Change from "*"
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

---

## 📈 Monitoring

### Check Daily CPU Usage

Dashboard → Your account → CPU usage graph

### View Live Traffic

Web tab → Access/Error logs section → View logs

### Set Up Email Alerts

Account → Email settings → Enable error notifications

---

## 🚀 Next Steps After Deployment

1. ✅ Test all API endpoints
2. ✅ Verify iOS app connectivity
3. ✅ Monitor error logs for first 24 hours
4. 📊 Add more facilities via Google Maps API
5. 🔐 Implement authentication (JWT)
6. 📱 Submit iOS app to TestFlight
7. 🎨 Customize web interface branding
8. 📈 Set up analytics tracking

---

## 📞 Need Help?

**PythonAnywhere Support:**
- Forum: https://www.pythonanywhere.com/forums/
- Help pages: https://help.pythonanywhere.com/
- Email: support@pythonanywhere.com

**Common Issues:**
- Deployment problems → Check error logs first
- Import errors → Verify virtualenv and dependencies
- 404 errors → Check WSGI configuration
- Slow performance → Consider upgrading to Hacker plan

---

## 🎉 Congratulations!

Your BrainSAIT RHDTE backend is now live at:

**https://maplinc.pythonanywhere.com** 🚀

Accessible 24/7 from anywhere in the world!

---

**Last Updated:** November 25, 2025  
**Platform:** PythonAnywhere Free Tier  
**Backend:** FastAPI + Python 3.11  
**Frontend:** iOS (Swift) + Web Interface
