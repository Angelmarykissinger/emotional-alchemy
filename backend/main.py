from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from emotion_engine import EmotionEngine
import uvicorn

app = FastAPI(title="Emotional Alchemy Backend")

# ✅ Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

emotion_engine = EmotionEngine()

class MoodRequest(BaseModel):
    text: str
    user_id: str = None # Optional for now

class ChatRequest(BaseModel):
    message: str
    user_id: str = None

@app.get("/")
def read_root():
    return {"message": "Welcome to Emotional Alchemy API"}

@app.post("/analyze_mood")
def analyze_mood(request: MoodRequest):
    if not request.text:
        raise HTTPException(status_code=400, detail="Text is required")
    
    analysis = emotion_engine.analyze_sentiment(request.text)
    recommendation = emotion_engine.get_recommendation(analysis['label'])
    
    return {
        "analysis": analysis,
        "recommendation": recommendation
    }

@app.post("/chat")
def chat(request: ChatRequest):
    if not request.message:
         raise HTTPException(status_code=400, detail="Message is required")
    
    analysis = emotion_engine.analyze_sentiment(request.message)
    # Note: generate_chat_response re-analyzes, but that's fine for now.
    response_text = emotion_engine.generate_chat_response(request.message)
    
    return {
        "response": response_text,
        "analysis": analysis
    }

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
