# Invoice Generator - Complete Setup Guide

## 🎯 Overview

This invoice generator application includes:
- ✅ **Logo & Signature Upload** (Base64 storage)
- ✅ **Email-Based Authentication** (Supabase Auth)
- ✅ **Integrated Dashboard** (Tab navigation)
- ✅ **Cloud Sync** (Supabase backend)
- ✅ **Multilanguage Support** (EN/ES/PT)
- ✅ **Status Tracking** (Draft → Ready to Send → Paid)

---

## 📋 Prerequisites

1. Supabase account (https://supabase.com)
2. Your project URL: `https://fwpadfroagpzkmcxzppq.supabase.co`
3. Modern web browser (Chrome, Firefox, Safari, Edge)

---

## 🚀 Step-by-Step Setup

### **Step 1: Clone and Set Up Configuration**

1. **Clone the repository** (if not already done)
   ```bash
   git clone https://github.com/aahincapie/invoice-generator.git
   cd invoice-generator
   ```

2. **Create config.js from template**
   ```bash
   cp config.example.js config.js
   ```

3. **Get your Supabase Publishable Key:**
   - Go to: https://supabase.com/dashboard/project/fwpadfroagpzkmcxzppq
   - Click **Settings** → **API**
   - Copy the **Publishable Key** (starts with `sb_publishable_`)

4. **Edit config.js:**
   ```javascript
   const SUPABASE_CONFIG = {
     url: 'https://fwpadfroagpzkmcxzppq.supabase.co',
     publishableKey: 'YOUR_PUBLISHABLE_KEY_HERE' // ← Paste your key here
   };
   ```

   **⚠️ IMPORTANT:** Never commit `config.js` to GitHub! It's already in `.gitignore`

---

### **Step 2: Set Up Supabase Database**

1. **Go to SQL Editor:**
   - Navigate to: https://supabase.com/dashboard/project/fwpadfroagpzkmcxzppq/sql
   - Click **New Query**

2. **Run the Schema:**
   - Copy ALL contents from `supabase-schema.sql`
   - Paste into SQL Editor
   - Click **Run** (or press Ctrl+Enter)

3. **Verify Tables Created:**
   - Go to **Table Editor**
   - You should see the `invoices` table

---

### **Step 3: Enable Email Authentication**

1. **Go to Authentication Settings:**
   - Navigate to: https://supabase.com/dashboard/project/fwpadfroagpzkmcxzppq/auth/providers
   - Click **Email** provider

2. **Configure Email Auth:**
   - ✅ Enable Email provider
   - ✅ Confirm email: **Enabled** (recommended)
   - Click **Save**

3. **Configure Site URL (Optional but Recommended):**
   - Go to **Authentication** → **URL Configuration**
   - Set **Site URL** to your deployment URL (e.g., `https://aahincapie.github.io/invoice-generator/`)

---

### **Step 4: Test Locally**

1. **Open the Application:**
   ```bash
   # If you have a local server (recommended):
   python -m http.server 8000
   # OR
   npx http-server
   
   # Then open: http://localhost:8000
   ```

   OR simply open `index.html` in your browser (may have CORS issues with some browsers)

2. **Create an Account:**
   - You should see the **Sign In** page
   - Click **Sign Up**
   - Enter your email and password
   - Check your email for confirmation link (if enabled)
   - Click confirmation link
   - Return to app and **Sign In**

3. **Test the Application:**
   - ✅ Upload logo and signature images
   - ✅ Create an invoice
   - ✅ Click **Save** → Should save to cloud
   - ✅ Click **Download PDF** → Status should change to "Ready to Send"
   - ✅ Switch to **Dashboard** tab
   - ✅ See your invoice listed
   - ✅ Change status to "Paid"

---

## 🎨 Features Guide

### **Authentication**

**Sign Up:**
1. Open the app
2. Click **Sign Up**
3. Enter email and password
4. Check email for confirmation (if enabled)
5. Click confirmation link
6. Return and **Sign In**

**Sign In:**
1. Enter email and password
2. Click **Sign In**
3. App loads with your invoices

**Logout:**
- Click **Logout** button in top right
- Returns to Sign In page

---

### **Create Invoice**

1. **Upload Images** (optional):
   - Click **Company Logo** → Select PNG/JPG
   - Click **Signature** → Select PNG/JPG
   - Images appear in invoice preview

2. **Fill Invoice Details:**
   - Invoice Number
   - Date & Due Date
   - Bill To / Ship To
   - Add line items
   - Notes and payment details

3. **Save Invoice:**
   - Click **Save** button
   - Status: **Draft**
   - Saved to cloud (if authenticated)

4. **Download PDF:**
   - Click **Download PDF**
   - Status automatically changes to: **Ready to Send**
   - PDF includes logo and signature

---

### **Dashboard**

1. **Switch to Dashboard:**
   - Click **Dashboard** tab

2. **View Statistics:**
   - Total Invoices
   - Draft count
   - Ready to Send count
   - Paid count

3. **Filter Invoices:**
   - Use status dropdown to filter
   - Use search box for invoice # or client name

4. **Update Status:**
   - Click status dropdown on any invoice
   - Select new status (Draft / Ready to Send / Paid)
   - Status updates immediately

---

## 🔐 Security & Privacy

### **Row Level Security (RLS)**

The database is configured so that:
- ✅ Users can only see their own invoices
- ✅ Users cannot access other users' data
- ✅ All operations are user-scoped

### **Data Storage**

- **Images:** Base64 encoded, stored in database
- **Personal Data:** Encrypted by Supabase
- **Passwords:** Hashed by Supabase Auth

### **Config File Security**

- `config.js` is **NOT committed** to GitHub
- Listed in `.gitignore`
- Use `config.example.js` as template
- Only share publishable key (not secret key)

---

## 🌐 Deployment to GitHub Pages

### **Option 1: Automatic Deployment** (Already configured)

1. **Commit your changes:**
   ```bash
   git add .
   git commit -m "Your changes"
   git push origin main
   ```

2. **GitHub Actions will:**
   - Automatically build
   - Deploy to GitHub Pages
   - Available at: `https://aahincapie.github.io/invoice-generator/`

3. **⚠️ IMPORTANT for GitHub Pages:**
   Since `config.js` is not committed, you need to configure it manually:

   **Create config.js on GitHub Pages:**
   - Option A: Create a separate branch `gh-pages` with config.js
   - Option B: Use GitHub Secrets and build step (advanced)
   - **Option C (Recommended): Environment Variables via GitHub Actions**

### **Option 2: Manual Deployment**

Deploy to any static hosting:
- Netlify
- Vercel
- Cloudflare Pages

Remember to:
1. Include `config.js` with your credentials
2. Set environment variables if supported

---

## 🧪 Testing Checklist

### **Authentication Tests**
- [ ] Sign up with new email
- [ ] Receive confirmation email
- [ ] Confirm email and sign in
- [ ] Logout and sign back in
- [ ] Try signing in with wrong password (should fail)

### **Invoice Creation Tests**
- [ ] Upload logo image
- [ ] Upload signature image
- [ ] Create invoice with all fields
- [ ] Save invoice (status = draft)
- [ ] Download PDF (status changes to ready_to_send)
- [ ] Verify images in PDF

### **Dashboard Tests**
- [ ] Switch to Dashboard tab
- [ ] See invoice in list
- [ ] Statistics show correct counts
- [ ] Filter by status works
- [ ] Search by invoice # works
- [ ] Update status from dashboard
- [ ] Status persists after refresh

### **Multi-user Tests**
- [ ] Sign up with second email
- [ ] Create invoice
- [ ] Verify first user can't see second user's invoices
- [ ] Verify each user only sees their own data

---

## 🔧 Troubleshooting

### **Problem: "Sign In" page doesn't appear**

**Cause:** Supabase not configured

**Fix:**
1. Verify `config.js` exists
2. Check publishable key is correct
3. Clear browser cache and refresh

---

### **Problem: "Failed to save invoice"**

**Cause:** Not authenticated or RLS policies blocking

**Fix:**
1. Ensure you're signed in
2. Check browser console for errors
3. Verify RLS policies in Supabase dashboard
4. Ensure `user_id` column exists in invoices table

---

### **Problem: "Email confirmation required"**

**Solution:** This is normal!
1. Check your email inbox
2. Click the confirmation link
3. Return to app and sign in
4. OR disable email confirmation in Supabase settings

---

### **Problem: Can't see other user's invoices in dashboard**

**This is correct!** 
- Each user can only see their own invoices
- This is enforced by Row Level Security (RLS)
- It's a security feature, not a bug

---

### **Problem: Images not showing in PDF**

**Fixes:**
1. Use PNG or JPG only (not HEIC, WebP, etc.)
2. Keep images under 2MB
3. Check browser console for errors
4. Try re-uploading the image

---

### **Problem: Status not updating when downloading PDF**

**Cause:** Not authenticated or invoice not in database

**Fix:**
1. Sign in first
2. Save invoice before downloading PDF
3. Check browser console for errors

---

## 📊 Database Schema

```sql
invoices (
  id                BIGSERIAL PRIMARY KEY,
  user_id           UUID → auth.users(id),  -- User who owns this invoice
  invoice_number    TEXT,
  invoice_date      DATE,
  due_date          DATE,
  bill_to           TEXT,
  ship_to           TEXT,
  notes             TEXT,
  tax               DECIMAL(10, 2),
  payment_details   TEXT,
  currency          TEXT,
  total_amount      DECIMAL(10, 2),
  items             JSONB,                  -- Array of line items
  logo              TEXT,                   -- Base64 encoded image
  signature         TEXT,                   -- Base64 encoded image
  status            TEXT,                   -- draft | ready_to_send | paid
  created_at        TIMESTAMPTZ,
  updated_at        TIMESTAMPTZ
)
```

---

## 🎯 Status Workflow

```
1. Create Invoice
   ↓
2. Click "Save" → Status = "draft"
   ↓
3. Click "Download PDF" → Status = "ready_to_send"
   ↓
4. In Dashboard, manually mark → Status = "paid"
```

---

## 💡 Tips & Best Practices

1. **Save Frequently:**
   - Click Save before Download PDF
   - Changes are synced to cloud

2. **Use Search:**
   - Dashboard search works on invoice # and client name
   - Very useful for finding specific invoices

3. **Filter by Status:**
   - See only Draft invoices to finish
   - See only Ready to Send to track pending
   - See only Paid for accounting

4. **Logout When Done:**
   - Especially on shared computers
   - Protects your data

5. **Backup:**
   - Data is in Supabase cloud
   - Also stored in browser localStorage
   - Export important invoices as PDF

---

## 🆘 Need Help?

1. **Check browser console** for error messages
2. **Check Supabase logs** in dashboard
3. **Review this setup guide**
4. **Check TESTING-CHECKLIST.md** for detailed tests
5. **Review supabase-schema.sql** for database structure

---

## 📝 For Developers

### **Local Development:**

```bash
# Install a local server (if not already)
npm install -g http-server

# Run server
http-server -p 8000

# Open browser
http://localhost:8000
```

### **Environment Variables:**

For production deployment, consider:
- GitHub Actions secrets
- Environment variable substitution
- Build-time configuration injection

### **Code Structure:**

- `index.html` - Main application (auth + invoice + dashboard)
- `config.js` - Credentials (not committed)
- `config.example.js` - Template (committed)
- `supabase-schema.sql` - Database schema
- `.gitignore` - Protects config.js

---

## ✅ Ready to Use!

Once you've completed the setup:
1. ✅ Supabase configured
2. ✅ Database schema created
3. ✅ Email auth enabled
4. ✅ config.js created with your credentials
5. ✅ Application tested locally

**You're ready to create professional invoices!** 🎉
