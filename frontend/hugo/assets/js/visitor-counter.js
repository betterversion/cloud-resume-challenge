// Define environment once at the top level
const ENVIRONMENT = '{{ getenv "HUGO_ENV" | default "blue" }}';
const API_URLS = {
  blue: "{{ .Site.Params.api_url_blue }}",
  green: "{{ .Site.Params.api_url_green }}",
};

// Professional visitor counter with minimum loading time implementation
document.addEventListener("DOMContentLoaded", function () {
  // Brief delay to ensure DOM readiness, then initialize counter
  setTimeout(() => {
    initializeVisitorCounter();
  }, 100);
});

function initializeVisitorCounter() {
  const counterElement = document.getElementById("visitor-count");

  if (!counterElement) {
    console.log("Visitor counter element not found");
    return;
  }

  // Set loading state immediately when user sees the page
  setLoadingState(counterElement);

  // Implement minimum loading time pattern used in professional applications
  executeCounterUpdate(counterElement);
}

async function executeCounterUpdate(element) {
  // Define minimum loading time for consistent user experience
  const minimumLoadingTime = 400; // 400ms feels natural and intentional

  // Record when we started the loading process
  const loadingStartTime = Date.now();

  const apiCallPromise = makeRealApiCall();

  // Create minimum timer promise
  const minimumTimerPromise = new Promise((resolve) => {
    setTimeout(resolve, minimumLoadingTime);
  });

  try {
    // Wait for both the API call AND the minimum time to complete
    // This ensures users always see loading state for at least 400ms
    const [apiResult] = await Promise.all([
      apiCallPromise,
      minimumTimerPromise,
    ]);

    // Calculate how long the entire process actually took
    const totalTime = Date.now() - loadingStartTime;
    console.log(
      `Loading completed in ${totalTime}ms (minimum: ${minimumLoadingTime}ms)`
    );

    // Update counter with successful result
    updateCounterValue(element, apiResult.count);
  } catch (error) {
    // Even error handling respects minimum loading time
    const totalTime = Date.now() - loadingStartTime;
    if (totalTime < minimumLoadingTime) {
      // Wait for remaining time before showing error
      await new Promise((resolve) =>
        setTimeout(resolve, minimumLoadingTime - totalTime)
      );
    }

    handleCounterError(element);
  }
}

async function makeRealApiCall() {
  const API_URL = `${API_URLS[ENVIRONMENT]}/counter`;

  try {
    console.log(`Making API call to ${ENVIRONMENT} environment:`, API_URL);

    const response = await fetch(API_URL, {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
      },
    });

    console.log("API Response status:", response.status);

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const data = await response.json();
    console.log("API Response data:", data);

    // Handle different response formats from your Lambda
    const count = data.count || data.visit_count || data.visitor_count;

    return {
      count: count,
      timestamp: Date.now(),
    };
  } catch (error) {
    console.error("Real API call failed:", error);
    throw error; // Re-throw to be handled by executeCounterUpdate
  }
}

function setLoadingState(element) {
  element.className = "count-loading";
  element.textContent = "--";
  console.log(
    "Loading state activated - minimum display time will be enforced"
  );
}

function updateCounterValue(element, newValue) {
  console.log("Transitioning to loaded state with value:", newValue);
  element.className = "count-loaded";
  element.textContent = newValue;
}

function handleCounterError(element) {
  console.log("Handling API error with consistent timing");
  element.className = "count-error";
  element.textContent = "--";
}
