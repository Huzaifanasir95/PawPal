# 🎯 PawPal - Step-by-Step Running Instructions

## Current Status ✅

**What's Ready:**
- ✅ Python virtual environment created (`AI_Chatbot/venv`)
- ✅ Python dependencies installing
- ✅ Backend `.env` file created
- ✅ Git installed
- ✅ Python 3.13.9 installed

**What's Needed:**
- ❌ Go installation (required for Backend)
- ❌ Supabase account setup
- ❌ Flutter (optional - for mobile app)

---

## 🚀 Quick Run Guide (30 Minutes)

### STEP 1: Install Go (5 minutes) ⏱️

1. **Download Go:**
   - Visit: https://go.dev/dl/
   - Download: `go1.21.x.windows-amd64.msi` (or newer)
   - File size: ~140 MB

2. **Install:**
   - Run the downloaded `.msi` file
   - Use default installation path: `C:\Go`
   - Click "Next" → "Next" → "Install"
   - **Important:** Restart your terminal/CMD after installation

3. **Verify:**
   ```bash
   go version
   ```
   Should show: `go version go1.21.x windows/amd64`

---

### STEP 2: Setup Supabase Database (10 minutes) ⏱️

1. **Create Account:**
   - Go to: https://supabase.com
   - Click "Start your project"
   - Sign up with GitHub/Google (free)

2. **Create New Project:**
   - Click "New Project"
   - Name: `pawpal` (or anything)
   - Database Password: Choose a strong password (save it!)
   - Region: Choose closest to you
   - Click "Create new project"
   - Wait 2-3 minutes for provisioning

3. **Get API Keys:**
   - Go to Project Settings (⚙️ icon) → API
   - Copy these values:
     - **Project URL** (looks like: `https://xxxxx.supabase.co`)
     - **anon public** key (starts with `eyJhbGc...`)
     - **service_role** key (starts with `eyJhbGc...`)

4. **Run Database Migration:**
   - In Supabase Dashboard, click "SQL Editor" (left sidebar)
   - Click "New query"
   - Open file: `Backend/migrations/001_initial_schema.sql`
   - Copy ALL contents and paste into Supabase SQL Editor
   - Click "RUN" (bottom right)
   - Should see: "Success. No rows returned"

---

### STEP 3: Configure Backend (2 minutes) ⏱️

1. **Edit `.env` file:**
   ```bash
   notepad "d:\D drive\SEm 07\fyp\project_code\PawPal\Backend\.env"
   ```

2. **Update these lines** with your Supabase values:
   ```env
   # Replace YOUR_PROJECT with your actual project ID from Supabase URL
   SUPABASE_URL=https://YOUR_PROJECT.supabase.co
   SUPABASE_ANON_KEY=eyJhbGc... (paste your anon key)
   SUPABASE_SERVICE_ROLE_KEY=eyJhbGc... (paste your service_role key)
   
   # Get from Supabase Settings → Database → Connection String
   DB_HOST=aws-0-xx-x.pooler.supabase.com
   DB_PASSWORD=your_database_password
   ```

3. **Save and close** the file

---

### STEP 4: Get Groq API Key (3 minutes) ⏱️

1. **Create Groq Account:**
   - Visit: https://console.groq.com
   - Sign up (free)

2. **Generate API Key:**
   - Go to "API Keys" section
   - Click "Create API Key"
   - Name it: `PawPal`
   - Copy the key (starts with `gsk_...`)

3. **Add to `.env`:**
   ```bash
   notepad "d:\D drive\SEm 07\fyp\project_code\PawPal\Backend\.env"
   ```
   Update:
   ```env
   GROQ_API_KEY=gsk_your_actual_key_here
   ```

---

### STEP 5: Build AI Knowledge Base (5 minutes) ⏱️

Open a **new terminal** and run:

```bash
cd /d "d:\D drive\SEm 07\fyp\project_code\PawPal\AI_Chatbot"
venv\Scripts\activate
python build_knowledge_base.py
```

This will:
- Process veterinary documents
- Create vector embeddings
- Build ChromaDB database
- Takes ~5 minutes

---

### STEP 6: Start Backend Server (1 minute) ⏱️

Open a **new terminal** (Terminal 1):

```bash
cd /d "d:\D drive\SEm 07\fyp\project_code\PawPal\Backend"
go mod download
go run cmd\api\main.go
```

