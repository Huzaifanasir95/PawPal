"""
PawPal AI Chatbot - RAG Pipeline Implementation
Retrieval-Augmented Generation for Veterinary Assistance
"""

from langchain_community.llms import Ollama
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
        model_name: str = "llama3.2:1b",  # Using 1B for speed (change to llama3.1:8b for quality)
        embedding_model: str = "all-MiniLM-L6-v2",
        vector_db_path: str = "./vector_db",
        temperature: float = 0.3,
        silent: bool = False,  # Suppress emoji output for API mode
    ):
        """
        Initialize RAG pipeline
        
        Args:
            model_name: Ollama model name
            embedding_model: HuggingFace embedding model
            vector_db_path: Path to ChromaDB storage
            temperature: LLM creativity (0=factual, 1=creative)
        """
        self.model_name = model_name
        self.vector_db_path = vector_db_path
        self.silent = silent
        
        if not silent:
            print("Initializing PawPal Veterinary RAG System...")
        
        # Initialize Ollama LLM
        if not silent:
            print(f"Connecting to Ollama ({model_name})...")
        self.llm = Ollama(
            model=model_name,
            temperature=temperature,
            num_ctx=4096,  # Context window
            num_predict=512,  # Max tokens for detailed responses
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
        
        # Setup retriever
        self.retriever = self.vector_db.as_retriever(
            search_type="similarity",
            search_kwargs={"k": 2}  # Top 2 chunks (faster than 3)
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
            for doc in docs[:2]:  # Top 2 sources (faster)
                sources.append({
                    "content": doc.page_content[:200] + "...",
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
