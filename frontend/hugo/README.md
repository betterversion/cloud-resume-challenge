[← Back to Root Overview](../../README.md)

# 🎨 Frontend - Professional Cloud Resume Site

**Enterprise-grade Hugo frontend** showcasing cloud engineering expertise through a serverless-integrated resume website with zero-downtime deployments and comprehensive testing.

🔗 **[Live Demo](https://dzresume.dev/)** |
📚 **[Backend Guide →](../../backend/README.md)** |
🏗️ **[Infrastructure Guide →](../../infrastructure/README.md)**

---

## 📑 Table of Contents

- [🏗️ Architecture Overview](#architecture-overview)
- [📁 Project Structure](#project-structure)
- [✨ Key Features](#key-features)
- [🚀 Quick Start](#quick-start)
- [🧪 Testing Strategy](#testing-strategy)
- [🌐 Deployment Strategy](#deployment-strategy)
- [🏗️ Architecture Decisions](#️architecture-decisions)
- [📊 Performance Metrics](#performance-metrics)

---

<h2 id="architecture-overview">🏗️ Architecture Overview</h2>

### Visitor Counter Request Flow
![Visitor Counter Sequence](../../docs/architecture/visitor-counter-sequence-diagram.png)
*Figure 1: Complete request lifecycle from user interaction to database update*

**Tech Stack:** Hugo + Hugo Pipes | Bootstrap 4 | Vanilla JavaScript | AWS S3/CloudFront | Blue-Green Deployment

---

<h2 id="project-structure">📁 Project Structure</h2>

```
frontend/hugo/
├── 📄 hugo.toml                    # Hugo configuration & API endpoints
├── 📄 package.json                 # Node.js dependencies & scripts
├── 📁 layouts/                     # Hugo template overrides
│   ├── partials/
│   │   ├── about.html              # Hero section + visitor counter
│   │   ├── visitor-counter-js.html # Asset processing pipeline
│   │   └── portfolio/              # Custom page sections
│   └── _default/baseof.html        # Main HTML structure
├── 📁 assets/js/                   # Source JavaScript (processed by Hugo Pipes)
│   └── visitor-counter.js          # Counter logic with environment routing
├── 📁 data/                        # Content as structured data
│   ├── skills.json                 # Technical skills by category
│   ├── experience.json             # Work history
│   └── certifications.json        # AWS certifications
├── 📁 test/                        # Unit tests (Vitest)
│   └── visitor-counter.test.js     # JavaScript logic testing
├── 📁 cypress/                     # End-to-end tests
│   └── e2e/                        # User journey validation
└── 📁 static/                      # Static assets (CSS, images)
    ├── css/tweaks.css              # Custom styling
    └── img/profile.jpg             # Professional photo
```

**Key Directories:**

- **`layouts/`** - Hugo template customizations (where the magic happens)
- **`assets/`** - Source files processed by Hugo Pipes
- **`data/`** - JSON content files (easily editable)
- **`test/` + `cypress/`** - Comprehensive testing setup

---

<h2 id="key-features">✨ Key Features</h2>

|Feature|Description|Implementation|
|---|---|---|
|**🔄 Dynamic Visitor Counter**|Real-time tracking with serverless backend|API Gateway → Lambda → DynamoDB|
|**⚡ Advanced Build Pipeline**|Content-based fingerprinting for cache-busting|Hugo Pipes with automatic optimization|
|**🎯 Blue-Green Deployment**|Zero-downtime updates between environments|Environment-aware builds and routing|
|**🧪 Multi-Layer Testing**|Unit + E2E + API validation|Vitest + Cypress + Newman (36 assertions)|
|**📱 Professional Presentation**|SEO-optimized responsive design|Mobile-first with credential verification|

<details>

**Key Implementation Details:**

- **Environment-aware routing:** Automatically selects blue/green API endpoints
- **UX pattern:** 400ms minimum loading time for smooth animations
- **Error handling:** Graceful degradation with fallback states
- **Performance:** Handles Lambda cold starts (5+ second timeouts)

</details> <details> <summary><strong>⚡ Hugo Pipes Asset Pipeline</strong></summary>

**Automated optimization** from source to production-ready assets.

**Pipeline Features:**

- **Content-based fingerprinting:** Automatic cache invalidation
- **Template-driven JavaScript:** Build-time configuration injection
- **Zero-configuration optimization:** Production minification, development debugging
- **Performance impact:** ~70% size reduction, instant cache busting

</details>

---

<h2 id="quick-start">🚀 Quick Start</h2>

### Prerequisites

- **Node.js** 18+ and **Hugo Extended** 0.136.0+
- **Git** for version control

### Getting Started

```bash
# 1. Clone and install
git clone <repo-url>
cd frontend/hugo
npm install

# 2. Start development server
npm run serve

# 3. View site
open http://localhost:1580
```

<details> <summary><strong>📝 All Development Commands</strong></summary>

```bash
# Development
npm run serve                    # Development server (blue env)
HUGO_ENV=green npm run serve    # Green environment

# Testing
npm test                        # Unit tests (Vitest)
npm run test:watch             # TDD watch mode
npm run test:e2e:local         # Full E2E suite

# Building
npm run build                   # Production build (blue)
HUGO_ENV=green npm run build   # Green environment build

# Utilities
hugo version                    # Verify Hugo installation
hugo server -D                  # Include draft content
```

</details>

---

<h2 id="testing-strategy">🧪 Testing Strategy</h2>

**Multi-layer validation** ensuring reliability at every level.

|Layer|Framework|Focus|Coverage|
|---|---|---|---|
|**Unit Tests**|Vitest|JavaScript business logic|API calls, state management, DOM updates|
|**E2E Tests**|Cypress|User journeys|Page loads, counter functionality, responsive design|
|**API Tests**|Newman|Backend integration|36 assertions across endpoints|

<details> <summary><strong>🔬 Testing Implementation Details</strong></summary>

**Unit Testing (Vitest):**

```javascript
// Example: API response handling
test("handles successful API response", async () => {
  global.fetch = vi.fn().mockResolvedValue({
    ok: true,
    json: async () => ({ count: 42 })
  });

  const result = await makeRealApiCall();
  expect(result.count).toBe(42);
});
```

**E2E Testing (Cypress):**

```javascript
// Example: Counter increment validation
it("counter increments on page refresh", () => {
  cy.get("#visitor-count", { timeout: 20000 })
    .should("not.have.class", "count-loading")
    .invoke("text")
    .then((initialText) => {
      const initialCount = parseInt(initialText);
      cy.reload();
      // Verify increment...
    });
});
```

**Configuration:**

- Extended timeouts for serverless cold starts
- Environment-specific test URLs
- Artifact capture for failed tests

</details>

---

<h2 id="deployment-strategy">🌐 Deployment Strategy</h2>

**Blue-green zero-downtime deployments** with automated validation.

### Architecture

- **Two environments:** Blue (production) and Green (staging)
- **Content-based routing:** CloudFront origin paths (`/blue/` vs `/green/`)
- **Atomic switching:** Traffic changes without infrastructure recreation
- **Comprehensive validation:** Health checks before promotion

### Build Process

1. **Environment detection:** Automatic blue/green targeting
2. **Asset optimization:** Minification + fingerprinting via Hugo Pipes
3. **S3 deployment:** Optimized sync with cache headers
4. **CDN invalidation:** Global cache refresh
5. **Verification:** Automated smoke tests

<details> <summary><strong>🔧 Manual Deployment Commands</strong></summary>

```bash
# Production build
HUGO_ENV=blue hugo --minify --environment=blue

# Deploy to S3
aws s3 sync public/ s3://bucket/blue/ --delete \
  --cache-control "public, max-age=31536000"

# Invalidate CloudFront
aws cloudfront create-invalidation \
  --distribution-id DIST_ID --paths "/*"
```

**Cache Strategy:** Fingerprinted assets = 1 year, HTML = 1 hour

</details>

---

<h2 id="architecture-decisions">🏗️ Architecture Decisions</h2>

<details> <summary><strong>🤔 Key Design Choices</strong></summary>

**Hugo vs Next.js/Gatsby:**

- **Build speed:** <1 second vs 30+ seconds
- **Simplicity:** Single binary, no dependency management
- **Learning curve:** Template-based, not React complexity

**Theme Overrides vs Custom:**

- **Maintainability:** Easy to pull upstream updates
- **Clarity:** Only changed files visible in version control
- **Flexibility:** Mix theme components with custom logic

**Content Fingerprinting:**

- **Cache optimization:** Aggressive caching without manual invalidation
- **Atomic deploys:** Old versions remain accessible during rollouts
- **Performance:** ~70% size reduction with automatic optimization

</details>

---

<h2 id="performance-metrics">📊 Performance Metrics</h2>

|Metric|Value|Implementation|
|---|---|---|
|**Build Time**|<1 second|Hugo's Go-based compilation|
|**Lighthouse Score**|95+|Optimized assets, proper caching|
|**Bundle Size**|<500KB|Minification + tree shaking|
|**First Paint**|<1.5s|Preloaded critical resources|

---

_Professional resume site demonstrating enterprise cloud patterns at scale 🚀_
