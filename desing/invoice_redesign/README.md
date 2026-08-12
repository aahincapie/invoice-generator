# Handoff: Invoice Generator redesign ("Invoice Studio")

## Overview

A redesign of `github.com/aahincapie/invoice-generator` — a single-user invoice tool (static HTML + Tailwind CDN + Supabase auth/storage, deployed to GitHub Pages).

The redesign replaces the current tab-bar layout (`#tab-invoice` / `#tab-dashboard`) with a persistent sidebar app shell and five screens: **Sign in, Dashboard, Invoice editor, Clients, Settings**. It keeps every existing capability (EN/ES/PT UI, currency switching, logo/signature upload, PDF download, draft → ready-to-send → paid status flow, Supabase sync with row-level security) and adds three requested features:

1. **Saved clients + bill-to auto-fill** — a client directory; picking a client fills the invoice address block.
2. **Multi-currency with FX reference** — USD/EUR/BRL/COP switch in the header; every monetary value re-renders, and the invoice shows an FX reference line stating the rate and the USD-equivalent total.
3. **Revenue overview** — KPI cards, revenue-by-month bar chart, and top-clients ranking on the dashboard.

Target: **desktop only**. Single user (solo consultant). Status vocabulary: `draft`, `ready` (ready to send), `paid`, `overdue` — note `overdue` is **new**; the existing schema has `draft | ready_to_send | paid`.

## About the design files

The files in `prototype/` are a **design reference created in HTML** — a prototype showing intended look and behavior. They are **not production code to copy directly**. `Invoice Studio.dc.html` uses a bespoke streaming-component runtime (`support.js`) that exists only in the design tool; do not port that runtime.

The task is to **recreate this design in the target codebase**: `aahincapie/invoice-generator`, which today is plain static HTML with the Tailwind CDN, vanilla JS, and `@supabase/supabase-js` v2 from CDN, no build step (GitHub Pages). Stay in that environment unless there is reason to introduce a build step — implement the redesign as plain HTML + CSS custom properties + vanilla JS modules, keeping the existing Supabase calls and `config.js` credential loading intact. If the developer chooses to modernize (Vite + React), the design maps cleanly onto components, but that is a separate decision.

All data in the prototype is **mock data**. There is no auth and no network call. Every list, KPI, and chart must be re-derived from the real `invoices` table.

## Fidelity

**High fidelity.** Colors, typography, spacing, radii, and copy are final and should be reproduced exactly. All values come from the CarbonSourcing design system (tokens in `tokens/`). The one deliberately loose area is the printed PDF sheet: the user asked to *keep the existing PDF layout and only tidy it* — do not restyle the PDF output beyond aligning fonts and the header block.

---

## Design system

Everything is built on the **CarbonSourcing design system** — "scientific blueprint" aesthetic: near-white mist surfaces, a single deep teal primary, hairline borders, no gradients, no shadows heavier than `shadow-sm`, no emoji.

- `tokens/colors.css` — copy verbatim; it defines every `--*` custom property the design uses.
- `tokens/fonts.css` — Google Fonts import for **Space Grotesk** (all UI text) and **JetBrains Mono** (technical labels).
- `tokens/typography.css`, `tokens/spacing.css`, `tokens/effects.css`, `tokens/base.css` — supporting tokens and the `cs-btn` / `cs-card` / `cs-input` / `cs-nav-item` / `cs-badge` class definitions.

**The current app's Inter font, `sky-600` blue, `slate-*` greys, and `emerald`/`yellow`/`red` accents are all removed.** If Tailwind is kept, map the theme to these variables rather than using default Tailwind palettes.

### Core tokens (resolved values)

| Token | Value | Use |
| --- | --- | --- |
| `--background` | `oklch(0.98 0.005 250)` | page background |
| `--card` | `oklch(0.97 0.005 250)` | card surfaces |
| `--sidebar` | `oklch(0.96 0.005 250)` | sidebar background |
| `--primary` | `oklch(0.45 0.15 200)` | deep teal — buttons, active nav, balance due |
| `--primary-foreground` | `oklch(0.98 0.005 250)` | text on primary |
| `--foreground` | `oklch(0.15 0.02 250)` | body text |
| `--muted-foreground` | `oklch(0.5 0.02 250)` | secondary text, mono captions |
| `--muted` | `oklch(0.94 0.008 250)` | table header row, progress track |
| `--accent` | `oklch(0.9 0.05 180)` | hover wash, icon chips, "ready" status chip |
| `--border` | `oklch(0.9 0.01 250)` | all 1px hairlines |
| `--input` | `oklch(0.92 0.008 250)` | input borders |
| `--destructive` | `oklch(0.577 0.245 27.325)` | overdue text, remove-line hover |
| `--chart-3` | `oklch(0.75 0.08 200)` | current-month bar (lighter teal) |

