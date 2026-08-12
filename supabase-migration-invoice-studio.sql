-- Migration SQL for Invoice Studio Redesign
-- Run this AFTER the base supabase-schema.sql has been executed

-- 1. Create clients table
CREATE TABLE IF NOT EXISTS clients (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  code TEXT NOT NULL CHECK (length(code) = 3), -- 3-letter code for invoice numbering
  name TEXT NOT NULL,
  country TEXT,
  initials TEXT, -- 2-letter initials for avatar display
  address TEXT,
  billed_total DECIMAL(10, 2) DEFAULT 0, -- Lifetime billed amount
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, code) -- Code must be unique per user
);

-- Create index on clients for faster lookups
CREATE INDEX IF NOT EXISTS idx_clients_user_id ON clients(user_id);
CREATE INDEX IF NOT EXISTS idx_clients_code ON clients(code);

-- Enable Row Level Security (RLS) on clients
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;

-- Create policies for clients table
CREATE POLICY "Users can view their own clients" ON clients
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own clients" ON clients
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own clients" ON clients
  FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own clients" ON clients
  FOR DELETE
  USING (auth.uid() = user_id);

-- 2. Create profile table (company/user settings)
CREATE TABLE IF NOT EXISTS profile (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  trade_name TEXT, -- Trading/business name
  legal_name TEXT, -- Legal registered name
  tax_id TEXT, -- Tax ID / NIT / EIN
  address TEXT,
  postal_code TEXT,
  phone TEXT,
  email TEXT,
  website TEXT,
  invoice_prefix TEXT DEFAULT 'AHI', -- User's invoice prefix (e.g., "AHI")
  next_sequence INTEGER DEFAULT 1, -- Next invoice sequence number
  default_terms INTEGER DEFAULT 30, -- Default payment terms in days (Net 30)
  logo TEXT, -- Base64 encoded logo (optional, can also be per-invoice)
  signature TEXT, -- Base64 encoded signature (optional, can also be per-invoice)
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index on profile for faster lookups
CREATE INDEX IF NOT EXISTS idx_profile_user_id ON profile(user_id);

-- Enable Row Level Security (RLS) on profile
ALTER TABLE profile ENABLE ROW LEVEL SECURITY;

-- Create policies for profile table
CREATE POLICY "Users can view their own profile" ON profile
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own profile" ON profile
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own profile" ON profile
  FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own profile" ON profile
  FOR DELETE
  USING (auth.uid() = user_id);

-- 3. Add new columns to invoices table
ALTER TABLE invoices ADD COLUMN IF NOT EXISTS client_id BIGINT REFERENCES clients(id) ON DELETE SET NULL;
ALTER TABLE invoices ADD COLUMN IF NOT EXISTS reference TEXT; -- Project reference (replaces ship_to)
ALTER TABLE invoices ADD COLUMN IF NOT EXISTS fx_currency TEXT DEFAULT 'USD'; -- Currency at issue time
ALTER TABLE invoices ADD COLUMN IF NOT EXISTS fx_rate DECIMAL(10, 4) DEFAULT 1.0; -- Exchange rate at issue time
ALTER TABLE invoices ADD COLUMN IF NOT EXISTS issued_at TIMESTAMPTZ; -- Actual issue timestamp

-- Create index on client_id for faster joins
CREATE INDEX IF NOT EXISTS idx_invoices_client_id ON invoices(client_id);

-- 4. Update status constraint to allow 'overdue'
-- First, drop the old constraint if it exists
ALTER TABLE invoices DROP CONSTRAINT IF EXISTS invoices_status_check;

-- Add the new constraint with 'overdue' status
ALTER TABLE invoices ADD CONSTRAINT invoices_status_check
  CHECK (status IN ('draft', 'ready_to_send', 'paid', 'overdue'));

-- Note: 'ready_to_send' is kept for backward compatibility
-- The app will map 'ready_to_send' to 'ready' in the UI

-- 5. Create trigger to automatically update updated_at on clients
CREATE OR REPLACE FUNCTION update_clients_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_clients_updated_at_trigger
  BEFORE UPDATE ON clients
  FOR EACH ROW
  EXECUTE FUNCTION update_clients_updated_at();

-- 6. Create trigger to automatically update updated_at on profile
CREATE OR REPLACE FUNCTION update_profile_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_profile_updated_at_trigger
  BEFORE UPDATE ON profile
  FOR EACH ROW
  EXECUTE FUNCTION update_profile_updated_at();

-- 7. Create function to compute overdue status dynamically
-- This is a view that derives 'overdue' from 'ready_to_send' + past due date
CREATE OR REPLACE VIEW invoices_with_status AS
SELECT
  *,
  CASE
    WHEN status = 'ready_to_send' AND due_date < CURRENT_DATE THEN 'overdue'
    WHEN status = 'ready_to_send' THEN 'ready'
    ELSE status
  END AS computed_status
FROM invoices;

-- Grant access to the view
GRANT SELECT ON invoices_with_status TO authenticated, anon;

-- 8. Optional: Migration helper to populate client_id from existing bill_to data
-- This helps link existing invoices to clients if you create them manually
-- Comment: Run this after manually creating clients that match your existing invoices

-- 9. Create function to increment invoice sequence
CREATE OR REPLACE FUNCTION get_next_invoice_number(p_user_id UUID)
RETURNS INTEGER AS $$
DECLARE
  next_num INTEGER;
BEGIN
  UPDATE profile
  SET next_sequence = next_sequence + 1
  WHERE user_id = p_user_id
  RETURNING next_sequence - 1 INTO next_num;

  RETURN next_num;
END;
$$ LANGUAGE plpgsql;

-- 10. Sample data insert function (optional - for testing)
-- Creates a default profile for a new user
CREATE OR REPLACE FUNCTION create_default_profile()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profile (user_id, trade_name, invoice_prefix, next_sequence)
  VALUES (NEW.id, 'My Company', 'INV', 1)
  ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to auto-create profile when user signs up (optional)
-- DROP TRIGGER IF EXISTS create_profile_on_signup ON auth.users;
-- CREATE TRIGGER create_profile_on_signup
--   AFTER INSERT ON auth.users
--   FOR EACH ROW
--   EXECUTE FUNCTION create_default_profile();
-- Note: Uncomment above if you want auto-profile creation

-- MIGRATION COMPLETE
-- Summary:
-- ✓ Added clients table with RLS
-- ✓ Added profile table with RLS
-- ✓ Extended invoices table with client_id, reference, fx_currency, fx_rate
-- ✓ Updated status constraint to allow 'overdue'
-- ✓ Created view for computed status (overdue = ready + past due)
-- ✓ Created helper functions for invoice numbering
