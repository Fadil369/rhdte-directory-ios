# BrainSAIT - RHDTE Main API
# Riyadh Health Digital Transformation Engine

import json
import os
from pathlib import Path
from datetime import datetime
from typing import List, Optional

from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from pydantic import BaseModel
import googlemaps

# Import utils
from utils.config import settings

# Initialize Google Maps Client
gmaps = None
if settings.GOOGLE_MAPS_API_KEY:
    try:
        gmaps = googlemaps.Client(key=settings.GOOGLE_MAPS_API_KEY)
        print("✅ Google Maps client initialized successfully")
    except Exception as e:
        print(f"❌ Failed to initialize Google Maps client: {e}")

app = FastAPI(
    title=settings.API_TITLE,
    description=settings.API_DESCRIPTION,
    version=settings.API_VERSION
)

# CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount static files (web interface)
static_dir = Path(__file__).parent / "static"
if static_dir.exists():
    app.mount("/static", StaticFiles(directory=str(static_dir)), name="static")

# ============================================================================
# Request/Response Models
# ============================================================================

class FacilityModel(BaseModel):
    id: str
    placeId: str
    nameEn: str
    nameAr: str
    type: str
    address: str
    district: str
    city: str
    latitude: float
    longitude: float
    phone: Optional[str] = None
    website: Optional[str] = None
    email: Optional[str] = None
    rating: Optional[float] = None
    reviewCount: int = 0
    isOpen: Optional[bool] = None
    openingHours: Optional[List[str]] = None
    services: List[str] = []
    insuranceAccepted: List[str] = []
    languages: List[str] = ["Arabic", "English"]
    hasEmergency: bool = False
    is24Hours: bool = False
    hasOnlineBooking: bool = False
    hasWhatsApp: bool = False
    digitalScore: Optional[int] = None
    maturityLevel: Optional[str] = None

class DistrictInfo(BaseModel):
    key: str
    nameAr: str
    nameEn: str
    facilityCount: int
    avgRating: float
    avgDigitalScore: float

class FacilityTypeInfo(BaseModel):
    key: str
    nameEn: str
    nameAr: str
    icon: str
    count: int

class DashboardStats(BaseModel):
    totalFacilities: int
    totalDistricts: int
    avgRating: float
    avgDigitalScore: float
    facilityTypeBreakdown: dict
    maturityDistribution: dict
    topRatedFacilities: List[dict]
    digitalLeaders: List[dict]

class MapSearchRequest(BaseModel):
    query: str
    location: Optional[str] = None
    radius: Optional[int] = 5000
    type: Optional[str] = "hospital"

# ============================================================================
# Helper Functions
# ============================================================================

def load_facilities_data():
    """Load facility data from JSON file"""
    data_path = Path(__file__).parent / "data" / "facility_analysis.json"
    
    if not data_path.exists():
        print(f"⚠️ Data file not found: {data_path}")
        return []
    
    try:
        with open(data_path, "r", encoding="utf-8") as f:
            data = json.load(f)
        
        results = []
        for item in data.get("detailed_results", []):
            facility = item.get("facility", {})
            analysis = item.get("maturity_analysis", {})
            
            f_type = item.get("facility_type", "Medical Center")
            mapped_type = "Hospital" if f_type == "Hospital" else "Medical Center"
            
            fac_obj = {
                "id": facility.get("place_id", ""),
                "placeId": facility.get("place_id", ""),
                "nameEn": facility.get("name", ""),
                "nameAr": facility.get("name", ""),
                "type": mapped_type,
                "address": facility.get("address", ""),
                "district": facility.get("district", "Riyadh"),
                "city": "Riyadh",
                "latitude": facility.get("location", {}).get("lat", 0.0),
                "longitude": facility.get("location", {}).get("lng", 0.0),
                "phone": facility.get("phone"),
                "website": facility.get("website"),
                "email": None,
                "rating": facility.get("rating"),
                "reviewCount": facility.get("review_count", 0),
                "isOpen": None,
                "openingHours": None,
                "services": [],
                "insuranceAccepted": [],
                "languages": ["Arabic", "English"],
                "hasEmergency": f_type == "Hospital",
                "is24Hours": False,
                "hasOnlineBooking": False,
                "hasWhatsApp": False,
                "digitalScore": int(analysis.get("score", 0)),
                "maturityLevel": analysis.get("level", "OFF_GRID")
            }
            results.append(fac_obj)
        
        print(f"✅ Loaded {len(results)} facilities from data file")
        return results
        
    except Exception as e:
        print(f"❌ Error loading facilities: {e}")
        return []

