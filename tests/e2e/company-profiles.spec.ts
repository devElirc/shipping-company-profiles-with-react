import { expect, test } from "@playwright/test";
import { readFile } from "node:fs/promises";
import { pathToFileURL } from "node:url";

const expectedCompanyDataSource = `const companies = [
  {
    id: "atlas-freight",
    name: "Atlas Freight Lines International",
    logoUrl: "/atlas-logo.svg",
    verifiedIconUrl: "/verified-badge.svg",
    averageRating: 4.7,
    reviewCount: 214,
    metrics: {
      pricingAccuracy: 92,
      communication: 88,
      vehicleCondition: 95,
    },
  },
  {
    id: "nova-transport",
    name: "Nova Transport Partners",
    logoUrl: "",
    verifiedIconUrl: "/verified-badge.svg",
    averageRating: 4.2,
    reviewCount: 87,
    metrics: {
      pricingAccuracy: 82,
      communication: 91,
      vehicleCondition: 86,
    },
  },
  {
    id: "echo-logistics",
    name: "Echo Logistics Group",
    logoUrl: "",
    verifiedIconUrl: "/verified-badge.svg",
    averageRating: null,
    reviewCount: null,
    metrics: {
      pricingAccuracy: 70,
      communication: 75,
      vehicleCondition: 68,
    },
  },
];

export default companies;
`;

async function loadSeededCompanies() {
  const mod = await import(pathToFileURL("/app/src/companyData.js").href);
  return mod.default as Array<{
    name: string;
    averageRating?: number | null;
    reviewCount?: number | null;
  }>;
}

function escapeRegex(text: string) {
  return text.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function ratingTextPattern(company?: { averageRating?: number | null; reviewCount?: number | null }) {
  const rating = company?.averageRating?.toFixed(1) ?? "";
  const reviewCount = String(company?.reviewCount ?? "");
  return new RegExp(`${escapeRegex(rating)}\\s*\\(${escapeRegex(reviewCount)}\\s+reviews\\)`, "i");
}

test("renders one labelled company article for each seeded company", async ({ page }) => {
  await page.goto("/");

  await expect(page.getByRole("article", { name: "Atlas Freight Lines International" })).toBeVisible();
  await expect(page.getByRole("article", { name: "Nova Transport Partners" })).toBeVisible();
  await expect(page.getByRole("article", { name: "Echo Logistics Group" })).toBeVisible();
  await expect(page.getByRole("article")).toHaveCount(3);
});

test("keeps the seeded companyData.js file unchanged", async () => {
  const currentSource = await readFile("/app/src/companyData.js", "utf8");
  expect(currentSource).toBe(expectedCompanyDataSource);
});

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

  const echo = page.getByRole("article", { name: "Echo Logistics Group" });
  await expect(echo.getByLabel("Echo Logistics Group initial")).toContainText("E");
  await expect(echo.getByRole("heading", { name: "Echo Logistics Group" })).toBeVisible();
  await expect(echo.getByRole("img", { name: "Verified company" })).toBeVisible();
  await expect(echo.locator(".rating-row")).toHaveCount(0);
  await expect(echo.locator(".stars")).toHaveCount(0);
  await expect(echo).not.toContainText(/\breviews?\b/i);
  await expect(echo).not.toContainText(/[\u2605\u2606]/);
});

test("displays badges, trust scores, and semantic progress metrics", async ({ page }) => {
  await page.goto("/");

  for (const name of [
    "Atlas Freight Lines International",
    "Nova Transport Partners",
    "Echo Logistics Group",
  ]) {
    const card = page.getByRole("article", { name });
    await expect(card.getByText("Trust Score")).toHaveCount(1);
    const badgeList = card.getByRole("list");
    await expect(badgeList).toBeVisible();
    await expect(badgeList.getByRole("listitem")).toHaveCount(3);
  }

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

  const echo = page.getByRole("article", { name: "Echo Logistics Group" });
  await expect(echo.getByRole("progressbar", { name: "Pricing Accuracy" })).toHaveAttribute("aria-valuenow", "70");
  await expect(echo.getByRole("progressbar", { name: "Communication" })).toHaveAttribute("aria-valuenow", "75");
  await expect(echo.getByRole("progressbar", { name: "Vehicle Condition" })).toHaveAttribute("aria-valuenow", "68");
});

test("honors prefers-reduced-motion for trust ring and metric bar animations", async ({ page }) => {
  await page.emulateMedia({ reducedMotion: "reduce" });
  await page.goto("/");

  const ringMotion = await page
    .locator(".ring")
    .first()
    .evaluate((el) => {
      const style = getComputedStyle(el);
      return { animationName: style.animationName, animationDuration: style.animationDuration };
    });
  expect(
    ringMotion.animationName === "none" ||
      ringMotion.animationDuration === "0s" ||
      ringMotion.animationName === "",
  ).toBeTruthy();

  const metricMotion = await page
    .locator(".metric-bar span")
    .first()
    .evaluate((el) => {
      const style = getComputedStyle(el);
      return { animationName: style.animationName, animationDuration: style.animationDuration };
    });
  expect(
    metricMotion.animationName === "none" ||
      metricMotion.animationDuration === "0s" ||
      metricMotion.animationName === "",
  ).toBeTruthy();
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

test("uses a readable single-column mobile layout", async ({ page }) => {
  await page.setViewportSize({ width: 390, height: 844 });
  await page.goto("/");
  await expect(page.getByRole("article").first()).toBeVisible();

  const articleCount = await page.getByRole("article").count();
  expect(articleCount).toBe(3);

  const viewportWidth = await page.evaluate(() => window.innerWidth);
  const boxes = [];
  for (let index = 0; index < articleCount; index += 1) {
    const box = await page.getByRole("article").nth(index).boundingBox();
    expect(box).not.toBeNull();
    expect(box!.width).toBeLessThanOrEqual(viewportWidth);
    boxes.push(box!);
  }

  const [first, second, third] = boxes;
  expect(Math.abs(first.x - second.x)).toBeLessThanOrEqual(2);
  expect(Math.abs(second.x - third.x)).toBeLessThanOrEqual(2);
  expect(second.y).toBeGreaterThan(first.y + first.height - 2);
  expect(third.y).toBeGreaterThan(second.y + second.height - 2);
});