Two status colors are defined inline in the prototype (not tokens):
- paid chip: background `oklch(0.92 0.06 150)`, text `oklch(0.42 0.11 150)`
- overdue chip: background `oklch(0.93 0.06 25)`, text `var(--destructive)`

### Typography

- **Space Grotesk** — every heading, label, button, table cell. Weights 400/600/700.
- **JetBrains Mono**, `letter-spacing: 0.02em` — bracketed labels, table headers, all money amounts in tables/totals, invoice numbers, dates in the timeline, tags.
- Scale used: 26px/700 (page numbers, KPI values, invoice word), 22px/700 (sign-in title), 20px/700 (balance due, sidebar outstanding), 16px/700 (page title, editor total row), 15px/700 (wordmark, client name), 14px/700 (card titles), 13px (body, inputs, table cells), 12px (secondary text, labels), 11px (field labels, chips), 10px (bracketed mono captions), 9px (bar-chart value labels).
- Headline letter-spacing: `-0.02em` at 15–22px, `-0.03em` at 26px.

### Radii, borders, shadows

- Cards: `border-radius: 12px`, `1px solid var(--border)`.
- Buttons, inputs, selects, chips-with-square-corners: `6px`.
- Icon chips / avatars / small tiles: `8px` (or `10px` for the 46px invoice logo tile).
- Pills (status chips): `999px`.
- Shadows: only `0 1px 2px rgba(0,0,0,.05)` on the sign-in card. No other shadows.

### Voice / copy rules

- Sentence case for headings and buttons. No emoji, no exclamation points.
- **Bracketed monospace labels** are the signature pattern — a lowercase dot-separated tag under or beside a title: `[auth.email_password]`, `[revenue.overview]`, `[invoice.compose]`, `[clients.directory]`, `[account.profile]`, `[outstanding.total]`, `[revenue.by_month]`, `[bill_to]`, `[project_reference]`, `[balance_due]`, `[notes]`, `[payment_details]`, `[billed.total]`. Table headers are lowercase mono: `number`, `client`, `issued`, `due`, `amount`, `status`.
- KPI sub-captions use the same style: `[3 open]`, `[4 settled]`, `[1 late]`, `[net_30 terms]`.

### Icons

**Lucide** only, `stroke-width: 2`, sized 14–18px, colored via `currentColor`. Names used: `file-text`, `bar-chart-3`, `users`, `settings`, `log-out`, `trending-up`, `check-circle-2`, `x-circle`, `clock`, `send`, `eye`, `wallet`, `image`, `pen-line`. The prototype loads the Lucide UMD build from `https://unpkg.com/lucide@latest/dist/umd/lucide.js`; in the real app either keep that CDN script or install `lucide`.

---

## App shell (all screens except Sign in)

Full-viewport flex row, `min-height: 100vh`, background `--background`.

### Sidebar — 232px fixed

- Background `--sidebar`, right border 1px `--sidebar-border`, padding `16px 12px`, flex column.
- **Wordmark row**: 30×30 tile, radius 8px, background `--accent`, centered `file-text` Lucide icon at 16px in `--primary`; next to it "Invoice Studio" at 15px/700, `-0.02em`. Padding `6px 8px 18px`.
- **Nav**: four rows (`cs-nav-item`) with 2px gap — Dashboard (`bar-chart-3`), Invoice editor (`file-text`), Clients (`users`), Settings (`settings`). Active row uses the sidebar-accent tint; inactive rows get an accent wash on hover. Height ~34px, 16px icon, label flush left.
- **Outstanding card**: below nav with 24px top margin. 1px `--sidebar-border`, radius 10px, background `--background`, padding 12px. Contains `[outstanding.total]` (10px mono, muted), the outstanding sum (20px/700, `-0.02em`), and a caption "across 3 invoices" (11px muted). The count in the caption must be computed, not hard-coded.
- **Spacer**, then a **user row** pinned to the bottom: 1px top border, 28px circular avatar (background `--primary`, `--primary-foreground` initials at 11px/700), name at 12px/600 with ellipsis overflow, mono `solo` at 10px muted, and a `log-out` icon button (16px, `--muted-foreground`) that signs out.

