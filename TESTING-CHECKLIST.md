# Testing Checklist

## ⚠️ Important: Before Testing

### 1. Configure Supabase Credentials
You **MUST** configure your Supabase credentials before the application will work with cloud storage:

**In `index.html` (line ~338):**
```javascript
const SUPABASE_ANON_KEY = 'YOUR_ANON_KEY_HERE'; // ← Replace this
```

**In `dashboard.html` (line ~105):**
```javascript
const SUPABASE_ANON_KEY = 'YOUR_ANON_KEY_HERE'; // ← Replace this
```

**Steps to get your key:**
1. Go to https://supabase.com/dashboard/project/fwpadfroagpzkmcxzppq
2. Click **Settings** → **API**
3. Copy the **anon/public** key
4. Replace `'YOUR_ANON_KEY_HERE'` with your actual key in both files

### 2. Set Up Database
Run the SQL schema in Supabase:
1. Go to **SQL Editor** in Supabase dashboard
2. Create new query
3. Copy contents of `supabase-schema.sql`
4. Click **Run**

## Testing Checklist

### ✅ Feature 1: Logo Upload
- [ ] Open `index.html` in browser
- [ ] Click "Company Logo" file input
- [ ] Select a PNG or JPG image
- [ ] **Expected:** Image appears in preview section
- [ ] **Expected:** Logo replaces "AHI" initials in invoice header
- [ ] Refresh page
- [ ] **Expected:** Logo persists (loaded from localStorage)
- [ ] Click "Remove" button
- [ ] **Expected:** Logo is removed, "AHI" initials return

### ✅ Feature 2: Signature Upload
- [ ] Click "Signature" file input
- [ ] Select a PNG or JPG image
- [ ] **Expected:** Image appears in preview section
- [ ] **Expected:** Signature appears in Terms & Payment section (bottom left)
- [ ] Refresh page
- [ ] **Expected:** Signature persists
- [ ] Click "Remove" button
- [ ] **Expected:** Signature is removed

### ✅ Feature 3: Save Invoice (With Supabase)
**Prerequisites:** Supabase credentials configured

- [ ] Fill in invoice details:
  - Invoice number: Test-001
  - Date: Today's date
  - Due Date: 30 days from today
  - Bill To: Test Client Ltd
  - Ship To: 123 Test Street
  - Add 2-3 line items
- [ ] Click **Save** button
- [ ] **Expected:** Toast message "Invoice saved locally (Local + Cloud)"
- [ ] Open browser DevTools → Console
- [ ] **Expected:** No errors
- [ ] Go to Supabase Dashboard → Table Editor → `invoices` table
- [ ] **Expected:** New row with invoice data

### ✅ Feature 4: Save Invoice (Without Supabase)
**Prerequisites:** Supabase NOT configured (key = 'YOUR_ANON_KEY_HERE')

- [ ] Fill in invoice details
- [ ] Click **Save** button
- [ ] **Expected:** Toast message "Invoice saved locally"
- [ ] Open browser DevTools → Application → Local Storage
- [ ] **Expected:** `invoices-7zones` key contains the invoice

### ✅ Feature 5: PDF Generation with Images
- [ ] Upload logo and signature images
- [ ] Fill in complete invoice details
- [ ] Click **Download PDF** button
- [ ] **Expected:** PDF downloads with filename `invoice-client-Test-001.pdf`
- [ ] Open the PDF
- [ ] **Expected:** Logo appears in header (top left)
- [ ] **Expected:** All ZONE 1-7 information is present
- [ ] **Expected:** Signature image appears in Terms & Payment section
- [ ] **Expected:** PDF is readable and properly formatted

### ✅ Feature 6: PDF Multi-Page Support
- [ ] Add 20+ line items to invoice
- [ ] Click **Download PDF**
- [ ] Open the PDF
- [ ] **Expected:** PDF has multiple pages
- [ ] **Expected:** Table headers repeat on each page
- [ ] **Expected:** No information is cut off or missing

### ✅ Feature 7: Dashboard - View Invoices
- [ ] Create 3-4 test invoices with different statuses
- [ ] Click **Dashboard** button
- [ ] **Expected:** Dashboard page opens
- [ ] **Expected:** Statistics cards show correct counts:
  - Total: All invoices
  - Draft: Invoices with status 'draft'
  - Sent: Invoices with status 'sent'
  - Paid: Invoices with status 'paid'
- [ ] **Expected:** Invoice table lists all invoices

