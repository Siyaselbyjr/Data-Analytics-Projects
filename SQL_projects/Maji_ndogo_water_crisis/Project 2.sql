USE md_water_services;
-- REVIEW OF DATASET'S DICTIONARY
SELECT 
	*
FROM
	data_dictionary;
    
    
/** CLEANING UP THE DATA**/ 
    
-- 1. EXPLORE EMPLOYEE TABLE
SELECT
	*
FROM
	employee;
    
    -- CREATE EMAILS FOR ALL EMPLOYEES FOR COMMUNICATION (first_name.last_name@ndogowater.gov.)
SELECT
	CONCAT(
		LOWER(
			REPLACE(employee_name, ' ', '.')), '@ndogowater.gov') AS new_email 
FROM
	employee;
    
    -- UPDATE THE NEW EMAILS ON THE DATASET
    UPDATE employee
    SET email = CONCAT(
					LOWER(
						REPLACE(employee_name, ' ', '.')), '@ndogowater.gov');
                        
-- 2. CHECK OUT THE PHONE NUMBER, SUPPOSED TO BE 12 DIGITS LONG
SELECT
	LENGTH(phone_number)
FROM
	employee;
			/** 
				TURNS OUT THE NUMBER IS 13 DIGITS LONG INSTEAD
				OF 12 DIGITS, MEANING THERE IS UNWANTED SPACE
			**/
SELECT
	LENGTH(TRIM((phone_number))) -- THE SPACE WAS TRIMMED OUT AND ONLY DIGITS WERE LEFT
FROM
	employee;
  
UPDATE employee
SET phone_number = TRIM((phone_number));

-- 3. HONOURING THE EMPLOYEES FRO THEIR WORK
	
	-- HOW MANY EMPLOYEES PER TOWN?
SELECT
	town_name,
    COUNT(town_name)
FROM
	employee
GROUP BY 
	town_name;
		/** 
			MANY OF THE EMPLOYEES LIVE IN THE RURAL PARTS OF MAJI NDOGO (29/56)
		**/

    -- WHO WERE THE TOP THREE EMPLOYEES (DONE MORE VISITS)?
SELECT
	assigned_employee_id,
    COUNT(visit_count) AS number_of_visits
FROM
	visits
GROUP BY
	assigned_employee_id
ORDER BY
	number_of_visits DESC;
    /**
		THE TOP 3 ASSIGNED EMPLOYEE NUMBERS AND THEIR VISIT COUNTS WERE:
        1	3708
		30	3676
		34	3539
	**/
    
    -- LETS FIND OUT WHO THEY ARE (FIRST NAME AND LAST NAME, WITH THEIR POSITIONS)
SELECT
	assigned_employee_id,
    employee_name,
    email,
    phone_number,
    position
FROM
	employee
WHERE
	assigned_employee_id = 1;
    /** 
		FIRST PLACE EMPLOYEE WAS BELLO AZIBO WHO IS A FIELD SURVEYOR WITH 3708 VISITS
    **/
    
    SELECT
	assigned_employee_id,
    employee_name,
	email,
    phone_number,
    position
FROM
	employee
WHERE
	assigned_employee_id = 30;
    /** 
		SECOND PLACE EMPLOYEE WAS PILI ZOLA WHO IS A FIELD SURVEYOR WITH 3676 VISITS
    **/
    
    SELECT
	assigned_employee_id,
    employee_name,
	email,
    phone_number,
    position
FROM
	employee
WHERE
	assigned_employee_id = 34;
    /** 
		THRIRD PLACE EMPLOYEE WAS RUDO IMANI WHO IS A FIELD SURVEYOR WITH 3539 VISITS
    **/
        
-- 4. ANALYZING THE LOCATIONS
SELECT
	* 
FROM
	location;
    
    -- WHAT IS THE WATER SOURCE RECORD PER TOWN?
SELECT
	town_name,
    COUNT(town_name) AS records_per_town
FROM
	location
GROUP BY
	town_name
