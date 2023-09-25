CREATE SCHEMA IF NOT EXISTS reporting;

CREATE OR REPLACE VIEW reporting.flight AS
SELECT CASE WHEN dep_delay_new > 0 THEN 1
            ELSE 0
       END AS is_delayed
FROM flight
WHERE cancelled = 0;

CREATE OR REPLACE VIEW reporting.top_reliability_roads AS
SELECT flight.origin_airport_id, 
       t1.name AS origin_airport_name, 
       flight.dest_airport_id, 
       t2.display_airport_name AS dest_airport_name, 
       flight.year,
       SUM(flight.op_carrier_fl_num) OVER (PARTITION BY flight.origin_airport_id, flight.dest_airport_id) AS cnt,
       100.0 * SUM(flight.dep_delay_new) / SUM(flight.op_carrier_fl_num) OVER (PARTITION BY flight.origin_airport_id, flight.dest_airport_id, flight.year) AS reliability,
       ROW_NUMBER() OVER (ORDER BY 100.0 * SUM(flight.dep_delay_new) / SUM(flight.op_carrier_fl_num)) AS nb
FROM flight
JOIN airport_list t1 ON flight.origin_airport_id = t1.origin_airport_id
JOIN airport_list t2 ON flight.dest_airport_id = t2.origin_airport_id
GROUP BY flight.origin_airport_id, t1.name, flight.dest_airport_id, t2.display_airport_name , flight.year, flight.op_carrier_fl_num
HAVING SUM(flight.op_carrier_fl_num) > 10000;

CREATE OR REPLACE VIEW reporting.year_to_year_comparision AS
SELECT flight.year, 
       flight.month, 
       COUNT(flight.id) AS flights_amount,
       (COUNT(CASE WHEN dep_delay_new > 0 THEN dep_delay_new END)::float / COUNT(flight.id)::float) AS reliability
FROM flight
GROUP BY flight.year, flight.month;

CREATE OR REPLACE VIEW reporting.day_to_day_comparision AS
SELECT flight.year, day_of_week, COUNT(flight.id) AS flights_amount
FROM flight
GROUP BY flight.year, day_of_week;

CREATE OR REPLACE VIEW reporting.day_by_day_reliability AS
SELECT TO_DATE(flight.year::text || LPAD(flight.month::text, 2, '0') || LPAD(flight.day_of_month::text, 2, '0'), 'YYYYMMDD') AS date,
       (COUNT(CASE WHEN dep_delay_new > 0 THEN dep_delay_new END)::float / COUNT(flight.id)::float) AS reliability
FROM flight
GROUP BY date