# KPI definitions

Every KPI is defined once, in `metrics/punctuality_metrics.sql`, and the dashboard and the Genie space read it from there. This file says in words what each one means.

## Rules that apply to all of them

- One row in `gold.stop_events` is one train at one station.
- A stop is measured at arrival. At the first stop of a train there is no arrival, and DB leaves first stops out of its figure, so they are left out here too.
- Only complete days count (`complete_day`). The first and last day a source has for a station are dropped when they hold less than half of the station's usual traffic.
- A stop is punctual when the train arrives less than 6 minutes late. This is DB's rule.
- FlixTrain and other non-DB long-distance trains are their own train class, `other_operator`. DB's published figure covers DB trains only.
- The ratios are computed from stop counts for whatever grouping is asked for. They are never averages of daily or per-station percentages, so a small station does not weigh as much as Berlin Hbf.

## The KPIs

| KPI | Question it answers | Formula |
|---|---|---|
| Punctuality (DB definition) | How often were trains on time, measured the way DB measures? | punctual stops ÷ stops that ran |
| Punctuality incl. cancellations | Same, if a train that never came counts as not on time | punctual stops ÷ all planned stops |
| Cancelled share | How many planned stops did not happen? | cancelled stops ÷ all planned stops |
| Average delay (min) | How late were the trains that ran? | average delay of stops that ran |
| Share 15+ min late | How often was a delay large enough to miss a connection? | stops that ran with delay ≥ 15 min ÷ stops that ran |
| Stops | How much data is behind a number? | all planned stops |
| Cancelled stops | | stops marked cancelled |

## Things to keep in mind when reading them

- The gap between the two punctuality figures is what cancellations cost. For long-distance trains it is 2 to 3 points every month.
- Always look at Stops next to a percentage. Berlin-Wannsee had 62 long-distance stops in October 2026, so a handful of late trains decides its figure. The Genie space leaves out stations with fewer than 500 stops when it ranks them.
- These are 25 hub stations, not the network. Hubs are worse than DB's network figure because delays add up along a route.
- Until 12 October 2026 the data comes from the open archive, from 17 October from the collector. The collector records about 7 % fewer long-distance stops, so compare months across that date with care.
