from fastapi import FastAPI, HTTPException, Depends
from sqlalchemy.orm import Session
from backend.database import SessionLocal, WeatherData, User # Import the User model as well
from pydantic import BaseModel
import pandas as pd
import pickle
import os

# Initialize FastAPI
app = FastAPI()

# Get the directory of the current script
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# Load the prediction models
try:
    with open(os.path.join(BASE_DIR, "model/temp_model.pkl"), "rb") as f:
        temp_model = pickle.load(f)

    with open(os.path.join(BASE_DIR, "model/rain_model.pkl"), "rb") as f:
        rain_model = pickle.load(f)
except FileNotFoundError:
    raise RuntimeError("Model files not found! Ensure they exist in the correct directory.")

# Dependency to get a database session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Pydantic model for prediction requests
class PredictionRequest(BaseModel):
    date: str
    location: str

@app.post("/predict/")
async def predict_weather(request: PredictionRequest):
    # Convert the input date to a datetime object
    try:
        date = pd.to_datetime(request.date)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid date format. Use YYYY-MM-DD.")

    # Create a DataFrame for prediction
    future_df = pd.DataFrame({'ds': [date]})

    # Generate predictions using the loaded models
    temp_prediction = temp_model.predict(future_df).iloc[0]["yhat"]
    rain_prediction = rain_model.predict(future_df).iloc[0]["yhat"]

    return {
        "date": request.date,
        "location": request.location,
        "temperature_prediction": round(temp_prediction, 2),
        "rain_prediction": round(rain_prediction, 2)
    }

@app.post("/save_prediction/")
def save_prediction(date: str, location: str, temperature: float, rain: float, db: Session = Depends(get_db)):
    new_weather = WeatherData(date=date, location=location, temperature=temperature, rain=rain)
    db.add(new_weather)
    db.commit()
    return {"message": "Prediction saved successfully"}

# Pydantic model for user creation
class UserCreate(BaseModel):
    name: str
    phone_number: str
    password: str

@app.post("/users/")
def create_user(user: UserCreate, db: Session = Depends(get_db)):
    # Check if the phone number is already registered
    existing_user = db.query(User).filter(User.phone_number == user.phone_number).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="Phone number already registered")

    # Create a new user instance
    new_user = User(name=user.name, phone_number=user.phone_number, password=user.password)
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return {"message": "User created successfully", "user_id": new_user.id}

# Pydantic model for login request
class LoginRequest(BaseModel):
    phone_number: str
    password: str

@app.post("/login/")
def login_user(request: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.phone_number == request.phone_number).first()
    
    if not user or user.password != request.password:  # NOTE: In production, hash passwords!
        raise HTTPException(status_code=401, detail="Invalid phone number or password")

    return {"message": "Login successful", "user_id": user.id}
