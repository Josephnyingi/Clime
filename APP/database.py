from sqlalchemy import Column, Integer, String, Float, Date
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from sqlalchemy import create_engine

# Define the base class
Base = declarative_base()

# Create an engine that connects to your database (in this case, SQLite)
DATABASE_URL = "sqlite:///./weather.db"  # Use the appropriate path or URL for your DB

# Create the SQLite engine
engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})

# Create a session 
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# If you're defining models, make sure to use the Base class
class User(Base):
    __tablename__ = "users" # table to store user information

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    phone_number = Column(String, unique=True, index=True)  # Changed from email to phone number
    password = Column(String)

class WeatherData(Base):
    __tablename__ = "weather_data" # to store weather prediction (date, location, temperature, and rain)

    id = Column(Integer, primary_key=True, index=True)
    date = Column(String, index=True)
    location = Column(String, index=True)
    temperature = Column(Float)
    rain = Column(Float)

# Create all the tables
Base.metadata.create_all(bind=engine)


