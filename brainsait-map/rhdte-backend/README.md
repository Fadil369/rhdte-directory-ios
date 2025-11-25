# BrainSAIT RHDTE - Backend

FastAPI backend for Riyadh Health Digital Transformation Engine.

## 📁 Project Structure

```
rhdte-backend/
├── main.py                      # FastAPI application
├── wsgi.py                      # PythonAnywhere WSGI config
├── requirements.txt             # Python dependencies
├── .env                         # Environment variables (create this)
├── PYTHONANYWHERE_SETUP.md      # Deployment guide
├── utils/
│   ├── __init__.py
│   └── config.py                # Configuration management
├── data/
│   └── facility_analysis.json   # Facility data
└── static/
    └── index.html               # Web interface
```

## 🚀 Quick Start

### 1. Install Dependencies

```bash
python3.11 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### 2. Create Environment File

Create `.env` file:

```env
# Google Maps API Key
GOOGLE_MAPS_API_KEY=AIzaSyDhRh6vGKGsxGDa4w96OSp4_NOGhdF0PJw

# Environment
ENVIRONMENT=development
DEBUG=True
LOG_LEVEL=INFO

# Security
JWT_SECRET_KEY=your-secret-key-change-in-production

# Database (optional)
DATABASE_URL=sqlite:///./rhdte.db
```

### 3. Add Facility Data

Place your `facility_analysis.json` file in the `data/` directory.

### 4. Run Development Server

```bash
# With uvicorn
uvicorn main:app --reload --host 0.0.0.0 --port 8000

# Or with python
python main.py
```

Visit:
- Web Interface: http://localhost:8000
- API Docs: http://localhost:8000/docs
- Facilities API: http://localhost:8000/api/facilities

## 🌐 Deployment

### PythonAnywhere (Recommended)

See complete guide: [PYTHONANYWHERE_SETUP.md](./PYTHONANYWHERE_SETUP.md)

**Quick Deploy:**
1. Create account at pythonanywhere.com (username: `maplinc`)
2. Upload files to `/home/maplinc/rhdte-backend/`
3. Create venv and install requirements
4. Configure WSGI file
5. Reload web app

Live at: https://maplinc.pythonanywhere.com

### Other Platforms

- **Railway**: `railway up`
- **Render**: Connect GitHub repo
- **Fly.io**: `flyctl deploy`
- **AWS**: See AWS deployment docs

## 📚 API Endpoints

### Health & Info
- `GET /` - Web interface
- `GET /health` - Health check

### Facilities
- `GET /api/facilities` - List all facilities
- `GET /api/facilities/{id}` - Get facility by ID
- `GET /api/districts` - List all districts
- `GET /api/facility-types` - List facility types

### Analytics
- `GET /api/dashboard/stats` - Dashboard statistics

### Google Maps
- `POST /api/map/search` - Search places
- `GET /api/map/place/{id}` - Get place details

## 🔧 Configuration

All configuration is managed through environment variables in `.env` file:

- `GOOGLE_MAPS_API_KEY` - Required for Google Maps integration
- `ENVIRONMENT` - `development` or `production`
- `DEBUG` - Enable/disable debug mode
- `LOG_LEVEL` - Logging level (INFO, DEBUG, ERROR)
- `JWT_SECRET_KEY` - Secret key for JWT tokens
- `CORS_ORIGINS` - Allowed CORS origins (default: `["*"]`)

## 🧪 Testing

```bash
# Install test dependencies
pip install pytest pytest-asyncio

# Run tests
pytest
```

## 📖 Documentation

- **API Docs**: Available at `/docs` (Swagger UI)
- **ReDoc**: Available at `/redoc`
- **Deployment Guide**: [PYTHONANYWHERE_SETUP.md](./PYTHONANYWHERE_SETUP.md)

## 🔒 Security

- JWT authentication for protected endpoints
- CORS configuration
- Environment-based secrets
- SQL injection prevention (parameterized queries)
- Input validation with Pydantic

## 📊 Data Format

Facility data should be in JSON format:

```json
{
  "detailed_results": [
    {
      "facility": {
        "place_id": "...",
        "name": "...",
        "address": "...",
        "location": {"lat": 0.0, "lng": 0.0},
        "rating": 4.5,
        "review_count": 100
      },
      "maturity_analysis": {
        "score": 85,
        "level": "DIGITAL_NATIVE"
      }
    }
  ]
}
```

## 🛠️ Development

### Code Style
- Follow PEP 8
- Use type hints
- Document functions with docstrings

### Project Guidelines
- Keep functions focused and small
- Use Pydantic for data validation
- Handle errors gracefully
- Log important events

## 📝 License

Copyright © 2025 BrainSAIT. All rights reserved.

## 🤝 Support

For deployment help, see PYTHONANYWHERE_SETUP.md or contact support.

---

**Built with ❤️ using FastAPI**
