# 🌐 Day 3: Static Resume Deployment – AWS S3 Production Hosting

## 🎯 Objective

Deploy the Hugo-built resume website to **AWS S3 static hosting** with secure, production-ready configuration. Implement IAM policies for public access, verify deployment end-to-end, and resolve Hugo pathing issues.

---

## 🏗️ Phase 1: Production Build Prep

- Ran production build using Hugo:
  ```bash
  hugo --minify
  ```
- Verified contents of `public/` directory included:
  - `index.html`
  - `css/`, `js/`, `img/` folders
- Confirmed responsive layout and asset rendering via local Hugo server (`hugo server -D`)

---

## ☁️ Phase 2: AWS S3 Bucket Creation

- Created S3 bucket: `dzresume.dev.s3-website-us-east-1.amazonaws.com`
- Region: `us-east-1`
- Disabled **Block All Public Access** to enable web access
- Enabled **Static Website Hosting**
  - Index document: `index.html`
  - Error document: `404.html` (optional)
- Noted generated website URL

---

## 🔐 Phase 3: Public Access Bucket Policy

- Applied least-privilege bucket policy to enable global read access:
  ```json
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "PublicReadGetObject",
        "Effect": "Allow",
        "Principal": "*",
        "Action": "s3:GetObject",
        "Resource": "arn:aws:s3:::dzresume.dev/*"
      }
    ]
  }
  ```

---

## 🚀 Phase 4: Content Upload & Deployment

- Uploaded contents of `public/` to S3 bucket via AWS Console
- Maintained full directory structure (`css/`, `img/`, `js/`, etc.)
- Validated S3 object paths matched local Hugo output

---

## 🧪 Phase 5: Production Testing

- Accessed static website via S3 endpoint:
  ```
  http://dzresume.dev.s3-website-us-east-1.amazonaws.com/
  ```
- Verified:
  - ✅ Resume loads with full styling
  - ✅ Profile image appears
  - ✅ Sections display properly
  - ✅ Browser resize retains responsive layout
- Confirmed behavior across:
  - Chrome, Edge
  - Desktop + mobile

---

## 🛠️ Phase 6: Style Bug Fix

- Identified issue: broken styling after deployment caused by baseURL mismatch
- Root cause: Hugo config had `localhost:1313` as `baseURL`
- Resolution:
  - Updated `hugo.toml`:
    ```toml
    baseURL = "http://dzresume.dev.s3-website-us-east-1.amazonaws.com/"
    ```
  - Rebuilt and re-uploaded site

---

## 🧠 Lessons & Takeaways

- Hugo’s `baseURL` controls absolute paths in production – critical for S3 deployment
- Public read access must be deliberately configured with IAM, not assumed
- Static website hosting on S3 is powerful, simple, and enterprise-aligned
- Local testing isn't enough — production must be validated visually
- This is real-world cloud engineering: infrastructure + security + deployment + QA

---

## 📌 Summary

> “Today I turned my local resume into a real, production-ready website hosted on AWS S3 — complete with IAM security, public access control, and cloud deployment validation.”

---
