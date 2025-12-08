# 🚀 Quick Start - 5 Minutes to Running App

Follow these steps to get PawPal running on your machine.

## ⚡ Fastest Path to Success

### Step 1: Check Prerequisites (1 minute)
```bash
# Run the prerequisite checker
check-prerequisites.bat
```

This will verify you have:
- ✅ Go installed
- ✅ Python installed  
- ✅ Flutter installed
- ✅ Git installed

**Missing something?** See detailed installation in `SETUP_GUIDE.md`

---

### Step 2: Configure Backend (2 minutes)

1. **Create environment file:**
   ```bash
   cd Backend
   copy .env.example .env
   ```

2. **Get Supabase credentials:**
   - Go to [supabase.com](https://supabase.com)
   - Create a free project
   - Copy Project URL and API keys from Settings > API

3. **Update `Backend\.env`:**
   ```env
   SUPABASE_URL=https://YOUR_PROJECT.supabase.co
   SUPABASE_ANON_KEY=your_anon_key_here
   SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here
   GROQ_API_KEY=your_groq_api_key_here
   ```

4. **Run database migrations:**
   - Open Supabase SQL Editor
   - Paste contents of `Backend/migrations/001_initial_schema.sql`
   - Click "RUN"

---

### Step 3: Start Services (2 minutes)

**Option A: Start Everything at Once**
```bash
# This opens 3 windows: Backend, Chatbot, Flutter
start-all-services.bat
```

**Option B: Start Individually**
```bash
# Terminal 1: Backend
cd Backend
start-backend.bat

# Terminal 2: Chatbot (optional)
cd AI_Chatbot
start-chatbot.bat

# Terminal 3: Flutter
cd App
flutter run
```

---

## 📱 What You'll See

1. **Backend** starts on `http://localhost:8081`
2. **Chatbot** starts on `http://localhost:8000` 
3. **Flutter App** launches on your emulator/device

---

## 🧪 Test It's Working

### Test Backend:
```bash
curl http://localhost:8081/health
```
Expected: `{"status": "healthy"}`

### Test Chatbot:
```bash
curl -X POST http://localhost:8000/health
```
Expected: `{"status": "healthy", "rag_loaded": true}`

### Test App:
- Open app on emulator
- Complete onboarding
- Sign up with email/password
- Select "Pet Owner" role
- You're in! 🎉

---

## ⚠️ Common First-Time Issues

### "Supabase connection failed"
- Check your `.env` file has correct credentials
- Verify Supabase project is active
- Make sure you ran the migration SQL

### "Python module not found"
```bash
cd AI_Chatbot
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
```

### "Flutter build failed"
```bash
cd App
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### "Port already in use"
- Something is using port 8081 or 8000
- Change port in `.env` OR kill the process

---

## 📚 Next Steps

Once running:
- 📖 Read `SETUP_GUIDE.md` for detailed configuration
- 🔧 Explore the codebase
- 🐛 Check `Backend/README.md` for API documentation
- 🤖 See `AI_Chatbot/README.md` for chatbot details

---

## 🆘 Need Help?

1. Check terminal outputs for error messages
2. Verify all environment variables are set
3. Review `SETUP_GUIDE.md` for detailed troubleshooting
4. Check that all services are running

---

**Ready to code? Let's go! 🐾**
