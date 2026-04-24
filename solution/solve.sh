#!/usr/bin/env bash
set -euo pipefail

cd /app
mkdir -p src

cat > package.json <<'EOF'
{
  "name": "shipping-company-profiles",
  "private": true,
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "19.0.0",
    "react-dom": "19.0.0"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "4.3.4",
    "vite": "6.0.7"
  },
  "packageManager": "npm@10.8.2"
}
EOF

cat > index.html <<'EOF'
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Shipping Company Profiles</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
EOF

cat > vite.config.js <<'EOF'
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

export default defineConfig({
  plugins: [react()],
});
EOF

cat > src/main.jsx <<'EOF'
import React from "react";
import { createRoot } from "react-dom/client";
import App from "./App.jsx";

createRoot(document.getElementById("root")).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
);
EOF

cat > src/App.jsx <<'EOF'
import companies from "./companyData";
import "./styles.css";

const clampPercent = (value) => Math.max(0, Math.min(100, Math.round(Number(value) || 0)));

const metricLabels = [
  ["pricingAccuracy", "Pricing Accuracy"],
  ["communication", "Communication"],
  ["vehicleCondition", "Vehicle Condition"],
];

function CompanyCard({ company }) {
  const rating = Number(company?.averageRating);
  const reviewCountRaw = company?.reviewCount;
  const parsedReviewCount = Number.isFinite(Number(reviewCountRaw))
    ? Number(reviewCountRaw)
    : Number.parseInt(String(reviewCountRaw ?? "").replace(/[^\d]/g, ""), 10);
  const reviewCount = Number.isFinite(parsedReviewCount) ? parsedReviewCount : null;
  const hasRating = Number.isFinite(rating) && reviewCount != null;
  const trustScore = clampPercent(hasRating ? (rating / 5) * 100 : 0);
  const filledStars = hasRating ? Math.max(0, Math.min(5, Math.round(rating))) : 0;
  const reviewLabel = hasRating ? `${reviewCount} ${reviewCount === 1 ? "review" : "reviews"}` : "";
  const ratingSummary = hasRating ? `${rating.toFixed(1)} (${reviewLabel})` : "";

  return (
    <article className="company-card" aria-label={company.name}>
      <section className="card-top" aria-label={`${company.name} overview`}>
        <div className="logo-frame">
          {company.logoUrl ? (
            <img className="logo-image" src={company.logoUrl} alt={`${company.name} logo`} />
          ) : (
            <span className="initial" role="img" aria-label={`${company.name} initial`}>
              {company.name?.charAt(0) || "?"}
            </span>
          )}
        </div>

        <div className="company-copy">
          <div className="title-row">
            <h2>{company.name}</h2>
            {company.verifiedIconUrl ? (
              <img className="verified-icon" src={company.verifiedIconUrl} alt="Verified company" />
            ) : null}
          </div>

          {hasRating ? (
            <div className="rating-row" aria-label={`${ratingSummary}, ${rating.toFixed(1)} out of 5 stars`}>
              <span className="stars" aria-hidden="true">
                {"\u2605".repeat(filledStars)}
                {"\u2606".repeat(5 - filledStars)}
              </span>
              <span>{ratingSummary}</span>
            </div>
          ) : null}
        </div>
      </section>

      <section className="badges" aria-label={`${company.name} highlights`}>
        <span>Verified</span>
        <span>Top Reviewed</span>
        <span>Customer Favorite</span>
      </section>

      <section className="card-bottom" aria-label={`${company.name} performance metrics`}>
        <div className="trust-score" style={{ "--score": trustScore }}>
          <div className="ring" aria-hidden="true">
            <span>{trustScore}%</span>
          </div>
          <p>Trust Score</p>
        </div>

        <div className="metrics">
          {metricLabels.map(([key, label]) => {
            const percent = clampPercent(company?.metrics?.[key]);
            return (
              <div className="metric" key={key}>
                <div className="metric-label">
                  <span>{label}</span>
                  <strong>{percent}%</strong>
                </div>
                <div
                  className="metric-bar"
                  role="progressbar"
                  aria-label={label}
                  aria-valuemin="0"
                  aria-valuemax="100"
                  aria-valuenow={percent}
                >
                  <span style={{ "--value": `${percent}%` }} />
                </div>
              </div>
            );
          })}
        </div>
      </section>
    </article>
  );
}

export default function App() {
  return (
    <main className="app-shell">
      <p className="eyebrow">Carrier confidence desk</p>
      <h1>Shipping company profiles</h1>
      <div className="profile-grid">
        {(companies || []).map((company) => (
          <CompanyCard company={company} key={company.id || company.name} />
        ))}
      </div>
    </main>
  );
}
EOF

cat > src/styles.css <<'EOF'
:root {
  color: #15363b;
  background: #efe6d4;
  font-family: "Trebuchet MS", "Avenir Next", sans-serif;
}

* {
  box-sizing: border-box;
}

body {
  min-width: 320px;
  margin: 0;
  background:
    radial-gradient(circle at 15% 12%, rgba(245, 193, 93, 0.38), transparent 24rem),
    linear-gradient(135deg, #f7f0df 0%, #d7e8e6 100%);
}

.app-shell {
  width: min(1120px, calc(100% - 32px));
  margin: 0 auto;
  padding: 48px 0;
}

.eyebrow {
  margin: 0 0 8px;
  color: #b4652e;
  font-size: 0.82rem;
  font-weight: 800;
  letter-spacing: 0.18em;
  text-transform: uppercase;
}

h1 {
  margin: 0 0 28px;
  font-size: clamp(2.2rem, 6vw, 5rem);
  line-height: 0.95;
}

.profile-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 24px;
}

