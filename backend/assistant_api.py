from fastapi import FastAPI
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware
import sys
import os

# Step 1: Add assistant path to sys.path
assistant_path = os.path.abspath("../models/AI-Farming-Assistant-App")
sys.path.append(assistant_path)

# Step 2: Import the response generator
try:
    from assistant_core import generate_response
except ImportError:
    raise ImportError("❌ Could not import `generate_response()` from assistant_core.py")

# Step 3: Init FastAPI app
app = FastAPI(
    title="ANGA - AI Farming Assistant API",
    description="An API endpoint to ask farming & climate questions via LLM",
    version="1.0.0"
)

# Step 4: Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # ✅ safe for local dev
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Step 5: Define schema
class Question(BaseModel):
    query: str
    use_case: str = "Smart Farming Advice"

# Step 6: Endpoint
@app.post("/ask")
def ask_ai_farming_assistant(data: Question):
    answer = generate_response(data.query, data.use_case)
    return {"answer": answer}
   