# ============================================================================
# API Endpoints
# ============================================================================

@app.get("/")
async def root():
    """Root endpoint - Serve web interface or return API info"""
    static_file = Path(__file__).parent / "static" / "index.html"
    
    if static_file.exists():
        return FileResponse(str(static_file))
    
    return {
        "service": "BrainSAIT RHDTE",
        "status": "operational",
        "version": settings.API_VERSION,
        "timestamp": datetime.utcnow().isoformat(),
        "endpoints": {
            "facilities": "/api/facilities",
            "districts": "/api/districts",
            "dashboard": "/api/dashboard/stats",
            "docs": "/docs"
        }
    }

@app.get("/health")
async def health_check():
    """Health check endpoint for monitoring"""
    return {
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat(),
        "google_maps": "connected" if gmaps else "not_configured"
    }

@app.get("/api/facilities", response_model=List[FacilityModel])
async def get_facilities(
    district: Optional[str] = None,
    type: Optional[str] = None,
    min_rating: Optional[float] = Query(None, alias="min_rating")
):
    """Get all facilities with optional filtering"""
    facilities = load_facilities_data()
    
    # Apply filters
    if district:
        facilities = [f for f in facilities if district.lower() in f["district"].lower()]
    
    if type:
        facilities = [f for f in facilities if type.lower() == f["type"].lower()]
    
    if min_rating is not None:
        facilities = [f for f in facilities if (f.get("rating") or 0) >= min_rating]
    
    return facilities

@app.get("/api/facilities/{facility_id}", response_model=FacilityModel)
async def get_facility_by_id(facility_id: str):
    """Get a specific facility by ID"""
    facilities = load_facilities_data()
    
    for facility in facilities:
        if facility["id"] == facility_id:
            return facility
    
    raise HTTPException(status_code=404, detail="Facility not found")

@app.get("/api/districts")
async def get_districts():
    """Get all districts with statistics"""
    facilities = load_facilities_data()
    
    district_data = {}
    for facility in facilities:
        district = facility["district"]
        if district not in district_data:
            district_data[district] = {
                "facilities": [],
                "ratings": [],
                "scores": []
            }
        district_data[district]["facilities"].append(facility)
        if facility.get("rating"):
            district_data[district]["ratings"].append(facility["rating"])
        if facility.get("digitalScore"):
            district_data[district]["scores"].append(facility["digitalScore"])
    
    districts = []
    for key, data in district_data.items():
        avg_rating = sum(data["ratings"]) / len(data["ratings"]) if data["ratings"] else 0.0
        avg_score = sum(data["scores"]) / len(data["scores"]) if data["scores"] else 0.0
        
        districts.append({
            "key": key,
            "nameAr": key,
            "nameEn": key,
            "facilityCount": len(data["facilities"]),
            "avgRating": round(avg_rating, 1),
            "avgDigitalScore": round(avg_score, 1)
        })
    
    districts.sort(key=lambda x: x["facilityCount"], reverse=True)
    
    return {"districts": districts}

@app.get("/api/facility-types")
async def get_facility_types():
    """Get all facility types with counts"""
    facilities = load_facilities_data()
    
    type_config = {
        "Hospital": {"nameAr": "مستشفى", "icon": "cross.circle.fill"},
        "Clinic": {"nameAr": "عيادة", "icon": "stethoscope"},
        "Medical Center": {"nameAr": "مركز طبي", "icon": "cross.case.fill"},
        "Dental Clinic": {"nameAr": "عيادة أسنان", "icon": "mouth.fill"},
        "Pharmacy": {"nameAr": "صيدلية", "icon": "pills.fill"},
    }
    
    type_counts = {}
    for facility in facilities:
        f_type = facility["type"]
        type_counts[f_type] = type_counts.get(f_type, 0) + 1
    
    facility_types = []
    for type_key, count in type_counts.items():
        config = type_config.get(type_key, {"nameAr": type_key, "icon": "building.fill"})
        facility_types.append({
            "key": type_key,
            "nameEn": type_key,
            "nameAr": config["nameAr"],
            "icon": config["icon"],
            "count": count
        })
    
    facility_types.sort(key=lambda x: x["count"], reverse=True)
    
    return {"facilityTypes": facility_types}

