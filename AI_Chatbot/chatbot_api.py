"""
PawPal Chatbot API - Standalone script for Go backend integration
"""
import sys
import json
import os
import io

# Force UTF-8 encoding for stdout/stderr on Windows
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8')

# Get absolute path to AI_Chatbot directory
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

# Add src to path
sys.path.insert(0, os.path.join(SCRIPT_DIR, 'src'))

from rag_pipeline import VeterinaryRAG

# Global cache for RAG instance (loaded once, reused)
_rag_instance = None

def get_rag_instance():
    """Get or create cached RAG instance"""
    global _rag_instance
    if _rag_instance is None:
        SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
        vector_db_path = os.path.join(SCRIPT_DIR, "vector_db")
        _rag_instance = VeterinaryRAG(
            model_name="llama-3.3-70b-versatile",  # Groq's latest powerful model
            vector_db_path=vector_db_path,
            silent=True,
            use_groq=True,  # Use Groq API for speed
        )
    return _rag_instance


def main():
    try:
        # Read request from stdin
        request_data = json.load(sys.stdin)
        message = request_data.get('message', '')
        pet_profile = request_data.get('pet_profile')
        
        if not message:
            raise ValueError("Message is required")
        
        # Get cached RAG instance (much faster!)
        rag = get_rag_instance()
        
        # Query with optional pet profile
        result = rag.query(message, pet_profile=pet_profile, return_sources=True)
        
        # Output response as JSON with UTF-8 encoding
        output = json.dumps(result, ensure_ascii=False)
        print(output)
        
    except Exception as e:
        error_response = {
            "error": str(e),
            "answer": f"Sorry, I encountered an error: {str(e)}"
        }
        print(json.dumps(error_response, ensure_ascii=False), file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
