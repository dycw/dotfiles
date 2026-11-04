"use strict";

const button = document.getElementById("organize");
const status = document.getElementById("status");

button.addEventListener("click", async () => {
  button.disabled = true;
  status.textContent = "Organizing tabs…";

  try {
    const response = await browser.runtime.sendMessage({
      type: "organize-safari-tabs",
    });
    if (response.error) throw new Error(response.error);

    const result = response.result;
    status.textContent =
      `Closed ${result.closedCount} matching tab(s), moved ${result.movedCount}, ` +
      `and sorted ${result.sortedCount} tab(s).`;
  } catch (error) {
    status.textContent = error.message || "Could not organize Safari tabs.";
  } finally {
    button.disabled = false;
  }
});
