Build a React + Vite profile page in /app for the shipping companies exported from /app/src/companyData.js. Keep that data file unchanged and use it as the source for the rendered company profiles. Render one accessible <article> per company using the company name as the article label.

The /app project should be a working Vite app: dependencies install successfully, the development server starts, and the production build completes.

Each company card should have three parts.

At the top, show the company logo if it exists. If it does not exist, show the first letter of the company name instead. 
Show the company name in an <h2>. Next to the name, show the verified badge image by using company.verifiedIconUrl, with "Verified company" as the alt text. 
Show the five-star rating row only when both rating values exist.

In the middle, add these three badges: "Verified", "Top Reviewed", and "Customer Favorite".

At the bottom, show a circular Trust Score percentage based on the company rating. 
Also show three metric rows for "Pricing Accuracy", "Communication", and "Vehicle Condition". 
Each metric row should include progressbar accessibility, and aria-valuenow should use the whole-number percentage for that metric.

Make the layout stay readable on mobile screen sizes. 
Include CSS animations for the trust ring and metric bars, using the keyframe hooks ring-fill, metric-grow, and stripes. Also make sure missing optional values do not break the UI.
