USE md_water_services;
-- IMPORTING AN AUDITOR'S REPORT TABLE TO VALIDATE THE INITIAL DATASET.
	/**
		AN AUDIT REPORT TABLE WAS IMPORTED INTO THE DAYABASE. IN THIS SPECIFIC AUDIT, THE OBJECTIVE WAS TO ASSESS THE INTEGRITY,
		AND ACCURACY OF THE DATA STORED IN THE DATABASE. AUDITING A DATABASE INVOLVES VERIFYING THAT THE DATA IT CONTAINS IS BOTH 
		ACCURATE AND HAS NOT BEEN TAMPERED WITH, THEREBY ENSURING THAT THE INFORMATION CAN BE RELIED UPON FOR DECISION-MAKING AND GOVERNANCE.
	**/


-- 1. A DIVE INTO AUDITOR'S REPORT TABLE
SELECT
	*
FROM
	auditor_report;
	/**
		THE TABLE HAS THE SAME type_of_water_source, location_id.
        WHAT IS DIFFERENT IS THE true_water_source_score and statemenrs BY 
        LOCAL MEMBERS OF THE COMMUNITY
	**/

-- 2. CREATING AN ENTITY RELATIONSHIP (ERD) WITH THE DATASET
		-- CTRL+R (CLICK NEXT, THEN CHOOSE ACTIVE SCHEMA AND NEXT AGAIN UNTIL FINISH)
        -- IT ATTACHED ON THE PROJECT FOLDER
        /**
			THE RELATIONSHIPS ARE MOSTLY ONE-TO-MANY RELATIONSHIP WHICH ARE GOOD, 
            BUT THERE WAS A MANY-TO-ONE WITH THE record_id ALTHOUGH THEY SHOULD BE A ONE-TO-ONE
            RELASHIONSHIP. SO TO FIX THAT I:
            1. RIGHT-CLICK ON THE RELATIONSHIP LINE
            2. EDIT RELATIONSHIP
            3. SELECTED FOREIGN KEY TAB
            4. CHANGED THE CARDINALITY TO ONE-TO-ONE FROM MANY-TO-ONE.
		**/
            
-- 3. IS THERE A DIFFERENCE IN THE QUALITY SCORES?
	-- WE HAVE TO COMPARE AUDITOR'S REPORT AND THE WATER QUALITY BUT THEY HAVE DIFFERENT COLUMNS FOR THE TO JOIN DIRECTLY
    -- SO WE WILL FIND A TABLE THAT WILL SERVE AS A BRIDGE TO JOIN THEM SO THEY CAN BE QUERIED.
    
    -- JOIN AUDITOR REPORT AND VISITS TABLE ON LOCATION ID AND FETCH LOCATION ID & TRUE WATER QUALITY SCORE ON AUDITOR REPORT
SELECT 
	ar.location_id,
    ar.true_water_source_score
FROM
	auditor_report ar
		JOIN
    visits vs
		ON
	ar.location_id = vs.location_id;
    
    -- JOIN WATER QUALITY TABLE WITH VISITS ON RECORD ID AND FETCH WATER QUALITY SCORE ON WATER QUALITY
SELECT
	wq.subjective_quality_score
FROM
	water_quality wq
		JOIN
	visits vs
		ON
        wq.record_id = vs.record_id;
    
   -- NOW JOIN THESE JOINTS SUCH THAT THE AUDITOR REPORT AND WATER QUALITY DISPLAY ON SAME TABLE WITH VISITS AS THE BIDGE
SELECT 
	ar.location_id,
    ar.true_water_source_score,
    vw.subjective_quality_score
FROM
	auditor_report ar
		JOIN
    (SELECT
		vs.location_id,
		wq.subjective_quality_score,
        vs.visit_count
	FROM
		water_quality wq
		JOIN
		visits vs
		ON
			wq.record_id = vs.record_id) AS vw
			ON
	ar.location_id = vw.location_id
WHERE 
	vw.visit_count = 1	-- THIS IS TO REMOVE ANY DUPLICATES AS INITIALLY WE FOUND 2505 RESULTS INSTEAD OF 1620 RESULTS MATCHING TO THE AUDITOR REPORT RECORD (1620)
    AND
    ar.true_water_source_score = vw.subjective_quality_score; -- THIS IS TO MATCH BOTH SCORES AND SEE HOW MANY ARE MATCHING AND ARE CONSIDERED CORRECT
    /**
		OUUT OF 1620 RECORD, WE FOUND THAT 1518 RESULTS ARE INDEED ACCURATE,
        THAT MEANS OVERALL THE INITIAL SURVEY IS RELIABLE AS IT WAS ACCURATE BY
        1518/1620 = 94% .
        BUT THAT ALSO MEANS THAT THERE WAS A 6% NOTICEABLE ERROR FOUND,
        AND BECAUSE THIS MAY HIGHLY AFFECT PEOPLE'S HEALTH. THE INCORRECT 
        RECORD WILL BE INVESTIGATED FURTHER.
	**/
    
    -- 4. INVESTIGATE INCORRECT SCORES AND PEOPLE INCLUDED.
    
    -- FETCHING THE UNMATCHING WATER QUALITY SCORES
