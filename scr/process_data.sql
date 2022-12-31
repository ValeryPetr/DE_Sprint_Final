
DROP TABLE IF EXISTS day_stats;
CREATE TABLE day_stats (
	trip_date DATE PRIMARY KEY,
	percentage_zero FLOAT(24),
	percentage_1p FLOAT(24),
	percentage_2p FLOAT(24),
	percentage_3p FLOAT(24),
	percentage_4p_plus FLOAT(24)
);

INSERT INTO day_stats(trip_date, percentage_zero, percentage_1p, percentage_2p, percentage_3p, percentage_4p_plus) 
SELECT trip_day, 
       100.0*SUM(CASE WHEN passenger_count = 0 THEN 1 ELSE 0 END)/COUNT(*) AS percentage_zero,
	   100.0*SUM(CASE WHEN passenger_count = 1 THEN 1 ELSE 0 END)/COUNT(*) AS percentage_1p,
	   100.0*SUM(CASE WHEN passenger_count = 2 THEN 1 ELSE 0 END)/COUNT(*) AS percentage_2p,
	   100.0*SUM(CASE WHEN passenger_count = 3 THEN 1 ELSE 0 END)/COUNT(*) AS percentage_3p,
	   100.0*SUM(CASE WHEN passenger_count > 3 THEN 1 ELSE 0 END)/COUNT(*) AS percentage_4p_plus
	   FROM yellow_taxi_data GROUP BY trip_day ORDER BY trip_day ASC;

DROP TABLE IF EXISTS min_max_cost_tmp;
CREATE TEMP TABLE min_max_cost_tmp(
	trip_date DATE PRIMARY KEY,
	total_min FLOAT(24),
	total_max FLOAT(24)
);

DROP TABLE IF EXISTS new_fields_list;
CREATE TEMP TABLE new_fields_list (
	col_name VARCHAR(20),
	col_condition VARCHAR(20)
);
INSERT INTO new_fields_list
VALUES ('percentage_zero'   , 'passenger_count = 0'),
       ('percentage_1p'     , 'passenger_count = 1'),
       ('percentage_2p'     , 'passenger_count = 2'),
       ('percentage_3p'     , 'passenger_count = 3'),
       ('percentage_4p_plus', 'passenger_count > 3');
	   
DO $$
DECLARE
    f record;
BEGIN
    FOR f IN SELECT col_name, col_condition FROM new_fields_list LOOP
        RAISE NOTICE 'Adding columns %_min and %_max to the day_stats table with condition (%)', f.col_name, f.col_name, f.col_condition;
		EXECUTE 'ALTER TABLE day_stats
                 ADD COLUMN IF NOT EXISTS ' ||f.col_name|| '_min FLOAT(24),
                 ADD COLUMN IF NOT EXISTS ' ||f.col_name|| '_max FLOAT(24)';
		TRUNCATE min_max_cost_tmp;
        EXECUTE 'INSERT INTO min_max_cost_tmp(trip_date, total_min, total_max)
                 SELECT trip_day, MIN(total_amount) AS total_min, MAX(total_amount) AS total_max
                 FROM yellow_taxi_data WHERE '||f.col_condition|| ' GROUP BY trip_day';
		EXECUTE 'UPDATE day_stats AS st SET (' ||f.col_name|| '_min, ' ||f.col_name|| '_max) = (total_min, total_max) 
                 FROM min_max_cost_tmp AS tmp WHERE st.trip_date = tmp.trip_date';
    END LOOP;
END$$;

SELECT * FROM day_stats ORDER BY trip_date ASC;
-- The file yellow_taxi_stats_Jan2020.csv has to be created in davance with a permission 'write by others'
COPY (SELECT * FROM day_stats ORDER BY trip_date ASC) TO '/home/valeryp/final/yellow_taxi_stats_Jan2020.csv'
WITH DELIMITER ','
CSV HEADER;