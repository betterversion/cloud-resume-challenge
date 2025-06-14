// cypress/e2e/professional-links.cy.js
describe("Professional Links Validation", () => {
  beforeEach(() => {
    cy.visit("/");
  });

  it("has working GitHub profile link", () => {
    cy.get('a[href*="github.com/betterversion"]')
      .should("be.visible")
      .and("have.attr", "href", "https://github.com/betterversion")
      .and("have.attr", "rel", "me");
  });

  it("has working AWS certification link", () => {
    // Separate assertions
    cy.get('a[href*="credly.com"]')
      .should("be.visible")
      .should("have.attr", "rel", "me");

    // Test href attribute
    cy.get('a[href*="credly.com"]')
      .should("have.attr", "href")
      .should("include", "credly.com/badges");

    // Test image
    cy.get('a[href*="credly.com"] img')
      .should("be.visible")
      .should("have.attr", "width", "75");

    cy.get('a[href*="credly.com"] img')
      .should("have.attr", "src")
      .should("include", "credly.com");
  });

  it("has properly formatted email contact", () => {

    cy.get('a[href="mailto:dmitriy.z.tech@gmail.com"]')
      .should("be.visible")
      .and("have.attr", "href", "mailto:dmitriy.z.tech@gmail.com")
      .should("have.length.at.least", 1);

    cy.get('a[href="mailto:dmitriy.z.tech@gmail.com"]')
      .first()
      .should("contain.text", "dmitriy.z.tech@gmail.com");
  });

  it("has working phone contact", () => {
    cy.get('a[href="tel:+15036603010"]')
      .should("be.visible")
      .and("have.attr", "href", "tel:+15036603010")
      .should("contain.text", "503-660-3010");
  });

  it("LinkedIn links are configured", () => {
    // LinkedIn icon on about html page
    cy.get(
      'a[href="https://www.linkedin.com/in/dmitriy-zhernoviy"][data-original-title="LinkedIn"]'
    )
      .should("be.visible")
      .and("have.attr", "rel", "me");

    // Contact section LinkedIn
    cy.get('a[href*="linkedin.com/in/dmitriy-zhernoviy"]')
      .should("be.visible")
      .and("have.attr", "rel", "me");
  });

  it("contact section displays all methods", () => {
    cy.get("#contact").should("be.visible");
    cy.get("#contact h2").should("contain.text", "Contact");

    // All contact methods should be present in contact section
    cy.get("#contact").within(() => {
      cy.get('a[href^="mailto:"]').should("be.visible");
      cy.get('a[href^="tel:"]').should("be.visible");
      cy.get('a[href*="github.com"]').should("be.visible");
      cy.get('a[href*="linkedin.com"]').should("be.visible");
    });
  });

  it("professional links have security attributes", () => {
    const professionalLinks = [
      'a[href*="github.com/betterversion"]',
      'a[href*="credly.com"]',
    ];

    professionalLinks.forEach((selector) => {
      cy.get(selector).should("have.attr", "rel", "me");
    });
  });

  it("contact information is visible in header", () => {
    cy.get(".subheading")
      .should("be.visible")
      .and("contain.text", "Denver, CO");

    cy.get(".subheading").should("contain.text", "dmitriy.z.tech@gmail.com");
  });

  it("certification section displays properly", () => {
    cy.get("h3").contains("Certifications").should("be.visible");

    cy.get('img[src*="credly.com"]')
      .should("be.visible")
      .and("have.attr", "width", "75");
  });

  it("skills section external links are functional", () => {
    const skillsLinks = [
      "https://postman.com",
      "https://restsharp.dev",
      "https://aws.amazon.com",
      "https://docker.com",
      "https://k6.io",
    ];

    skillsLinks.forEach((url) => {
      cy.get(`a[href="${url}"]`)
        .should("be.visible")
        .and("have.attr", "href", url);
    });
  });
});