SELECT 
	ar.location_id,
    ar.true_water_source_score,
    vw.subjective_quality_score
FROM
	auditor_report ar
		JOIN
    (SELECT
		vs.location_id,
		wq.subjective_quality_score,
        vs.visit_count
	FROM
		water_quality wq
		JOIN
		visits vs
		ON
			wq.record_id = vs.record_id) AS vw
			ON
	ar.location_id = vw.location_id
WHERE 
	vw.visit_count = 1	
    AND
    ar.true_water_source_score != vw.subjective_quality_score;
    /**
		102 RECORDS SEEM TO BE FAKE AND IT SEEMS THAT INITIALLY ALL OF THEM 
        WERE SAID TO HAVE A SCORE OF 10 AND COMPARED TO THE SECOND RECORDS THEY
        SHOWCASE A HIGH RISK TO CONSUMERS OF THE WATER. THE 10s ARE VERY SUSPICIOUS, 
        THIS MAY MEAN THERE HAVE BEEN A HAND THAT PLAYED OTHERWISE OR A MISTAKE.
        LET'S INVESTIGATE!!!
	**/
    
    -- FETCH THE WATER SOURCE TYPE FROM THE AUDITOR TO SEE WHICH WATER SOURCE TYPE WAS INCORRECTLY SCORED
SELECT 
	ar.location_id,
    ar.type_of_water_source,
    ar.true_water_source_score,
    vw.subjective_quality_score
FROM
	auditor_report ar
		JOIN
    (SELECT
		vs.location_id,
		wq.subjective_quality_score,
        vs.visit_count
	FROM
		water_quality wq
		JOIN
		visits vs
		ON
			wq.record_id = vs.record_id) AS vw
			ON
	ar.location_id = vw.location_id
WHERE 
	vw.visit_count = 1	
    AND
    ar.true_water_source_score != vw.subjective_quality_score;

-- LLETS JOIN THE VISITS TABLE WITH EMPLOYYE TABLE SO FETCH EMPLOYEE DATA AND SEE WHO IS ASSOCIATED TO THE ERRORS AND FETCH EMPLOYEE NAME
SELECT
	em.employee_name
FROM
	employee em
		JOIN
	visits vs
		ON 
        em.assigned_employee_id = vs.assigned_employee_id;
        
        -- OVERALL JOINT
SELECT 
	ar.location_id,
    vw.employee_name,
    ar.type_of_water_source,
    ar.true_water_source_score,
    vw.subjective_quality_score
FROM
	auditor_report ar
		JOIN
    (SELECT
		vem.location_id,
		wq.subjective_quality_score,
        vem.visit_count,
        vem.employee_name
	FROM
		water_quality wq
		JOIN
		(SELECT
			em.employee_name,
            vs.record_id,
            vs.location_id,
            vs.visit_count
		FROM
			employee em
				JOIN
			visits vs
				ON 
				em.assigned_employee_id = vs.assigned_employee_id) vem
			ON
			wq.record_id = vem.record_id) AS vw
			ON
	ar.location_id = vw.location_id
WHERE 
	vw.visit_count = 1	
    AND
    ar.true_water_source_score != vw.subjective_quality_score;
        
	-- 5. THE QUERY HAS BECOME MORE LARGE AND COMPLEX, A CTE (COMMON TABLE EXPRESSION) WILL BE BEST FOR FURTHER ANALYSIS
    
    -- CREATE A CTE FOR THE INCORRECT DATA
WITH 
	incorrect_records 
AS(
	SELECT 
	ar.location_id,
    vw.employee_name,
    ar.type_of_water_source,
    ar.true_water_source_score,
    vw.subjective_quality_score
FROM
	auditor_report ar
		JOIN
    (SELECT
		vem.location_id,
		wq.subjective_quality_score,
        vem.visit_count,
        vem.employee_name
	FROM
		water_quality wq
		JOIN
		(SELECT
			em.employee_name,
            vs.record_id,
            vs.location_id,
            vs.visit_count
		FROM
			employee em
				JOIN
			visits vs
				ON 
				em.assigned_employee_id = vs.assigned_employee_id) vem
			ON
			wq.record_id = vem.record_id) AS vw
			ON
	ar.location_id = vw.location_id
WHERE 
	vw.visit_count = 1	
    AND
    ar.true_water_source_score != vw.subjective_quality_score)
   
   	-- OVERVIEW OF CTE (102 RECORDS)
/**
	SELECT
		*
	FROM
		incorrect_records 
**/

	-- HOW MANY TIMES WERE THE WATER FALLS INCORRECTLY SCORED INDIVIDUALLY
