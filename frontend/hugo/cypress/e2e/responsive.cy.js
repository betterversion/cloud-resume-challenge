describe("Responsive Design Validation", () => {
  beforeEach(() => {
    cy.visit("/");
    // Start each test with clean desktop state
    cy.viewport(1200, 800);
    cy.wait(200);
  });

  afterEach(() => {
    // Clean up after each test
    cy.viewport(1200, 800);
  });

  it("navigation menu is responsive", () => {
    // Switch to mobile
    cy.viewport(375, 667);
    cy.wait(300);

    // Test mobile navigation
    cy.get(".navbar-toggler").should("be.visible");
    cy.get("#navbarSupportedContent").should("not.be.visible");

    // Open menu and wait for Bootstrap animation
    cy.get(".navbar-toggler").click();
    cy.get("#navbarSupportedContent").should("be.visible");
    cy.wait(600); 

    // Navigate - element is now reliably findable
    cy.get('a[href="/#contact"]').should("be.visible").click();

    cy.get("#contact").should("be.visible");

    // Close menu
    cy.get(".navbar-toggler").click();
    cy.get("#navbarSupportedContent").should("not.be.visible");
  });

  it("desktop navigation is always visible", () => {
    // Test desktop state
    cy.get(".navbar-toggler").should("not.be.visible");
    cy.get("#navbarSupportedContent").should("be.visible");
    cy.get(".navbar-nav").should("be.visible");
  });

  it("viewport changes work correctly", () => {
    // Desktop → Mobile → Desktop
    cy.get(".navbar-toggler").should("not.be.visible");

    cy.viewport(375, 667);
    cy.wait(300);
    cy.get(".navbar-toggler").should("be.visible");

    cy.viewport(1200, 800);
    cy.wait(300);
    cy.get(".navbar-toggler").should("not.be.visible");
  });
});
