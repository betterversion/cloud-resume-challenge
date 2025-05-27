# 🎨 Day 2: Hugo Static Resume – Professional Frontend Architecture

## 🎯 Objective

Build a clean, modular frontend for the Cloud Resume Challenge using **Hugo**, a static site generator. Integrate professional resume content using a structured, data-driven architecture with the `hugo-resume` theme and local testing.

---

## 🛠️ Phase 1: Hugo Project Initialization

* Created `frontend/hugo` directory as an isolated workspace
* Ran `hugo new site . --force` to initialize Hugo site inside subdirectory
* Added `hugo-resume` as a Git submodule:

  ```bash
  git submodule add https://github.com/eddiewebb/hugo-resume.git themes/hugo-resume
  ```

* Created `hugo.toml` as the new standard config format in Hugo
* Populated base config with:
  - Personal info (name, email, phone, location)
  - Professional description and branding
  - LinkedIn + GitHub links
  - Theme reference: `theme = "hugo-resume"`
* Launched local dev server:

  ```bash
  hugo server -D
  ```

---

## 🧱 Phase 2: Resume Content Architecture

* Created structured resume data files under `data/`:
  - `skills.json`
  - `experience.json`
  - `education.json`
  - `certifications.json` (linked to live Credly badge)
* Each file uses key-value JSON structure for modularity
* Added `content/_index.md` with About Me content and project elevator pitch

---

## 🧪 Phase 3: Local Testing & QA

* Verified site renders properly at `localhost:1313`
* Confirmed:
  - Profile image and avatar load successfully
  - Skills display in categorized sections
  - Experience and education show correct formatting
  - AWS certification badge shows with link
* Responsive layout verified in desktop and mobile views
* Sidebar and header links all functional

---

## 🚧 Phase Skipped: Contact Page Enhancements

> Contact page QR code and `.vcf` setup deferred for later phase.
> Current contact fields exist in `params` but not fully tested yet.

---

## 🧠 Lessons & Takeaways

* Hugo reflects real-world practices: config files, templating, modular data
* Using submodules for themes maintains separation of concerns
* JSON-based resume structuring scales better than hardcoded content
* Clean local preview and testing lays the foundation for AWS hosting
