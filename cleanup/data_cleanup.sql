-- Delete all the records which contain null in any column
DELETE FROM yellow_taxi_data WHERE NOT (yellow_taxi_data IS NOT null);   
-- Delete the records which ended before or after 2020
DELETE FROM yellow_taxi_data WHERE EXTRACT(YEAR FROM (tpep_dropoff_datetime)) != 2020;
-- Delete the records which started after Jan 2020 and in Dec 2019
DELETE FROM yellow_taxi_data WHERE EXTRACT(MONTH FROM (tpep_pickup_datetime)) > 1;     
-- Delete trips that lasted more than 6 h
DELETE FROM yellow_taxi_data WHERE EXTRACT(EPOCH from AGE(tpep_dropoff_datetime, tpep_pickup_datetime)) > 3600*6; -- Length > 6h
-- Delete trips that lasted more than 1 hour and erroneously ended at 00:00
DELETE FROM yellow_taxi_data WHERE EXTRACT(EPOCH from AGE(tpep_dropoff_datetime, tpep_pickup_datetime)) > 3600 and  tpep_dropoff_datetime :: TIME = '00:00:00';
-- Delete trips with a duration of less than 10 sec.
DELETE FROM yellow_taxi_data WHERE EXTRACT(EPOCH from AGE(tpep_dropoff_datetime, tpep_pickup_datetime)) < 10; 
-- Delete trips where the number of passengers is less than zero.
DELETE FROM yellow_taxi_data WHERE passenger_count < 0;
/*We delete trips that have a trip length less than zero or
a trip cost less than 2.5 USD (this is the minimum payment that follows from the analysis) or
additional payments more than 7 USD (also follows from the analysis).*/
DELETE FROM yellow_taxi_data WHERE trip_distance <= 0 OR fare_amount < 2.5 OR extra > 7;