### Top bar — 60px

1px bottom border `--border`, background `--background`, padding `0 28px`, flex row, gap 12px, items centered.

- **Left**: page title 16px/700 `-0.02em`, and under it the bracketed mono tag at 10px muted — `[revenue.overview]`, `[invoice.compose]`, `[clients.directory]`, `[account.profile]`.
- **Right**: language `<select>` (EN/ES/PT), currency `<select>` (USD/EUR/BRL/COP) — both 32px tall, 6px radius, 1px `--input`, 12px mono text; then a primary **"New invoice"** button (32px tall, `0 14px` padding, 6px radius, background `--primary`, 13px/600).

Both selects are global state: changing language re-renders all UI strings; changing currency re-renders every monetary value app-wide.

### Content area

`flex: 1`, `overflow: auto`, `padding: 28px`. Content columns cap at `max-width: 1180px`.

---

## Screen 1 — Sign in

Replaces `#auth-section` in `index.html`.

- Full viewport, centered grid, background `--background` with the **`.cs-grid-pattern`** faint cyan grid overlay (from `tokens/effects.css`). Padding 48px.
- 420px column. Above the card: the 36px `file-text` tile + "Invoice Studio" wordmark at 18px/700, 28px bottom margin.
- **Card**: `--card`, 1px `--border`, radius 12px, `box-shadow: 0 1px 2px rgba(0,0,0,.05)`, padding 28px.
  - Title "Sign in" 22px/700 `-0.02em`; below it `[auth.email_password]` 11px mono muted, 6px top margin.
  - 22px top margin, then a 14px-gap grid: Email field, Password field, primary "Sign in" button (40px, `--primary`), outline "Create account" button (40px, 1px `--border`, transparent, accent wash on hover).
  - Labels 12px `--muted-foreground` above 38px inputs (6px radius, 1px `--input`, 14px text).
- Below the card, 16px margin: "Invoices sync to your private cloud. Only you can see them." — 12px muted, centered.

Real behavior: keep the existing Supabase `signInWithPassword` / `signUp` flow, email confirmation, and the `auth-message` error surface (render errors under the buttons in `--destructive`, 12px).

---

## Screen 2 — Dashboard

Replaces `#dashboard-section` and the standalone `dashboard.html`. Vertical grid, 20px gap.

### KPI row — 4 equal columns, 16px gap

Each card: `--card`, 1px `--border`, radius 12px, padding 18px.
- Row 1: 14px Lucide icon + 12px label, both `--muted-foreground`, 8px gap.
- Row 2: value 26px/700 `-0.03em`, 10px top margin.
- Row 3: mono caption 10px muted, 4px top margin.

| KPI | Icon | Value | Caption |
| --- | --- | --- | --- |
| Outstanding | `trending-up` | sum of `ready` + `overdue` | `[3 open]` |
| Paid this year | `check-circle-2` | sum of `paid` in current year | `[4 settled]` |
| Overdue | `x-circle` | sum of `overdue` | `[1 late]` |
| Avg. days to pay | `clock` | integer, e.g. `26` | `[net_30 terms]` |

Counts in captions must be computed from the data.

### Charts row — `2fr 1fr`, 16px gap

**Revenue card** (left): title "Revenue" 14px/700 with `[revenue.by_month]` mono 10px muted right-aligned on the same baseline. Below, a 180px-tall flex row of bars, 14px gap, aligned to bottom, with a 1px `--border` baseline. Each bar column: a 9px mono value label above the bar (abbreviated — `12k`, or `M` for COP), then the bar itself, full column width, `border-radius: 4px 4px 0 0`, height = `value / max * 100%`. Bars are `--primary` except the current (last) month, which is `--chart-3`. Month labels sit in a second row under the baseline: 10px mono muted, centered, matching column widths. Eight months shown (rolling window).

**Top clients card** (right): title 14px/700, then per client a 6px-gap group — a row with client name (13px/600) and billed total (13px mono muted) space-between, and under it a 6px-tall progress bar (`--muted` track, `--primary` fill, `999px` radius) with width = `client.billed / max * 100%`. Four clients, 16px gap. Ranked by lifetime billed.

### Invoices table card

`--card`, 1px `--border`, radius 12px, `overflow: hidden`.