.company-card {
  overflow: hidden;
  border: 1px solid rgba(21, 54, 59, 0.18);
  border-radius: 30px;
  background: rgba(255, 251, 241, 0.88);
  box-shadow: 0 24px 70px rgba(31, 64, 69, 0.16);
}

.card-top,
.card-bottom {
  display: grid;
  gap: 18px;
  padding: 24px;
}

.card-top {
  grid-template-columns: 76px minmax(0, 1fr);
  align-items: center;
}

.logo-frame {
  display: grid;
  width: 76px;
  height: 76px;
  place-items: center;
  border-radius: 24px;
  background: #143f49;
  color: #fff7df;
  font-size: 2rem;
  font-weight: 900;
}

.logo-image {
  width: 100%;
  height: 100%;
  object-fit: contain;
  padding: 10px;
}

.title-row {
  display: flex;
  align-items: center;
  gap: 10px;
  min-width: 0;
}

h2 {
  overflow: hidden;
  margin: 0;
  font-size: 1.35rem;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.verified-icon {
  width: 24px;
  height: 24px;
  flex: 0 0 auto;
}

.rating-row {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 8px;
  color: #526a6d;
  font-weight: 700;
}

.stars {
  color: #d98d2b;
  letter-spacing: 0.04em;
}

.badges {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  padding: 0 24px 24px;
}

.badges span {
  border: 1px solid rgba(20, 124, 114, 0.22);
  border-radius: 999px;
  padding: 8px 12px;
  background: #ecf7f4;
  color: #12645d;
  font-size: 0.84rem;
  font-weight: 800;
}

.card-bottom {
  grid-template-columns: 130px minmax(0, 1fr);
  align-items: center;
  background: #143f49;
  color: #fff7df;
}

.trust-score {
  text-align: center;
}

.ring {
  display: grid;
  width: 106px;
  height: 106px;
  place-items: center;
  margin: 0 auto 8px;
  border-radius: 50%;
  background: conic-gradient(#f5c15d calc(var(--score) * 1%), rgba(255, 255, 255, 0.18) 0);
  animation: ring-fill 900ms ease-out both;
}

.ring span {
  display: grid;
  width: 74px;
  height: 74px;
  place-items: center;
  border-radius: 50%;
  background: #143f49;
  font-size: 1.25rem;
  font-weight: 900;
}

.trust-score p {
  margin: 0;
  color: #bad5d2;
  font-size: 0.86rem;
  font-weight: 800;
}

.metrics {
  display: grid;
  gap: 14px;
}

.metric-label {
  display: flex;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 6px;
  font-size: 0.92rem;
  font-weight: 800;
}

.metric-bar {
  overflow: hidden;
  height: 12px;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.18);
}

.metric-bar span {
  display: block;
  width: var(--value);
  height: 100%;
  border-radius: inherit;
  background:
    repeating-linear-gradient(135deg, rgba(255, 255, 255, 0.3) 0 8px, transparent 8px 16px),
    #f5c15d;
  animation: metric-grow 800ms ease-out both, stripes 1.2s linear infinite;
}

@keyframes ring-fill {
  from {
    filter: saturate(0.25);
    transform: rotate(-18deg) scale(0.92);
  }
  to {
    filter: saturate(1);
    transform: rotate(0) scale(1);
  }
}

@keyframes metric-grow {
  from {
    width: 0;
  }
}

@keyframes stripes {
  to {
    background-position: 32px 0;
  }
}

@media (prefers-reduced-motion: reduce) {
  .ring,
  .metric-bar span {
    animation: none;
  }
}

@media (max-width: 640px) {
  .app-shell {
    width: min(100% - 20px, 480px);
    padding: 28px 0;
  }

  .profile-grid,
  .card-bottom {
    grid-template-columns: 1fr;
  }

  .card-top {
    grid-template-columns: 58px minmax(0, 1fr);
    padding: 18px;
  }

  .logo-frame {
    width: 58px;
    height: 58px;
    border-radius: 18px;
  }

  .badges {
    padding: 0 18px 18px;
  }

  .metric-label {
    align-items: flex-start;
    flex-direction: column;
    gap: 4px;
  }
}
EOF

npm install
npm run build

DEV_SERVER_LOG=/tmp/shipping-company-profiles-dev.log
npm run dev -- --host 127.0.0.1 --port 3000 >"$DEV_SERVER_LOG" 2>&1 &
DEV_SERVER_PID=$!
trap 'kill "$DEV_SERVER_PID" 2>/dev/null || true' EXIT

for _ in 1 2 3 4 5 6 7 8 9 10; do
  if node -e "fetch('http://127.0.0.1:3000').then((response) => { if (!response.ok) process.exit(1); }).catch(() => process.exit(1));"; then
    break
  fi
  sleep 1
done

node -e "fetch('http://127.0.0.1:3000').then(async (response) => { const html = await response.text(); if (!response.ok || !html.includes('<div id=\"root\"></div>')) process.exit(1); }).catch(() => process.exit(1));"