ORDER BY
	records_per_town DESC;
	/**
		THE RURAL PARTS OF MAJI NDOGO SEEM TO HAVE THE MOST WATER SOURCES
        BY A HUGE MARGIN COMPARED TO THE OTHER TOWNS
    **/
    
    -- WHAT IS THE WATER SOURCE RECORD PER PROVINCE?
SELECT
	province_name,
    COUNT(province_name) AS records_per_province
FROM
	location
GROUP BY
	province_name
ORDER BY
	records_per_province DESC;
	/**
		MOST OF THEM HAVE SIMILAR NUMBER OF WATER SOURCES,
        MEANING THE PROVINCES ARE REPRSENTED IN THE SURVEY.
    **/
    
    -- WHAT ARE THE RECORDS OF WATER SOURCES IF SEPERATED BY BOTH TOWNS AND PROVINCES?
SELECT
	province_name,
    town_name,
    COUNT(town_name) AS record_per_town
FROM
	location
GROUP BY
	province_name,
    town_name
ORDER BY
	province_name,
	record_per_town DESC;
		/**
			ALL THE RURAL PARTS OF THE % PROVINCES WERE DOMINANT IN TERMS OF WATER SOURCES<
            MEANING MOST OF THE WORK WAS DONE IN THE RURAL PARTS OF MAJI NDOGO
		**/
        
	-- WHAT ARE THE RECORDS PER LOCATION TYPE (RURAL & URBAM)?
SELECT
	location_type,
    COUNT(location_type)
FROM
	location
GROUP BY
	location_type;
    
    SELECT 
		ROUND(23740 /(23749 + 15910) * 100,0);
		/** 
			THIS FURTHER SOLIDIFIES THAT MOST OF THE WATER SOURCES SURVEYED
            WERE WITHIN THE RURAL PARTS OF MAJI NDOGO (60%)
		**/
        
-- 5. ANALYZING THE PEOPLE AND WATER SOURCES
SELECT
	*
FROM
water_source;

	-- HOW MANY PEOPLE WERE SURVEYED?
SELECT
	SUM(number_of_people_served)
FROM
	water_source;
    /** 
		27628140 (27.6M) PEOPLE WERE SURVEYED
	**/

	-- WHAT IS THE COUNT OF EACH WATER SOURCE IN MAJI NDOGO?
SELECT
	type_of_water_source,
    COUNT(type_of_water_source) AS water_source_type_count
FROM
	water_source
GROUP BY
	type_of_water_source;
    /** 
		tap_in_home      	7265
		tap_in_home_broken	5856
		well	            17383
		shared_tap	        5767
		river	            3379
	**/
    -- HOW MANY PEOPLE ARE GETTING WATER FROM EACH WATER TYPE?
SELECT
	type_of_water_source,
	SUM(number_of_people_served) AS people_served_per_water_source
FROM
	water_source
GROUP BY
	type_of_water_source;
	/**
		tap_in_home	        4678880  (~ 5M)
		tap_in_home_broken	3799720	 (~ 4M)
		well	            4841724  (~ 5M)
		shared_tap      	11945272 (~ 12M)
		river				2362544  (~ 2M)
	**/
	-- PUT IT ALL IN PERCENTAGES FOR BETTER INTERPRETATION
SELECT
	type_of_water_source,
	ROUND(SUM(number_of_people_served)/ (27628140) * 100) AS people_served_per_water_source
FROM
	water_source
GROUP BY
	type_of_water_source;
    /**
		tap_in_home	        17%
		tap_in_home_broken	14%
		well	            18%
		shared_tap	        43%
		river	            9%
        
        43% OF OUR PEOPLE ARE USING SHARED TAPS IN THEIR COMMUNITIES, AND ON AVERAGE, WE SAW EARLIER, THAT 2000 PEOPLE SHARE ONE SHARED_TAP.
        BY ADDING TAP_IN_HOME AND TAP_IN_HOME_BROKEN TOGETHER, WE SEE THAT 31% OF PEOPLE HAVE WATER INFRASTRUCTURE INSTALLED IN THEIR HOMES, BUT 45%
		(14/31) OF THESE TAPS ARE NOT WORKING! THIS ISN'T THE TAP ITSELF THAT IS BROKEN, BUT RATHER THE INFRASTRUCTURE LIKE TREATMENT PLANTS, RESERVOIRS, PIPES, AND
		PUMPS THAT SERVE THESE HOMES THAT ARE BROKEN.
		18% OF PEOPLE ARE USING WELLS. BUT ONLY 4916 OUT OF 17383 ARE CLEAN = 28% FROM PREVIOUS DATA
	**/
    
    -- WHAT IS THE AVERAGE OIF PEOPLE SHARING A WATER SOURCE?
