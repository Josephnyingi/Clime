from fastapi import FastAPI, HTTPException, Depends
from sqlalchemy.orm import Session
from backend.database import SessionLocal, WeatherData, User
from pydantic import BaseModel
import pandas as pd
import pickle
import os
import requests
from datetime import datetime

app = FastAPI()

# Load ML models
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

try:
    with open(os.path.join(BASE_DIR, "model/temp_model.pkl"), "rb") as f:
        temp_model = pickle.load(f)
    with open(os.path.join(BASE_DIR, "model/rain_model.pkl"), "rb") as f:
        rain_model = pickle.load(f)
except FileNotFoundError:
    raise RuntimeError("Model files not found!")

# Database dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# ✅ Default supported locations
SUPPORTED_LOCATIONS = {
    "machakos": {"lat": -1.5167, "lon": 37.2667},
    "vhembe": {"lat": -22.9781, "lon": 30.4516}
}

# PREDICTION ENDPOINT
class PredictionRequest(BaseModel):
    date: str
    location: str = "machakos"  # ✅ Default location

@app.post("/predict/")
async def predict_weather(request: PredictionRequest):
    location = request.location.lower()
    if location not in SUPPORTED_LOCATIONS:
        raise HTTPException(status_code=400, detail="Unsupported location. Use 'machakos' or 'vhembe'.")

    try:
        date = pd.to_datetime(request.date)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid date format. Use YYYY-MM-DD.")

    future_df = pd.DataFrame({'ds': [date]})
    temp_prediction = temp_model.predict(future_df).iloc[0]["yhat"]
    rain_prediction = rain_model.predict(future_df).iloc[0]["yhat"]

    return {
        "date": request.date,
        "location": location.title(),
        "temperature_prediction": round(temp_prediction, 2),
        "rain_prediction": round(rain_prediction, 2)
    }

# SAVE PREDICTION
@app.post("/save_prediction/")
def save_prediction(date: str, location: str, temperature: float, rain: float, db: Session = Depends(get_db)):
    new_weather = WeatherData(date=date, location=location, temperature=temperature, rain=rain)
    db.add(new_weather)
    db.commit()
    return {"message": "Prediction saved successfully"}

# USER CREATION
class UserCreate(BaseModel):
    name: str
    phone_number: str
    password: str

@app.post("/users/")
def create_user(user: UserCreate, db: Session = Depends(get_db)):
    if db.query(User).filter(User.phone_number == user.phone_number).first():
        raise HTTPException(status_code=400, detail="Phone number already registered")

    new_user = User(name=user.name, phone_number=user.phone_number, password=user.password)
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return {"message": "User created successfully", "user_id": new_user.id}

# LOGIN
class LoginRequest(BaseModel):
    phone_number: str
    password: str

@app.post("/login/")
def login_user(request: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.phone_number == request.phone_number).first()
    if not user or user.password != request.password:
        raise HTTPException(status_code=401, detail="Invalid phone number or password")
    return {"message": "Login successful", "user_id": user.id}

# ✅ LIVE WEATHER ENDPOINT (Machakos and Vhembe only)
@app.get("/live_weather/")
def get_live_weather(location: str = "machakos"):
    loc = location.lower()
    if loc not in SUPPORTED_LOCATIONS:
        return {"error": "Only 'machakos' and 'vhembe' are supported."}

    coords = SUPPORTED_LOCATIONS[loc]
    today = datetime.now().strftime('%Y-%m-%d')

    url = (
        f"https://api.open-meteo.com/v1/forecast?"
        f"latitude={coords['lat']}&longitude={coords['lon']}"
        f"&daily=temperature_2m_max,precipitation_sum"
        f"&start_date={today}&end_date={today}"
        "&timezone=Africa%2FNairobi"
    )

    try:
        res = requests.get(url)
        res.raise_for_status()
        data = res.json()

        return {
            "location": loc.title(),
            "date": data["daily"]["time"][0],
            "temperature_max": data["daily"]["temperature_2m_max"][0],
            "rain_sum": data["daily"]["precipitation_sum"][0]

        }
    except Exception as e:
        return {"error": "Failed to fetch live weather", "details": str(e)}
