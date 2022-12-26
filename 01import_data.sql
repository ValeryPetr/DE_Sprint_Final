/* In this module we create tables, the database itself is created on the command line.
Tables and files are stored in the folder '/home/valeryp/desprint/final' */
DROP TABLE IF EXISTS public.yellow_taxi_data;

CREATE TABLE IF NOT EXISTS public.yellow_taxi_data (
	"VendorID" SMALLINT, 
	tpep_pickup_datetime TIMESTAMP WITHOUT TIME ZONE, 
	tpep_dropoff_datetime TIMESTAMP WITHOUT TIME ZONE, 
	passenger_count SMALLINT, 
	trip_distance FLOAT(24), 
	"RatecodeID" SMALLINT, 
	store_and_fwd_flag CHAR(1), 
	"PULocationID" SMALLINT, 
	"DOLocationID" SMALLINT, 
	payment_type SMALLINT, 
	fare_amount FLOAT(24), 
	extra FLOAT(24), 
	mta_tax FLOAT(24), 
	tip_amount FLOAT(24), 
	tolls_amount FLOAT(24), 
	improvement_surcharge FLOAT(24), 
	total_amount FLOAT(24),
  	congestion_surcharge FLOAT(24)
)
TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.yellow_taxi_data
    OWNER to postgres;

COPY public.yellow_taxi_data("VendorID",tpep_pickup_datetime,tpep_dropoff_datetime,passenger_count,trip_distance,"RatecodeID",store_and_fwd_flag,"PULocationID","DOLocationID",payment_type,fare_amount,extra,mta_tax,tip_amount,tolls_amount,improvement_surcharge,total_amount,congestion_surcharge)
FROM '/home/valeryp/desprint/final/yellow_tripdata_2020-01.csv'
DELIMITER ','
CSV HEADER;	