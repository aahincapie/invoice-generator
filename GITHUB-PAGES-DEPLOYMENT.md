# GitHub Pages Deployment Guide

## ⚠️ Important: Config File Challenge

Since `config.js` contains your Supabase credentials and is **not committed** to GitHub (for security), you need a special approach for GitHub Pages deployment.

## 🎯 Solution Options

### **Option 1: GitHub Actions with Secrets (Recommended)**

This automatically builds and deploys with your config file.

#### Step 1: Add GitHub Secrets

1. Go to your repository: https://github.com/aahincapie/invoice-generator
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add this secret:
   - Name: `SUPABASE_PUBLISHABLE_KEY`
   - Value: `sb_publishable_u3Vv70ovBiEGZ8G1uCdw7w_phEZhjo4`
5. Click **Add secret**

#### Step 2: Update GitHub Actions Workflow

Edit `.github/workflows/deploy.yml`:

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches:
      - main
      - master
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Create config.js
        run: |
          cat > config.js << EOF
          const SUPABASE_CONFIG = {
            url: 'https://fwpadfroagpzkmcxzppq.supabase.co',
            publishableKey: '${{ secrets.SUPABASE_PUBLISHABLE_KEY }}'
          };
          EOF

      - name: Setup Pages
        uses: actions/configure-pages@v4

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: '.'

  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

#### Step 3: Deploy

```bash
git add .github/workflows/deploy.yml
git commit -m "Update deployment workflow with config generation"
git push origin main
```

Your site will be at: `https://aahincapie.github.io/invoice-generator/`

---

### **Option 2: Manual Config in gh-pages Branch**

This approach creates a separate `gh-pages` branch with the config file.

#### Step 1: Create gh-pages branch

```bash
git checkout --orphan gh-pages
git reset --hard
```

#### Step 2: Copy all files from main

```bash
git checkout main -- .
```

#### Step 3: Create config.js

```bash
cat > config.js << 'EOF'
const SUPABASE_CONFIG = {
  url: 'https://fwpadfroagpzkmcxzppq.supabase.co',
  publishableKey: 'sb_publishable_u3Vv70ovBiEGZ8G1uCdw7w_phEZhjo4'
};
EOF
```

#### Step 4: Commit and push

```bash
git add .
git commit -m "Deploy to GitHub Pages with config"
git push origin gh-pages
```

#### Step 5: Configure GitHub Pages

1. Go to **Settings** → **Pages**
2. Source: **Deploy from a branch**
3. Branch: **gh-pages** / **root**
4. Click **Save**

**⚠️ Downside:** You need to manually update gh-pages whenever main changes.

---

### **Option 3: Environment-Agnostic Deployment**

Make the app work without hardcoded config by prompting users to enter their credentials.

#### Modify index.html to include:

```html
<script>
  // Check if config exists, otherwise prompt user
  if (typeof SUPABASE_CONFIG === 'undefined') {
    const savedConfig = localStorage.getItem('supabase-config');
    if (savedConfig) {
      window.SUPABASE_CONFIG = JSON.parse(savedConfig);
    } else {
      // Show config input modal
      const modal = document.createElement('div');
      modal.innerHTML = `
        <div style="position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.8); display: flex; align-items: center; justify-content: center; z-index: 9999;">
          <div style="background: white; padding: 2rem; border-radius: 8px; max-width: 500px;">
            <h2>Supabase Configuration Required</h2>
            <p>Enter your Supabase credentials:</p>
            <input id="config-url" placeholder="Supabase URL" style="width: 100%; margin: 0.5rem 0; padding: 0.5rem;">
            <input id="config-key" placeholder="Publishable Key" style="width: 100%; margin: 0.5rem 0; padding: 0.5rem;">
            <button id="save-config" style="width: 100%; padding: 0.5rem; background: #0ea5e9; color: white; border: none; border-radius: 4px; cursor: pointer;">Save</button>
          </div>
        </div>
      `;
      document.body.appendChild(modal);

      document.getElementById('save-config').onclick = () => {
        const config = {
          url: document.getElementById('config-url').value,
          publishableKey: document.getElementById('config-key').value
        };
        localStorage.setItem('supabase-config', JSON.stringify(config));
        window.SUPABASE_CONFIG = config;
        modal.remove();
        location.reload();
      };
    }
  }
</script>
```

**⚠️ Downside:** Less convenient, but works everywhere without build steps.

---

## 🎯 Recommended Approach

**For this project: Option 1 (GitHub Actions with Secrets)**

Why?
- ✅ Automatic deployment
- ✅ Config stays secure
- ✅ Easy to update
- ✅ Professional approach
- ✅ No manual steps after initial setup

---

## 🚀 Quick Start (Option 1)

1. **Add Secret:**
   - Go to repo Settings → Secrets → Actions
   - Add `SUPABASE_PUBLISHABLE_KEY`

2. **Update Workflow:**
   - Edit `.github/workflows/deploy.yml`
   - Add config.js creation step (see above)

3. **Push to main:**
   ```bash
   git push origin main
   ```

4. **Visit your site:**
   https://aahincapie.github.io/invoice-generator/

---

## ✅ Verification

After deployment, verify:
- [ ] Site loads at GitHub Pages URL
- [ ] Sign In page appears
- [ ] Can create account
- [ ] Can create invoice
- [ ] Can save to Supabase
- [ ] Can download PDF
- [ ] Dashboard works

---

## 🔧 Troubleshooting

### **Problem: Site loads but can't sign in**

**Cause:** config.js not created properly

**Fix:**
1. Check GitHub Actions workflow logs
2. Verify secret name matches exactly
3. Ensure config.js creation step ran

### **Problem: GitHub Actions workflow fails**

**Cause:** Missing permissions or secrets

**Fix:**
1. Check workflow permissions (should be read + write)
2. Verify secret exists and is named correctly
3. Check Actions logs for specific error

### **Problem: Changes don't appear on site**

**Cause:** Workflow hasn't run or Pages not updated

**Fix:**
1. Go to Actions tab → Check if workflow ran
2. Go to Settings → Pages → Check last deployment time
3. Hard refresh browser (Ctrl+Shift+R)

---

## 📝 Next Steps

After successful deployment:
1. Test all features on live site
2. Share URL with users
3. Monitor Supabase usage in dashboard
4. Set up custom domain (optional)

---

## 🔐 Security Notes

- ✅ Publishable key is safe to expose (it's designed for client-side)
- ✅ GitHub Secrets are encrypted
- ✅ Row Level Security protects user data
- ✅ Never expose your Supabase **secret key** (this guide only uses publishable key)

---

Your GitHub Pages site will be live at:
**https://aahincapie.github.io/invoice-generator/** 🎉
