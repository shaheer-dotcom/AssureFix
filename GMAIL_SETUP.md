# Gmail App Password Setup - Quick Guide

## ⚠️ **Important: Email OTP Won't Work Until You Complete This**

Your app is showing "Failed to send verification code" because the Gmail App Password is not configured.

---

## 🔧 **Quick Fix (5 minutes)**

### **Step 1: Enable 2-Step Verification**

1. Go to: https://myaccount.google.com/security
2. Click on **"2-Step Verification"**
3. Follow the prompts to enable it (you'll need your phone)

### **Step 2: Create App Password**

1. After enabling 2-Step Verification, go back to: https://myaccount.google.com/security
2. Scroll down to **"2-Step Verification"** section
3. Click on **"App passwords"** at the bottom
4. You might need to sign in again
5. In the "Select app" dropdown, choose **"Mail"**
6. In the "Select device" dropdown, choose **"Other (Custom name)"**
7. Type: **"AssureFix"**
8. Click **"Generate"**
9. **Copy the 16-character password** (it looks like: `abcd efgh ijkl mnop`)

### **Step 3: Add to Your App**

1. Open file: `backend/.env`
2. Find the line: `EMAIL_PASS=YOUR_GMAIL_APP_PASSWORD_HERE`
3. Replace `YOUR_GMAIL_APP_PASSWORD_HERE` with your 16-character password
4. **Remove all spaces** - it should look like: `EMAIL_PASS=abcdefghijklmnop`
5. Save the file

### **Step 4: Restart Backend**

The backend will restart automatically, or you can restart it manually.

---

## ✅ **Test It**

1. Go to your app: http://localhost:8082
2. Click "Register"
3. Enter your email
4. Click "Send Verification Code"
5. **Check your email** - you should receive the OTP!

---

## 🔄 **Alternative: Use Console OTP (For Testing)**

If you don't want to set up Gmail right now, you can use the OTP from the console:

1. Try to register
2. Check the **backend terminal/console**
3. Look for lines like:
   ```
   📧 ASSUREFIX - EMAIL VERIFICATION CODE
   To: your@email.com
   OTP: 123456
   ```
4. Copy the OTP code
5. Enter it in the app

**Note:** This only works for testing. For production, you MUST configure Gmail.

---

## 📝 **Your Current Configuration**

File: `backend/.env`

```env
EMAIL_USER=shaheer13113@gmail.com
EMAIL_PASS=YOUR_GMAIL_APP_PASSWORD_HERE  ← Replace this!
PRIMARY_ADMIN_EMAIL=shaheer13113@gmail.com
```

---

## ❓ **Troubleshooting**

### **"Invalid credentials" error:**
- Make sure you're using the App Password, not your regular Gmail password
- Remove all spaces from the password
- Make sure 2-Step Verification is enabled

### **"Less secure app" error:**
- This doesn't apply to App Passwords
- App Passwords work even with enhanced security

### **Still not working:**
1. Double-check the password has no spaces
2. Make sure the email is correct: `shaheer13113@gmail.com`
3. Restart the backend server
4. Try generating a new App Password

---

## 🎯 **Quick Summary**

1. ✅ Enable 2-Step Verification
2. ✅ Generate App Password
3. ✅ Add to `backend/.env`
4. ✅ Restart backend
5. ✅ Test registration

**Time needed:** 5 minutes
**Difficulty:** Easy

---

## 📞 **Need Help?**

If you're stuck, you can:
1. Use console OTP for now (see above)
2. Follow the detailed guide in `ADMIN_SETUP_GUIDE.md`
3. Check Google's official guide: https://support.google.com/accounts/answer/185833

---

**Once configured, email OTP will work perfectly!** 📧✅
