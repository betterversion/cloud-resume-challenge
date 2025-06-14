# 🏛️ Day 1: From SAA-C03 Theory to Real AWS Architecture - Building Like the Pros

## 🎯 The Reality Check

After passing my AWS Solutions Architect Associate certification, I thought I understood AWS pretty well. I could answer questions about multi-account strategies, identity management, and cost optimization. But when I sat down to actually start building my Cloud Resume Challenge project, I faced a moment of truth: **Do I build this like a tutorial, or do I build it like a real enterprise would?**

Most people starting the Cloud Resume Challenge create a single AWS account, maybe set up an IAM user with programmatic access, and start clicking through the console. That's the quick path, the tutorial path. But I realized this was my chance to demonstrate that I actually understand professional cloud architecture, not just exam concepts.

---

## 🤔 Why Professional Architecture Matters

Here's the thing about the Cloud Resume Challenge - it's not really about building a resume website. It's about proving to hiring managers that you can think like a cloud engineer. And real cloud engineers never start with single-account architectures and long-lived access keys.

I'd studied multi-account strategies for the SAA-C03, but implementing one yourself is completely different. You have to make actual decisions about organizational structure, permission boundaries, and operational workflows. This was my opportunity to show I could take exam theory and turn it into production reality.

If I was going to do this project, I wanted to be able to walk into any technical interview and confidently discuss enterprise AWS architecture patterns because I'd actually implemented them, not just memorized them.

---

## 🏗️ Phase 1: The Organizations Foundation Decision

The first major decision was organizational structure. I could have just used my existing personal AWS account, but that felt amateur. Real enterprises use AWS Organizations for a reason.

I set up a root account purely for governance - no workloads, just organizational management. Then I designed the OU structure:

```
Root Organization
├── Security OU (future audit/compliance accounts)
├── Workloads OU
│   ├── Development OU
│   └── Production OU
└── Shared Services OU (future logging/monitoring)
```

The beauty of this approach is that it's already thinking about scale. Sure, I'm just building a resume site now, but this structure could handle a full enterprise workload. That's the kind of forward-thinking that impresses hiring managers.

I enabled Organizations in "All Features" mode because I knew I'd want Service Control Policies later. Small decision, but it shows understanding of where AWS governance is heading.

---

## 👥 Phase 2: The Gmail Plus-Addressing Hack

Creating multiple AWS accounts sounds expensive and complicated, but here's a neat trick I learned: Gmail plus-addressing. Instead of creating separate email accounts, I used:

- `dmitriy.z.tech+crc-dev@gmail.com`
- `dmitriy.z.tech+crc-prod@gmail.com`

Both emails route to my main inbox, but AWS sees them as different addresses. This let me create separate accounts without managing multiple email inboxes. It's the kind of practical solution that shows you understand how to work efficiently with AWS's requirements.

I placed each account in the appropriate OU within my organization. The Development account went into the Development OU, Production into Production OU. Simple, but it establishes proper boundaries from day one.

---

## 🔐 Phase 3: Identity Management - Choosing the Professional Path

This is where I made the biggest decision that separated my project from typical tutorials. Instead of creating IAM users with access keys, I went straight to AWS Single Sign-On (now called IAM Identity Center).

Why? Because no enterprise uses long-lived access keys anymore. They're a security nightmare - they don't rotate, they're easy to leak, and they're impossible to audit properly. Real cloud teams use federated identity with temporary credentials.

Setting up SSO was honestly a bit intimidating at first. The interface is more complex than just creating an IAM user. But once I got it working, I had something powerful:

- MFA enforced for all access
- Temporary credentials that expire automatically
- Clean audit trails of who accessed what when
- Role-based access that scales to teams

I created three permission sets that mirror real-world roles:

**DevFullAccess** - For learning and experimentation in the dev account. I needed freedom to break things and try stuff out.

**ProdDeployAccess** - Scoped permissions for controlled production changes. This simulates how deployment pipelines get access to production.

