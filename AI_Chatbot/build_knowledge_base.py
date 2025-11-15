"""
Build Knowledge Base - Process documents and create vector database
"""

from langchain_community.document_loaders import (
    PyPDFLoader,
    TextLoader,
    CSVLoader,
    DirectoryLoader
)
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_community.embeddings import HuggingFaceEmbeddings
from langchain_community.vectorstores import Chroma
from pathlib import Path
from tqdm import tqdm
import os


class KnowledgeBaseBuilder:
    """
    Build vector database from veterinary knowledge documents
    """
    
    def __init__(
        self,
        knowledge_base_path: str = "./knowledge_base",
        vector_db_path: str = "./vector_db",
        embedding_model: str = "all-MiniLM-L6-v2",
        chunk_size: int = 500,
        chunk_overlap: int = 50
    ):
        self.knowledge_base_path = Path(knowledge_base_path)
        self.vector_db_path = vector_db_path
        self.chunk_size = chunk_size
        self.chunk_overlap = chunk_overlap
        
        print("🔧 Initializing Knowledge Base Builder...")
        
        # Initialize embeddings
        print(f"🔤 Loading embedding model: {embedding_model}...")
        self.embeddings = HuggingFaceEmbeddings(
            model_name=embedding_model,
            model_kwargs={'device': 'cpu'},
            encode_kwargs={'normalize_embeddings': True}
        )
        
        # Text splitter
        self.text_splitter = RecursiveCharacterTextSplitter(
            chunk_size=chunk_size,
            chunk_overlap=chunk_overlap,
            separators=["\n\n", "\n", ". ", " ", ""]
        )
        
        print("✅ Builder initialized!\n")
    
    def load_documents(self) -> list:
        """Load all documents from knowledge base directory"""
        
        if not self.knowledge_base_path.exists():
            print(f"⚠️  Creating knowledge base directory: {self.knowledge_base_path}")
            self.knowledge_base_path.mkdir(parents=True, exist_ok=True)
            return []
        
        all_documents = []
        
        print(f"📂 Scanning {self.knowledge_base_path} for documents...\n")
        
        # Load PDFs
        pdf_files = list(self.knowledge_base_path.rglob("*.pdf"))
        if pdf_files:
            print(f"📄 Found {len(pdf_files)} PDF files")
            for pdf_file in tqdm(pdf_files, desc="Loading PDFs"):
                try:
                    loader = PyPDFLoader(str(pdf_file))
                    docs = loader.load()
                    all_documents.extend(docs)
                except Exception as e:
                    print(f"  ⚠️  Error loading {pdf_file.name}: {e}")
        
        # Load text files
        txt_files = list(self.knowledge_base_path.rglob("*.txt"))
        if txt_files:
            print(f"📝 Found {len(txt_files)} text files")
            for txt_file in tqdm(txt_files, desc="Loading text files"):
                try:
                    loader = TextLoader(str(txt_file), encoding='utf-8')
                    docs = loader.load()
                    all_documents.extend(docs)
                except Exception as e:
                    print(f"  ⚠️  Error loading {txt_file.name}: {e}")
        
        # Load CSV files
        csv_files = list(self.knowledge_base_path.rglob("*.csv"))
        if csv_files:
            print(f"📊 Found {len(csv_files)} CSV files")
            for csv_file in tqdm(csv_files, desc="Loading CSV files"):
                try:
                    loader = CSVLoader(str(csv_file))
                    docs = loader.load()
                    all_documents.extend(docs)
                except Exception as e:
                    print(f"  ⚠️  Error loading {csv_file.name}: {e}")
        
        print(f"\n✅ Loaded {len(all_documents)} documents total")
        return all_documents
    
    def create_sample_documents(self):
        """Create sample veterinary documents for testing"""
        
        print("\n📝 Creating sample veterinary knowledge base...")
        
        # Create subdirectories
        categories = ['dog_health', 'cat_health', 'nutrition', 'emergency']
        for category in categories:
            (self.knowledge_base_path / category).mkdir(parents=True, exist_ok=True)
        
        # Sample dog health document
        dog_health = """
# Common Dog Health Issues

## Vomiting in Dogs

**Causes:**
- Dietary indiscretion (eating inappropriate items)
- Sudden diet changes
- Food allergies or intolerance
- Parasites (worms, giardia)
- Viral or bacterial infections
- Pancreatitis
- Kidney or liver disease
- Poisoning

**When to See a Vet:**
- Vomiting persists for more than 24 hours
- Blood in vomit
- Accompanied by diarrhea, lethargy, or fever
- Dog shows signs of pain or distress
- Suspected poisoning

**Home Care:**
- Withhold food for 12-24 hours
- Provide small amounts of water frequently
- Gradually reintroduce bland diet (boiled chicken and rice)
- Monitor for worsening symptoms

## Diarrhea in Dogs

**Common Causes:**
- Dietary changes or indiscretion
- Stress or anxiety
- Parasites
- Viral infections (parvovirus, distemper)
- Bacterial infections
- Inflammatory bowel disease
- Food allergies

**Treatment:**
- Bland diet for 2-3 days
- Probiotics for gut health
- Ensure adequate hydration
- Seek vet if bloody diarrhea or severe dehydration

## Skin Issues

**Types:**
- Hot spots (acute moist dermatitis)
- Allergic dermatitis
- Flea allergy dermatitis
- Ringworm (fungal infection)
- Dry skin

**Management:**
- Regular grooming
- Flea prevention
- Appropriate shampoos
- Diet with omega fatty acids
- Allergy testing if chronic issues
"""
        
        # Sample cat health document
        cat_health = """
# Common Cat Health Issues

## Upper Respiratory Infections (URI)

**Symptoms:**
- Sneezing
- Runny nose and eyes
- Coughing
- Loss of appetite
- Lethargy

**Causes:**
- Feline herpesvirus (FHV-1)
- Feline calicivirus (FCV)
- Bacterial infections (Bordetella, Chlamydia)

**Treatment:**
- Most URIs are viral and resolve in 7-14 days
- Supportive care: humidifier, clean eyes/nose
- Ensure eating and drinking
- Antibiotics if bacterial secondary infection
- L-lysine supplements may help with herpesvirus

**Prevention:**
- Regular vaccinations
- Minimize stress
- Isolate infected cats

## Urinary Issues (FLUTD)

**Feline Lower Urinary Tract Disease:**
- Straining to urinate
- Frequent trips to litter box
- Blood in urine
- Urinating outside litter box
- Crying while urinating

**Emergency Signs:**
- Complete inability to urinate (male cats especially)
- This is LIFE-THREATENING - see vet immediately!

**Management:**
- Wet food diet
- Increased water intake
- Stress reduction
- Appropriate litter box maintenance
- Prescription diets if needed

## Dental Disease

**Signs:**
- Bad breath
- Red, swollen gums
- Difficulty eating
- Drooling
- Pawing at mouth

**Prevention:**
- Regular tooth brushing
- Dental treats and toys
- Professional cleanings
- Dental-specific dry food
"""
        
        # Sample nutrition guide
        nutrition = """
# Pet Nutrition Guidelines

## Dog Nutrition by Life Stage

### Puppy (0-12 months)
- High protein (22-32%)
- High fat (10-25%)
- Calcium and phosphorus for bone growth
- Feed 3-4 times daily when young
- Gradually reduce to 2 meals by 6 months

### Adult Dog (1-7 years)
- Protein: 18-25%
- Fat: 10-15%
- Feed twice daily
- Monitor weight and adjust portions
- Regular exercise

### Senior Dog (7+ years)
- Lower calories (less active)
- Higher quality protein
- Joint support (glucosamine, omega-3)
- May need more frequent, smaller meals

## Dog Nutrition by Breed Size

### Small Breeds (<20 lbs)
- Higher metabolism
- Small, frequent meals
- Calorie-dense food
- Small kibble size

### Medium Breeds (20-50 lbs)
- Balanced nutrition
- Moderate exercise needs
- Standard feeding schedules

### Large Breeds (50-100 lbs)
- Joint support important
- Controlled growth in puppies
- Watch for bloat risk
- Large breed specific formulas

### Giant Breeds (100+ lbs)
- Slow, controlled growth critical
- Joint and bone support
- Lower calcium in puppies
- Multiple small meals to prevent bloat

## Cat Nutrition

### Obligate Carnivores
- Require animal protein
- Taurine essential
- Cannot be vegetarian
- Need moisture in diet

### Feeding Guidelines
- Wet food preferred (moisture)
- Multiple small meals
- Fresh water always available
- Avoid free-feeding dry food
- Monitor weight closely

### Special Dietary Needs
- Urinary health: increased moisture
- Weight management: portion control
- Senior cats: easier to digest protein
- Kidney disease: low phosphorus
"""
        
        # Sample emergency guide
        emergency = """
# Pet Emergency Quick Reference

## IMMEDIATE VET CARE NEEDED

### Critical Emergencies (GO NOW!)
1. **Difficulty Breathing**
   - Labored breathing, gasping
   - Blue/pale gums
   - Extended neck, open-mouth breathing in cats

2. **Bleeding That Won't Stop**
   - Apply pressure with clean cloth
   - Don't remove cloth if soaked, add more
   - Head to vet immediately

3. **Inability to Urinate**
   - Especially male cats - LIFE THREATENING
   - Straining with no output
   - Distended, painful abdomen

4. **Seizures**
   - Especially if lasting >5 minutes
   - Multiple seizures in 24 hours
   - First-time seizure

5. **Suspected Poisoning**
   - Ingestion of toxic substances
   - Bring package/sample if possible
   - Call ASPCA Poison Control: (888) 426-4435

6. **Trauma**
   - Hit by car
   - Serious falls
   - Dog fights with puncture wounds
   - Broken bones visible

7. **Heatstroke**
   - Heavy panting, drooling
   - Rapid heartbeat
   - Vomiting, diarrhea
   - Collapse
   - **Action**: Cool with water (not ice), vet ASAP

8. **Bloat (GDV in Dogs)**
   - Distended, hard abdomen
   - Unproductive vomiting/retching
   - Restlessness, pacing
   - EMERGENCY - minutes matter!

## URGENT (WITHIN 24 HOURS)

- Vomiting/diarrhea lasting >24 hours
- Not eating for >24 hours
- Lethargy, weakness
- Eye injury or sudden vision loss
- Lameness, limping
- Ear infections (head shaking, odor)

## CAN WAIT FOR REGULAR APPOINTMENT

- Minor skin irritation
- Mild itching
- Routine wellness concerns
- Vaccination updates
- Dental cleaning
- Nail trimming

## First Aid Kit for Pets

Essential Items:
- Gauze pads and rolls
- Adhesive tape
- Cotton balls
- Tweezers
- Digital thermometer
- Hydrogen peroxide (3%) - for inducing vomiting IF vet instructs
- Saline eye wash
- Muzzle (even friendly pets may bite when in pain)
- Blanket for warmth/transport
- Pet carrier

Emergency Contacts:
- Regular vet phone
- 24-hour emergency vet
- ASPCA Poison Control: (888) 426-4435
"""
        
        # Write sample documents
        (self.knowledge_base_path / 'dog_health' / 'common_issues.txt').write_text(dog_health)
        (self.knowledge_base_path / 'cat_health' / 'common_issues.txt').write_text(cat_health)
        (self.knowledge_base_path / 'nutrition' / 'feeding_guide.txt').write_text(nutrition)
        (self.knowledge_base_path / 'emergency' / 'quick_reference.txt').write_text(emergency)
        
        print("✅ Sample documents created!")
        print(f"   📍 Location: {self.knowledge_base_path}")
        print("   📝 4 documents covering dog/cat health, nutrition, and emergencies")
    
    def build(self, create_samples: bool = True):
        """Build the vector database"""
        
        print("\n" + "="*60)
        print("🏗️  Building PawPal Knowledge Base")
        print("="*60 + "\n")
        
        # Create sample documents if knowledge base is empty
        if create_samples and not any(self.knowledge_base_path.rglob("*.txt")):
            self.create_sample_documents()
        
        # Load documents
        documents = self.load_documents()
        
        if not documents:
            print("\n⚠️  No documents found!")
            print("   Add veterinary documents (.pdf, .txt, .csv) to:")
            print(f"   {self.knowledge_base_path.absolute()}")
            return
        
        # Split documents into chunks
        print(f"\n✂️  Splitting documents (chunk_size={self.chunk_size}, overlap={self.chunk_overlap})...")
        chunks = self.text_splitter.split_documents(documents)
        print(f"   Created {len(chunks)} chunks from {len(documents)} documents")
        
        # Create vector database
        print(f"\n🔨 Creating vector database at {self.vector_db_path}...")
        print("   This may take a few minutes...")
        
        vector_db = Chroma.from_documents(
            documents=chunks,
            embedding=self.embeddings,
            persist_directory=self.vector_db_path
        )
        
        # Persist to disk
        vector_db.persist()
        
        print(f"\n✅ SUCCESS! Vector database created!")
        print(f"   📊 Total chunks indexed: {len(chunks)}")
        print(f"   💾 Saved to: {Path(self.vector_db_path).absolute()}")
        print(f"\n🎉 Knowledge base is ready for RAG queries!")
        print(f"   Run: python chatbot.py")


if __name__ == "__main__":
    builder = KnowledgeBaseBuilder()
    builder.build(create_samples=True)
