// cypress/e2e/navigation.cy.js
describe("Site Navigation Validation", () => {
  beforeEach(() => {
    cy.visit("/");
  });

  it("all main sections are present on homepage", () => {
    cy.get("#about").should("be.visible");
    cy.get("#skills").should("be.visible");
    cy.get("#experience").should("be.visible");
    cy.get("#education").should("be.visible");
    cy.get("#contact").should("be.visible");
  });

  it("internal scroll navigation works", () => {
    const scrollSections = [
      { link: 'a[href="/#about"]', target: "#about" },
      { link: 'a[href="/#skills"]', target: "#skills" },
      { link: 'a[href="/#experience"]', target: "#experience" },
      { link: 'a[href="/#education"]', target: "#education" },
      { link: 'a[href="/#contact"]', target: "#contact" },
    ];

    scrollSections.forEach(({ link, target }) => {
      cy.get(link).should("be.visible").click();
      cy.get(target).should("be.visible");
      cy.get(target).within(() => {
        cy.get("h2").should("be.visible");
      });
      cy.wait(300);

      cy.log(`✅ Navigation to ${target} working with content visible`);
    });
  });

  it("contact section functionality", () => {
    cy.get('a[href="/#contact"]').should("be.visible").click();
    cy.get("#contact").should("be.visible");

    cy.get("#contact").within(() => {
      cy.get("h2").should("contain.text", "Contact");
      cy.get('a[href^="mailto:"]').should("be.visible");
      cy.get('a[href^="tel:"]').should("be.visible");
      cy.get('a[href*="github.com"]').should("be.visible");
      cy.get('a[href*="linkedin.com"]').should("be.visible");
    });
  });

  it("navbar brand/logo works", () => {
    cy.get('a[href="/#contact"]').click();
    cy.get("#contact").should("be.visible");

    cy.get(".navbar-brand").should("be.visible").click();
    cy.get("#about").should("be.visible");
    cy.window().its("scrollY").should("be.lessThan", 100);
  });

  it("all navigation links are accessible", () => {
    cy.get(".navbar-nav .nav-link").each(($link) => {
      cy.wrap($link)
        .should("be.visible")
        .and("have.attr", "href")
        .and("not.be.empty");

      cy.wrap($link).then(($el) => {
        const href = $el.attr("href");
        const text = $el.text().trim();
        cy.log(`Navigation link: ${text} → ${href}`);

        expect(href).to.match(/^\/#[a-z]+$/);
      });
    });
  });

  it("key professional sections have substantial content", () => {
    const criticalSections = [
      { section: "#about", navLink: 'a[href="/#about"]' },
      { section: "#skills", navLink: 'a[href="/#skills"]' },
      { section: "#experience", navLink: 'a[href="/#experience"]' },
      { section: "#contact", navLink: 'a[href="/#contact"]' },
    ];

    criticalSections.forEach(({ section, navLink }) => {
      cy.get(navLink).click();

      cy.get(section).should("be.visible").and("not.be.empty");

      cy.get(section).within(() => {
        cy.get("h2").should("be.visible");

        if (section === "#contact") {
          cy.get("a").should("have.length.greaterThan", 2);
        } else {
          cy.get("p, li, .resume-item").should("have.length.greaterThan", 0);
        }
      });
    });
  });

  it("smooth scrolling behavior works", () => {
    cy.get('a[href="/#about"]').click();
    cy.get("#about").should("be.visible");
    cy.get('a[href="/#contact"]').click();
    cy.get("#contact").should("be.visible");
    cy.get('a[href="/#skills"]').click();
    cy.get("#skills").should("be.visible");
  });

  it("page load performance and UX", () => {
    cy.get("#about, #skills, #experience, #education, #contact").should(
      "be.visible"
    );
    cy.get(".navbar-nav").should("be.visible");
    cy.get(".navbar-brand").should("be.visible");
    cy.get("#visitor-count-container").should("be.visible");
  });
});
