import { expect, test } from "@playwright/test";

test("pressing the button stores and displays click event", async ({ page }) => {
  await page.goto("/");

  const button = page.getByRole("button", { name: "Press me" });
  await expect(button).toBeVisible();

  await button.click();

  await expect(page.getByText("Saved event #", { exact: false })).toBeVisible();
});
