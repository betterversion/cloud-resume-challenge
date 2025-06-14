[← Back to Root Overview](../README.md)

<!-- WORKFLOWS README v1.0 | Updated: 2025-06-12 -->

# 🚀 CI/CD Workflows - GitHub Actions Implementation

**Production-grade deployment pipelines orchestrating blue-green deployments across Terraform infrastructure, serverless backend, and Hugo frontend with comprehensive quality gates and zero-downtime promotion strategies.**

![CI/CD Blue-Green Workflow](../../docs/architecture/ci-cd-blue-green-workflow.png)

---

## 📋 Workflow Matrix

|File|Trigger|Key Jobs|Purpose|
|---|---|---|---|
|**`deploy-staging.yml`**|Push to `feature/**`, Manual dispatch|`determine-environment`, `build-deploy-frontend`, `deploy-backend`, `test-api-endpoints`, `cypress-test`|Automated staging deployment with comprehensive validation|
|**`promote-production.yml`**|Manual dispatch only|`analyze-and-plan`, `validate-staging`, `switch-traffic`, `verify-production`, `rollback`|Production promotion with approval gates and automatic rollback|

---

## 🔄 Blue-Green Promotion Logic

### Staging Deployment Flow
**`deploy-staging.yml`** automatically deploys to the **inactive environment**:

1. **Environment Detection** - Queries Terraform state to determine active production environment
2. **Target Selection** - Deploys to opposite environment (if production = blue, deploy to green)
3. **Parallel Deployment** - Frontend (Hugo) and backend (Terraform application layer) deploy simultaneously
4. **Validation Pipeline** - API tests, E2E tests, and health checks confirm deployment success
5. **Staging Access** - `test.dzresume.dev` always points to inactive environment for validation

### Production Promotion Flow
**`promote-production.yml`** orchestrates zero-downtime traffic switching:

1. **Staging Validation** - Confirms latest staging deployment succeeded
2. **Infrastructure Analysis** - Determines current active environment and promotion target
3. **Manual Approval Gate** - Production environment protection requires human approval
4. **Traffic Switch** - Updates `active_environment` variable in [persistent layer](../infrastructure/terraform/README.md#blue-green-deployment-flow)
5. **Cache Invalidation** - Global CloudFront invalidation ensures immediate propagation
6. **Verification** - Confirms production functionality with version correlation
7. **Automatic Rollback** - Reverts on verification failure

---

## 🛠️ Reusable Actions & Composite Steps

### Third-Party Actions
- **`aws-actions/configure-aws-credentials@v4`** - OIDC authentication with temporary credentials
- **`hashicorp/setup-terraform@v3`** - Terraform CLI with provider caching
- **`peaceiris/actions-hugo@v3`** - Hugo extended installation
- **`cypress-io/github-action@v6`** - E2E testing with artifact capture

### Custom Composite Logic
- **Environment orchestration** - Single job determines deployment targets for all downstream jobs
- **Terraform caching** - Provider cache reduces deployment time by 60%
- **Conditional deployment** - Git diff analysis deploys only changed components
- **Version correlation** - Build numbers embedded in deployments for verification

---

## 🔐 Secrets & OIDC Permissions

### Required Secrets
|Secret|Purpose|Environment|
|---|---|---|
|`AWS_ROLE_ARN`|GitHub Actions OIDC role for AWS access|Repository|

### OIDC Configuration
**Zero stored credentials** - GitHub Actions authenticates via OpenID Connect:

```yaml
permissions:
  id-token: write  # Required for OIDC token generation
  contents: read   # Repository access
  actions: read    # Workflow status queries
```

**IAM Trust Relationship** configured in [persistent layer](../infrastructure/terraform/README.md#security--compliance) restricts access to specific repository and workflow conditions.

---

## 🧪 Quality Gates

### Automated Testing Pipeline
- **Frontend Unit Tests** - **Vitest** validation of JavaScript business logic
- **API Integration Tests** - **Newman** execution of 36 Postman assertions
- **End-to-End Tests** - **Cypress** user journey validation with screenshot capture
- **Infrastructure Validation** - Terraform plan verification and compliance scanning

### Failure Conditions
- **Unit test failures** block frontend deployment
- **API test failures** prevent staging promotion readiness
- **E2E test failures** mark deployment as incomplete
- **Production verification failures** trigger automatic rollback

### Quality Artifacts
```yaml
- name: 📊 Upload test results
  uses: actions/upload-artifact@v4
  with:
    name: cypress-results-${{ github.run_number }}
    path: |
      frontend/hugo/cypress/screenshots
      frontend/hugo/cypress/videos
    retention-days: 3
```

---

## 🖥️ Local Debug Tips

### Workflow Execution
```bash
# Trigger staging deployment manually
gh workflow run deploy-staging.yml \
  --field deploy_frontend=true \
  --field deploy_backend=true

# Trigger production promotion
gh workflow run promote-production.yml \
  --field force_promotion=false

# View workflow status
gh run list --workflow=deploy-staging.yml
```

### Local Testing with Act
```bash
# Install act for local workflow testing
brew install act

# Run staging workflow locally (requires Docker)
act push --secret-file .secrets \
  --workflows .github/workflows/deploy-staging.yml
```

### Branch Protection Bypass
```bash
# Emergency production deployment (admin only)
gh workflow run promote-production.yml \
  --field force_promotion=true
```

---

## 📚 Further Reading

### Architecture Documentation
- **[Infrastructure as Code](../infrastructure/terraform/README.md)** - Terraform layers and blue-green architecture
- **[Serverless Backend](../backend/README.md)** - Lambda function and API Gateway configuration
- **[Hugo Frontend](../frontend/README.md)** - Static site generation and deployment pipeline

### Implementation Details
- **[Daily Development Log](../docs/progress.md)** - Chronological implementation decisions
- **[Security Implementation](../infrastructure/terraform/README.md#security--compliance)** - OIDC and IAM configuration
- **[Testing Strategy](../backend/README.md#testing)** - Comprehensive validation approach

### Operational Guides
- **Branch Protection Rules** - Staging deployment required for production promotion
- **Concurrency Groups** - `concurrency: ${{ github.workflow }}-${{ github.ref }}` prevents overlapping deployments
- **Environment Protection** - Production requires manual approval with designated reviewers
- **Artifact Management** - Automated cleanup with 3-day retention for debugging artifacts

---

_Automated deployment pipelines demonstrating enterprise CI/CD patterns with comprehensive quality gates and zero-downtime promotion strategies 🚀_