- **Toolbar** — padding `16px 20px`, 1px bottom border, flex row, 12px gap: title "Invoices" 14px/700 (flex 1), a 240px search input (32px tall, placeholder "Search number or client"), and a status `<select>` (All statuses / Draft / Ready to send / Paid / Overdue). Filtering is client-side over number and client name, case-insensitive, and combines with the status filter.
- **Table** — `width: 100%`, `border-collapse: collapse`.
  - Header row background `--muted`; cells 11px/600 mono `--muted-foreground`, padding `10px 20px` on the first/last and `10px 12px` between. Amount column right-aligned.
  - Body rows: 1px top border `--border`, hover background `--muted`. Cells padding 12px (20px on the outer edges), 13px text. Number cell 600 weight mono; dates `--muted-foreground`; amount right-aligned 600 mono.
  - **Status cell**: pill — `display:inline-block`, padding `3px 9px`, radius 999px, 11px/600 mono, colors per the status table above.
  - **Action cell**: right-aligned "Open" button — 28px tall, `0 10px`, 1px `--border`, 6px radius, transparent, 12px/600, accent wash on hover. Opens that invoice in the editor.

---

## Screen 3 — Invoice editor

Replaces `#invoice-section` / `.sheet` in `index.html`. Two columns: `1fr 300px`, 20px gap, `align-items: start`. The right rail is `position: sticky; top: 0`.

### Left — the invoice sheet

`--card`, 1px `--border`, radius 12px, padding `36px 40px`.

1. **Header row** (space-between, top-aligned):
   - Left: 46px tile, radius 10px, background `--primary`, `--primary-foreground` initials "AHI" at 14px/700 (replaced by the uploaded logo when present); beside it company name 15px/700 and tagline 12px `--muted-foreground`.
   - Right: the word "Invoice" 26px/700 `-0.03em`, and under it `#AHI-2026-014` in 12px mono muted.
2. **1px `--border` divider**, 26px vertical margin.
3. **Three columns** `1fr 1fr 200px`, 24px gap:
   - **Bill to** — `[bill_to]` mono label, a 32px client `<select>` (the saved-clients dropdown; choosing one overwrites the textarea with `name\naddress`), then a 4-row textarea (1px `--input`, 6px radius, 13px, line-height 1.5, vertical resize).
   - **Project reference** — `[project_reference]` label + 6-row textarea. *This replaces the old "Ship to" field*, which made no sense for a consulting invoice.
   - **Dates + balance** — 10px-gap stack: "Issue date" and "Due date" `<input type="date">` (32px, 11px muted label above), then a bordered tile (1px `--border`, radius 8px, padding 10px, background `--background`) with `[balance_due]` mono caption and the balance at 20px/700 in `--primary`.
4. **Line items** — 30px top margin. Grid template `1fr 90px 130px 130px 32px`, 10px gap.
   - Header row: mono 10px muted labels `description / qty / rate / amount`, right-aligned for the numeric ones, 8px bottom padding, 1px bottom border.
   - Each row: three borderless inputs (transparent background, `1px solid transparent` border, 6px radius, 32px tall) that reveal a `--ring`-colored border and `--background` fill on focus; qty and rate are right-aligned mono. Fourth cell is the computed amount (13px/600 mono, right-aligned). Fifth is an `x-circle` icon button, 15px, `--muted-foreground`, turning `--destructive` on hover, that removes the row. Row padding `8px 0`, 1px bottom border.
   - **"+ Line item"** button below: full width, 36px, 1px dashed `--border`, 8px radius, transparent, `--primary` text 13px/600, accent wash on hover.
5. **Notes + totals** — grid `1fr 300px`, 30px gap, 28px top margin.
   - Left: `[notes]` label + 5-row textarea.
   - Right: 8px-gap stack, 13px — "Subtotal" row (muted label, mono 600 value); "Tax" row with an inline 52×26 mono percentage input followed by a literal `%`, and the computed tax amount; 1px divider; "Total" row at 16px (600 label, 700 mono value); and an FX line in 11px mono muted — left `1 USD = 0.92 EUR`, right the USD-equivalent total.
6. **Payment details + signature** — grid `1fr 260px`, 30px gap, 28px top margin, bottom-aligned.
   - Left: `[payment_details]` label + a bordered block (1px `--border`, radius 8px, padding 12px, 12px text, line-height 1.7) — name in body font, bank lines in mono muted. Pull from the settings profile.
   - Right: a 54px signature area with a 1px bottom border and the mono caption "Signature" sitting on it (replaced by the uploaded signature image when present), and the signer name at 12px below.