SELECT
	type_of_water_source,
    ROUND(
		AVG(number_of_people_served))
FROM
	water_source
GROUP BY
	type_of_water_source;
	/**
		tap_in_home      	644 -- THIS ONE DOESN'T MAKE SENSE AS APPROXIMATELY 6 PEOPLE SHARE A TAP AT HOME ON AVERAGE.
								   THE SURVEYORS COMBINED MULTIPLE HOMES IN 1 TAP_IN_HOME, IN THIS CASE (644/6 = +-100 TAPS).
		tap_in_hom0e_broken	649
		well	            279
		shared_tap	        2071
		river	            699
	**/

-- 6. START OF SOLUTIONS!!

	-- RANK WATER SOURCES BY POPULATION SERVED.
SELECT
	type_of_water_source,
	SUM(number_of_people_served) AS people_served_per_water_source,
    RANK() OVER(
		ORDER BY SUM(number_of_people_served) DESC) AS rank_by_position
FROM
	water_source
GROUP BY
	type_of_water_source;
	
    -- RANKING WATER SOURCES
SELECT
	source_id,
    type_of_water_source,
    number_of_people_served,
    RANK() OVER(
		PARTITION BY 
			type_of_water_source
        ORDER BY 
			number_of_people_served DESC
        ) AS rank_priority
FROM
	water_source
WHERE
	type_of_water_source != 'tap_in_home';
    
-- 7. ANALYSING QUEUES
SELECT 
	*
FROM	
	visits
ORDER BY
	time_of_record;
    
	-- HOW LONG DID THE OVERALL SURVEY TAKE?
SELECT
	CONCAT(
		ROUND(
			DATEDIFF('2023-07-14', '2021-01-01')/365,1), + ' years')
		AS survey_duration;
        /** 
			THE SURVEY TOOK ABOUT 924 DAYS WHICH IS YEARS 2 YEARS AND 5 MONTHS.
		**/
        
	-- WHAT IS THE TOTAL QUEUE TIME AVERAGE FOR WATER
SELECT
	ROUND(
		AVG(NULLIF(time_in_queue, 0))) AS average_queue_time_for_water
FROM
	visits;
    /**
		ON AVERAGE, THE TIME SPENT ON A QUEUE FOR WATER FOR EVERYONE IS 123 MINUTES (~ 2 HOURS) BY
        THOSE WITH NO TAPS AT THEIR HOMES. THAT IS VERY CONCERNING BECAUSE ON TOP OF THAT IS THE
        TIME SPENT ON TRAVELLING TO GET WATER.
	**/
    
    -- WHAT IS THE AVERAGE QUEUE TIMES IN DIFFERENT DATES?
SELECT
	DAYNAME(time_of_record) AS weekdays,
    ROUND(
		AVG(NULLIF(time_in_queue, 0))) AS average_queue_time_for_water
FROM
	visits
GROUP BY
	weekdays
ORDER BY
	average_queue_time_for_water DESC;
    /** 
		IT SEEMS PEOPLE ARE QUEING MORE ON SATURDAY AND MONDAY, THIS TALKS MUCH ABOUT THEIR 
        AVAILABILITY ON SATURDAYS AND THEIR PREPARATIONS FOR SCHOOL AND WORK ON MONDAYS. 
        THEY QUEUE LESS ON SUNDAYS AS THEY MAY BE RELAXING OR AT CHURCH CONSIDERING MOST ARE CHRISTIANS.
	**/
    
	-- WHAT IS THE TIME OF THE DAY PEOPLE COLLECT WATER?