**ProdReadOnlyAccess** - For monitoring and observability. Sometimes you just need to look around without changing anything.

The assignment matrix was straightforward: DevFullAccess to the dev account, both ProdDeployAccess and ProdReadOnlyAccess to the prod account.

---

## 💰 Phase 4: Cost Control That Actually Works

One thing they don't prepare you for in certification study is how quickly AWS costs can spiral out of control when you're learning. I needed proper financial governance, not just hoping I'd remember to check my bill.

I set up a layered approach to cost monitoring:

**Organization Level**: $20 warning, $50 critical alert. This catches any major problems across all accounts.

**Account Level**: $10 for dev (where I'm experimenting), $5 for prod (which should be very predictable).

**Service Level**: Specific budgets for EC2, Lambda, API Gateway - the services I knew I'd be using.

The key insight here is that good cost governance isn't just about alerts - it's about understanding your spending patterns and making sure they align with your usage patterns.

I also implemented cost allocation tags from the beginning:
- `Project`: CloudResumeChallenge
- `Environment`: Development/Production
- `Owner`: Dmitriy Zhernoviy

This seems like overkill for a personal project, but it demonstrates understanding of how real organizations track cloud spending.

---

## 🛡️ Phase 5: Security Hardening and Smart Guardrails

With the foundation in place, I focused on security hardening. But here's where I got clever - instead of just implementing security controls, I used Service Control Policies to create learning guardrails.

I implemented SCPs that would prevent me from making expensive mistakes while learning:

**Dev Account Restrictions**:
- No RDS instances (too expensive for learning)
- Only free-tier eligible EC2 instances (t2.micro, t3.micro)

**Production Account**: More permissive, but still cost-conscious

The genius of this approach is that I could experiment freely in dev without worrying about accidentally spinning up a massive RDS cluster and getting a surprise bill. The guardrails let me learn confidently.

Testing the SCPs was actually fun. I tried launching a t3.large instance and got denied. I tried creating an RDS database in dev and got blocked. The policies were working exactly as designed.

---

## 💻 Phase 6: Local Development That Actually Works

The final piece was setting up my local development environment to work with this professional authentication setup. This is where the AWS CLI SSO integration really shines.

I configured two SSO profiles:
- `crc-dev` for Development account access
- `crc-prod` for Production account access

Both profiles share the same SSO session, so I authenticate once and can switch between accounts seamlessly:

```bash
aws sso login --profile crc-dev
aws sts get-caller-identity --profile crc-dev
# Shows dev account details

aws sts get-caller-identity --profile crc-prod
# Automatically works - shared SSO session
```

This workflow is identical to what I'd use in a real enterprise environment. No stored credentials, automatic session expiration, clean audit trails.

I also set up my development tools: Hugo for static site generation, AWS CLI v2, Python with virtual environments, Node.js for any frontend tooling I'd need later.

---

## 🚀 Why This Foundation Matters

By the end of Day 1, I hadn't built anything user-facing yet. No website, no fancy features. But I had something more valuable: a professional-grade AWS foundation that I could confidently discuss in any technical interview.

The multi-account structure, SSO integration, cost governance, and security guardrails aren't just resume padding. They're the foundation that real cloud engineers build on. When I eventually implement CI/CD pipelines, they'll integrate cleanly with my SSO roles. When I add monitoring and logging, they'll fit naturally into my organizational structure.

Most importantly, I could now honestly say I'd implemented enterprise AWS architecture patterns, not just studied them. That's the kind of hands-on experience that moves you from "passed the certification" to "ready for the job."

The authentication setup alone gave me talking points about federated identity, temporary credentials, least-privilege access, and cost governance - all topics that come up constantly in cloud engineering interviews.

Starting with this foundation meant every subsequent day would build on professional patterns rather than tutorial shortcuts. That decision on Day 1 shaped the entire project's trajectory.
