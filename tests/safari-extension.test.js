"use strict";

const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const test = require("node:test");

const extensionDirectory = path.join(
  __dirname,
  "..",
  "configs",
  "safari",
  "extension",
);
const manifest = JSON.parse(
  fs.readFileSync(path.join(extensionDirectory, "manifest.json"), "utf8"),
);
const { hostForURL, organizeTabs } = require(
  path.join(extensionDirectory, "background.js"),
);

function createBrowser(initialTabs, focusedWindowId) {
  let tabs = initialTabs.map((tab) => ({ ...tab }));
  const windowIds = new Set(initialTabs.map((tab) => tab.windowId));
  let lastFocusedWindowId = focusedWindowId;
  const calls = [];

  function reindex(windowId) {
    tabs
      .filter((tab) => tab.windowId === windowId)
      .sort((first, second) => first.index - second.index)
      .forEach((tab, index) => {
        tab.index = index;
      });
  }

  const browserAPI = {
    calls,
    tabs: {
      async query(query = {}) {
        return tabs
          .filter((tab) => {
            if (query.active && !tab.active) return false;
            if (query.lastFocusedWindow && tab.windowId !== lastFocusedWindowId)
              return false;
            if (query.windowId !== undefined && tab.windowId !== query.windowId)
              return false;
            return true;
          })
          .sort(
            (first, second) =>
              first.windowId - second.windowId || first.index - second.index,
          )
          .map((tab) => ({ ...tab }));
      },
      async remove(tabIds) {
        const ids = new Set(Array.isArray(tabIds) ? tabIds : [tabIds]);
        calls.push({ type: "remove", ids: [...ids] });
        const affectedWindows = new Set(
          tabs.filter((tab) => ids.has(tab.id)).map((tab) => tab.windowId),
        );
        tabs = tabs.filter((tab) => !ids.has(tab.id));
        for (const windowId of affectedWindows) reindex(windowId);
      },
      async move(tabId, destination) {
        calls.push({ type: "move", tabId, destination: { ...destination } });
        const tab = tabs.find((candidate) => candidate.id === tabId);
        assert.ok(tab, `unknown tab ${tabId}`);
        const sourceWindowId = tab.windowId;
        tabs = tabs.filter((candidate) => candidate.id !== tabId);
        reindex(sourceWindowId);

        tab.windowId = destination.windowId;
        const destinationTabs = tabs
          .filter((candidate) => candidate.windowId === destination.windowId)
          .sort((first, second) => first.index - second.index);
        destinationTabs.splice(destination.index, 0, tab);
        destinationTabs.forEach((candidate, index) => {
          candidate.index = index;
        });
        tabs.push(tab);
      },
      async update(tabId, properties) {
        calls.push({ type: "update", tabId, properties: { ...properties } });
        const tab = tabs.find((candidate) => candidate.id === tabId);
        assert.ok(tab, `unknown tab ${tabId}`);
        if (properties.active) {
          for (const candidate of tabs) {
            if (candidate.windowId === tab.windowId) candidate.active = false;
          }
        }
        Object.assign(tab, properties);
      },
    },
    windows: {
      async getAll() {
        return [...windowIds].map((id) => ({ id }));
      },
      async remove(windowId) {
        calls.push({ type: "window-remove", windowId });
        assert.equal(
          tabs.some((tab) => tab.windowId === windowId),
          false,
        );
        windowIds.delete(windowId);
      },
      async update(windowId, properties) {
        calls.push({
          type: "window-update",
          windowId,
          properties: { ...properties },
        });
        if (properties.focused) lastFocusedWindowId = windowId;
      },
    },
  };

  return {
    api: browserAPI,
    getTabs: () => tabs.map((tab) => ({ ...tab })),
  };
}

test("manifest exposes a toolbar action and non-conflicting shortcut", () => {
  assert.equal(manifest.manifest_version, 2);
  assert.equal(manifest.browser_action.default_popup, "popup.html");
  assert.equal(
    manifest.commands["organize-tabs"].suggested_key.mac,
    "Command+Shift+Y",
  );
  assert.ok(manifest.permissions.includes("tabs"));
});

