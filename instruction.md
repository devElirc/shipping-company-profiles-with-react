Build a React + Vite profile page in /app for the shipping companies exported from /app/src/companyData.js. 
Keep that data file unchanged and use it as the source for the rendered company profiles. Leave the existing SVG files under /app/public/ in place so the logo and verified badge URLs from the data keep resolving. Render one accessible <article> per company using the company name as the article label.

The /app project should be a working Vite app: dependencies install successfully, the development server starts, and the production build completes.

Each company card should have three parts.

At the top, show the company logo if it exists, using the company name followed by " logo" as the image alt text. 
If it does not exist, show the first letter of the company name instead in an element labelled with the company name followed by "initial".
Show the company name in an <h2>. Next to the name, show the verified badge image by using company.verifiedIconUrl, with "Verified company" as the alt text. 
Show the five-star rating row only when both rating values exist. 
When it is shown, include the numeric rating and review count in the exact text format `4.7 (214 reviews)`, with the company values substituted and the rating shown to one decimal place.

In the middle, add these three badges: "Verified", "Top Reviewed", and "Customer Favorite". 
Present them as a real HTML list inside each card so there are exactly three list items (for example using ul/li).

At the bottom, show a circular Trust Score percentage based on the company rating (when there is no usable rating, show `0%`). Every card must still show the Trust Score label and percentage so the bottom section never disappears for missing ratings. Render the visible text `Trust Score` only once per company card, and keep any decorative SVG or ring artwork hidden from assistive technology so it does not create a second `Trust Score` text or accessible-name match.
Also show three metric rows for "Pricing Accuracy", "Communication", and "Vehicle Condition". 
Each metric row should include progressbar accessibility, and aria-valuenow should use the whole-number percentage for that metric.

Make the layout stay readable on mobile screen sizes, and include a CSS media query with the exact hook `@media (max-width: 640px)`.
Include CSS animations for the trust ring and metric bars, using the keyframe hooks ring-fill, metric-grow, and stripes. 
When the user prefers reduced motion (`prefers-reduced-motion: reduce`), those animations must not run on the trust ring or the metric bar fills. 
Also make sure missing optional values do not break the UI.
