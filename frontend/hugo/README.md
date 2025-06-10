[![Deploy Staging](https://github.com/betterversion/cloud-resume-challenge/actions/workflows/deploy-staging.yml/badge.svg)](https://github.com/betterversion/cloud-resume-challenge/actions/workflows/deploy-staging.yml)


# 🌟 Cloud Resume Challenge - Hugo Frontend

Professional resume site built with Hugo, deployed via AWS S3 + CloudFront.

---

## 🏗️ Structure
```
frontend/hugo/
├── layouts/             # Theme overrides
├── data/                # Resume content (JSON)
├── static/img/          # Profile image
├── hugo.toml            # Config (prod)
└── public/              # Generated site (gitignored)
```

---

## 🛠️ Local Development

```bash
cd frontend/hugo

# Test blue environment (default)
HUGO_ENV=blue hugo server

# Test green environment
HUGO_ENV=green hugo server

---

## 🚀 Production Deploy
```bash
hugo --minify
aws s3 sync public/ s3://dzresume.dev --delete --profile crc-dev
aws cloudfront create-invalidation --distribution-id E39IUOSQTLZZWP --paths "/*" --profile crc-dev
```

## Cache Verification Commands
```bash
echo "🧪 Verifying deployment accessibility..."
# Test site loads successfully
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://www.dzresume.dev/)
if [ "$HTTP_STATUS" -eq 200 ]; then
  echo "✅ Site is accessible"
else
  echo "❌ Site returned $HTTP_STATUS"
  exit 1
fi

# Extract and test fingerprinted JavaScript asset
FINGERPRINTED_JS=$(grep -o '/js/visitor-counter\.[^"]*\.js' public/index.html)
JS_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://www.dzresume.dev${FINGERPRINTED_JS}")
if [ "$JS_STATUS" -eq 200 ]; then
  echo "✅ JavaScript asset is accessible"
else
  echo "❌ JavaScript returned $JS_STATUS"
  exit 1
fi
```

---

## 🔧 AWS Services
- **S3**: Website hosting
- **CloudFront**: CDN + HTTPS
- **DynamoDB (planned)**: Visitor count
- **Lambda + API Gateway (planned)**: Backend API

---

## 💡 Custom Additions
- SEO meta tags
- Visitor counter placeholder in `layouts/partial.index.html`
- Hugo theme override with `layouts/`

---
