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
hugo serve --baseURL="http://localhost:1313"
```

---

## 🚀 Production Deploy
```bash
hugo --minify
aws s3 sync public/ s3://dzresume.dev --delete --profile crc-dev
aws cloudfront create-invalidation --distribution-id E39IUOSQTLZZWP --paths "/*" --profile crc-dev
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
