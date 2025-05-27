# 🧠 Day 1: Enterprise-Grade AWS Environment Setup

## 🎯 Objective

Establish a professional multi-account AWS architecture with centralized identity management, cost governance, and secure CLI access — mirroring real-world enterprise cloud environments.

---

## 🏛️ Phase 1: Management Foundation with AWS Organizations

* Created root AWS account for governance (no workloads)
* Enabled AWS Organizations in **All Features** mode
* Designed organizational structure:

  * `Security OU` (future: audit/compliance)
  * `Workloads OU`

    * `Development OU`
    * `Production OU`
  * `Shared Services OU` (future: logging/monitoring)

---

## 🧾 Phase 2: Dev and Prod Account Provisioning

* Created two AWS member accounts:

  * `CloudResumeChallenge-Dev-DmitriyZ`
  * `CloudResumeChallenge-Prod-DmitriyZ`
* Used **Gmail plus-addressing** to reuse one inbox
* Placed accounts into correct OUs within AWS Org

---

## 👥 Phase 3: AWS SSO & Identity Management

* Enabled **AWS Single Sign-On** in `us-east-1`
* Created professional user identity: `dmitriy.zhernoviy`
* Enforced **MFA** for all access paths
* Created 3 permission sets:

  * `DevFullAccess` → for learning & experimentation
  * `ProdDeployAccess` → scoped for controlled production changes
  * `ProdReadOnlyAccess` → for monitoring/observability
* Assigned appropriate roles across both accounts
* Configured AWS CLI with named profiles via `aws configure sso`

---

## 💰 Phase 4: Financial Governance & Cost Control

* Enabled **billing integration** for all accounts
* Created **budgets and alerts** at:

  * Org-wide (\$20 warning, \$50 critical)
  * Account-specific (\$10 dev, \$5 prod)
  * Service-specific (e.g., EC2, Lambda, API Gateway)
* Configured cost allocation tags:

  * `Project`: CloudResumeChallenge
  * `Environment`: Development / Production
  * `Owner`: Dmitriy Zhernoviy

---

## 🔐 Phase 5: Security Hardening & Operational Readiness

* Verified **MFA enforced** for root and SSO identities
* No long-term access keys created
* All CLI usage routed through temporary credentials with session expiration
* Verified account switching via CLI with SSO profile config
* CloudTrail logging defaulted; GuardDuty planned for later

---

## 💻 Local Dev Environment Setup

* Installed and validated tools for local development:

  * AWS CLI v2 with SSO support
  * Python 3.13+ with `venv`
  * Node.js + NPM
  * Hugo (static site generator)
  * Postman
  * Git + VS Code with AWS Toolkit extension
* Configured AWS CLI SSO profiles for both accounts:

  * `crc-dev` for Development (DevFullAccess role)
  * `crc-prod` for Production (ProdDeployAccess role)
  * Reused a single SSO session for efficient authentication (`crc-sso`)
* Verified SSO login, session expiration behavior, and role-based access with:

  ```bash
  aws sso login --profile crc-dev
  aws sts get-caller-identity --profile crc-dev
  aws s3 ls --profile crc-dev
  aws sso login --profile crc-prod
  aws sts get-caller-identity --profile crc-prod
  ```
* Initialized GitHub repository and Hugo site:

  ```bash
  hugo new site cloud-resume
  ```

---

## 🧠 Lessons & Takeaways

* Multi-account architecture is the backbone of professional cloud security and cost management
* AWS SSO greatly simplifies identity and access control while enabling enterprise-grade security
* Cost tagging + budget alerts are not “extras” — they are **required infrastructure hygiene**
* AWS CLI with SSO is smooth, secure, and reflects modern DevOps best practices
