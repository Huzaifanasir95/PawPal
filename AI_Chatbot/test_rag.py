"""
Quick RAG Test Script
"""
from src.rag_pipeline import VeterinaryRAG

print("=" * 70)
print("🧪 Testing PawPal RAG System")
print("=" * 70)

# Initialize RAG
rag = VeterinaryRAG(model_name="llama3.1:8b")

# Test query 1: Emergency situation
print("\n" + "=" * 70)
print("TEST 1: Emergency Situation")
print("=" * 70)
result = rag.query("My dog is vomiting blood. What should I do?")
print(f"\n💬 Question: {result['query']}")
print(f"\n🤖 Answer:\n{result['answer']}")
print(f"\n📚 Sources: {len(result['sources'])} documents retrieved")

# Test query 2: Diet question with profile
print("\n" + "=" * 70)
print("TEST 2: Diet Question with Pet Profile")
print("=" * 70)
pet_profile = {
    "type": "dog",
    "breed": "Golden Retriever",
    "age": 3,
    "weight": 30
}
result = rag.query(
    "What should I feed my dog for optimal health?",
    pet_profile=pet_profile
)
print(f"\n💬 Question: {result['query']}")
print(f"\n🐕 Pet: {pet_profile['type'].title()}, {pet_profile['breed']}, {pet_profile['age']} years")
print(f"\n🤖 Answer:\n{result['answer']}")
print(f"\n📚 Sources: {len(result['sources'])} documents retrieved")

# Test query 3: Senior care
print("\n" + "=" * 70)
print("TEST 3: Senior Pet Care")
print("=" * 70)
result = rag.query("What special care does a senior cat need?")
print(f"\n💬 Question: {result['query']}")
print(f"\n🤖 Answer:\n{result['answer']}")
print(f"\n📚 Sources: {len(result['sources'])} documents retrieved")

print("\n" + "=" * 70)
print("✅ RAG Testing Complete!")
print("=" * 70)
