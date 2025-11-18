"""
PawPal Chatbot Streaming API - Word-by-word streaming like ChatGPT
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

# Global cache for RAG instance
_rag_instance = None

def get_rag_instance():
    """Get or create cached RAG instance"""
    global _rag_instance
    if _rag_instance is None:
        vector_db_path = os.path.join(SCRIPT_DIR, "vector_db")
        _rag_instance = VeterinaryRAG(
            model_name="llama3.2:1b", 
            vector_db_path=vector_db_path,
            silent=True
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
        
        # Get cached RAG instance
        rag = get_rag_instance()
        
        # Stream the response word-by-word
        for chunk in rag.query_stream(message, pet_profile=pet_profile):
            # Output each chunk immediately
            output = json.dumps({"chunk": chunk, "done": False})
            print(output, flush=True)
        
        # Send completion signal
        completion = json.dumps({"chunk": "", "done": True})
        print(completion, flush=True)
        
    except Exception as e:
        error_response = {
            "error": str(e),
            "chunk": f"Sorry, I encountered an error: {str(e)}",
            "done": True
        }
        print(json.dumps(error_response), file=sys.stderr, flush=True)
        sys.exit(1)


if __name__ == "__main__":
    main()