### Right rail — three cards, 16px gap

Each: `--card`, 1px `--border`, radius 12px, padding 18px.

- **Actions** — title 13px/700, then 10px-gap buttons, all 36px/6px radius/13px 600: "Save invoice" (primary), "Download PDF" (outline), "Duplicate" (outline). Under them a 10px mono centered status line: `All changes saved` / `unsaved changes`.
- **Status** — title, a 34px status `<select>` (Draft / Ready to send / Paid / Overdue), then a 4-step **timeline**, 8px gap: `check-circle-2` Created, `send` Sent to client, `eye` Viewed by client, `wallet` Payment received. Each row: 14px icon, 12px label (flex 1), 10px mono date right-aligned. Completed steps use `--foreground`; not-yet-reached steps use `--muted-foreground` and show `—` or "Pending".
- **Exchange rate** — title, then two 11px mono muted lines at line-height 1.8: `1 USD = 0.92 EUR` and `fetched 2026-08-12 09:00 UTC`.

**Behavior preserved from the current app**: "Download PDF" advances status `draft → ready`; save writes to Supabase; the sheet must remain printable.

---

## Screen 4 — Clients (new)

A 3-column grid of client cards, 16px gap. Each card: `--card`, 1px `--border`, radius 12px, padding 20px, 12px-gap grid.

- **Header row**: 36px tile, radius 8px, background `--accent`, `--primary` initials 12px/700; beside it client name 14px/700 `-0.01em` and country in 11px mono muted.
- **Address**: 12px `--muted-foreground`, line-height 1.6.
- **Footer**: 1px top border, 10px top padding, space-between — left a `[billed.total]` mono caption over the lifetime billed amount (14px/700); right a "New invoice" button (30px, `0 12px`, 1px `--border`, 6px radius, 12px/600, accent wash on hover) that opens the editor pre-filled with that client.

Needs a new `clients` table (see State below) plus create/edit affordances, which the prototype does not draw — follow the same card and field styling.

---

## Screen 5 — Settings

Two columns `1fr 1fr`, 16px gap, `max-width: 900px`, `align-items: start`. All cards `--card` / 1px `--border` / radius 12px / padding 22px, 14px-gap grids, titles 14px/700. All fields: 11px `--muted-foreground` label above a 34px input (6px radius, 1px `--input`, 13px).

- **Company profile** (left) — Legal name, Tax ID (mono), Address (3-row textarea), then two side-by-side upload dropzones: 1px dashed `--border`, radius 8px, 76px tall, centered 16px icon (`image` / `pen-line`) over an 11px muted label — "Upload logo" and "Upload signature". Wire these to the existing base64 upload logic.
- **Numbering** (right, top) — Prefix (mono, e.g. `AHI-2026-`), Next number (mono, e.g. `014`), Default terms `<select>` (Net 15 / **Net 30** / Net 45). New invoices take `prefix + next number`; the due date defaults to issue date + terms.
- **Cloud sync** (right, bottom) — title, then a row: 16px `check-circle-2` in `--primary`, "Connected" in `--foreground` 13px, and `supabase` in 10px mono muted, right-aligned. Below, 12px muted line-height 1.6: "Invoices and clients are stored per account with row-level security." When `config.js` is missing or the key is a placeholder, swap to an `x-circle` in `--destructive` and the existing configuration warning text.

---

## Interactions & behavior

