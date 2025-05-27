# 🌍 Day 4: CloudFront CDN, HTTPS & Custom Domain Integration

## 🎯 Objective

Deliver the resume site globally using **Amazon CloudFront** with custom domain and SSL via ACM. Secure the S3 origin, configure CDN behaviors, and integrate domain DNS through Cloudflare with workarounds.

---

## 🔑 Phase 1: Domain Registration & DNS Provider Setup

* Purchased domain: `dzresume.dev` via Google Domains (managed through **Cloudflare**)
* Kept DNS management in **Cloudflare** for this phase
* Created initial CNAME records in Cloudflare for ACM DNS validation:

  * `_acm-validation.dzresume.dev` → ACM DNS target
  * `_acm-validation.www.dzresume.dev` → ACM DNS target
* Successfully validated both domain names via AWS Certificate Manager (ACM)
  ✅ Certificate issued in **us-east-1**

---

## ☁️ Phase 2: CloudFront CDN Configuration

* Created CloudFront distribution via **console** with:

  * **Origin domain**: `dzresume.dev.s3-website-us-east-1.amazonaws.com` (static website endpoint)
  * **Viewer protocol policy**: `Redirect HTTP to HTTPS`
  * **Custom domain aliases**:

    * `dzresume.dev`
    * `www.dzresume.dev`
  * Attached previously issued ACM certificate (us-east-1)
  * Enabled compression (GZIP) and set default root object (`index.html`)
  * 🧯 *Fix*: Initial creation failed due to missing `MinTTL` — added `MinTTL: 0`

---

## 🧱 Phase 3: Hugo Styling + Base URL Fix

* Updated `baseURL` in `hugo.toml` to match CloudFront domain:

  ```toml
  baseURL = "https://www.dzresume.dev/"
  ```
* Rebuilt and deployed Hugo site:

  ```bash
  hugo --minify
  aws s3 sync public/ s3://dzresume.dev --delete --profile crc-dev
  ```
* ✅ Fixed broken styling caused by incorrect asset paths

---

## 🔐 Phase 4: S3 Origin Hardening via Origin Access Control

* Created **Origin Access Control (OAC)** and attached to CloudFront origin
* Updated **S3 bucket policy** to allow only CloudFront access:

  ```json
  {
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "AllowCloudFrontServicePrincipal",
        "Effect": "Allow",
        "Principal": {
          "Service": "cloudfront.amazonaws.com"
        },
        "Action": "s3:GetObject",
        "Resource": "arn:aws:s3:::dzresume.dev/*",
        "Condition": {
          "StringEquals": {
            "AWS:SourceArn": "arn:aws:cloudfront::830279065089:distribution/E39IUOSQTLZZWP"
          }
        }
      }
    ]
  }
  ```
* Enabled **Block All Public Access** in the bucket
* 🧪 Confirmed direct S3 access returns `403` or `404` as expected

---

## 🌐 Phase 5: Cloudflare DNS Workarounds

* 🛠️ *Blocker*: Cloudflare **does not support ALIAS or ANAME** records for apex domain (`dzresume.dev`)
* Solution:

  * Added `CNAME` for `www.dzresume.dev` → CloudFront domain
  * Created **Page Rule** in Cloudflare to redirect:

    * `dzresume.dev/*` → `https://www.dzresume.dev/$1`
    * This simulates root domain → `www.` redirection
* DNS records summary in Cloudflare:

  * ✅ ACM validation CNAMEs
  * ✅ `www` → CloudFront
  * ✅ Page rule-based redirection for apex

---

## 🧪 Phase 6: Full End-to-End Testing

* ✅ `https://www.dzresume.dev` loads properly via CloudFront
* ✅ Styling, assets, and layout fully functional
* ✅ SSL certificate trusted, issued by Amazon
* ✅ Manual CLI checks:

  * `curl -I https://dzresume.dev` → 301 redirect to `www`
  * `curl -I https://www.dzresume.dev` → 200 OK
  * `nslookup`, `dig` confirmed correct DNS resolution
* ✅ S3 origin secured — cannot be accessed directly
* ✅ Verified on desktop + mobile (Chrome/Firefox)

---

## 🧠 Lessons & Takeaways

* Using Cloudflare with AWS requires **manual ACM validation** and smart DNS planning
* Apex domain support is **limited in Cloudflare** — expect to use `www` subdomain or external redirects
* CloudFront OAC is modern, secure, and preferred over legacy OAI
* Correct `baseURL` is critical for Hugo to render assets properly
* Simulated **real-world CDN + DNS edge cases** — just like in professional environments

---

## 📌 Summary

> “Today I connected my resume to the world through CloudFront and ACM. I battled DNS edge cases, secured my origin with OAC, and launched a production-grade HTTPS resume with global reach. Cloud engineering feels real now.”
