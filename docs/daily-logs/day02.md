# 🎨 Day 2: Hugo and the Content Architecture Challenge - Moving Beyond HTML

## 🎯 From Infrastructure to Interface

With my enterprise AWS foundation locked in on Day 1, I faced my next decision point. I needed to build the actual resume website, and I had a choice that would define the entire project's technical credibility.

Option 1: Write plain HTML and CSS like most tutorials suggest. Quick, simple, gets the job done.

Option 2: Use a modern static site generator and treat this like a real development project.

I chose Hugo, and that choice completely changed how the rest of the project unfolded.

---

## 🤷 Why Not Just Write HTML?

Look, I could have written a basic HTML resume in an hour. Three files, some CSS, done. But that would have been a missed opportunity to demonstrate understanding of modern web development workflows.

Real development teams don't hand-write HTML anymore. They use build tools, content management systems, and structured data approaches. If I was going to convince hiring managers I understand professional development practices, I needed to show familiarity with the tools that actual teams use.

Hugo also solved a practical problem I knew was coming: content management. My resume content would need updates, and I wanted a system that separated content from presentation. When I eventually add the visitor counter API integration, I'd need a build system that could handle JavaScript processing and environment variables.

---

## 🏗️ Phase 1: Project Structure That Makes Sense

Instead of dumping everything in my project root, I created a dedicated workspace:

```bash
mkdir frontend/hugo
cd frontend/hugo
hugo new site . --force
```

The `--force` flag was necessary because I was initializing Hugo inside an existing Git repository. This gave me a clean separation between my AWS infrastructure code and my frontend application.

For the theme, I went with `hugo-resume` because it's specifically designed for professional resumes. But instead of just downloading it, I added it as a Git submodule:

```bash
git submodule add https://github.com/eddiewebb/hugo-resume.git themes/hugo-resume
```

Submodules are how professional teams manage external dependencies. It keeps my customizations separate from the upstream theme while allowing me to pull theme updates if needed. It's the kind of detail that shows you understand real-world development workflows.

---

## 📝 Phase 2: Data-Driven Content Architecture

This is where Hugo really shines compared to static HTML. Instead of hardcoding my resume content into templates, I created structured data files:

```
data/
├── skills.json
├── experience.json
├── education.json
└── certifications.json
```

Each file follows a clean JSON structure. For example, my skills file organizes everything into logical categories:

```json
{
  "skills": [
    {
      "grouping": "Cloud & Infrastructure",
      "skills": [
        {"name": "AWS Solutions Architecture", "icon": "amazonwebservices"},
        {"name": "Terraform", "icon": "terraform"},
        {"name": "Docker", "icon": "docker"}
      ]
    }
  ]
}
```

This approach has serious advantages. Content updates don't require touching template code. Adding new skills means editing JSON, not hunting through HTML. When I eventually add the visitor counter feature, the content structure won't be affected.

More importantly, this demonstrates understanding of content-as-code principles that are fundamental to modern development workflows.

---

## 🔧 Phase 3: Configuration for Professional Presentation

The `hugo.toml` configuration file became my control center for professional presentation:

```toml
baseURL = "https://dzresume.dev/"
title = "Dmitriy Zhernoviy - Cloud Engineer"
theme = "hugo-resume"

[params]
firstName = "Dmitriy"
lastName = "Zhernoviy"
address = "Denver, CO"
email = "dmitriy.z.tech@gmail.com"
```

Notice the baseURL already points to my custom domain. I hadn't set up the domain yet, but I was thinking ahead to the AWS hosting phase. This kind of forward planning prevents the configuration headaches that trip up amateur implementations.

I linked my AWS certification directly from Credly, which provides automatic verification. Hiring managers can click through and confirm my credentials are legitimate. It's the kind of credibility detail that distinguishes professional portfolios from academic projects.

---

## 🧪 Phase 4: Local Development Workflow

Getting the local development environment working smoothly was crucial. Hugo's development server with live reload meant I could see changes instantly:

```bash
hugo server -D
```

The `-D` flag includes draft content, which I'd need later for testing. The development server runs on `localhost:1313` by default.

I tested everything systematically:
- Profile image loading
- Skills categorization and icons
- Experience timeline formatting
- Responsive design across viewport sizes
- Navigation and anchor links

This kind of systematic testing shows attention to quality and user experience. It's the difference between "it works on my machine" and "it works reliably for users."

---

## 🎯 Why This Architecture Matters

By the end of Day 2, I had something that looked like a simple resume website. But underneath, I'd built a foundation that would support everything coming next.

The Hugo build system would handle JavaScript processing for the visitor counter. The data-driven content structure would scale to more complex resume sections. The theme architecture would support custom styling without breaking upstream updates.

Most importantly, I could now discuss modern frontend development practices in technical interviews. Content management, build tools, responsive design, structured data - all topics that come up when cloud engineers need to work with development teams.

The choice to use Hugo over plain HTML demonstrated understanding that even "simple" projects benefit from professional development practices. That mindset - treating every project like it might need to scale - is exactly what distinguishes engineers who can handle enterprise complexity from those who only know tutorial-level implementations.

When I eventually deploy this to AWS S3 with CloudFront, the Hugo build process will integrate seamlessly with my deployment automation. That integration started with the architectural decisions I made on Day 2.