You should see:
```
Starting PawPal Backend API server on port 8081
Access at: http://localhost:8081
```

**Keep this terminal open!**

---

### STEP 7: Start Chatbot Server (1 minute) ⏱️

Open **another new terminal** (Terminal 2):

```bash
cd /d "d:\D drive\SEm 07\fyp\project_code\PawPal\AI_Chatbot"
venv\Scripts\activate
python chatbot_fastapi_server.py
```

You should see:
```
🚀 Initializing PawPal RAG System...
✅ RAG System ready!
INFO: Uvicorn running on http://0.0.0.0:8000
```

**Keep this terminal open too!**

---

## ✅ Test Everything Works

### Test 1: Backend Health Check
Open **new terminal** (Terminal 3):
```bash
curl http://localhost:8081/health
```
Expected: `{"status":"healthy"}`

### Test 2: Chatbot Health Check
```bash
curl http://localhost:8000/health
```
Expected: `{"status":"healthy","rag_loaded":true}`

### Test 3: Create Test User
```bash
curl -X POST http://localhost:8081/api/v1/auth/signup ^
  -H "Content-Type: application/json" ^
  -d "{\"email\":\"test@example.com\",\"password\":\"Test123!\",\"displayName\":\"Test User\"}"
```
Expected: JSON with user details and access token

### Test 4: Ask Chatbot
```bash
curl -X POST http://localhost:8000/api/chatbot/query ^
  -H "Content-Type: application/json" ^
  -d "{\"message\":\"What should I feed my puppy?\"}"
```
Expected: JSON with AI-generated veterinary advice

---

## 🎉 Success! What's Running?

You now have:
- ✅ **Backend API** on `http://localhost:8081`
- ✅ **AI Chatbot** on `http://localhost:8000`
- ✅ **Database** on Supabase cloud
- ✅ **Vector DB** locally for AI RAG

---

## 🔄 Daily Workflow

**To start everything after first setup:**

1. Open 2 terminals

**Terminal 1 - Backend:**
```bash
cd /d "d:\D drive\SEm 07\fyp\project_code\PawPal\Backend"
go run cmd\api\main.go
```

**Terminal 2 - Chatbot:**
```bash
cd /d "d:\D drive\SEm 07\fyp\project_code\PawPal\AI_Chatbot"
venv\Scripts\activate
python chatbot_fastapi_server.py
```

**Or use the batch file:**
```bash
cd /d "d:\D drive\SEm 07\fyp\project_code\PawPal"
start-all-services.bat
```

---

## 🐛 Troubleshooting

### "Go not found" after installation
- Close ALL terminals and CMD windows
- Open a **fresh** terminal
- Try `go version` again

### "Supabase connection failed"
- Check `.env` file has correct credentials
- Verify no extra spaces in the keys
- Make sure you ran the SQL migration

### "Module not found" in Python
```bash
cd /d "d:\D drive\SEm 07\fyp\project_code\PawPal\AI_Chatbot"
venv\Scripts\activate
pip install -r requirements.txt
```

### "Port already in use"
```bash
# Kill process on port 8081
netstat -ano | findstr :8081
taskkill /PID <PID> /F

# Or change port in .env
PORT=8082
```

---

## 📱 Mobile App (Optional - Later)

To run the Flutter mobile app:

1. **Install Flutter:**
   - Download: https://docs.flutter.dev/get-started/install/windows
   - Extract and add to PATH
   - Run: `flutter doctor`

2. **Setup Firebase:**
   - Create project at: https://console.firebase.google.com
   - Add Android app
   - Download `google-services.json` → `App/android/app/`

3. **Run:**
   ```bash
   cd /d "d:\D drive\SEm 07\fyp\project_code\PawPal\App"
   flutter pub get
   flutter run
   ```

---

## 📚 API Testing

Use the test scripts in `Backend/scripts/`:
```bash
cd Backend\scripts
python test_vet_endpoints.py
```

Or use Postman:
- Import: `Backend/PawPal_API_Collection.postman_collection.json`

---

## 🎯 What You Can Do Now

With Backend + Chatbot running:

1. **Create user accounts** via API
2. **Add pets** to profiles
3. **Ask AI veterinary questions**
4. **Setup vet profiles**
5. **Test chat system**
6. **Browse API documentation** in `Backend/README.md`

---

**Need help? Check `SETUP_GUIDE.md` for more details!**