SELECT
	TIME_FORMAT(
		TIME(time_of_record), ' %H:00' ) AS weekdays,
    ROUND(
		AVG(NULLIF(time_in_queue, 0))) AS average_queue_time_for_water
FROM
	visits
GROUP BY
	weekdays
ORDER BY
	average_queue_time_for_water DESC;
    /**
		EVENINGS AND MONINGS ARE THE MOST BUSIESTS, THIS THEN MEANS PEOPLE COLLECT WATER 
        BEFORE AND AFTER WORK. THE EVENINGS ARE CONCERNING AS CRIMERATES COULD BE A CHALLENGE
        ESPECIALLY ASSAULTS AND THEFT BACK AT HOME WHILST THEY ARE OUT TO COLLECT WATER
	**/
    
SELECT
	DAYNAME(time_of_record) AS weekdays,
	TIME_FORMAT(
		TIME(time_of_record), ' %H:00' ) AS hour_of_the_day,
    ROUND(
		AVG(NULLIF(time_in_queue, 0))) AS average_queue_time_for_water
FROM
	visits
GROUP BY
	weekdays,
	hour_of_the_day
ORDER BY
	average_queue_time_for_water DESC;
    
    -- ALTERNATIVE WAY TO SHOW THE DATA (PIVOTING)
SELECT
TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
-- Sunday
ROUND(AVG(
	CASE
		WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
		ELSE NULL
		END
		),0) AS Sunday,
-- Monday
ROUND(AVG(
	CASE
		WHEN DAYNAME(time_of_record) = 'Monday' THEN time_in_queue
		ELSE NULL
		END
		),0) AS Monday,
-- Tuesday
ROUND(AVG(
	CASE
		WHEN DAYNAME(time_of_record) = 'Tuesday' THEN time_in_queue
		ELSE NULL
		END
		),0) AS Tuesday,
-- Wednesday
ROUND(AVG(
	CASE
		WHEN DAYNAME(time_of_record) = 'Wednesday' THEN time_in_queue
		ELSE NULL
		END
		),0) AS Wednesday,
 -- Thursday
ROUND(AVG(
	CASE
		WHEN DAYNAME(time_of_record) = 'Thursday' THEN time_in_queue
		ELSE NULL
		END
		),0) AS Thursday,
 -- Firday
ROUND(AVG(
	CASE
		WHEN DAYNAME(time_of_record) = 'Friday' THEN time_in_queue
		ELSE NULL
		END	
		),0) AS Friday,
 -- Saturday
ROUND(AVG(
	CASE
		WHEN DAYNAME(time_of_record) = 'Saturday' THEN time_in_queue
		ELSE NULL
		END
		),0) AS Saturday
FROM
	visits
WHERE
	time_in_queue != 0 -- this excludes other sources with 0 queue times
GROUP BY
	hour_of_day
ORDER BY
	hour_of_day;
    

-- CONCLUSIONS
/**
	1. QUEUES ARE VERY LONG ON A MONDAY MORNING AND MONDAY EVENING AS PEOPLE RUSH TO GET WATER.
	2. WEDNESDAY HAS THE LOWEST QUEUE TIMES, BUT LONG QUEUES ON WEDNESDAY EVENING.
	3. PEOPLE HAVE TO QUEUE PRETTY MUCH TWICE AS LONG ON SATURDAYS COMPARED TO THE WEEKDAYS. IT LOOKS LIKE PEOPLE SPEND THEIR SATURDAYS QUEUEING
	FOR WATER, PERHAPS FOR THE WEEK'S SUPPLY?
	4. THE SHORTEST QUEUES ARE ON SUNDAYS, AND THIS IS A CULTURAL THING. THE PEOPLE OF MAJI NDOGO PRIORITISE FAMILY AND RELIGION, SO SUNDAYS ARE SPENT
	WITH FAMILY AND FRIENDS.
**/

	