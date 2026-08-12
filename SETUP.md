# Invoice Generator - Setup Guide

## Features

✅ **Image Upload Support**
- Company logo upload (displayed in invoice header)
- Signature upload (displayed in Terms & Payment section)
- Images stored as Base64 in localStorage and Supabase
- Automatic display in web UI and PDF export

✅ **Supabase Backend Integration**
- Cloud storage for all invoice data
- Real-time sync between local and cloud storage
- Automatic status tracking (Draft → Sent → Paid)
- Fallback to localStorage when Supabase is not configured

✅ **Invoice Dashboard**
- View all invoices in one place
- Filter by status (Draft, Sent, Paid)
- Search by invoice number or client name
- Update invoice status directly from dashboard
- Statistics overview (total, draft, sent, paid counts)

✅ **Multilanguage Support**
- English, Spanish, Portuguese (Brazilian)

✅ **Enhanced PDF Generation**
- Dynamic filename with invoice number
- Logo and signature images embedded
- Multi-page support
- Complete invoice information

## Setup Instructions

### 1. Supabase Configuration

#### Step 1: Access Your Supabase Project
1. Go to https://supabase.com/dashboard/project/fwpadfroagpzkmcxzppq
2. Sign in to your account

#### Step 2: Get Your API Keys
1. Click on **Settings** (gear icon) in the left sidebar
2. Click on **API**
3. Copy the following:
   - **Project URL**: `https://fwpadfroagpzkmcxzppq.supabase.co`
   - **Anon/Public Key**: (copy the `anon` key)

#### Step 3: Create the Database Schema
1. In your Supabase dashboard, go to **SQL Editor**
2. Click **New Query**
3. Copy the contents of `supabase-schema.sql` and paste it
4. Click **Run** to execute the SQL

#### Step 4: Configure the Application
1. Open `index.html` in a text editor
2. Find this line (around line 338):
   ```javascript
   const SUPABASE_ANON_KEY = 'YOUR_ANON_KEY_HERE'; // Replace with actual key
   ```
3. Replace `'YOUR_ANON_KEY_HERE'` with your actual Anon Key
4. Save the file

5. Open `dashboard.html` in a text editor
6. Find the same line (around line 105):
   ```javascript
   const SUPABASE_ANON_KEY = 'YOUR_ANON_KEY_HERE'; // Replace with actual key
   ```
7. Replace `'YOUR_ANON_KEY_HERE'` with your actual Anon Key
8. Save the file

### 2. Testing the Application

#### Test Image Upload
1. Open `index.html` in a web browser
2. Click on the **Company Logo** file input
3. Select a PNG or JPG image
4. Verify the image appears in:
   - The upload preview section
   - The invoice header (replacing "AHI" initials)
5. Repeat for **Signature** upload
6. Verify signature appears in the Terms & Payment section

#### Test Invoice Creation & Save
1. Fill in the invoice details:
   - Invoice number
   - Date and Due Date
   - Bill To and Ship To information
   - Add line items
2. Click **Save** button
3. You should see a toast message:
   - If Supabase is configured: "Invoice saved locally (Local + Cloud)"
   - If not configured: "Invoice saved locally"

#### Test PDF Generation
1. Click **Download PDF** button
2. Verify the PDF includes:
   - Company logo in the header (if uploaded)
   - All invoice information from ZONE 1-7
   - Signature image in the Terms & Payment section (if uploaded)
   - Filename format: `invoice-client-{invoice-number}.pdf`

#### Test Dashboard
1. Click the **Dashboard** button in the top menu
2. Verify you can see:
   - Statistics cards (Total, Draft, Sent, Paid)
   - List of all invoices
   - Status dropdowns for each invoice
3. Try changing an invoice status from "Draft" to "Sent"
4. Verify the change is saved (refresh the page)
5. Test the search and filter functionality

### 3. Row Level Security (Optional)

The default SQL schema allows all operations for all users. For production use, you should implement proper authentication and RLS policies:

1. In Supabase Dashboard, go to **Authentication**
2. Enable your preferred authentication provider (Email, Google, etc.)
3. Update the RLS policy in the SQL Editor:

```sql
-- Remove the permissive policy
DROP POLICY "Allow all operations for authenticated users" ON invoices;

-- Create stricter policies
CREATE POLICY "Users can view all invoices" ON invoices
  FOR SELECT
  USING (true);

CREATE POLICY "Authenticated users can insert invoices" ON invoices
  FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can update invoices" ON invoices
  FOR UPDATE
  USING (auth.uid() IS NOT NULL);
```

### 4. Deployment

#### Option 1: GitHub Pages (Already Configured)
The repository already has a GitHub Actions workflow for deployment:
1. Push your changes to the `main` branch
2. Go to **Settings** → **Pages** in your GitHub repository
3. Set Source to **GitHub Actions**
4. Your site will be available at: `https://aahincapie.github.io/invoice-generator/`

#### Option 2: Local Development
Simply open `index.html` in a web browser. All features work locally except:
- Supabase sync requires internet connection
- Base64 image storage works offline

### 5. Environment Variables (Optional)

For better security, you can create a separate config file:

1. Create `config.js`:
```javascript
const SUPABASE_CONFIG = {
  url: 'https://fwpadfroagpzkmcxzppq.supabase.co',
  anonKey: 'your-actual-anon-key-here'
};
```

2. Add to `.gitignore`:
```
config.js
```

3. Update `index.html` and `dashboard.html` to load this config file before other scripts

## Troubleshooting

### Images Not Appearing in PDF
- Ensure images are PNG or JPG format
- Check browser console for errors
- Verify Base64 data is being stored correctly

### Supabase Connection Issues
- Verify the Anon Key is correct
- Check browser console for CORS errors
- Ensure RLS policies allow the operation
- Verify the `invoices` table exists in your database

### Dashboard Not Loading Invoices
- Check browser console for errors
- Verify Supabase configuration
- Try refreshing with localStorage data only
- Check if any invoices exist in the database

## Support

For issues or questions:
1. Check browser console for error messages
2. Verify Supabase configuration
3. Review the SQL schema in Supabase SQL Editor
4. Check the GitHub repository issues

## Next Steps

Potential enhancements:
- Add user authentication
- Implement invoice templates
- Add email functionality to send invoices
- Export to Excel/CSV
- Recurring invoices
- Client management system
- Payment tracking integration
