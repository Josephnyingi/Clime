from fastapi import FastAPI, HTTPException, Depends
from sqlalchemy.orm import Session
#from database import SessionLocal, WeatherData
from APP.database import SessionLocal, WeatherData
from pydantic import BaseModel
import pandas as pd
import pickle
import os

# Initialize FastAPI
app = FastAPI()

# Get script directory
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# Load Models
try:
    with open(os.path.join(BASE_DIR, "model/temp_model.pkl"), "rb") as f:
        temp_model = pickle.load(f)

    with open(os.path.join(BASE_DIR, "model/rain_model.pkl"), "rb") as f:
        rain_model = pickle.load(f)
except FileNotFoundError:
    raise RuntimeError("Model files not found! Ensure they exist in the correct directory.")

# Dependency to get database session
def get_db():
    db = SessionLocal()
    try:
        return db
    finally:
        db.close()

# Request Body Schema
class PredictionRequest(BaseModel):
    date: str
    location: str

@app.post("/predict/")
async def predict_weather(request: PredictionRequest):
    # Parse the date
    try:
        date = pd.to_datetime(request.date)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid date format. Use YYYY-MM-DD.")

    # Create future DataFrame for prediction
    future_df = pd.DataFrame({'ds': [date]})

    # Make predictions
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