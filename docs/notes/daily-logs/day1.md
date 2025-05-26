# 🧠 Day 1: Enterprise-Grade AWS Environment Setup

## 🎯 Objective
Establish a professional multi-account AWS architecture with centralized identity management, cost governance, and secure CLI access — mirroring real-world enterprise cloud environments.

---

## 🏛️ Phase 1: Management Foundation with AWS Organizations
- Created root AWS account for governance (no workloads)
- Enabled AWS Organizations in **All Features** mode
- Designed organizational structure:
  - `Security OU` (future: audit/compliance)
  - `Workloads OU`
    - `Development OU`
    - `Production OU`
  - `Shared Services OU` (future: logging/monitoring)

---

## 🧾 Phase 2: Dev and Prod Account Provisioning
- Created two AWS member accounts:
  - `CloudResumeChallenge-Dev-DmitriyZ`
  - `CloudResumeChallenge-Prod-DmitriyZ`
- Used **Gmail plus-addressing** to reuse one inbox
- Placed accounts into correct OUs within AWS Org

---

## 👥 Phase 3: AWS SSO & Identity Management
- Enabled **AWS Single Sign-On** in `us-east-1`
- Created professional user identity: `dmitriy.zhernoviy`
- Enforced **MFA** for all access paths
- Created 3 permission sets:
  - `DevFullAccess` → for learning & experimentation
  - `ProdDeployAccess` → scoped for controlled production changes
  - `ProdReadOnlyAccess` → for monitoring/observability
- Assigned appropriate roles across both accounts
- Configured AWS CLI with named profiles via `aws configure sso`

---

## 💰 Phase 4: Financial Governance & Cost Control
- Enabled **billing integration** for all accounts
- Created **budgets and alerts** at:
  - Org-wide ($20 warning, $50 critical)
  - Account-specific ($10 dev, $5 prod)
  - Service-specific (e.g., EC2, Lambda, API Gateway)
- Configured cost allocation tags:
  - `Project`: CloudResumeChallenge
  - `Environment`: Development / Production
  - `Owner`: Dmitriy Zhernoviy

---

## 🔐 Phase 5: Security Hardening & Operational Readiness
- Verified **MFA enforced** for root and SSO identities
- No long-term access keys created
- All CLI usage routed through temporary credentials with session expiration
- Verified account switching via CLI with SSO profile config
- CloudTrail logging defaulted; GuardDuty planned for later

---

## 💻 Local Dev Environment Setup
- Installed and validated:
  - AWS CLI
  - Python 3.13+ with `venv`
  - Node.js + NPM
  - Hugo (static site generator)
  - Postman
  - Git + VS Code with AWS extension
- Initialized GitHub repository and Hugo site:
  ```bash
  hugo new site cloud-resume
