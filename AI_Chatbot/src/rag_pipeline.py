"""
PawPal AI Chatbot - RAG Pipeline Implementation
Retrieval-Augmented Generation for Veterinary Assistance
"""

from langchain_community.llms import Ollama
from langchain_groq import ChatGroq
from langchain_community.embeddings import HuggingFaceEmbeddings
from langchain_community.vectorstores import Chroma
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_core.prompts import PromptTemplate
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough
from typing import List, Dict, Optional
import os


class VeterinaryRAG:
    """
    RAG system for veterinary queries using Ollama + ChromaDB
    """
    
    def __init__(
        self,
        model_name: str = "llama-3.3-70b-versatile",  # Groq's latest model (llama-3.3-70b, llama-3.1-8b, mixtral-8x7b)
        embedding_model: str = "all-MiniLM-L6-v2",
        vector_db_path: str = "./vector_db",
        temperature: float = 0.3,
        silent: bool = False,  # Suppress emoji output for API mode
        use_groq: bool = True,  # Use Groq API (fast) or local Ollama
        groq_api_key: str = "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",
    ):
        """
        Initialize RAG pipeline
        
        Args:
            model_name: Model name (Groq: llama-3.3-70b-versatile, llama-3.1-8b-instant; Ollama: llama3.2:1b)
            embedding_model: HuggingFace embedding model
            vector_db_path: Path to ChromaDB storage
            temperature: LLM creativity (0=factual, 1=creative)
            use_groq: Use Groq API (True) or local Ollama (False)
            groq_api_key: Groq API key for cloud inference
        """
        self.model_name = model_name
        self.vector_db_path = vector_db_path
        self.silent = silent
        self.use_groq = use_groq
        
        if not silent:
            print("Initializing PawPal Veterinary RAG System...")
        
        # Initialize LLM (Groq or Ollama)
        if use_groq:
            if not silent:
                print(f"Connecting to Groq API ({model_name})...")
            self.llm = ChatGroq(
                model=model_name,
                temperature=temperature,
                groq_api_key=groq_api_key,
                max_tokens=384,  # Reduced for faster responses
            )
        else:
            if not silent:
                print(f"Connecting to Ollama ({model_name})...")
            self.llm = Ollama(
                model=model_name,
                temperature=temperature,
                num_ctx=2048,  # Reduced context window for speed
                num_predict=256,  # Reduced tokens for faster responses
                num_gpu=0,  # Use CPU to avoid GPU out-of-memory errors
            )
        
        # Initialize embeddings
        if not silent:
            print(f"Loading embedding model ({embedding_model})...")
        self.embeddings = HuggingFaceEmbeddings(
            model_name=embedding_model,
            model_kwargs={'device': 'cpu'},  # Use GPU if available
            encode_kwargs={'normalize_embeddings': True}
        )
        
        # Load or create vector database
        if os.path.exists(vector_db_path):
            if not silent:
                print(f"Loading vector database from {vector_db_path}...")
            self.vector_db = Chroma(
                persist_directory=vector_db_path,
                embedding_function=self.embeddings
            )
            if not silent:
                print(f"Vector DB loaded: {self.vector_db._collection.count()} documents")
        else:
            if not silent:
                print("No vector database found. Run build_knowledge_base.py first!")
            self.vector_db = None
        
        # Setup retrieval chain
        if self.vector_db:
            self._setup_retrieval_chain()
        
        if not silent:
            print("RAG System initialized successfully!\n")
    
    def _setup_retrieval_chain(self):
        """Setup the retrieval chain with custom prompt"""
        
        # Veterinary-specific prompt template
        template = """You are PawPal, an expert veterinary AI assistant. Your role is to provide helpful, accurate, and compassionate guidance on pet health matters.

Context from veterinary knowledge base:
{context}

User Question: {question}

Instructions:
1. Provide clear, actionable advice based on the context above
2. If it's an emergency (severe symptoms), clearly state: "⚠️ EMERGENCY: Seek immediate veterinary care"
3. For diet questions, provide breed and age-appropriate recommendations
4. Always include a disclaimer that you're an AI assistant and serious concerns require a vet visit
5. Be empathetic and supportive to pet owners
6. Cite specific information from the context when relevant

Answer:"""

        self.prompt = PromptTemplate(
            template=template,
            input_variables=["context", "question"]
        )
        
        # Setup retriever - optimized for speed
        self.retriever = self.vector_db.as_retriever(
            search_type="similarity",
            search_kwargs={"k": 2}  # Top 2 chunks for faster retrieval
        )
        
        # Create RAG chain using LCEL (LangChain Expression Language)
        def format_docs(docs):
            return "\n\n".join(doc.page_content for doc in docs)
        
        self.qa_chain = (
            {"context": self.retriever | format_docs, "question": RunnablePassthrough()}
            | self.prompt
            | self.llm
            | StrOutputParser()
        )
    
    def query(
        self,
        question: str,
        pet_profile: Optional[Dict] = None,
        return_sources: bool = True
    ) -> Dict:
        """
        Query the RAG system
        
        Args:
            question: User's veterinary question
            pet_profile: Optional pet info (type, breed, age, weight, conditions)
            return_sources: Whether to return source documents
            
        Returns:
            Dict with answer and optional sources
        """
        if not self.vector_db:
            return {
                "answer": "❌ Vector database not initialized. Please run build_knowledge_base.py first.",
                "sources": []
            }
        
        # Enhance query with pet profile
        enhanced_query = self._enhance_query_with_profile(question, pet_profile)
        
        if not self.silent:
            print(f"Processing query: {enhanced_query[:100]}...")
        
        # Get response from RAG chain
        answer = self.qa_chain.invoke(enhanced_query)
        
        response = {
            "answer": answer,
            "query": question,
            "enhanced_query": enhanced_query
        }
        
        if return_sources:
            # Get source documents separately
            docs = self.retriever.invoke(enhanced_query)
            sources = []
            for doc in docs[:2]:  # Top 2 sources for speed
                sources.append({
                    "content": doc.page_content[:150] + "...",  # Reduced content preview
                    "metadata": doc.metadata
                })
            response["sources"] = sources
        
        return response
    
    def _enhance_query_with_profile(
        self,
        question: str,
        pet_profile: Optional[Dict]
    ) -> str:
        """Enhance query with pet profile information"""
        
        if not pet_profile:
            return question
        
        profile_text = f"Pet Profile: "
        if "type" in pet_profile:
            profile_text += f"{pet_profile['type'].title()}"
        if "breed" in pet_profile:
            profile_text += f", {pet_profile['breed']}"
        if "age" in pet_profile:
            profile_text += f", {pet_profile['age']} years old"
        if "weight" in pet_profile:
            profile_text += f", {pet_profile['weight']}kg"
        if "conditions" in pet_profile:
            profile_text += f", Conditions: {', '.join(pet_profile['conditions'])}"
        
        return f"{profile_text}\n\nQuestion: {question}"
    
    def query_stream(
        self,
        question: str,
        pet_profile: Optional[Dict] = None
    ):
        """
        Query the RAG system with streaming response (word-by-word like ChatGPT)
        
        Args:
            question: User's veterinary question
            pet_profile: Optional pet info (type, breed, age, weight, conditions)
            
        Yields:
            Response chunks from the LLM
        """
        if not self.vector_db:
            yield "❌ Vector database not initialized. Please run build_knowledge_base.py first."
            return
        
        # Enhance query with pet profile
        enhanced_query = self._enhance_query_with_profile(question, pet_profile)
        
        if not self.silent:
            print(f"Processing streaming query: {enhanced_query[:100]}...")
        
        # Stream response from RAG chain
        for chunk in self.qa_chain.stream(enhanced_query):
            yield chunk
    
    def chat(self):
        """Interactive chat mode"""
        
        print("\n" + "="*60)
        print("🐾 PawPal Veterinary AI Assistant")
        print("="*60)
        print("\nI'm here to help with your pet health questions!")
        print("Type 'quit' to exit\n")
        
        while True:
            try:
                question = input("🧑 You: ").strip()
                
                if question.lower() in ['quit', 'exit', 'q']:
                    print("\n👋 Thank you for using PawPal! Take care of your furry friends!")
                    break
                
                if not question:
                    continue
                
                # Get response
                response = self.query(question, return_sources=True)
                
                print(f"\n🤖 PawPal: {response['answer']}\n")
                
                # Show sources if available
                if response.get("sources"):
                    print("📚 Sources:")
                    for i, source in enumerate(response["sources"][:3], 1):
                        print(f"  {i}. {source['content']}")
                    print()
                
            except KeyboardInterrupt:
                print("\n\n👋 Goodbye!")
                break
            except Exception as e:
                print(f"\n❌ Error: {e}\n")


# Quick test function
def test_rag():
    """Test the RAG system with sample queries"""
    
    rag = VeterinaryRAG()
    
    test_queries = [
        "My dog is vomiting. What should I do?",
        "What's a healthy diet for a Golden Retriever?",
        "My cat has been sneezing. Is this serious?",
    ]
    
    print("\n" + "="*60)
    print("Testing RAG System")
    print("="*60 + "\n")
    
    for query in test_queries:
        print(f"❓ Query: {query}")
        response = rag.query(query, return_sources=False)
        print(f"💬 Answer: {response['answer'][:200]}...\n")


if __name__ == "__main__":
    # Test mode
    test_rag()
