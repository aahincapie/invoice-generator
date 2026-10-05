-- Per-invoice currency: line amounts are qty × rate in the invoice's own currency.
-- Run AFTER supabase-migration-refinements.sql. Safe to re-run.
--
-- New invoices store a bare code ('USD', 'EUR', 'BRL', 'COP') in `currency` and their totals in
-- that currency; fx_rate is USD → currency captured on the invoice. Older rows keep the
-- 'USD $' default and are read as USD.

-- Both views depend on total_amount, so they must be dropped before its type can change.
DROP VIEW IF EXISTS invoices_with_status;
DROP VIEW IF EXISTS invoice_stats;

-- DECIMAL(10,2) caps at 99,999,999.99, which a COP invoice above ~USD 25k exceeds.
ALTER TABLE invoices ALTER COLUMN total_amount TYPE NUMERIC(18, 2);
ALTER TABLE invoices ALTER COLUMN fx_rate TYPE NUMERIC(18, 6);

-- security_invoker makes the views apply the caller's RLS policies. Without it a view runs
-- as its owner and exposes every user's invoices to anyone holding the publishable key.
CREATE VIEW invoices_with_status WITH (security_invoker = true) AS
SELECT
  *,
  CASE
    WHEN status = 'ready_to_send' AND due_date < CURRENT_DATE THEN 'overdue'
    WHEN status = 'ready_to_send' THEN 'ready'
    ELSE status
  END AS computed_status
FROM invoices;

CREATE VIEW invoice_stats WITH (security_invoker = true) AS
WITH usd AS (
  SELECT
    user_id,
    status,
    CASE
      WHEN currency IN ('USD', 'EUR', 'BRL', 'COP') THEN total_amount / NULLIF(fx_rate, 0)
      ELSE total_amount
    END AS total_usd
  FROM invoices
)
SELECT
  user_id,
  COUNT(*) AS total_invoices,
  COUNT(*) FILTER (WHERE status = 'draft') AS draft_count,
  COUNT(*) FILTER (WHERE status = 'ready_to_send') AS ready_to_send_count,
  COUNT(*) FILTER (WHERE status = 'paid') AS paid_count,
  SUM(total_usd) AS total_revenue_usd,
  SUM(total_usd) FILTER (WHERE status = 'paid') AS paid_revenue_usd,
  SUM(total_usd) FILTER (WHERE status = 'ready_to_send') AS pending_revenue_usd
FROM usd
GROUP BY user_id;

REVOKE ALL ON invoices_with_status, invoice_stats FROM anon;
GRANT SELECT ON invoices_with_status, invoice_stats TO authenticated;

NOTIFY pgrst, 'reload schema';
