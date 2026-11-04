"use strict";

const ORGANIZE_MESSAGE = "organize-safari-tabs";
const ORGANIZE_COMMAND = "organize-tabs";

function hostForURL(url) {
  if (typeof url !== "string") return "";

  try {
    const parsedURL = new URL(url);
    if (parsedURL.protocol !== "http:" && parsedURL.protocol !== "https:") {
      return "";
    }
    return parsedURL.hostname.toLowerCase();
  } catch {
    return "";
  }
}

function sameBrowsingContext(tab, activeTab) {
  return Boolean(tab.incognito) === Boolean(activeTab.incognito);
}

function compareTabsByURL(firstTab, secondTab) {
  const firstURL = typeof firstTab.url === "string" ? firstTab.url : "";
  const secondURL = typeof secondTab.url === "string" ? secondTab.url : "";
  const firstFoldedURL = firstURL.toLowerCase();
  const secondFoldedURL = secondURL.toLowerCase();

  if (firstFoldedURL < secondFoldedURL) return -1;
  if (firstFoldedURL > secondFoldedURL) return 1;
  if (firstURL < secondURL) return -1;
  if (firstURL > secondURL) return 1;
  return (firstTab.id || 0) - (secondTab.id || 0);
}

function compareTabs(firstTab, secondTab) {
  const pinnedOrder =
    Number(Boolean(secondTab.pinned)) - Number(Boolean(firstTab.pinned));
  return pinnedOrder || compareTabsByURL(firstTab, secondTab);
}

async function organizeTabs(browserAPI) {
  const activeTabs = await browserAPI.tabs.query({
    active: true,
    lastFocusedWindow: true,
  });
  const activeTab = activeTabs[0];

  if (
    !activeTab ||
    !Number.isInteger(activeTab.id) ||
    !Number.isInteger(activeTab.windowId)
  ) {
    throw new Error("Could not find the active Safari tab.");
  }

  const activeHost = hostForURL(activeTab.url);
  if (!activeHost) {
    throw new Error("The active tab must have an HTTP or HTTPS address.");
  }

  const initialTabs = await browserAPI.tabs.query({});
  const matchingTabIds = initialTabs
    .filter((tab) => {
      return (
        tab.id !== activeTab.id &&
        sameBrowsingContext(tab, activeTab) &&
        hostForURL(tab.url) === activeHost
      );
    })
    .map((tab) => tab.id);

  if (matchingTabIds.length > 0) {
    await browserAPI.tabs.remove(matchingTabIds);
  }

  const remainingTabs = (await browserAPI.tabs.query({}))
    .filter((tab) => sameBrowsingContext(tab, activeTab))
    .sort(compareTabs);

  if (!remainingTabs.some((tab) => tab.id === activeTab.id)) {
    throw new Error(
      "The active tab disappeared during cleanup; no tabs were moved.",
    );
  }

  const movedTabs = remainingTabs.filter(
    (tab) => tab.windowId !== activeTab.windowId,
  );
  const sourceWindowIds = [...new Set(movedTabs.map((tab) => tab.windowId))];

  for (let index = 0; index < remainingTabs.length; index += 1) {
    const tab = remainingTabs[index];
    await browserAPI.tabs.move(tab.id, {
      windowId: activeTab.windowId,
      index,
    });
  }

  if (browserAPI.windows.getAll && browserAPI.windows.remove) {
    const openWindowIds = new Set(
      (await browserAPI.windows.getAll()).map((window) => window.id),
    );
    for (const windowId of sourceWindowIds) {
      if (!openWindowIds.has(windowId)) continue;
      const tabsInWindow = await browserAPI.tabs.query({ windowId });
      if (tabsInWindow.length === 0) await browserAPI.windows.remove(windowId);
    }
  }

  await browserAPI.tabs.update(activeTab.id, { active: true });
  await browserAPI.windows.update(activeTab.windowId, { focused: true });

  return {
    closedCount: matchingTabIds.length,
    movedCount: movedTabs.length,
    sortedCount: remainingTabs.length,
  };
}

function attachListeners(browserAPI) {
  let currentOperation = null;

  function runOnce() {
    if (currentOperation) return currentOperation;
    currentOperation = organizeTabs(browserAPI).finally(() => {
      currentOperation = null;
    });
    return currentOperation;
  }

  browserAPI.runtime.onMessage.addListener((message, sender, sendResponse) => {
    if (!message || message.type !== ORGANIZE_MESSAGE) return false;

    runOnce().then(
      (result) => sendResponse({ result }),
      (error) =>
        sendResponse({
          error: error.message || "Could not organize Safari tabs.",
        }),
    );
    return true;
  });

  if (browserAPI.commands && browserAPI.commands.onCommand) {
    browserAPI.commands.onCommand.addListener((command) => {
      if (command === ORGANIZE_COMMAND) {
        runOnce().catch((error) => console.error(error));
      }
    });
  }
}

if (typeof browser !== "undefined") attachListeners(browser);

if (typeof module !== "undefined" && module.exports) {
  module.exports = {
    compareTabs,
    hostForURL,
    organizeTabs,
    sameBrowsingContext,
  };
}