### ✅ Feature 8: Dashboard - Filter by Status
- [ ] In dashboard, select "Draft" from status filter
- [ ] **Expected:** Only draft invoices shown
- [ ] Select "Sent"
- [ ] **Expected:** Only sent invoices shown
- [ ] Select "All Statuses"
- [ ] **Expected:** All invoices shown

### ✅ Feature 9: Dashboard - Search
- [ ] Type invoice number in search box (e.g., "Test-001")
- [ ] **Expected:** Only matching invoice shown
- [ ] Type client name in search box (e.g., "Test Client")
- [ ] **Expected:** Only matching invoices shown
- [ ] Clear search box
- [ ] **Expected:** All invoices shown

### ✅ Feature 10: Dashboard - Update Status
- [ ] Find an invoice with status "Draft"
- [ ] Click the status dropdown
- [ ] Select "Sent"
- [ ] **Expected:** Status updates immediately
- [ ] **If Supabase configured:** Check Supabase table
- [ ] **Expected:** Status updated in database
- [ ] Refresh page
- [ ] **Expected:** Status persists

### ✅ Feature 11: Status Auto-Update on PDF Download
- [ ] Create new invoice (status will be 'draft')
- [ ] Click **Save**
- [ ] Click **Download PDF**
- [ ] Go to Dashboard
- [ ] **If Supabase configured:** Invoice status should be 'sent'
- [ ] **Expected:** Status automatically changed from 'draft' to 'sent'

### ✅ Feature 12: Multilanguage Support
- [ ] Change language selector to "Español"
- [ ] **Expected:** All labels change to Spanish
- [ ] Change to "Português"
- [ ] **Expected:** All labels change to Portuguese
- [ ] Change back to "English"
- [ ] **Expected:** All labels change to English

### ✅ Feature 13: Currency Support (BRL)
- [ ] Select "BRL (R$)" from currency dropdown
- [ ] Add line items
- [ ] **Expected:** Balance Due shows "BRL R$ X.XX"
- [ ] **Expected:** Totals section shows "BRL R$"
- [ ] Click **Download PDF**
- [ ] **Expected:** PDF shows BRL R$ currency

## Common Issues & Troubleshooting

### Issue: "Invoice saved locally (Supabase error)"
**Cause:** Supabase credentials not configured or incorrect
**Fix:** 
1. Verify SUPABASE_ANON_KEY is set correctly
2. Check browser console for specific error
3. Verify database schema is created

### Issue: Images not showing in PDF
**Cause:** Invalid image format or too large
**Fix:**
1. Use PNG or JPG only
2. Keep images under 2MB
3. Check browser console for errors

### Issue: Dashboard shows "Loading invoices..."
**Cause:** JavaScript error or no invoices exist
**Fix:**
1. Open browser console, check for errors
2. Create at least one invoice first
3. Verify Supabase connection

### Issue: Status not updating in Supabase
**Cause:** RLS policies or permissions
**Fix:**
1. Check Supabase RLS policies
2. Verify anon key has write permissions
3. Check browser console for 403 errors

## Browser Compatibility

Tested on:
- [ ] Chrome/Edge (latest)
- [ ] Firefox (latest)
- [ ] Safari (latest)

## Performance Tests

- [ ] Upload 5MB image - Should show warning or resize
- [ ] Create invoice with 100 line items - Should handle gracefully
- [ ] Dashboard with 50+ invoices - Should load within 3 seconds

## Security Checks

- [ ] Supabase credentials not exposed in browser DevTools
- [ ] localStorage data is sanitized
- [ ] No XSS vulnerabilities in text fields
- [ ] Base64 images are validated before storage

## Final Verification

Before declaring testing complete:
1. [ ] All features work with Supabase configured
2. [ ] All features work WITHOUT Supabase (localStorage fallback)
3. [ ] No console errors during normal operation
4. [ ] PDF generation works with and without images
5. [ ] Dashboard reflects accurate data
6. [ ] Multilanguage works across all pages
7. [ ] Data persists after browser refresh
8. [ ] Mobile responsive (test on 375px width minimum)

## Ready for Pull Request?

- [ ] All tests pass
- [ ] No console errors
- [ ] Code is committed
- [ ] SETUP.md documentation is accurate
- [ ] Supabase schema is tested
- [ ] Dashboard is functional
- [ ] Images work in PDF

**If all boxes are checked, you're ready to create the pull request!**
