# 🌐 Day 4: Wrestling with CloudFront, SSL Certificates, and the Cloudflare DNS Challenge

## 🎯 The Global Distribution Challenge

After getting my resume live on S3, I realized I had a problem. That ugly S3 URL wasn't going to impress anyone, and more importantly, I had no HTTPS. Time to add CloudFront and figure out this whole SSL certificate thing.

What seemed like a straightforward task turned into a masterclass in DNS complications and AWS service integration. Spoiler alert: Cloudflare and AWS don't always play nice together.

---

## 🔐 SSL Certificates: My First ACM Adventure

Before diving into CloudFront, I needed SSL certificates. AWS Certificate Manager (ACM) sounded simple enough - request a certificate, wait for validation, done.

I requested a certificate for both `dzresume.dev` and `www.dzresume.dev`. ACM offered two validation methods: DNS and email. I chose DNS because it's more automated and professional.

Here's where things got interesting. ACM generated these cryptic CNAME records I needed to add to my DNS:

```
_acme-challenge.dzresume.dev → some-long-aws-string.acm-validations.aws.
_acme-challenge.www.dzresume.dev → another-long-aws-string.acm-validations.aws.
```

The records looked scary, but adding them to Cloudflare was straightforward. Within minutes, ACM validated both domains and issued my certificate. First win of the day.

---

## ☁️ CloudFront Configuration: More Complex Than Expected

Creating a CloudFront distribution seemed simple in theory. Point it at my S3 bucket, attach the SSL certificate, add my custom domains. What could go wrong?

Turns out, everything.

My first attempt failed immediately with a vague error about missing `MinTTL` values. After some digging, I learned CloudFront needs explicit cache behavior settings. I set `MinTTL` to 0, which allows CloudFront to respect the origin's cache headers.

The origin configuration was trickier than expected. I had two choices:
- Point to the S3 bucket directly (`dzresume.dev.s3.amazonaws.com`)
- Point to the S3 static website endpoint (`dzresume.dev.s3-website-us-east-1.amazonaws.com`)

I went with the website endpoint because it handles redirect rules and error pages properly. This decision would matter later when I implemented proper 404 handling.

---

## 🔒 Origin Access Control: Securing the Backend

With CloudFront working, I had a new problem. My S3 bucket was still publicly accessible, which meant people could bypass CloudFront entirely. That defeats the purpose of having a CDN.

AWS recently replaced Origin Access Identity (OAI) with Origin Access Control (OAC). The new system is more secure and works better with modern S3 features.

Creating the OAC was simple, but updating the S3 bucket policy required some careful ARN management:

```json
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudfront.amazonaws.com"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::dzresume.dev/*",
      "Condition": {
        "StringEquals": {
          "AWS:SourceArn": "arn:aws:cloudfront::account-id:distribution/distribution-id"
        }
      }
    }
  ]
}
```

That `StringEquals` condition is crucial. It ensures only my specific CloudFront distribution can access the bucket, not just any CloudFront distribution in AWS.

After applying the policy, I enabled "Block All Public Access" on the bucket. Testing confirmed that direct S3 access now returned 403 errors, while CloudFront access worked perfectly.

---

## 🌐 The Cloudflare DNS Nightmare

This is where my day went sideways. I wanted both `dzresume.dev` and `www.dzresume.dev` to work with CloudFront. In a perfect world, I'd create an ALIAS record pointing the apex domain to CloudFront.

But Cloudflare doesn't support ALIAS records for apex domains when the target is outside Cloudflare. Their "flattening" feature only works for their own services.

After trying multiple approaches, I settled on a workaround:
1. CNAME record: `www.dzresume.dev` → CloudFront distribution domain
2. Cloudflare Page Rule: `dzresume.dev/*` → `https://www.dzresume.dev/$1`

The page rule essentially redirects the apex domain to the www subdomain. Not ideal, but it works reliably across all browsers and doesn't require complex DNS trickery.

---

## 🎨 Hugo BaseURL Adventures

With CloudFront working, I loaded my site and... it looked terrible again. No CSS, broken images, the works. Sound familiar?

The problem was my Hugo `baseURL` configuration. It was still pointing to the ugly S3 website URL:

```toml
baseURL = "http://dzresume.dev.s3-website-us-east-1.amazonaws.com/"
```

Hugo generates absolute URLs for assets based on this setting. Every CSS and JavaScript reference was pointing to S3 instead of CloudFront.

Simple fix:

```toml
baseURL = "https://www.dzresume.dev/"
```

Rebuild, redeploy, and everything worked perfectly. Professional HTTPS site with global CDN distribution.

---

## 🧪 Testing Everything End-to-End

I'm paranoid about testing, especially with DNS and CDN configurations. Too many moving pieces can fail silently.

My testing checklist:
- ✅ `https://www.dzresume.dev` loads correctly
- ✅ `https://dzresume.dev` redirects to www version
- ✅ Direct S3 access blocked (returns 403)
- ✅ SSL certificate valid and trusted
- ✅ All assets loading through CloudFront
- ✅ Mobile responsive design working
- ✅ Page load speed improved (CDN benefits)

The curl commands were particularly useful for debugging:

```bash
# Check redirect behavior
curl -I https://dzresume.dev
# Should return 301 redirect

# Verify final destination
curl -I https://www.dzresume.dev
# Should return 200 OK with CloudFront headers
```

---

## 💡 What I Learned About Real-World AWS

This day taught me that AWS documentation often glosses over the integration challenges with third-party services. The "simple" CloudFront + custom domain setup becomes complex when you're not using Route 53 for DNS.

Understanding the difference between S3 bucket endpoints and website endpoints matters. The choice affects redirects, error handling, and security configurations.

Most importantly, I learned that modern web architecture requires thinking about the entire request flow: DNS → CDN → Origin → Application. Each layer has its own caching, security, and performance considerations.

The Cloudflare workaround was frustrating but educational. Real-world cloud engineering often involves working within the constraints of existing services and finding creative solutions when the "standard" approach doesn't work.

By day's end, I had a professional HTTPS website with global distribution. More importantly, I understood how all the pieces fit together and could troubleshoot issues confidently.

The ugly S3 URL was history. Time to move on to the fun part: making this site actually do something interesting.
