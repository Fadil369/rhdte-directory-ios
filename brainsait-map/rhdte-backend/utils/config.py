# BrainSAIT RHDTE - Configuration Management
from pydantic_settings import BaseSettings
from typing import Optional

class Settings(BaseSettings):
    """Application settings loaded from environment variables"""
    
    # Environment
    ENVIRONMENT: str = "development"
    DEBUG: bool = True
    LOG_LEVEL: str = "INFO"
    
    # Google Maps API
    GOOGLE_MAPS_API_KEY: Optional[str] = None
    
    # Database
    DATABASE_URL: Optional[str] = None
    
    # Security
    JWT_SECRET_KEY: str = "change-this-in-production"
    JWT_ALGORITHM: str = "HS256"
    JWT_EXPIRATION_HOURS: int = 24
    
    # CORS
    CORS_ORIGINS: list = ["*"]
    
    # API Configuration
    API_VERSION: str = "1.0.0"
    API_TITLE: str = "BrainSAIT RHDTE API"
    API_DESCRIPTION: str = "Riyadh Health Digital Transformation Engine"
    
    class Config:
        env_file = ".env"
        case_sensitive = True

settings = Settings()
