import { test, expect } from "@playwright/test";

test("asks a question and renders an answer + sources", async ({ page }) => {
  // Point NEXT_PUBLIC_API_BASE_URL to your Rails (http://localhost:3000)
  await page.goto("/chat");

  // Type a simple question
  await page.fill(
    "input[placeholder='Ask: What should I emphasize?']",
    "What should I emphasize for Rails and React?",
  );
  await page.click("text=Ask");

  // Simple smoke expectations (answer text appears; sources list exists)
  await expect(page.locator("h3", { hasText: "Answer" })).toBeVisible({
    timeout: 10000,
  });
  await expect(page.locator("h3", { hasText: "Sources" })).toBeVisible();
});
