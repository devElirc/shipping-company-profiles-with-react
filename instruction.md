Build shipping company profiles in React with Vite.
Please read /app/src/companyData.js first.

It already exports companies, and you must render one profile card for each company in that array.
There are two companies in the file, and you should keep their names exactly the same: Atlas Freight Lines International and Nova Transport Partners.
Use the two companies from the data file exactly as they are.
Do not create your own company names, and do not render only one generic profile card.

Use a real <article> element for each company profile, and set it up so the company name is used as the label, for example <article aria-label={company.name}>.
Create the app inside /app and make sure it is a working React + Vite project.
The /app/package.json file should exist, and npm install, npm run dev, and npm run build should all work when run from /app.
Use this project structure: /app/package.json, /app/vite.config.js or /app/vite.config.ts, /app/index.html, /app/src/main.jsx, and /app/src/App.jsx.
In App.jsx, import companies from ./companyData and render one profile card per company.
Do not edit /app/src/companyData.js.
Use it as the source for all displayed company data.
The provided assets are already available in /app/public, including the logo and verified badge files.

Each company profile card should have three sections: top, middle, and bottom.

In the top section, show the company logo when logoUrl is available.
The image alt text should include the company name and end with logo, for example Atlas Freight Lines International logo.
If logoUrl is empty, do not render a logo image. Show the first letter of the company name instead, and add an accessible label like Nova Transport Partners initial.
Show the company name in an <h2>. On desktop, keep it on one line and use ellipsis if it gets too long.
Next to the company name, show the verified badge. Use company.verifiedIconUrl from the data, not a hardcoded path. 
The image alt text must be exactly Verified company.
Show the rating row only when both averageRating and reviewCount exist. 
Use five stars, where the filled star count is based on Math.round(averageRating).
The text format should look like this: 4.6 (214 reviews).
If either rating value is missing, do not render the rating row.

In the middle section, show these three labels exactly: Verified, Top Reviewed, and Customer Favorite.
Make sure the badges wrap cleanly on smaller screens.

In the bottom section, show a Trust Score based on Math.round((averageRating / 5) * 100).
Keep the result between 0 and 100, display it as a whole-number percentage, and show it with a circular progress ring.
Animate the ring using a CSS keyframe named ring-fill.
Also show these three metric rows: Pricing Accuracy, Communication, and Vehicle Condition.
Each row should display its percentage and include a progress element with role="progressbar" and aria-valuenow set to the whole-number percent from company.metrics.
Animate the metric bars using CSS keyframes named metric-grow and stripes.
Add a mobile rule such as @media (max-width: 640px) so the badges and metric rows stay readable on smaller screens.
Write the UI safely so missing values do not break the app. Use guards, optional chaining, or fallback values where needed.

Before you finish, run npm run build inside /app and fix any issues until the build succeeds.