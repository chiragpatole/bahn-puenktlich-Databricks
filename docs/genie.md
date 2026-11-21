# Genie space: Bahn pünktlich

A Databricks Genie space that answers questions about the data in plain language. It reads only the metric view `bahn.gold.punctuality_metrics`, so it uses the same KPI formulas as the dashboard.

## Instructions given to the space

```
This space answers questions about train punctuality at 25 large German stations, from 1 May 2026 onwards.

- "Punctuality", "on time" or "Pünktlichkeit" means the measure punctuality_db unless the user asks to include cancellations; then use punctuality_incl_cancelled.
- A stop is punctual if the train arrives less than 6 minutes late. First stops are excluded, like DB's own published figure.
- "ICE", "IC", "Fernverkehr" or "long-distance" means product_class = 'long_distance'. "S-Bahn" means 's_bahn'. "Regional", "RE" or "RB" means 'regional'. FlixTrain is 'other_operator' and is not part of DB's figure.
- Show percentages with one decimal.
- These are 25 hub stations, not the whole network. Do not compare them directly with DB's network-wide figure without saying so.
- Long-distance trains have no line number, so line rankings only cover regional, S-Bahn and FlixTrain.
- 13 to 16 October 2026 are undercounted. Until 12 October the data comes from an open archive, from 17 October from the project's own collector, which records about 7% fewer long-distance stops. Mention this when comparing October or November with earlier months.
- The current week and month are incomplete.
- When ranking stations or lines, always show the number of stops next to the percentage. Leave out stations with fewer than 500 stops in the period unless the user asks for them, and say that they were left out. Remove the small stations first (HAVING MEASURE(stops) >= 500), then rank or sort the rest.
```

## Example query

Question: *Which station had the worst long-distance punctuality last month?*

```sql
SELECT
  station_name,
  MEASURE(punctuality_db) AS punctuality_db,
  MEASURE(stops)          AS stops
FROM bahn.gold.punctuality_metrics
WHERE product_class = 'long_distance'
  AND month = CAST(date_trunc('MONTH', add_months(current_date(), -1)) AS DATE)
GROUP BY station_name
HAVING MEASURE(stops) >= 500
ORDER BY punctuality_db ASC
LIMIT 5;
```

## Sample questions

- Which station had the worst long-distance punctuality last month?
- How did long-distance punctuality change week by week since May?
- How much do cancellations lower punctuality for each train class?
- At what hour of the day is long-distance punctuality lowest at Köln Hbf?
- Which regional lines have the highest cancelled share?
- Compare weekdays and weekends for S-Bahn punctuality.

## What went wrong while setting it up

Asked on 21 November 2026: *Which station had the worst long-distance punctuality last month?*

1. **First answer: Berlin-Wannsee, 22.9 %.** Correct by the numbers, but the dashboard pointed at Dortmund. A check in SQL showed Wannsee had 62 long-distance stops in October, Dortmund 3,204. Two late ICs a day decide Wannsee's figure. Fix: an instruction to show stop counts and leave out stations with fewer than 500 stops.
2. **Second answer: empty.** The generated SQL ranked all stations first and filtered for 500 stops afterwards. Wannsee was rank 1 but failed the filter, Dortmund passed the filter but was rank 2, so no row was left. Fix: the instruction now says to remove small stations before ranking, and the example query above shows the pattern with `HAVING`.
3. **Third answer: Dortmund Hbf, 26.3 %, 3,204 stops.** Matches the SQL check.

The lesson: read the SQL Genie writes, not only its answer.
