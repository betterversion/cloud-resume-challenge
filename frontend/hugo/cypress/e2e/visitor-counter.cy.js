// cypress/e2e/visitor-counter.cy.js
describe("Visitor Counter Integration", () => {
  beforeEach(() => {
    cy.visit("/");
  });

  it("displays visitor counter element", () => {
    // Counter element exists and is visible
    cy.get("#visitor-count-container").should("be.visible");
    cy.get("#visitor-count").should("exist");

    // Should start with loading state
    cy.get("#visitor-count").should("have.class", "count-loading");
    cy.get("#visitor-count").should("contain.text", "--");
  });

  it("loads actual visitor count from API", () => {
    cy.get("#visitor-count", { timeout: 20000 }).should(
      "not.have.class",
      "count-loading"
    );

    cy.get("#visitor-count")
      .should("not.contain.text", "--")
      .invoke("text")
      .then((text) => {
        const count = parseInt(text.replace(/,/g, ""), 10);
        expect(count).to.be.a("number");
        expect(count).to.be.at.least(1);
        cy.log(`✅ Visitor count: ${count}`);
      });
  });

  it("counter increments on page refresh", () => {
    if (Cypress.config("baseUrl").includes("localhost")) {
      cy.log("⏭️ Skipping increment test in local mode");
      return;
    }

    // Get initial count
    cy.get("#visitor-count", { timeout: 20000 })
      .should("not.have.class", "count-loading")
      .invoke("text")
      .then((initialText) => {
        const initialCount = parseInt(initialText.replace(/,/g, ""), 10);
        cy.log(`📊 Initial count: ${initialCount}`);

        // Refresh page to trigger new API call
        cy.reload();

        // Wait for new count and verify it increased
        cy.get("#visitor-count", { timeout: 20000 })
          .should("not.have.class", "count-loading")
          .invoke("text")
          .then((newText) => {
            const newCount = parseInt(newText.replace(/,/g, ""), 10);
            cy.log(`📊 New count: ${newCount}`);
            expect(newCount).to.be.at.least(initialCount + 1);
          });
      });
  });

  it("handles API errors gracefully", () => {
    cy.intercept("GET", "**/counter", {
      statusCode: 500,
      body: { error: "Server error" },
    }).as("apiFailure");

    // Visit a NEW page (not reload) to trigger fresh API call
    cy.visit("/", { failOnStatusCode: false });

    // Wait for the failed API call
    cy.wait("@apiFailure");

    // Verify site still works despite API failure
    cy.get("h1").should("contain.text", "Dmitriy");
    cy.log("✅ Site functional despite API failure");
  });
});
