# Deployment Status & Quick Fix Guide

## 🚨 Current Issue: Site Not Working

**Symptoms:**
- ❌ Login screen not working
- ❌ Can't save invoices
- ❌ Can't download PDF
- ❌ Line items not adding
- ❌ Logout button not working

**Root Cause:** Missing Supabase configuration in deployment

---

## ✅ **Quick Fix (5 Minutes)**

### **Step 1: Add GitHub Secret** ⚠️ REQUIRED

1. **Go to:** https://github.com/aahincapie/invoice-generator/settings/secrets/actions

2. **Click:** "New repository secret"

3. **Add this secret:**
   ```
   Name: SUPABASE_PUBLISHABLE_KEY
   Secret: sb_publishable_u3Vv70ovBiEGZ8G1uCdw7w_phEZhjo4
   ```

4. **Click:** "Add secret"

---

### **Step 2: Trigger Redeploy**

After adding the secret, the site needs to redeploy. Two options:

**Option A: Manual Trigger (Recommended)**
1. Go to: https://github.com/aahincapie/invoice-generator/actions
2. Click "Deploy to GitHub Pages" workflow
3. Click "Run workflow" button
4. Select branch: `main`
5. Click "Run workflow"

**Option B: Push a Small Change**
```bash
# Make any small change to trigger deployment
git commit --allow-empty -m "Trigger redeploy with Supabase config"
git push origin main
```

---

### **Step 3: Set Up Supabase Database**

While waiting for deployment:

1. **Go to SQL Editor:**
   https://supabase.com/dashboard/project/fwpadfroagpzkmcxzppq/sql

2. **Click "New Query"**

3. **Copy and paste ALL of this SQL:**
   (Open `supabase-schema.sql` in the repository and copy its contents)

4. **Click "Run"** (or press Ctrl+Enter)

5. **Verify:** Go to Table Editor and check that `invoices` table exists

---

### **Step 4: Enable Email Authentication**

1. **Go to Auth Settings:**
   https://supabase.com/dashboard/project/fwpadfroagpzkmcxzppq/auth/providers

2. **Find "Email" provider**

3. **Toggle it ON** (enable)

4. **Click "Save"**

---

### **Step 5: Test the Site** (After Redeploy - Wait 2-3 minutes)

1. **Visit:** https://aahincapie.github.io/invoice-generator/

2. **You should now see:**
   - ✅ Login screen with email/password fields
   - ✅ Sign Up / Sign In buttons

3. **Test Sign Up:**
   - Click "Sign Up"
   - Enter your email and password
   - Check email for confirmation link
   - Click confirmation link
   - Return and Sign In

4. **Test Invoice Creation:**
   - ✅ Upload logo and signature
   - ✅ Fill invoice details
   - ✅ Add line items (+ Line Item button works)
   - ✅ Click "Save" (should say "Invoice saved")
   - ✅ Click "Download PDF" (should download)

5. **Test Dashboard:**
   - ✅ Switch to "Dashboard" tab
   - ✅ See your invoices
   - ✅ Change status

6. **Test Logout:**
   - ✅ Click "Logout" button
   - ✅ Should return to login screen

---

## 🔍 **How to Verify Secret Was Added**

1. Go to: https://github.com/aahincapie/invoice-generator/settings/secrets/actions
2. You should see: `SUPABASE_PUBLISHABLE_KEY` in the list
3. It will show "Updated X minutes ago"

---

## 🔍 **How to Check Deployment Status**

1. Go to: https://github.com/aahincapie/invoice-generator/actions
2. Look for latest "Deploy to GitHub Pages" workflow
3. Should show green checkmark ✅
4. Click on it to see logs
5. In the "Create config.js from secrets" step, you should see the config file created

---

## 🐛 **Troubleshooting**

### Issue: "Config file still not working after redeploy"

**Check workflow logs:**
1. Go to Actions → Latest workflow run
2. Click "build" job
3. Check "Create config.js from secrets" step
4. If it shows `publishableKey: ''` (empty), the secret wasn't added correctly

**Fix:** Delete and re-add the secret, ensure exact name: `SUPABASE_PUBLISHABLE_KEY`

---

### Issue: "Can sign in but can't save invoices"

**Cause:** Database not set up

**Fix:**
1. Run the SQL schema from `supabase-schema.sql`
2. Check browser console for errors (F12)
3. Should see Supabase errors if database is missing

---

### Issue: "Email confirmation required but no email received"

**Fix Options:**

**Option 1:** Disable email confirmation
1. Go to: https://supabase.com/dashboard/project/fwpadfroagpzkmcxzppq/auth/providers
2. Scroll to Email provider settings
3. Uncheck "Confirm email"
4. Save

**Option 2:** Check spam folder for confirmation email

**Option 3:** Use a different email address

---

### Issue: "Logout button doesn't work"

**Cause:** JavaScript error or Supabase not initialized

**Fix:**
1. Open browser console (F12)
2. Look for errors
3. Ensure config.js has valid publishableKey
4. Clear browser cache and try again

---

## ✅ **Success Checklist**

After completing all steps, verify:

- [ ] GitHub Secret `SUPABASE_PUBLISHABLE_KEY` is added
- [ ] Deployment workflow ran successfully (green checkmark)
- [ ] Supabase database schema is created
- [ ] Email authentication is enabled
- [ ] Site shows login screen
- [ ] Can create account and sign in
- [ ] Can upload images
- [ ] Can add line items
- [ ] Can save invoices
- [ ] Can download PDF
- [ ] Can switch to Dashboard tab
- [ ] Can logout

---

## 📞 **Still Not Working?**

Open browser console (F12) and check for errors. Common error messages:

- **"SUPABASE_CONFIG is not defined"** → Secret not added or deployment didn't run
- **"relation 'invoices' does not exist"** → Database schema not run
- **"Invalid API key"** → Wrong secret value
- **"Permission denied"** → RLS policies issue (should be fixed by schema)

---

## 🎯 **Expected Timeline**

- **Add Secret:** 1 minute
- **Trigger Redeploy:** 1 minute
- **Wait for Deployment:** 2-3 minutes
- **Set Up Database:** 2 minutes
- **Enable Auth:** 1 minute
- **Test Site:** 2-3 minutes

**Total:** ~10 minutes to full working site

---

## 📝 **Current Configuration**

- **Supabase URL:** `https://fwpadfroagpzkmcxzppq.supabase.co`
- **Publishable Key:** `sb_publishable_u3Vv70ovBiEGZ8G1uCdw7w_phEZhjo4`
- **Deployed Site:** https://aahincapie.github.io/invoice-generator/
- **Repository:** https://github.com/aahincapie/invoice-generator

---

**Last Updated:** After merge of PR #5
**Status:** ⚠️ Awaiting GitHub Secret configuration and Supabase setup
