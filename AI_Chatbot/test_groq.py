"""
Quick test to verify Groq API integration
"""
import time
from src.rag_pipeline import VeterinaryRAG

print("="*70)
print("🚀 Testing Groq API Integration")
print("="*70)

# Test 1: Initialize with Groq
print("\n📡 Initializing RAG with Groq API...")
start = time.time()
rag = VeterinaryRAG(
    model_name="llama-3.3-70b-versatile",  # Latest Groq model
    vector_db_path="./vector_db",
    use_groq=True,
    silent=False
)
init_time = time.time() - start
print(f"✅ Initialized in {init_time:.2f}s")

# Test 2: Quick query
print("\n" + "="*70)
print("🧪 TEST: Simple Health Query")
print("="*70)
query = "My dog is vomiting. What should I do?"
print(f"Question: {query}")

start = time.time()
response = rag.query(query, return_sources=True)
query_time = time.time() - start

print(f"\n⚡ Response Time: {query_time:.2f}s")
print(f"\n🤖 Answer:\n{response['answer']}\n")
print(f"📚 Sources: {len(response['sources'])} documents retrieved")

# Test 3: Query with pet profile
print("\n" + "="*70)
print("🧪 TEST: Personalized Query")
print("="*70)

pet_profile = {
    "type": "dog",
    "breed": "Golden Retriever",
    "age": 3,
    "weight": 30
}

query2 = "What diet is best for my dog?"
print(f"Question: {query2}")
print(f"Pet: {pet_profile['breed']}, {pet_profile['age']} years, {pet_profile['weight']}kg")

start = time.time()
response2 = rag.query(query2, pet_profile=pet_profile, return_sources=True)
query_time2 = time.time() - start

print(f"\n⚡ Response Time: {query_time2:.2f}s")
print(f"\n🤖 Answer:\n{response2['answer']}\n")

print("="*70)
print("✅ Groq API Integration Successful!")
print(f"Average Response Time: {(query_time + query_time2) / 2:.2f}s")
print("="*70)
