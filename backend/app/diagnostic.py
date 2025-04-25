"""
Diagnostic script to identify SQLAlchemy database connection issues
"""
import sys
import os
import importlib.util

# Check Python version
print(f"Python version: {sys.version}")

# Try to import required packages
packages_to_check = [
    "sqlalchemy",
    "psycopg2",
    "psycopg2.extensions",
    "psycopg2.extras"
]

for package in packages_to_check:
    spec = importlib.util.find_spec(package)
    if spec is None:
        print(f"❌ {package} is NOT installed")
    else:
        try:
            module = importlib.import_module(package)
            version = getattr(module, "__version__", "unknown version")
            print(f"✅ {package} is installed ({version})")
        except ImportError as e:
            print(f"⚠️ {package} import error: {e}")

# Try to create an engine and connect
from sqlalchemy import create_engine, inspect
from sqlalchemy.exc import SQLAlchemyError

# Test database URL (adjust as needed)
TEST_DB_URL = os.environ.get("DATABASE_URL", "postgresql+psycopg2://postgres:postgres@db:5432/survey_db")

print(f"\nTesting connection with: {TEST_DB_URL}")

try:
    # Create engine without pooling for simple test
    engine = create_engine(TEST_DB_URL, pool_pre_ping=True, connect_args={"connect_timeout": 5})
    
    # Try to connect
    print("Attempting to connect...")
    with engine.connect() as conn:
        print("✅ Connection successful!")
        
        # Get database info
        inspector = inspect(engine)
        print(f"Database dialect: {engine.dialect.name}")
        print(f"Driver: {engine.dialect.driver}")
        
        # List tables if connected
        try:
            print("\nDatabase tables:")
            for table_name in inspector.get_table_names():
                print(f"  - {table_name}")
        except Exception as e:
            print(f"Error listing tables: {e}")
            
except SQLAlchemyError as e:
    print(f"❌ SQLAlchemy error: {e}")
except Exception as e:
    print(f"❌ Unexpected error: {e}")

print("\nConnection string parsing check:")
from urllib.parse import urlparse

try:
    parsed = urlparse(TEST_DB_URL)
    print(f"Scheme: {parsed.scheme}")
    print(f"Network location: {parsed.netloc}")
    print(f"Path: {parsed.path}")
except Exception as e:
    print(f"Error parsing URL: {e}")