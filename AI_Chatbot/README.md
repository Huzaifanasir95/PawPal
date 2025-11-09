# 🤖 PawPal AI Chatbot - RAG-based Veterinary Assistant

## Overview
24/7 AI-powered veterinary assistant using **Retrieval-Augmented Generation (RAG)** with **Ollama** (local LLM) for privacy and cost-free operation.

## Features
✅ **AI-Powered Veterinary Guidance** - Common health queries & concerns  
✅ **Personalized Diet Plans** - Based on breed, age, weight, health  
✅ **24/7 Availability** - Sub-second response times  
✅ **Emergency Assessment** - Severity classification  
✅ **Context-Aware** - Integration with pet health journals  

## Architecture

```
User Query
    ↓
┌─────────────────────────────────────┐
│  Query Processing & Embedding       │
│  • SentenceTransformer              │
│  • Query enhancement                │
└─────────────┬───────────────────────┘
              ↓
┌─────────────────────────────────────┐
│  Vector Database (ChromaDB)         │
│  • Veterinary knowledge base        │
│  • Pet health information           │
│  • Diet & nutrition data            │
└─────────────┬───────────────────────┘
              ↓
┌─────────────────────────────────────┐
│  Context Retrieval                  │
│  • Top-K relevant documents         │
│  • Re-ranking                       │
└─────────────┬───────────────────────┘
              ↓
┌─────────────────────────────────────┐
│  Prompt Engineering                 │
│  • System prompt (veterinary role)  │
│  • Retrieved context                │
│  • User query                       │
│  • Pet profile (if available)       │
└─────────────┬───────────────────────┘
              ↓
┌─────────────────────────────────────┐
│  Ollama LLM (llama3.2:1b)          │
│  • Local inference                  │
│  • No API costs                     │
│  • Privacy preserved                │
└─────────────┬───────────────────────┘
              ↓
         Response + Sources
```

## Technology Stack

- **LLM**: Ollama (llama3.2:1b) - 1.3GB, runs locally
- **RAG Framework**: LangChain
- **Vector DB**: ChromaDB (persistent, embedded)
- **Embeddings**: SentenceTransformer (all-MiniLM-L6-v2)
- **Document Processing**: PyPDF, python-docx
- **Backend Integration**: FastAPI (ready for Go integration)

## Setup Instructions

### 1. Install Python Dependencies
```bash
cd D:\PawPal\AI_Chatbot
pip install -r requirements.txt
```

### 2. Verify Ollama Model
```bash
ollama list  # Should show llama3.2:1b
ollama run llama3.2:1b "Hello"  # Test the model
```

### 3. Prepare Knowledge Base
Place veterinary documents in `knowledge_base/`:
- PDFs: Pet health guides, disease info
- Text files: Common symptoms, treatments
- CSVs: Dog/cat breed health data, diet plans

### 4. Build Vector Database
```bash
python build_knowledge_base.py
```

### 5. Run Chatbot
```bash
python chatbot.py
# Or run as API: python api_server.py
```

## Project Structure

```
AI_Chatbot/
├── knowledge_base/          # Veterinary documents (PDFs, txt, csv)
│   ├── dog_health/
│   ├── cat_health/
│   ├── nutrition/
│   ├── emergency/
│   └── breed_info/
├── vector_db/              # ChromaDB storage (auto-created)
├── src/
│   ├── rag_pipeline.py    # Main RAG implementation
│   ├── embeddings.py      # Embedding generation
│   ├── prompt_templates.py # Prompt engineering
│   └── utils.py           # Helper functions
├── build_knowledge_base.py # Vector DB builder
├── chatbot.py             # Interactive chatbot
├── api_server.py          # FastAPI server
├── requirements.txt
└── README.md
```

## Usage Examples

### Interactive Mode
```python
python chatbot.py

> My dog is vomiting and has diarrhea. What should I do?

🤖 Based on the symptoms you've described...
[AI provides guidance with sources]
```

### API Mode
```bash
python api_server.py  # Starts on http://localhost:8000

# POST /api/chat
{
  "query": "What diet is best for a 3-year-old Golden Retriever?",
  "pet_profile": {
    "type": "dog",
    "breed": "Golden Retriever",
    "age": 3,
    "weight": 30
  }
}
```

## Integration with Go Backend

Once the RAG system is ready, we'll integrate it with the existing Go backend:

```go
// Future: internal/services/chatbot.go
func (s *ChatbotService) GetResponse(query string, petProfile PetProfile) (*ChatResponse, error) {
    // Call Python RAG API via HTTP
    pythonAPIURL := "http://localhost:8000/api/chat"
    // ... implementation
}
```

## Knowledge Base Sources (Planned)

1. **Veterinary Databases**: Cornell, UC Davis vet medicine
2. **Pet Health Guides**: AKC, Cat Fanciers Association
3. **Nutrition Data**: AAFCO guidelines, breed-specific diets
4. **Emergency Protocols**: ASPCA poison control, first aid
5. **Disease Information**: Common conditions, symptoms, treatments

## Performance Targets

- ⚡ **Response Time**: < 2 seconds (with context retrieval)
- 🎯 **Accuracy**: 85%+ for common queries
- 📚 **Knowledge Base**: 1000+ documents
- 🔍 **Context Retrieval**: Top-5 relevant chunks
- 💾 **Memory**: < 4GB RAM usage

## Next Steps

1. ✅ Install dependencies
2. ✅ Test Ollama connection
3. 📝 Create knowledge base documents
4. 🔨 Build RAG pipeline
5. 🧪 Test with sample queries
6. 🔗 Integrate with Go backend
