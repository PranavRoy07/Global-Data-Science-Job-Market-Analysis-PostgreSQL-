# Global Data Science Job Market Analysis (PostgreSQL)

A pure-SQL analysis of 3,925 global data science job listings, built entirely in PostgreSQL using window functions, CTEs, array parsing, and statistically-aware aggregation to uncover salary patterns across countries, experience levels, and job specializations.

## Project Summary

This project answers a core career-strategy question for data professionals: where does experience actually pay off, which roles command the biggest premiums, and how do country-level salary averages hide or distort the real picture? Every query in this project was written and debugged directly in PostgreSQL — no Python, no spreadsheet tool — using the dataset's full 3,925 rows across company location, job title, job category, experience level, and salary in USD.

A key discipline applied throughout: every aggregation query carries a minimum sample size filter (`HAVING COUNT(*) >= 5` or its window-function equivalent) to prevent single-listing outliers from distorting country or role-level averages — a statistical safeguard many beginner SQL projects skip entirely.

## Key Insights

- **Senior talent monopolizes the market.** Senior-level roles account for 67.2% of all active listings (2,638 of 3,925 rows) — companies are overwhelmingly favoring proven, day-one execution over entry-level training.
- **The experience premium is real and steep.** Moving from an Entry-level baseline ($77,953 avg) to Senior-level ($147,571 avg) delivers an 89.3% salary jump — one of the clearest career ROI signals in the dataset.
- **Executive roles are rare but elite.** Executive and leadership positions make up just 3.4% of global listings, yet command the highest average salary baseline at $198,568.
- **Local specialization beats regional baselines.** While a standard Data Analyst in Australia earns $165,000–$171,000, a specialized ML Engineer in that same market commands up to $300,000 — a $129,000 premium over the local Data Analyst benchmark.
- **Country-wide averages mask the real top earners.** Australia's national salary baseline sits at $123,648, but window-function benchmarking reveals specialized ML Engineering roles peaking at $300,000 — a $176,352 premium over the national average, more than double typical regional earnings. The same pattern holds in emerging hubs: a Principal Machine Learning Engineer in India secures $160,000, well above that market's general baseline.

## Tools and SQL Techniques Used

- PostgreSQL via pgAdmin
- Data cleaning: NULL audits, duplicate detection, text normalization with `CASE` + `ILIKE`
- Feature engineering: custom experience-band categorization via `ALTER TABLE` + `UPDATE`
- Aggregation: `GROUP BY`, `HAVING`, `COUNT(*) FILTER`
- Window functions: `RANK()`, `PERCENT_RANK()`, `PARTITION BY`, windowed `AVG()` and `COUNT()`
- CTEs (Common Table Expressions) for multi-step ranking logic
- Statistical safeguarding: minimum sample-size thresholds applied consistently across every aggregation to prevent outlier distortion

## Dataset Source

Global Data Science Job Market dataset, sourced from Kaggle. 3,925 rows covering job title, job category, experience level, company location, and salary in USD.

## Repository

https://github.com/PranavRoy07/Global-Data-Science-Job-Market-Analysis-PostgreSQL-

## Author

Pranav — Aspiring Data Analyst | BBACA Graduate