@app.get("/api/dashboard/stats", response_model=DashboardStats)
async def get_dashboard_stats():
    """Get comprehensive dashboard statistics"""
    facilities = load_facilities_data()
    
    if not facilities:
        return {
            "totalFacilities": 0,
            "totalDistricts": 0,
            "avgRating": 0.0,
            "avgDigitalScore": 0.0,
            "facilityTypeBreakdown": {},
            "maturityDistribution": {},
            "topRatedFacilities": [],
            "digitalLeaders": []
        }
    
    districts = set(f["district"] for f in facilities)
    ratings = [f["rating"] for f in facilities if f.get("rating")]
    scores = [f["digitalScore"] for f in facilities if f.get("digitalScore")]
    
    type_breakdown = {}
    for f in facilities:
        type_breakdown[f["type"]] = type_breakdown.get(f["type"], 0) + 1
    
    maturity_dist = {}
    for f in facilities:
        level = f.get("maturityLevel") or "UNKNOWN"
        maturity_dist[level] = maturity_dist.get(level, 0) + 1
    
    rated_facilities = [f for f in facilities if f.get("rating")]
    rated_facilities.sort(key=lambda x: (x["rating"], x["reviewCount"]), reverse=True)
    top_rated = [
        {
            "id": f["id"],
            "name": f["nameEn"],
            "rating": f["rating"],
            "reviewCount": f["reviewCount"],
            "type": f["type"]
        }
        for f in rated_facilities[:5]
    ]
    
    scored_facilities = [f for f in facilities if f.get("digitalScore")]
    scored_facilities.sort(key=lambda x: x["digitalScore"], reverse=True)
    digital_leaders = [
        {
            "id": f["id"],
            "name": f["nameEn"],
            "digitalScore": f["digitalScore"],
            "maturityLevel": f["maturityLevel"],
            "type": f["type"]
        }
        for f in scored_facilities[:5]
    ]
    
    return {
        "totalFacilities": len(facilities),
        "totalDistricts": len(districts),
        "avgRating": round(sum(ratings) / len(ratings), 1) if ratings else 0.0,
        "avgDigitalScore": round(sum(scores) / len(scores), 1) if scores else 0.0,
        "facilityTypeBreakdown": type_breakdown,
        "maturityDistribution": maturity_dist,
        "topRatedFacilities": top_rated,
        "digitalLeaders": digital_leaders
    }

# ============================================================================
# Google Maps Integration
# ============================================================================

@app.post("/api/map/search")
async def search_places(request: MapSearchRequest):
    """Search places using Google Maps Places API"""
    if not gmaps:
        raise HTTPException(
            status_code=503,
            detail="Google Maps service not configured. Please set GOOGLE_MAPS_API_KEY in .env file"
        )
    
    try:
        location_tuple = None
        if request.location:
            lat, lng = map(float, request.location.split(","))
            location_tuple = (lat, lng)
        
        places_result = gmaps.places(
            query=request.query,
            location=location_tuple,
            radius=request.radius,
            type=request.type
        )
        
        return places_result
        
    except Exception as e:
        print(f"❌ Google Maps Search Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/map/place/{place_id}")
async def get_place_details(place_id: str):
    """Get detailed information about a place from Google Maps"""
    if not gmaps:
        raise HTTPException(
            status_code=503,
            detail="Google Maps service not configured"
        )
    
    try:
        place_details = gmaps.place(
            place_id=place_id,
            fields=[
                "name", "formatted_address", "geometry",
                "formatted_phone_number", "website", "rating",
                "user_ratings_total", "opening_hours", "reviews"
            ]
        )
        return place_details
        
    except Exception as e:
        print(f"❌ Google Maps Details Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

# ============================================================================
# Startup Event
# ============================================================================

@app.on_event("startup")
async def startup_event():
    """Run on application startup"""
    print("=" * 60)
    print("🏥 BrainSAIT RHDTE API Starting...")
    print("=" * 60)
    print(f"Environment: {settings.ENVIRONMENT}")
    print(f"API Version: {settings.API_VERSION}")
    print(f"Google Maps: {'✅ Configured' if gmaps else '❌ Not Configured'}")
    
    # Load data to verify
    facilities = load_facilities_data()
    print(f"Facilities: {len(facilities)} loaded")
    print("=" * 60)
    print("✅ Server ready!")
    print("📚 API Docs: /docs")
    print("�� Web Interface: /")
    print("=" * 60)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
