from sqlalchemy import Column, Integer, String, Float, Date
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from sqlalchemy import create_engine

# Define the base class for our ORM models
Base = declarative_base()

# SQLite Database URL - this will create a 'weather.db' file in your project folder
DATABASE_URL = "sqlite:///./weather.db"

# Create the SQLite engine
engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})

# Create a session maker for interacting with the database
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Define the User model to store user information
class User(Base):
    __tablename__ = "users"  # Table name for users

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    phone_number = Column(String, unique=True, index=True)  # Stores user's phone number
    password = Column(String)  # In a real app, store a hashed password!

# Define the WeatherData model to store weather predictions
class WeatherData(Base):
    __tablename__ = "weather_data"  # Table name for weather predictions

    id = Column(Integer, primary_key=True, index=True)
    date = Column(Date, index=True)  # Using Date type for proper date storage
    location = Column(String, index=True)
    temperature = Column(Float)
    rain = Column(Float)

# Create all tables in the database if they don't already exist
Base.metadata.create_all(bind=engine)
