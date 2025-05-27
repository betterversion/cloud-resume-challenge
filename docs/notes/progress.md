# 📌 Cloud Resume Challenge – Daily Progress Summary

This file tracks daily progress throughout the Cloud Resume Challenge.
Click on a specific day to view the full breakdown and implementation notes.

## 🎯 Goal
Complete the Cloud Resume Challenge to land my first cloud engineering job!

## 📅 Timeline
- **Start Date:** [05/26/25]
- **Target End:** [6 weeks from start]
- **Actual End:** TBD

---

## ✅ Completed Days

### 🔹 [Day 1 – AWS Org Setup, Identity & Cost Governance](./daily-logs/day1.md)
- Created multi-account AWS Organization with root governance
- Provisioned dev/prod accounts in structured OUs
- Enabled AWS SSO with MFA, CLI profiles, and role-based permission sets
- Implemented cost tagging, budgets, and alerts
- Installed local tooling and initialized Hugo project + GitHub repo

### 🔹 [Day 2 – Repository Structure & Hugo Resume Integration](./daily-logs/day2.md)
- Created `frontend/hugo` project directory with clean modular structure
- Initialized Hugo site and added `hugo-resume` theme via Git submodule
- Structured resume data via JSON files (skills, experience, education, certifications)
- Customized `hugo.toml` with personal and professional branding
- Successfully tested site locally at `localhost:1313` with responsive layout and working sections

### 🔹 [Day 3 – Production Build & S3 Deployment](./daily-logs/day3.md)
- Ran `hugo --minify` to generate optimized production-ready static files
- Fixed `baseURL` in `config.toml` to match deployed S3 endpoint
- Verified correct HTML, CSS, JS asset generation in `public/` folder
- Uploaded build to S3 bucket configured for static website hosting
- Successfully opened live resume site via S3 public URL with styling intact

---

## 📋 Current Week Progress

### Week 1: Foundation & Frontend (Days 1-7)
- [x] Day 1: AWS Organization & Environment Setup ✅
- [x] Day 2: Repository structure & convert resume to Hugo format
- [ ] Day 3: Deploy resume to S3 with static website hosting
- [ ] Day 4: Enable HTTPS with CloudFront CDN
- [ ] Day 5: Setup custom domain with Route 53
- [ ] Day 6: Polish frontend & responsive design
- [ ] Day 7: Week 1 review & documentation

### Week 2: Backend API Development (Days 8-14)
- [ ] Day 8: DynamoDB table design & setup
- [ ] Day 9: DynamoDB testing & data modeling
- [ ] Day 10: Lambda function development (Python)
- [ ] Day 11: Lambda testing & error handling
- [ ] Day 12: API Gateway configuration
- [ ] Day 13: API Gateway testing & CORS setup
- [ ] Day 14: Week 2 review & integration planning

### Week 3: Frontend/Backend Integration (Days 15-21)
- [ ] Day 15: JavaScript visitor counter implementation
- [ ] Day 16: Frontend-backend connection & debugging
- [ ] Day 17: Python unit tests for Lambda
- [ ] Day 18: Cypress end-to-end tests
- [ ] Day 19: Error handling & edge cases
- [ ] Day 20: Performance optimization
- [ ] Day 21: Week 3 review & testing

### Week 4: Infrastructure as Code (Days 22-28)
- [ ] Day 22: IaC tool selection (Terraform/SAM/CDK)
- [ ] Day 23: Convert backend resources to IaC
- [ ] Day 24: Convert frontend resources to IaC
- [ ] Day 25: IaC testing & validation
- [ ] Day 26: Documentation & cleanup
- [ ] Day 27: Cost optimization review
- [ ] Day 28: Week 4 review

### Week 5: CI/CD Pipeline (Days 29-35)
- [ ] Day 29: GitHub Actions setup for backend
- [ ] Day 30: Backend CI/CD pipeline completion
- [ ] Day 31: GitHub Actions setup for frontend
- [ ] Day 32: Frontend CI/CD pipeline completion
- [ ] Day 33: End-to-end automation testing
- [ ] Day 34: Security scanning & improvements
- [ ] Day 35: Week 5 review

### Week 6: Polish & Launch (Days 36-42)
- [ ] Day 36: Final testing & bug fixes
- [ ] Day 37: Blog post draft
- [ ] Day 38: Blog post editing & diagrams
- [ ] Day 39: Architecture documentation
- [ ] Day 40: LinkedIn/Twitter announcements prep
- [ ] Day 41: Final deployment & go-live
- [ ] Day 42: Celebration & reflection! 🎉

---

## 🏆 Major Milestones

### Infrastructure
- [x] AWS Organization with multi-account setup
- [ ] Static website live on custom domain
- [ ] Backend API responding to requests
- [ ] Infrastructure fully defined as code
- [ ] CI/CD pipeline automated

### Technical Skillsc
- [x] AWS SSO & Organizations
- [ ] S3 static hosting
- [ ] CloudFront CDN
- [ ] DynamoDB
- [ ] Lambda & API Gateway
- [ ] Infrastructure as Code
- [ ] GitHub Actions

### Career Readiness
- [ ] Working portfolio site
- [ ] Blog post published
- [ ] Architecture diagram created
- [ ] Interview stories documented
- [ ] LinkedIn updated

---

## 📊 Project Stats

### Time Investment
- **Total Hours:** 2.5 (Day 1)
- **Daily Average:** 2.5 hours
- **Weekend Hours:** 0

### Progress Metrics
- **Commits:** 3
- **AWS Services Used:** 3 (Organizations, SSO, Billing)
- **Cost to Date:** $0.00
- **Errors Debugged:** 0
- **Stack Overflow Visits:** 0
- **Coffee Consumed:** ☕☕

### Learning Highlights
- **Biggest Win:** Enterprise-grade AWS setup on Day 1!
- **Toughest Challenge:** TBD
- **Most Interesting Discovery:** AWS SSO makes multi-account management smooth

---

## 🔗 Quick Links
- [Architecture Diagram](./docs/architecture/diagram.png) (coming soon)
- [Daily Logs](./daily-logs/)
- [Learning Notes](./notes/)
- [Blog Draft](./docs/blog-draft.md) (coming soon)

---
