USE md_water_services;
-- 1. UNDERSTANDING THE DATA
SHOW TABLES;
	-- we have 8 7 tables and 1 dictionary.
    
	-- Pull Out Disctionary to understand the data and become familiar with it
SELECT 
	*
FROM
	data_dictionary;
    
    -- Pull every table to understand what data it contains, LIMITED TO 10 ROWS
SELECT
	*
FROM
	employee
LIMIT 10;

SELECT
	*
FROM
	global_water_access
LIMIT 10;

    
SELECT
	*
FROM
	location
LIMIT 10;


SELECT
	*
FROM
	visits
LIMIT 10;

    
SELECT
	*
FROM
	water_quality
LIMIT 10;

    
SELECT
	*
FROM
	water_source
LIMIT 10;

    
SELECT
	*
FROM
	well_pollution
LIMIT 10;

-- 2. INVESTIGATING THE QUEUE TIMES IN MAJI NDOGO'S WATER SOURCES.

	-- LOOKING AT THE UNIQUE TYPES OF WATER SOURCES WE'RE DEALING WITH
SELECT
	DISTINCT 
		type_of_water_source
FROM 
	water_source;
    
    -- WHAT IS THE OVERALL AVERAGE QUEUE TIME TIMES IN MAJI NDOGO'S WATER SOURCES? ROUNDED OFF TO 2 DECIMALS
SELECT
	ROUND(AVG(time_in_queue), 2) AS Average_time
FROM 
	visits;
		/**
		   The average queue time 60.75 minutes (~ 1 hour)
		**/

	-- WHAT IS THE AVERAGE QUEUE TIME SPENT ON THE WATER SOURCES? ROUNDED OFF TO 0 decimals.
SELECT
	type_of_water_source,
    ROUND(AVG(time_in_queue), 0) AS time_in_queue
FROM
	visits vs
		JOIN
    water_source ws 
		ON
        vs.source_id = ws.source_id
GROUP BY	
	type_of_water_source;
			/**
            tap_in_home	= 0
			tap_in_home_broken = 0
			well = 0
			shared_tap = 137
			river =	17
            **/
    
    -- WHAT IS THE QUEUE TIMES OF OVER AN HOUR FOR WATER IN IN MAJI NDOGO?
SELECT
	DISTINCT(time_in_queue)
FROM 
	visits
ORDER BY
	time_in_queue DESC
LIMIT 10;
		/**
				1. 539
				2. 538
				3. 537
				4. 535
				5. 534
				6. 533
				7. 532
				8. 531
				9. 530
				10. 529
			**/

	-- WHAT IS THE TYPE OF WATER SOURCE(S) THAT HAVE NO QUEUE TIME?
SELECT DISTINCT
    type_of_water_source
FROM
    visits vs
        JOIN
    water_source ws ON vs.source_id = ws.source_id
WHERE
    time_in_queue = 0;
		/**We have the wells, 
        tap_in_home_broken,
        and tap_in_home,
        therefore we have queues only on the shared taps and rivers**/
	
	-- WHAT IS THE MAXIMUM TIME SPENT ON A SHARED TAP WATER TYPE"?
SELECT
	type_of_water_source,
    MAX(time_in_queue) AS time_in_queue
FROM
	visits vs
	JOIN
    water_source ws
		ON
        vs.source_id = ws.source_id
WHERE
	type_of_water_source = 'shared_tap';
		-- The maximum queue time spent on share taps was ~ 8 hours (539 Min) (Appaling!!)
        
	-- WHAT IS THE MAXIMUM TIME SPENT ON A RIVER WATER TYPE ?
SELECT
	type_of_water_source,
    MAX(time_in_queue) AS time_in_queue
FROM

	visits vs
	JOIN
    water_source ws
		ON
        vs.source_id = ws.source_id
WHERE
	type_of_water_source = 'river';
		-- The maximum queue time spect on river source was ~ 30 minutes (29 Min).

-- 3. INVESTIGATING THE WATER QUALITY OF WATER SOURCES IN MAJI NDOGO
	-- HOW MANY SCOURCES WERE INVESTIGATED?
SELECT
	COUNT(subjective_quality_score)
FROM
	water_quality;
		/** 
			60146 water sources were investigated
		**/ 

	-- WHAT IS THE AVERAGE SUBJECTIVE QUALITY SCORE OF THE WATER SOURCES ? ROUNDED OFF TO 2 DECIMALS
SELECT 
	ROUND(AVG(subjective_quality_score), 2)
FROM
	water_quality;
		/**               
			The average ssubjective quality score of the water sources is 4.62 (~5).
            This indicates that even though there is high queue times in the Maji Ndogo 
            water sources, the quality of the water is poor (marginal).
		**/
    
    -- HOW MANY WATER SOURCES HAVE WATER QUALITY THAT IS BELOW AVERAGE (4.62)? ROUNDED TO 0 DECIMALS.
SELECT 
	COUNT(subjective_quality_score) AS no_of_poor_quality_sources
FROM
	water_quality
WHERE 
	subjective_quality_score < (SELECT 
									ROUND(AVG(subjective_quality_score), 2)
								FROM
									water_quality);
		/** There was 38038 water sources which have a very poor subjective water quality score.**/
        
