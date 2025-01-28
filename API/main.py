from fastapi import FastAPI, HTTPException # type: ignore
from pydantic import BaseModel # type: ignore
import pandas as pd # type: ignore
import pickle

# Initialize FastAPI
app = FastAPI()

# Load Models
with open('models/temp_model.pkl', 'rb') as f:
    temp_model = pickle.load(f)

with open('models/rain_model.pkl', 'rb') as f:
    rain_model = pickle.load(f)

# Request Body Schema
class PredictionRequest(BaseModel):
    date: str
    location: str  # Optional for this case but included for future scalability

@app.post("/predict/")
async def predict_weather(request: PredictionRequest):
    # Parse the date
    try:
        date = pd.to_datetime(request.date)
    except Exception as e:
        return {"error": "Invalid date format. Use YYYY-MM-DD."}

    # Create future DataFrame for prediction
    future_df = pd.DataFrame({'ds': [date]})

    # Make predictions
    temp_prediction = temp_model.predict(future_df)['yhat'][0]
    rain_prediction = rain_model.predict(future_df)['yhat'][0]

    return {
        "date": request.date,
        "location": request.location,
        "temperature_prediction": round(temp_prediction, 2),
        "rain_prediction": round(rain_prediction, 2)
    }
