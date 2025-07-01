from fastapi import FastAPI
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware
import sys
import os

# 🔁 Step 1: Import the assistant logic from Streamlit app
# Add the assistant path to sys.path to import its logic
assistant_path = os.path.abspath("../models/ai_farming_assistant")
sys.path.append(assistant_path)

try:
    from app import generate_response  # Make sure your Streamlit app has this function
except ImportError:
    raise ImportError("Could not import `generate_response` from Streamlit app.py")

# 🔧 Step 2: Define FastAPI app
app = FastAPI(
    title="AI Farming Assistant API",
    description="Exposes the AI farming assistant via REST endpoint for ANGA",
    version="1.0.0"
)

# 🌐 CORS (optional - allow mobile or web frontends)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # change this in prod
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 📦 Step 3: Request and Response Schema
class Query(BaseModel):
    query: str

# 🚀 Step 4: Define endpoint
@app.post("/ask")
def ask_farming_assistant(q: Query):
    answer = generate_response(q.query)
    return {"answer": answer}
