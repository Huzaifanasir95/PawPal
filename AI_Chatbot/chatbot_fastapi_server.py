"""
FastAPI Server for PawPal Chatbot - Persistent Process
Keeps RAG model loaded in memory, eliminates cold start overhead
"""
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional, Dict, Any, List
import uvicorn
import sys
import os

# Add src to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from rag_pipeline import VeterinaryRAG

app = FastAPI(title="PawPal Chatbot API", version="2.0")

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global RAG instance (loaded ONCE at startup, reused for all requests)
rag_instance: Optional[VeterinaryRAG] = None


class ChatRequest(BaseModel):
    message: str
    pet_profile: Optional[Dict[str, Any]] = None


class ChatResponse(BaseModel):
    answer: str
    query: str
    enhanced_query: Optional[str] = None
    sources: Optional[List[Dict[str, Any]]] = None


@app.on_event("startup")
async def startup_event():
    """Initialize RAG system once at startup"""
    global rag_instance
    print("🚀 Initializing PawPal RAG System...")
    print("⏳ This may take 5-10 seconds (only happens once)...")
    
    rag_instance = VeterinaryRAG(
        model_name="llama-3.3-70b-versatile",
        vector_db_path="./vector_db",
        use_groq=True,
        silent=False,
    )
    
    print("✅ RAG System ready! Server is now blazing fast!")


@app.get("/")
async def root():
    return {
        "service": "PawPal Chatbot API",
        "status": "running",
        "model": "Groq llama-3.3-70b-versatile",
        "endpoints": {
            "query": "POST /api/chatbot/query",
            "health": "GET /health"
        }
    }


@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "rag_loaded": rag_instance is not None
    }


@app.post("/api/chatbot/query", response_model=ChatResponse)
async def query_chatbot(request: ChatRequest):
    """Process chatbot query with persistent RAG instance (FAST!)"""
    
    if rag_instance is None:
        raise HTTPException(status_code=503, detail="RAG system not initialized")
    
    try:
        # Query the pre-loaded RAG instance (no loading overhead!)
        result = rag_instance.query(
            question=request.message,
            pet_profile=request.pet_profile,
            return_sources=True
        )
        
        return ChatResponse(**result)
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Query failed: {str(e)}")


@app.post("/api/chatbot/stream")
async def stream_chatbot(request: ChatRequest):
    """Stream chatbot response word-by-word (FAST!)"""
    from fastapi.responses import StreamingResponse
    import json
    
    if rag_instance is None:
        raise HTTPException(status_code=503, detail="RAG system not initialized")
    
    async def generate():
        try:
            # Stream from pre-loaded RAG instance
            for chunk in rag_instance.query_stream(
                question=request.message,
                pet_profile=request.pet_profile
            ):
                # Send each chunk as SSE
                data = json.dumps({"chunk": chunk, "done": False})
                yield f"data: {data}\n\n"
            
            # Send completion signal
            completion = json.dumps({"chunk": "", "done": True})
            yield f"data: {completion}\n\n"
        
        except Exception as e:
            error = json.dumps({"chunk": f"Error: {str(e)}", "done": True, "error": str(e)})
            yield f"data: {error}\n\n"
    
    return StreamingResponse(
        generate(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no"
        }
    )


if __name__ == "__main__":
    # Run server
    uvicorn.run(
        app,
        host="0.0.0.0",
        port=8000,
        log_level="info"
    )
