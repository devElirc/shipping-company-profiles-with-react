import { expect, test } from "@playwright/test";
import { pathToFileURL } from "node:url";

test("renders one labelled company article for each seeded company", async ({ page }) => {
  await page.goto("/");

  await expect(page.getByRole("article", { name: "Atlas Freight Lines International" })).toBeVisible();
  await expect(page.getByRole("article", { name: "Nova Transport Partners" })).toBeVisible();
  await expect(page.getByRole("article")).toHaveCount(2);
});

async function loadSeededCompanies() {
  // The environment seeds `/app/src/companyData.js` into the runtime image.
  // Import it to keep expectations aligned with the seeded dataset.
  const mod = await import(pathToFileURL("/app/src/companyData.js").href);
  return mod.default as Array<{
    name: string;
    averageRating?: number;
    reviewCount?: number;
  }>;
}

function escapeRegex(text: string) {
  return text.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function ratingTextPattern(company?: { averageRating?: number; reviewCount?: number }) {
  const rating = company?.averageRating?.toFixed(1) ?? "";
  const reviewCount = String(company?.reviewCount ?? "");
  return new RegExp(`${escapeRegex(rating)}\\s*\\(${escapeRegex(reviewCount)}\\s+reviews\\)`, "i");
}

test("shows logos, fallback initials, verified badges, and ratings accessibly", async ({ page }) => {
  await page.goto("/");

  const companies = await loadSeededCompanies();
  const atlasData = companies.find((c) => c.name === "Atlas Freight Lines International");
  const novaData = companies.find((c) => c.name === "Nova Transport Partners");

  const atlas = page.getByRole("article", { name: "Atlas Freight Lines International" });
  await expect(atlas.getByRole("img", { name: "Atlas Freight Lines International logo" })).toBeVisible();
  await expect(atlas.getByRole("heading", { name: "Atlas Freight Lines International" })).toBeVisible();
  await expect(atlas.getByRole("img", { name: "Verified company" })).toBeVisible();
  await expect(atlas).toContainText(ratingTextPattern(atlasData));

  const nova = page.getByRole("article", { name: "Nova Transport Partners" });
  await expect(nova.getByLabel("Nova Transport Partners initial")).toContainText("N");
  await expect(nova.getByRole("img", { name: /Nova Transport Partners logo/i })).toHaveCount(0);
  await expect(nova.getByRole("heading", { name: "Nova Transport Partners" })).toBeVisible();
  await expect(nova.getByRole("img", { name: "Verified company" })).toBeVisible();
  await expect(nova).toContainText(ratingTextPattern(novaData));
});

test("displays badges, trust scores, and semantic progress metrics", async ({ page }) => {
  await page.goto("/");

  const atlas = page.getByRole("article", { name: "Atlas Freight Lines International" });
  await expect(atlas.getByText("Verified", { exact: true })).toBeVisible();
  await expect(atlas.getByText("Top Reviewed", { exact: true })).toBeVisible();
  await expect(atlas.getByText("Customer Favorite", { exact: true })).toBeVisible();
  await expect(atlas.getByText("Trust Score")).toBeVisible();
  await expect(atlas.getByText("94%")).toBeVisible();
  await expect(atlas.getByRole("progressbar", { name: "Pricing Accuracy" })).toHaveAttribute("aria-valuenow", "92");
  await expect(atlas.getByRole("progressbar", { name: "Communication" })).toHaveAttribute("aria-valuenow", "88");
  await expect(atlas.getByRole("progressbar", { name: "Vehicle Condition" })).toHaveAttribute("aria-valuenow", "95");

  const nova = page.getByRole("article", { name: "Nova Transport Partners" });
  await expect(nova.getByText("84%")).toBeVisible();
  await expect(nova.getByRole("progressbar", { name: "Pricing Accuracy" })).toHaveAttribute("aria-valuenow", "82");
  await expect(nova.getByRole("progressbar", { name: "Communication" })).toHaveAttribute("aria-valuenow", "91");
  await expect(nova.getByRole("progressbar", { name: "Vehicle Condition" })).toHaveAttribute("aria-valuenow", "86");
});

test("includes the required animation and mobile CSS hooks", async ({ page }) => {
  await page.goto("/");

  const cssText = await page.evaluate(() =>
    Array.from(document.styleSheets)
      .flatMap((sheet) => Array.from(sheet.cssRules ?? []).map((rule) => rule.cssText))
      .join("\n"),
  );
  expect(cssText).toContain("@keyframes ring-fill");
  expect(cssText).toContain("@keyframes metric-grow");
  expect(cssText).toContain("@keyframes stripes");
  expect(cssText).toContain("@media (max-width: 640px)");
});
