"""
PawPal Veterinary Chatbot - Interactive CLI
"""

import sys
import os

# Add src to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from rag_pipeline import VeterinaryRAG


def print_banner():
    """Print welcome banner"""
    banner = """
╔════════════════════════════════════════════════════════════╗
║                                                            ║
║              🐾 PawPal Veterinary AI Assistant 🐾          ║
║                                                            ║
║     24/7 AI-powered guidance for your pet's health         ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝

💡 Features:
   • Health concerns & symptom assessment
   • Personalized diet recommendations  
   • Emergency guidance & severity classification
   • Based on veterinary knowledge base

⚠️  Disclaimer: This is an AI assistant for informational purposes.
   Always consult a licensed veterinarian for serious concerns.

📝 Commands:
   • Type your question and press Enter
   • 'profile' - Add pet profile for personalized advice
   • 'clear' - Clear pet profile
   • 'help' - Show this message
   • 'quit' - Exit

Let's help your furry friend! 🐶🐱
"""
    print(banner)


def get_pet_profile():
    """Interactive pet profile creation"""
    print("\n📋 Pet Profile Setup")
    print("=" * 40)
    
    pet_profile = {}
    
    # Pet type
    while True:
        pet_type = input("Pet type (dog/cat): ").strip().lower()
        if pet_type in ['dog', 'cat']:
            pet_profile['type'] = pet_type
            break
        print("Please enter 'dog' or 'cat'")
    
    # Breed
    breed = input("Breed (or 'mixed'): ").strip()
    if breed:
        pet_profile['breed'] = breed
    
    # Age
    try:
        age = input("Age (in years): ").strip()
        if age:
            pet_profile['age'] = float(age)
    except ValueError:
        pass
    
    # Weight
    try:
        weight = input("Weight (in kg): ").strip()
        if weight:
            pet_profile['weight'] = float(weight)
    except ValueError:
        pass
    
    # Health conditions
    conditions = input("Health conditions (comma-separated, or press Enter to skip): ").strip()
    if conditions:
        pet_profile['conditions'] = [c.strip() for c in conditions.split(',')]
    
    print(f"\n✅ Profile saved for {pet_profile.get('breed', 'your')} {pet_profile['type']}!")
    return pet_profile


def main():
    """Main chatbot loop"""
    
    # Print banner
    print_banner()
    
    # Initialize RAG system
    try:
        rag = VeterinaryRAG(
            model_name="llama3.2:1b",  # Fast mode - use llama3.1:8b for quality demos
            vector_db_path="./vector_db",
            temperature=0.3
        )
    except Exception as e:
        print(f"\n❌ Error initializing RAG system: {e}")
        print("\n💡 Make sure you've:")
        print("   1. Run 'ollama serve' in another terminal")
        print("   2. Run 'python build_knowledge_base.py' to create vector DB")
        return
    
    pet_profile = None
    
    print("\n" + "="*60)
    print("🟢 Ready! Ask me anything about pet health.")
    print("="*60 + "\n")
    
    # Chat loop
    while True:
        try:
            # Get user input
            question = input("🧑 You: ").strip()
            
            if not question:
                continue
            
            # Handle commands
            if question.lower() in ['quit', 'exit', 'q']:
                print("\n👋 Thank you for using PawPal! Take care! 🐾")
                break
            
            elif question.lower() == 'profile':
                pet_profile = get_pet_profile()
                continue
            
            elif question.lower() == 'clear':
                pet_profile = None
                print("✅ Pet profile cleared")
                continue
            
            elif question.lower() == 'help':
                print_banner()
                continue
            
            # Process query
            print("\n🔍 Thinking...\n")
            
            response = rag.query(
                question=question,
                pet_profile=pet_profile,
                return_sources=True
            )
            
            # Display answer
            print(f"🤖 PawPal:\n")
            print(f"{response['answer']}\n")
            
            # Display sources
            if response.get('sources') and len(response['sources']) > 0:
                print("─" * 60)
                print("📚 Information sourced from:")
                for i, source in enumerate(response['sources'][:3], 1):
                    source_name = source['metadata'].get('source', 'Knowledge Base')
                    print(f"   {i}. {source_name}")
                print()
            
            # Disclaimer
            print("💡 Remember: This is AI-generated advice. Consult a vet for serious concerns.\n")
            print("─" * 60 + "\n")
            
        except KeyboardInterrupt:
            print("\n\n👋 Goodbye! Stay pawsitive! 🐾")
            break
            
        except Exception as e:
            print(f"\n❌ Error: {e}\n")
            continue


if __name__ == "__main__":
    main()
