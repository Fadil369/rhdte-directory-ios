"""
BrainSAIT RHDTE - PythonAnywhere WSGI Configuration
Deploy at: https://maplinc.pythonanywhere.com

SETUP INSTRUCTIONS:
1. Upload all files to: /home/maplinc/rhdte-backend/
2. Create virtualenv: python3.11 -m venv venv
3. Install deps: source venv/bin/activate && pip install -r requirements.txt
4. Create .env file with GOOGLE_MAPS_API_KEY
5. Set virtualenv path in Web tab: /home/maplinc/rhdte-backend/venv
6. Point WSGI file to this configuration
7. Reload web app
"""

import sys
import os

# Add project directory to path
project_home = '/home/maplinc/rhdte-backend'
if project_home not in sys.path:
    sys.path.insert(0, project_home)

# Load environment variables
from dotenv import load_dotenv
env_path = os.path.join(project_home, '.env')
load_dotenv(env_path)

# Import FastAPI app
from main import app

# BRAINSAIT: PythonAnywhere WSGI/ASGI compatibility
# For ASGI support (Hacker plan), use app directly
# For WSGI (free tier), use adapter below

try:
    # Try ASGI first (Hacker plan)
    application = app
    print("✅ Running in ASGI mode (Hacker plan)")
except Exception as e:
    # Fallback to WSGI adapter (Free tier)
    print(f"⚠️ ASGI not available, using WSGI adapter: {e}")
    from asgiref.wsgi import WsgiToAsgi
    application = WsgiToAsgi(app)
