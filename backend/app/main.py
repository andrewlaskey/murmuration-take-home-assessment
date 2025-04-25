from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# from app.api.router import router
from app.database import engine, Base

# Create database tables
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Survey API",
    description="API for accessing survey responses",
    version="0.1.0",
)

# Set up CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # For development; restrict in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include API router
# app.include_router(router, prefix="/api/v1")

@app.get("/")
async def root():
    return {"message": "Welcome to the Survey API"}