- **Navigation**: sidebar rows swap the content area; no page reloads. "New invoice" (top bar) and "New invoice" (client card) open the editor; "Open" in the table loads that invoice into the editor. Sign out returns to the Sign in screen.
- **Language**: EN/ES/PT swap every UI string immediately. Full translation dictionaries for all three languages are in the logic block of `prototype/Invoice Studio.dc.html` (the `STR` constant) — lift them directly; they cover navigation, table headers, editor labels, statuses, settings, and the timeline.
- **Currency**: switching re-renders every amount. Invoices are stored in **USD** (base); display converts using the rate table. The invoice's own FX line always states the rate and the USD-equivalent total, so the client can reconcile. Prototype rates (`USD 1, EUR 0.92, BRL 5.42, COP 3980`) are placeholders — fetch live rates (or store the rate captured at issue time on each invoice, which is the correct accounting behavior) and show the fetch timestamp in the Exchange rate card. COP renders with 0 decimals, all others with 2.
- **Line items**: amount = `qty × rate`, recomputed on every keystroke. Subtotal = sum; tax amount = `subtotal × tax%`; total = subtotal + tax; balance due mirrors total. Empty/NaN inputs count as 0.
- **Save state**: any edit sets "unsaved changes"; saving restores "All changes saved".
- **Duplicate**: clones the current invoice with the next number and status `draft`.
- **Hover**: outline/ghost buttons and nav rows take an `--accent` wash; table rows take `--muted`; the remove-line icon turns `--destructive`. No press/active state distinct from hover, no scale transforms.
- **Animation**: essentially none. If entrance motion is wanted, a 0.5s fade + 8px rise with ease `cubic-bezier(0.23,1,0.32,1)` on screen change is the system's only motion pattern. No looping or decorative animation.
- **Responsive**: not required — desktop only. The layout is comfortable from ~1280px; nothing below that was designed.
- **Not drawn in the prototype** (implement using the same patterns): loading skeletons, empty states ("No invoices yet" in the table body area, 13px `--muted-foreground`, centered, 32px padding), Supabase error toasts, form validation on sign-in, and client create/edit forms.

## State management

Client-side state in the prototype:

| State | Type | Notes |
| --- | --- | --- |
| `screen` | `signin \| dashboard \| editor \| clients \| settings` | replaced by real routing/auth guard |
| `lang` | `en \| es \| pt` | persist per user |
| `currency` | `USD \| EUR \| BRL \| COP` | display only; persist per user |
| `search`, `statusFilter` | string | dashboard table filters, client-side |
| `saved` | boolean | dirty flag for the editor |
| `inv` | object | current invoice: `number, clientId, billTo, reference, issued, due, tax, status, notes, items[]` where each item is `{ desc, qty, rate }` |

Data requirements — build on the existing `invoices` table (`supabase-schema.sql`), with these changes:

1. **Status**: the design uses `draft | ready | paid | overdue`. Either add `overdue` to the allowed values, or derive it at read time (`status = 'ready' && due_date < today`) — deriving is simpler and avoids a migration.
2. **New `clients` table**: `id, user_id, name, country, address, created_at`, RLS scoped to `user_id` exactly like `invoices`. Add `client_id` (nullable FK) to `invoices` so the dashboard and top-clients ranking can join rather than parsing `bill_to` text. Keep `bill_to` as the frozen snapshot printed on the invoice.
3. **New fields on `invoices`**: `reference` (replaces the `ship_to` use), and optionally `fx_rate` + `fx_currency` captured at issue time.
4. **Settings**: a `profile` table or a JSON blob for legal name, tax ID, address, invoice prefix, next number, default terms, logo, signature (the last two already exist per-invoice as base64).

Derived values, all computed from the invoice list — outstanding (`ready` + `overdue`), paid this year, overdue total, average days to pay (paid date − issue date), revenue by month (rolling 8 months), top clients by lifetime billed.

## Assets

None. No images, photography, or illustrations — the design is entirely type, hairlines, and Lucide icons. The user's own logo and signature uploads are the only images in the product.

## Files in this bundle

- `prototype/Invoice Studio.dc.html` — the full design: all five screens, the translation dictionaries, mock data, and every computed value. Read the markup for exact inline styles and the logic block at the bottom for the `STR` translations, `RATES`, and derivation logic. **Reference only** — the `support.js` runtime it depends on is design-tool infrastructure.
- `prototype/support.js` — that runtime, included only so the prototype opens in a browser. Do not port it.
- `tokens/colors.css`, `fonts.css`, `typography.css`, `spacing.css`, `effects.css`, `base.css` — the CarbonSourcing design system tokens and component classes. **Copy these into the codebase** and build against the variables.

## Source repo mapping

| Redesigned screen | Existing code it replaces |
| --- | --- |
| Sign in | `index.html` → `#auth-section` |
| Dashboard | `index.html` → `#dashboard-section`; standalone `dashboard.html` (delete or redirect) |
| Invoice editor | `index.html` → `#invoice-section`, `.sheet`; `index_usd.html` (delete — superseded by the currency switch) |
| Clients | new |
| Settings | new — absorbs the logo/signature uploads currently sitting above the invoice sheet |
| App shell | replaces the `#tab-invoice` / `#tab-dashboard` button pair and its class-toggling handlers |

Preserve: `config.js` credential loading and the `.gitignore` rule, the Supabase client init and RLS-scoped queries, base64 logo/signature storage, the PDF download path, and the GitHub Pages deploy workflow.
