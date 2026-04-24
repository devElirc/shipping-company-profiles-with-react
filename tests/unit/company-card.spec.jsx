import React from "react";
import { render, screen, within } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import App from "/app/src/App.jsx";

describe("shipping company profiles unit rendering", () => {
  it("renders one accessible article per seeded company with stable headings", () => {
    render(<App />);

    const atlas = screen.getByRole("article", { name: "Atlas Freight Lines International" });
    const nova = screen.getByRole("article", { name: "Nova Transport Partners" });
    const echo = screen.getByRole("article", { name: "Echo Logistics Group" });

    expect(atlas).toBeInTheDocument();
    expect(nova).toBeInTheDocument();
    expect(echo).toBeInTheDocument();
    expect(screen.getAllByRole("article")).toHaveLength(3);

    expect(within(atlas).getByRole("heading", { name: "Atlas Freight Lines International" })).toBeVisible();
    expect(within(nova).getByRole("heading", { name: "Nova Transport Partners" })).toBeVisible();
    expect(within(echo).getByRole("heading", { name: "Echo Logistics Group" })).toBeVisible();
  });

  it("renders the logo and verified badge for Atlas and fallback initials for companies without logos", () => {
    render(<App />);

    const atlas = screen.getByRole("article", { name: "Atlas Freight Lines International" });
    expect(within(atlas).getByRole("img", { name: "Atlas Freight Lines International logo" })).toBeVisible();
    expect(within(atlas).getByRole("img", { name: "Verified company" })).toBeVisible();

    const nova = screen.getByRole("article", { name: "Nova Transport Partners" });
    expect(within(nova).getByLabelText("Nova Transport Partners initial")).toHaveTextContent("N");
    expect(within(nova).queryByRole("img", { name: /Nova Transport Partners logo/i })).not.toBeInTheDocument();

    const echo = screen.getByRole("article", { name: "Echo Logistics Group" });
    expect(within(echo).getByLabelText("Echo Logistics Group initial")).toHaveTextContent("E");
  });

  it("renders ratings only for companies with both rating values and preserves metric accessibility", () => {
    render(<App />);

    const atlas = screen.getByRole("article", { name: "Atlas Freight Lines International" });
    expect(within(atlas).getByText("4.7 (214 reviews)")).toBeVisible();
    expect(within(atlas).getByRole("progressbar", { name: "Pricing Accuracy" })).toHaveAttribute("aria-valuenow", "92");
    expect(within(atlas).getByText("Trust Score")).toBeVisible();

    const echo = screen.getByRole("article", { name: "Echo Logistics Group" });
    expect(within(echo).queryByText(/\breviews?\b/i)).not.toBeInTheDocument();
    expect(within(echo).getByRole("progressbar", { name: "Vehicle Condition" })).toHaveAttribute("aria-valuenow", "68");
    expect(within(echo).getByText("Trust Score")).toBeVisible();
  });
});
