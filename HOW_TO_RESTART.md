# How to Restart the App

## 🔄 Quick Restart Guide

### **Method 1: Using Batch Files (Easiest)**

#### Restart Backend:
1. Close the backend terminal window (if open)
2. Double-click: `start_backend.bat`
3. Wait for: `✅ Connected to MongoDB`

#### Restart Frontend:
1. Close the frontend terminal window (if open)
2. Double-click: `start_frontend.bat`
3. Wait for the browser to open automatically

---

### **Method 2: Using Terminal/Command Prompt**

#### Restart Backend:
```bash
# Stop the backend (Ctrl+C in the terminal)
# Then run:
cd backend
npm start
```

#### Restart Frontend:
```bash
# Stop the frontend (Ctrl+C in the terminal)
# Then run:
cd frontend
flutter run -d chrome
```

---

### **Method 3: Kill and Restart (If stuck)**

#### For Backend (Port 5000):
```bash
# Find the process
netstat -ano | findstr :5000

# Kill it (replace XXXX with the PID number)
taskkill //F //PID XXXX

# Start again
cd backend
npm start
```

#### For Frontend (Port 8080/8081):
```bash
# Find the process
netstat -ano | findstr :8080

# Kill it (replace XXXX with the PID number)
taskkill //F //PID XXXX

# Start again
cd frontend
flutter run -d chrome
```

---

## 🎯 **When to Restart:**

### **Restart Backend When:**
- ✅ You change `.env` file (email password, database URL, etc.)
- ✅ You modify backend code (routes, models, services)
- ✅ Backend crashes or shows errors
- ✅ You update npm packages

### **Restart Frontend When:**
- ✅ You modify Dart code
- ✅ You add new packages to `pubspec.yaml`
- ✅ Frontend crashes or shows errors
- ✅ Hot reload doesn't work

### **No Restart Needed When:**
- ❌ Just viewing the app in browser
- ❌ Testing existing features
- ❌ Reading documentation

---

## 🚀 **Current Status:**

✅ **Backend:** Running on http://localhost:5000
✅ **Frontend:** Running on http://localhost:8081
✅ **Database:** MongoDB connected

---

## 📝 **Quick Commands:**

### Check if Backend is Running:
```bash
curl http://localhost:5000
```
Should return: `{"message":"AssureFix API is running!","status":"healthy"}`

### Check if Frontend is Running:
Open browser: http://localhost:8081

---

## ⚡ **Hot Reload (Frontend Only):**

When the Flutter app is running, you can use **Hot Reload** instead of full restart:

1. Make changes to your Dart code
2. Press `r` in the terminal (hot reload)
3. Press `R` in the terminal (hot restart)
4. Press `q` to quit

**Note:** Hot reload is faster than full restart!

---

## 🛑 **How to Stop the Apps:**

### Stop Backend:
- Press `Ctrl+C` in the backend terminal
- Or close the terminal window

### Stop Frontend:
- Press `q` in the frontend terminal
- Or press `Ctrl+C`
- Or close the terminal window

---

## 🔧 **Troubleshooting:**

### "Port already in use" error:
```bash
# For backend (port 5000)
netstat -ano | findstr :5000
taskkill //F //PID [PID_NUMBER]

# For frontend (port 8081)
netstat -ano | findstr :8081
taskkill //F //PID [PID_NUMBER]
```

### "MongoDB connection failed":
1. Make sure MongoDB is running
2. Check `MONGODB_URI` in `backend/.env`
3. Restart MongoDB service

### "Flutter command not found":
1. Make sure Flutter is installed
2. Add Flutter to PATH
3. Run: `flutter doctor`

---

## ✅ **Apps Successfully Restarted!**

Both backend and frontend are now running with the latest changes.

**Backend:** http://localhost:5000
**Frontend:** http://localhost:8081

You can now test the email OTP functionality! 📧