test("host parsing accepts web URLs and returns the exact normalized hostname", () => {
  assert.equal(hostForURL("HTTPS://Gitea.AI:8443/user"), "gitea.ai");
  assert.equal(hostForURL("https://code.gitea.ai/user"), "code.gitea.ai");
  assert.equal(hostForURL("safari-web-extension://example"), "");
  assert.equal(hostForURL(undefined), "");
});

test("closes same-host tabs, gathers remaining regular tabs, sorts by URL, and keeps focus", async () => {
  const fixture = createBrowser(
    [
      {
        id: 1,
        windowId: 1,
        index: 0,
        url: "https://Gitea.ai/current",
        active: true,
      },
      {
        id: 2,
        windowId: 1,
        index: 1,
        url: "https://z.example/path",
        active: false,
      },
      {
        id: 3,
        windowId: 2,
        index: 0,
        url: "https://gitea.ai/other",
        active: true,
      },
      {
        id: 4,
        windowId: 2,
        index: 1,
        url: "https://a.example/path",
        active: false,
      },
      {
        id: 5,
        windowId: 3,
        index: 0,
        url: "https://sub.gitea.ai/path",
        active: true,
      },
      {
        id: 6,
        windowId: 4,
        index: 0,
        url: "https://private.example/path",
        active: true,
        incognito: true,
      },
    ],
    1,
  );

  const result = await organizeTabs(fixture.api);
  const tabs = fixture.getTabs();
  const regularTabs = tabs
    .filter((tab) => !tab.incognito)
    .sort((first, second) => first.index - second.index);

  assert.deepEqual(result, { closedCount: 1, movedCount: 2, sortedCount: 4 });
  assert.deepEqual(
    regularTabs.map((tab) => tab.id),
    [4, 1, 5, 2],
  );
  assert.ok(regularTabs.every((tab) => tab.windowId === 1));
  assert.equal(regularTabs.find((tab) => tab.id === 1).active, true);
  assert.equal(tabs.find((tab) => tab.id === 6).windowId, 4);
  assert.ok(
    fixture.api.calls.find((call) => call.type === "remove").ids.includes(3),
  );
  assert.deepEqual(
    fixture.api.calls
      .filter((call) => call.type === "window-remove")
      .map((call) => call.windowId),
    [2, 3],
  );
});

test("sorts pinned and unpinned tabs by URL without changing their pinned status", async () => {
  const fixture = createBrowser(
    [
      {
        id: 1,
        windowId: 1,
        index: 0,
        url: "https://z.example/",
        active: false,
        pinned: true,
      },
      { id: 2, windowId: 1, index: 1, url: "https://b.example/", active: true },
      {
        id: 3,
        windowId: 1,
        index: 2,
        url: "https://a.example/",
        active: false,
        pinned: true,
      },
      {
        id: 4,
        windowId: 1,
        index: 3,
        url: "https://a.example/",
        active: false,
      },
    ],
    1,
  );

  await organizeTabs(fixture.api);
  const tabs = fixture
    .getTabs()
    .sort((first, second) => first.index - second.index);

  assert.deepEqual(
    tabs.map((tab) => tab.id),
    [3, 1, 4, 2],
  );
  assert.deepEqual(
    tabs.map((tab) => Boolean(tab.pinned)),
    [true, true, false, false],
  );
  assert.equal(tabs.find((tab) => tab.id === 2).active, true);
});

test("rejects a non-web active tab before closing or moving anything", async () => {
  const fixture = createBrowser(
    [
      { id: 1, windowId: 1, index: 0, url: "about:blank", active: true },
      {
        id: 2,
        windowId: 2,
        index: 0,
        url: "https://example.com/",
        active: true,
      },
    ],
    1,
  );

  await assert.rejects(organizeTabs(fixture.api), /HTTP or HTTPS/);
  assert.deepEqual(fixture.api.calls, []);
});
