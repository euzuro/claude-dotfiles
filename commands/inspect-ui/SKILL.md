---
name: inspect-ui
description: |
  Use this skill when the user says things like:
  - "inspect the UI"
  - "open the browser and check"
  - "take a screenshot"
  - "debug the CSS"
  - "check the layout"
  - "measure element heights"
  - "inspect the page"
  Opens a URL in Chrome via DevTools MCP, takes screenshots, and inspects DOM elements
  to debug layout, CSS, and rendering issues.
---

## Input

The user provided: $ARGUMENTS

## Overview

Use the Chrome DevTools MCP tools to navigate to a page, take screenshots, inspect DOM elements, and measure computed styles. This is useful for debugging CSS/layout issues, verifying UI changes, and comparing before/after states.

## Available Tools

You have access to these Chrome DevTools MCP tools:

- `mcp__chrome-devtools__navigate_page` — Navigate to a URL or reload
- `mcp__chrome-devtools__take_screenshot` — Capture a screenshot of the viewport or a specific element
- `mcp__chrome-devtools__take_snapshot` — Get an accessibility/text snapshot (useful for finding element UIDs)
- `mcp__chrome-devtools__evaluate_script` — Run JavaScript on the page (measure heights, inspect styles, click elements)
- `mcp__chrome-devtools__click` — Click an element by UID
- `mcp__chrome-devtools__list_pages` — List open browser tabs
- `mcp__chrome-devtools__select_page` — Switch between tabs
- `mcp__chrome-devtools__new_page` — Open a new tab

## Step 1: Authentication Check (Datadog Sites)

If the target URL is a Datadog site (`datad0g.com`, `datadoghq.com`, or `dd-dev-local`), **always proactively ask the user to log in first** before navigating. Use `AskUserQuestion` to ask:

> "Are you logged in to [site] in the Chrome instance connected to DevTools MCP? I need you to be logged in before I can inspect the page."

Options: "Yes, I\u2019m logged in" / "Let me log in first"

Only proceed to navigation after the user confirms they are logged in. This avoids wasted time on login redirects.

## Step 2: Navigate to the Page

If a URL is provided in the arguments, navigate to it:

```
mcp__chrome-devtools__navigate_page(type: "url", url: "<URL>")
```

If no URL is provided, ask the user for the URL. The local dev server is typically at `https://dd-dev-local.datad0g.com/`.

If the page redirects to a login page despite the auth check, tell the user and wait for them to log in.

## Step 2: Take a Screenshot

Always start by taking a screenshot to see the current state:

```
mcp__chrome-devtools__take_screenshot()
```

## Step 3: Find Elements

To interact with elements, you need their UIDs. Two approaches:

### Option A: Accessibility Snapshot (for finding clickable elements)

The snapshot can be very large. Save it to a file and search with grep:

```
mcp__chrome-devtools__take_snapshot(filePath: "/tmp/page-snapshot.txt")
```

Then grep for the element you need. **Important:** The snapshot output is a JSON array — use grep on the saved file, not JSON parsing.

### Option B: JavaScript Query (faster for known selectors)

Use `evaluate_script` to find elements by CSS selector:

```
mcp__chrome-devtools__evaluate_script(function: "() => {
  const el = document.querySelector('.my-class');
  return el ? { found: true, text: el.textContent } : 'NOT FOUND';
}")
```

## Step 4: Debug Layout/CSS Issues

Use `evaluate_script` to measure element dimensions and computed styles:

```javascript
() => {
  const el = document.querySelector('.my-element');
  if (!el) return 'NOT FOUND';
  const style = getComputedStyle(el);
  return {
    offsetHeight: el.offsetHeight,
    scrollHeight: el.scrollHeight,
    clientHeight: el.clientHeight,
    maxHeight: style.maxHeight,
    overflow: style.overflow,
    position: style.position,
    height: style.height,
    classList: Array.from(el.classList),
  };
}
```

### Checking if a CSS selector matches

If a CSS override isn't working, verify the element exists:

```javascript
() => {
  const el = document.querySelector('.parent-class .child-class');
  return el ? 'FOUND' : 'NOT FOUND — check if classes are on the same element (use compound selector without space)';
}
```

### Comparing container vs content heights

To detect overflow issues, compare `offsetHeight` (rendered) vs `scrollHeight` (content):

```javascript
() => {
  const container = document.querySelector('.container');
  return {
    offsetHeight: container.offsetHeight,
    scrollHeight: container.scrollHeight,
    isOverflowing: container.scrollHeight > container.offsetHeight,
  };
}
```

## Step 5: Interact with Elements

Click elements by UID (from snapshot) or via JavaScript:

```javascript
// Click by aria-label
() => {
  const btn = document.querySelector('[aria-label="My Button"]');
  if (btn) { btn.click(); return 'clicked'; }
  return 'not found';
}
```

## Tips

- **Always take a screenshot first** to understand the current visual state
- **Use `evaluate_script` over snapshots** when you know the CSS selectors — snapshots are huge on complex pages
- **Check `offsetHeight` vs `scrollHeight`** to detect content overflowing its container
- **Verify CSS selectors match** by querying with `document.querySelector` before assuming overrides work
- **Compound vs descendant selectors**: If `querySelector('.a .b')` returns null but both classes exist, they may be on the same element — try `.a.b` (no space)
- **After code changes**, use `navigate_page(type: "reload")` to reload and retest
