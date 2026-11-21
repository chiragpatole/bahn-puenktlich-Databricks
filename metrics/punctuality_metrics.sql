-- Metric view on top of gold.stop_events. Run in the Databricks SQL editor.
-- One formula per KPI. Dashboards and the Genie space read the measures from here,
-- so a ratio is always recomputed from stop counts and never averaged twice.

CREATE OR REPLACE VIEW bahn.gold.punctuality_metrics
WITH METRICS LANGUAGE YAML AS
$$
version: 1.1
comment: "Punctuality of trains at 25 large German stations, measured like DB: at arrival, first stops excluded, punctual = less than 6 minutes late"
source: bahn.gold.stop_events
filter: complete_day AND NOT is_origin

fields:
  - name: service_date
    expr: service_date
    display_name: "Date"
  - name: week
    expr: CAST(date_trunc('WEEK', service_date) AS DATE)
    display_name: "Week"
  - name: month
    expr: CAST(date_trunc('MONTH', service_date) AS DATE)
    display_name: "Month"
  - name: weekday
    expr: date_format(service_date, 'EEEE')
    display_name: "Weekday"
  - name: hour_local
    expr: hour_local
    display_name: "Hour of day (German time)"
  - name: station_name
    expr: station_name
    display_name: "Station"
    synonyms: ['Bahnhof', 'hub']
  - name: station_group
    expr: station_group
    display_name: "Station group"
  - name: product_class
    expr: product_class
    display_name: "Train class"
    synonyms: ['train type', 'Zuggattung']
    comment: "long_distance = ICE, IC, EC and similar (DB Fernverkehr); regional = RE, RB; s_bahn = S-Bahn; other_operator = FlixTrain and other non-DB long-distance trains"
  - name: line_label
    expr: line_label
    display_name: "Line"
    comment: "Line numbers repeat across regions. Long-distance trains have no line number"

measures:
  - name: stops
    expr: COUNT(1)
    display_name: "Stops"
  - name: cancelled_stops
    expr: COUNT_IF(cancelled)
    display_name: "Cancelled stops"
  - name: punctuality_db
    expr: COUNT_IF(punctual) / NULLIF(COUNT_IF(NOT cancelled), 0)
    display_name: "Punctuality (DB definition)"
    synonyms: ['on-time rate', 'Pünktlichkeit']
    comment: "Punctual stops divided by stops that ran. Cancelled stops excluded, as in DB's published figure"
  - name: punctuality_incl_cancelled
    expr: COUNT_IF(punctual) / COUNT(1)
    display_name: "Punctuality incl. cancellations"
    comment: "Punctual stops divided by all planned stops. A cancelled train counts as not on time"
  - name: cancelled_share
    expr: COUNT_IF(cancelled) / COUNT(1)
    display_name: "Cancelled share"
  - name: avg_delay_min
    expr: AVG(CASE WHEN NOT cancelled THEN delay_min END)
    display_name: "Average delay (min)"
  - name: late_15_plus_share
    expr: COUNT_IF(NOT cancelled AND delay_min >= 15) / NULLIF(COUNT_IF(NOT cancelled), 0)
    display_name: "Share 15+ min late"
$$;
