-- Supabase Database Schema for Invoice Generator
-- Execute this in your Supabase SQL Editor

-- Create invoices table
CREATE TABLE IF NOT EXISTS invoices (
  id BIGSERIAL PRIMARY KEY,
  invoice_number TEXT NOT NULL,
  invoice_date DATE,
  due_date DATE,
  bill_to TEXT,
  ship_to TEXT,
  notes TEXT,
  tax DECIMAL(10, 2) DEFAULT 0,
  payment_details TEXT,
  currency TEXT DEFAULT 'USD $',
  total_amount DECIMAL(10, 2) DEFAULT 0,
  items JSONB DEFAULT '[]'::jsonb,
  logo TEXT, -- Base64 encoded image
  signature TEXT, -- Base64 encoded image
  status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'sent', 'paid')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index on invoice_number for faster lookups
CREATE INDEX IF NOT EXISTS idx_invoices_invoice_number ON invoices(invoice_number);

-- Create index on status for filtering
CREATE INDEX IF NOT EXISTS idx_invoices_status ON invoices(status);

-- Create index on created_at for sorting
CREATE INDEX IF NOT EXISTS idx_invoices_created_at ON invoices(created_at DESC);

-- Enable Row Level Security (RLS)
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;

-- Create policy to allow all operations for authenticated users
-- Adjust this based on your security requirements
CREATE POLICY "Allow all operations for authenticated users" ON invoices
  FOR ALL
  USING (true)
  WITH CHECK (true);

-- Create a function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_invoices_updated_at
  BEFORE UPDATE ON invoices
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Optional: Create a view for invoice statistics
CREATE OR REPLACE VIEW invoice_stats AS
SELECT
  COUNT(*) AS total_invoices,
  COUNT(*) FILTER (WHERE status = 'draft') AS draft_count,
  COUNT(*) FILTER (WHERE status = 'sent') AS sent_count,
  COUNT(*) FILTER (WHERE status = 'paid') AS paid_count,
  SUM(total_amount) AS total_revenue,
  SUM(total_amount) FILTER (WHERE status = 'paid') AS paid_revenue,
  SUM(total_amount) FILTER (WHERE status = 'sent') AS pending_revenue
FROM invoices;

-- Grant access to the view
GRANT SELECT ON invoice_stats TO authenticated, anon;
