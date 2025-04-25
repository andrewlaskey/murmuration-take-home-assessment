from fastapi import APIRouter
from app.api.surveys import surveys

api_router = APIRouter()
api_router.include_router(surveys.router, tags=["surveys"])