/**
	SELECT
		type_of_water_source,
		COUNT(type_of_water_source) AS number_of_incorrect_scores
	FROM
		incorrect_records
	GROUP BY
		type_of_water_source
			
well            	49
shared_tap	        18
tap_in_home_broken	25
river	            10
			-- WELLS WERE THE MOST INCORRECTLY SCORED AT 49
**/

	-- WHO MADE THE MOST MISTAKES

	SELECT
		employee_name,
		COUNT(employee_name) AS number_of_mistakes
	FROM
		incorrect_records
	GROUP BY
		employee_name
	ORDER BY 
		number_of_mistakes DESC; 
    
    -- 17 EMPLOYEES MADE MISTAKES AND OUT OF THEM THERE ARE OUTLIERS WHICH ARE:
	Bello Azibo	    26
	Malachi Mavuso	21
	Zuriel Matembo	17;
    
	-- FINDING OUT WHO MADE MISTAKES THAT ARE ABOVE AVERAGE, WHICH MAY LEAD TO POSSIBLE CORRUPTION
    
-- 5. INVESTIGATING AND GATHERING EVIDENCE

	-- CREATE A VIEW TO ERFORM ADvANCED ANALYSIS AND ADD COMMUNITY STATEMENTS FROM AUDITOR REPORT
CREATE VIEW 
	incorrect_records 
AS(
	SELECT 
	ar.location_id,
    vw.employee_name,
    ar.type_of_water_source AS source_type,
    ar.true_water_source_score AS auditor_score,
    vw.subjective_quality_score AS survey_score,
    ar.statements
FROM
	auditor_report ar
		JOIN
    (SELECT
		vem.location_id,
		wq.subjective_quality_score,
        vem.visit_count,
        vem.employee_name
	FROM
		water_quality wq
		JOIN
		(SELECT
			em.employee_name,
            vs.record_id,
            vs.location_id,
            vs.visit_count
		FROM
			employee em
				JOIN
			visits vs
				ON 
				em.assigned_employee_id = vs.assigned_employee_id) vem
			ON
			wq.record_id = vem.record_id) AS vw
			ON
	ar.location_id = vw.location_id
WHERE 
	vw.visit_count = 1	
    AND
    ar.true_water_source_score != vw.subjective_quality_score);
    
	-- OVERVIEW OF VIEW CREATED
SELECT
	*
FROM
	incorrect_records; -- IT WORKED
    
    -- CREATE A CTE FOR ERROR COUNT (MISTAKES) AND CALCULATE AVERAGE O MISTAKES
WITH 
	error_count
AS(
    SELECT
		employee_name,
		COUNT(employee_name) AS number_of_mistakes
	FROM
		incorrect_records
	GROUP BY
		employee_name
	ORDER BY 
		number_of_mistakes DESC)

/**	
    -- WHATS THE AVERAGE OF MISTAKES
SELECT
	AVG(number_of_mistakes)
FROM
	error_count; -- THE AVERAGE FOR MISTAKES IS 6.
**/

	-- WHO HAS MISTAKES ABOVE AVERAGE
SELECT
	*
FROM
	error_count
WHERE
	number_of_mistakes > (SELECT
							  AVG(number_of_mistakes)
						  FROM
							  error_count);
/**
	Bello Azibo  	26
	Malachi Mavuso	21
	Zuriel Matembo	17
	Lalitha Kaburi	7
    
    THESE ARE THE ONES WITH MISTAKES ABOVE AVERAGE AND MAY BE LINKED TO CORRUPTION
    SO THE COMMUNITY STATEMENTS FROM THE AUDITOR WILL ASSIST US TO VERIFY THAT.
**/

	-- FETCHING COMMUNITY STAEMENTS ABOUT THE 4 SUSPECTS
WITH 
	error_count
AS(
    SELECT
		employee_name,
		COUNT(employee_name) AS number_of_mistakes
	FROM
		incorrect_records
	GROUP BY
		employee_name
	ORDER BY 
		number_of_mistakes DESC),
	suspect_list
AS(
	SELECT
		*
	FROM
		error_count
	WHERE
		number_of_mistakes > (SELECT
								  AVG(number_of_mistakes)
							  FROM
								  error_count))
							
SELECT
	employee_name,
    statements
FROM
	incorrect_records
WHERE
	employee_name IN (
					SELECT
						employee_name
					FROM
						suspect_list)
;

	-- INVESTIGATING THOSE WHO MAY HAVE BEEN INVOLVED IN CASH (MONEY) MENTIONS WHICH INDICATES CORRUPTION
WITH 
	error_count
AS(
    SELECT
		employee_name,
		COUNT(employee_name) AS number_of_mistakes
	FROM
		incorrect_records
	GROUP BY
		employee_name
	ORDER BY 
		number_of_mistakes DESC),
	suspect_list
AS(
	SELECT
		*
	FROM
		error_count
	WHERE
		number_of_mistakes > (SELECT
								  AVG(number_of_mistakes)
							  FROM
								  error_count))
							
SELECT
	employee_name,
    statements
FROM
	incorrect_records
WHERE
	employee_name IN (
					SELECT
						employee_name
					FROM
						suspect_list)
		AND
        statements LIKE '%cash%'; -- FILTERS THE STATEMENTS WHICH INCLUDES CASH
	/** 
		IT SEEMS ALL THE 4 SUSPECTS HAVE BEEN INVOLVED IN CASH MENTIONS STATEMENTS WHICH MEANS
        THEY ARE ALL CORRUPT HENCE THE INCONSISTENCY. STEPS SHOULD BE TAKEN!!
	**/
					
		