-- Invoice Studio refinements: project references per client + invoice timeline dates.
-- Run AFTER supabase-migration-invoice-studio.sql. Safe to re-run.

-- 1. Project references, one client can have many.
CREATE TABLE IF NOT EXISTS project_references (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  client_id BIGINT NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  text TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_project_references_user_client
  ON project_references(user_id, client_id);

ALTER TABLE project_references ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view their own project references" ON project_references;
CREATE POLICY "Users can view their own project references" ON project_references
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert their own project references" ON project_references;
CREATE POLICY "Users can insert their own project references" ON project_references
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own project references" ON project_references;
CREATE POLICY "Users can update their own project references" ON project_references
  FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own project references" ON project_references;
CREATE POLICY "Users can delete their own project references" ON project_references
  FOR DELETE USING (auth.uid() = user_id);

-- 2. Timeline dates. "Created" uses the existing created_at column.
ALTER TABLE invoices ADD COLUMN IF NOT EXISTS sent_at DATE;
ALTER TABLE invoices ADD COLUMN IF NOT EXISTS viewed_at DATE;
ALTER TABLE invoices ADD COLUMN IF NOT EXISTS paid_at DATE;

-- 3. Make PostgREST pick up the new columns immediately.
NOTIFY pgrst, 'reload schema';
