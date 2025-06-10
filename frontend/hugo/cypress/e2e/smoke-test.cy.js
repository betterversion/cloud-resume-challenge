// cypress/e2e/smoke-test.cy.js
describe("Resume Site - Smoke Test", () => {
  beforeEach(() => {
    // Visit homepage
    cy.visit("/");
  });

  it("loads the main page successfully", () => {
    // Check URL
    cy.url().should(
      "include",
      Cypress.config("baseUrl").replace("https://", "").replace("http://", "")
    );

    // Check heading
    cy.get("h1").should("be.visible");
    cy.get("h1").should("contain.text", "Dmitriy");

    // Check body
    cy.get("body").should("be.visible");
    cy.get("body").should("not.be.empty");
  });

  it("displays core resume sections", () => {
    // Check sections
    cy.get("#about").should("be.visible");
    cy.get("#skills").should("be.visible");
    cy.get("#experience").should("be.visible");
    cy.get("#education").should("be.visible");
  });

  it("has no critical JavaScript errors", () => {
    // Stub console
    cy.window().then((win) => {
      cy.stub(win.console, "error").as("consoleError");
    });

    // Reload page
    cy.reload();

    // Check for errors
    cy.get("@consoleError").should((stub) => {
      const calls = stub.getCalls();
      const criticalErrors = calls.filter((call) =>
        call.args.some(
          (arg) =>
            typeof arg === "string" &&
            (arg.includes("TypeError") ||
              arg.includes("ReferenceError") ||
              arg.includes("SyntaxError"))
        )
      );
      expect(criticalErrors).to.have.length(0);
    });
  });

  it("visitor counter element exists", () => {
    // Check counter container
    cy.get("#visitor-count-container").should("be.visible");

    // Check counter element
    cy.get("#visitor-count").should("exist");
    cy.get("#visitor-count").should("contain.text", "--");
  });
});