SELECT
	ROUND((38038 / 60146) * 100) AS pct_of_poor_quality_sources;
			
		/** 
			63% of the water sources have a poor quality of water, this then means there should be 
			further investigations on whatt may be causing that, such as contaminations and pollutions. 
			Luckily the surveyors managed to identify and classify the polution factors
		**/
    
	-- WHICH WATER SOURCE WAS VISITED MORE THAN ONCE?
SELECT
	DISTINCT(type_of_water_source),
    visit_count
FROM
	water_source ws
		JOIN
	visits vs
		ON
        ws.source_id = vs.source_id
WHERE 
	visit_count > 1;
		/** 
			SHARED TAPS were the only ones visited more than once, 
            this may be due to the high demand, lenthy queue times, and poor water quality. 
            The surveyors for sure could'nt only investigate and conclude on the first go.
		**/

-- 4. INVESTIGATING THE POLLUTION ISSUES OF THE WELL WATER SOURCES
	-- VIEW WELL POLLUTION TABLE
SELECT
	*
FROM
	well_pollution;
    
    -- WHAT ARE TYPES OF CONTAMINATIONS
SELECT
	DISTINCT(results)
FROM
	well_pollution
WHERE
	results LIKE "%contamin%";
		/**
			Contaminated: Biological
			Contaminated: Chemical
		**/
	
    -- WHAT IS THE INTEGRITY OF THE CLEAN SOURCES
SELECT
	biological,
    results
FROM
	well_pollution
WHERE
	results = "clean"
		AND
    biological > 0.01
ORDER BY
	biological DESC;
		/**
			64 well sources are classified as clean whilst their biological contamination
            is greater than 0.01 cfu/ml which is the maximum measure of biological contamination
            safe to drink. There seem to have been a mistake during the audit of the data, it needs to be investigated.
            The max biological contamination classified as clean is 49.5964 cfu/ml (~50) 
		**/
        
	-- WHAT ARE THE TYPES OF BIOLOGICAL CONATMINATIONS?
SELECT
	DISTINCT(description)
FROM
	well_pollution
WHERE 
	biological > 0.01;
    
			/**
				Bacteria: Giardia Lamblia
				Bacteria: E. coli
				Parasite: Cryptosporidium
				Bacteria: Vibrio cholerae
				Virus: Hepatitis A Virus
				Bacteria: Shigella
				Virus: Enteroviruses
				Bacteria: Salmonella
			  " Clean Bacteria: Giardia Lamblia "
			  " Clean Bacteria: E. coli "
				Bacteria: Salmonella Typhi
                
                As we can see there are some contaminations that have clean in them,
                those need to be rectified
			**/
    
	-- WHAT IS THE CONTAMINATION WITH THE HIGHEST CFU/mL?
SELECT	
	source_id,
    description,
	biological,
    results
FROM
	well_pollution
ORDER BY
	biological DESC
LIMIT 1;
		/**
			The bacteria Giarda Lamblia has the highest cfu/ml which means this
            was the most polluted well and it was very dangerous to collect water from
		**/

	-- HOW OFTEN WAS WAS EACH CONTAMINATION RECORDED?
SELECT
	description,
	COUNT(description) AS no_of_occurences
FROM
	well_pollution	
WHERE
	description <> "clean"
GROUP BY
	description
ORDER BY
	COUNT(description) DESC;
    
-- 5. FIXING THE 3 MISTAKES OF THE TABLE
		/** Clean Bacteria: E. Coli
		    Clean Bacteria: Gardia Lamblia
            cfu/ml > 0.01 described as clean.
		**/

		-- CREATING A COPY OF WELL POLLUTION FOR THE FIXES
CREATE TABLE 
	well_pollution_copy
AS 
	(SELECT 
			*
	 FROM
			well_pollution);
            
		-- VIEW TABLE CREATED
SELECT
	*
FROM
	well_pollution_copy;
    
		-- CHANGE CLEAN BACTERIA: E. COLI TO BACTERIA: E. COLI
UPDATE
	well_pollution_copy
SET
	description = "Bacteria: E. Coli"
WHERE
	description = "Clean Bacteria: E. Coli";
    
    -- CHANGE CLEAN BACTERIA: GARDIA LAMBLIA TO BACTERIA: GARDIA LAMBLIA
UPDATE
	well_pollution_copy
SET
	description = "Bacteria: Giardia Lamblia"
WHERE
	description = "Clean Bacteria: Giardia Lamblia";
	
    -- UPDATE CLEAN TO BIOLOGICALLY CONTAMINATED IF cfu/mL > 0.01
UPDATE
	well_pollution_copy
SET
	results = "Contaminated: Biological"
WHERE
	biological > 0.01;
    
    -- RECHECKING THE INTEGRITY OF THE CLEAN SOURCES
SELECT
	*
FROM
	well_pollution_copy
WHERE
	description 
		LIKE 
			"%Clean_%"
		OR 
			(results = "Clean" AND biological > 0.01)
;
		/** There is zero results meaning the mistakes have been fixed **/
        
	"THE END"
                                    