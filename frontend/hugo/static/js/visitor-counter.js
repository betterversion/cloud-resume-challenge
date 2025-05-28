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

  // Simulate API call (later this will be your actual Lambda API call)
  const apiCallPromise = simulateApiCall();

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

function simulateApiCall() {
  // Simulate variable API response times to test minimum loading behavior
  const randomDelay = Math.random() * 800; // 0-800ms random delay

  return new Promise((resolve) => {
    setTimeout(() => {
      console.log(
        `Simulated API call completed in ${Math.round(randomDelay)}ms`
      );
      resolve({ count: "01", timestamp: Date.now() });
    }, randomDelay);
  });
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
