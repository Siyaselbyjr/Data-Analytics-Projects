USE md_water_services;
-- START!!
-- 1. LINK WATER SOURCE AND LOCATION TABLES VIA VISITS
	-- LINKING VISITS AND LOCATION TABLES VIA LOCATION ID, FETCH REQUIRED COLUMNS
SELECT
	loc.province_name,
    loc.town_name
FROM
	visits vs
    JOIN
    location loc
    ON vs.location_id = loc.location_id;
    -- LINKING VISITS AND WATER SOUTCE VIA SOURCE ID, FETCH REQUIRED COLUMNS
SELECT
	ws.type_of_water_source,
    ws.number_of_people_served
FROM
	water_source ws
    JOIN
    visits vs
    ON ws.source_id = vs.source_id;
    
		-- JOIN ALL THE TABLES INTO ONE
SELECT
	loc.province_name,
    loc.town_name,
    /**vsws.visit_count,
    vsws.location_id,**/
    vsws.type_of_water_source,
    loc.location_type,
	vsws.number_of_people_served,
    vsws.time_in_queue
FROM
	(SELECT
		ws.type_of_water_source,
		ws.number_of_people_served,
        vs.location_id,
        vs.visit_count,
        vs.time_in_queue
	FROM
		water_source ws
		JOIN
		visits vs
		ON ws.source_id = vs.source_id) vsws
    JOIN
    location loc
    ON vsws.location_id = loc.location_id
WHERE vsws.visit_count = 1;

-- 2. JOIN VISITS & WATER SOURCE AND WELL POPULATION
SELECT 
	vsws.type_of_water_source,
    wp.*
FROM
	(SELECT
		ws.type_of_water_source,
		ws.number_of_people_served,
        vs.location_id,
        vs.visit_count,
        vs.time_in_queue,
        vs.source_id
	FROM
		water_source ws
		INNER JOIN
		visits vs
		ON ws.source_id = vs.source_id) vsws
        LEFT JOIN
    well_pollution wp
    ON vsws.source_id = wp.source_id;
    
    -- 3.FULL JOIN OF THE TABLES
SELECT
	vsws.type_of_water_source,
    loc.town_name,
	loc.province_name,
    /**vsws.visit_count,
    vsws.location_id,**/
    loc.location_type,
	vsws.number_of_people_served,
    vsws.time_in_queue,
    vsws.results
FROM
	(SELECT
		ws.type_of_water_source,
		ws.number_of_people_served,
        vswp.location_id,
        vswp.visit_count,
        vswp.time_in_queue,
        vswp.results
	FROM
		water_source ws
		JOIN
		(SELECT
			vs.location_id,
            vs.visit_count,
            vs.time_in_queue,
            wp.results,
            vs.source_id
		FROM
			visits vs
            LEFT JOIN
            well_pollution wp
            ON wp.source_id = vs.source_id) vswp
		ON ws.source_id = vswp.source_id) vsws
    JOIN
    location loc
    ON vsws.location_id = loc.location_id
WHERE vsws.visit_count = 1;

-- 4. CREATE A VIEW FOR THE OVERALL TABLE
CREATE VIEW combined_analysis_table AS (
	SELECT
	vsws.type_of_water_source,
    loc.town_name,
	loc.province_name,
    /**vsws.visit_count,
    vsws.location_id,**/
    loc.location_type,
	vsws.number_of_people_served,
    vsws.time_in_queue,
    vsws.results
FROM
	(SELECT
		ws.type_of_water_source,
		ws.number_of_people_served,
        vswp.location_id,
        vswp.visit_count,
        vswp.time_in_queue,
        vswp.results
	FROM
		water_source ws
		JOIN
		(SELECT
			vs.location_id,
            vs.visit_count,
            vs.time_in_queue,
            wp.results,
            vs.source_id
		FROM
			visits vs
            LEFT JOIN
            well_pollution wp
            ON wp.source_id = vs.source_id) vswp
		ON ws.source_id = vswp.source_id) vsws
    JOIN
    location loc
    ON vsws.location_id = loc.location_id
WHERE vsws.visit_count = 1);

-- 5. OVERVIEW OF VIEW
SELECT
	*
FROM
	combined_analysis_table;

-- 6. CALCULATE THE NUMBER OF PROPLE PER PROVINCE
SELECT
	province_name,
    SUM(number_of_people_served)
FROM
	combined_analysis_table
GROUP BY
	province_name;
    
-- 7. CREATE CTE OF THE SUMS
WITH province_totals AS (
	SELECT
		province_name,
        town_name,
		SUM(number_of_people_served) AS total_people_served
	FROM
		combined_analysis_table
	GROUP BY
		province_name,
		town_name
)

SELECT
	pt.province_name,
    pt.town_name,
    ROUND(SUM(CASE WHEN cat.type_of_water_source = 'river'
		THEN number_of_people_served ELSE 0 END *100 / pt.total_people_served), 0) AS river,
	ROUND(SUM(CASE WHEN cat.type_of_water_source = 'shared_tap'
		THEN number_of_people_served ELSE 0 END *100 / pt.total_people_served), 0) AS shared_tap,
    ROUND(SUM(CASE WHEN cat.type_of_water_source = 'tap_in_home'
		THEN number_of_people_served ELSE 0 END *100 / pt.total_people_served), 0) AS tap_in_home,
	ROUND(SUM(CASE WHEN cat.type_of_water_source = 'tap_in_home_broken'
		THEN number_of_people_served ELSE 0 END *100 / pt.total_people_served), 0) AS tap_in_home_broken,
    ROUND(SUM(CASE WHEN cat.type_of_water_source = 'well'
		THEN number_of_people_served ELSE 0 END *100 / pt.total_people_served), 0) AS well
FROM
	province_totals pt
    JOIN
    combined_analysis_table cat
    ON pt.province_name = cat.province_name
    GROUP BY 
		pt.province_name,
		pt.town_name
	ORDER BY 
		1;
        
-- 8. CREATE A VIEW OF THE TABLE
CREATE VIEW province_analysis AS 
(WITH province_totals AS (
	SELECT
		province_name,
        town_name,
		SUM(number_of_people_served) AS total_people_served
	FROM
		combined_analysis_table
	GROUP BY
		province_name,
		town_name
)

SELECT
	pt.province_name,
    pt.town_name,
    ROUND(SUM(CASE WHEN cat.type_of_water_source = 'river'
		THEN number_of_people_served ELSE 0 END *100 / pt.total_people_served), 0) AS river,
	ROUND(SUM(CASE WHEN cat.type_of_water_source = 'shared_tap'
		THEN number_of_people_served ELSE 0 END *100 / pt.total_people_served), 0) AS shared_tap,
    ROUND(SUM(CASE WHEN cat.type_of_water_source = 'tap_in_home'
		THEN number_of_people_served ELSE 0 END *100 / pt.total_people_served), 0) AS tap_in_home,
	ROUND(SUM(CASE WHEN cat.type_of_water_source = 'tap_in_home_broken'
		THEN number_of_people_served ELSE 0 END *100 / pt.total_people_served), 0) AS tap_in_home_broken,
    ROUND(SUM(CASE WHEN cat.type_of_water_source = 'well'
		THEN number_of_people_served ELSE 0 END *100 / pt.total_people_served), 0) AS well
FROM
	province_totals pt
    JOIN
    combined_analysis_table cat
    ON pt.province_name = cat.province_name
    GROUP BY 
		pt.province_name,
		pt.town_name
	ORDER BY 
		1);
        
SELECT 
	*
FROM
	province_analysis;
    
-- 9. CREATE TEMPORARY TABLE 
CREATE TEMPORARY TABLE town_aggregated_water_access
	WITH province_totals AS (
	SELECT
		province_name,
        town_name,
		SUM(number_of_people_served) AS total_people_served
	FROM
		combined_analysis_table
	GROUP BY
		province_name,
		town_name
)

SELECT
	pt.province_name,
    pt.town_name,
    ROUND(SUM(CASE WHEN cat.type_of_water_source = 'river'
		THEN number_of_people_served ELSE 0 END *100 / pt.total_people_served), 0) AS river,
	ROUND(SUM(CASE WHEN cat.type_of_water_source = 'shared_tap'
		THEN number_of_people_served ELSE 0 END *100 / pt.total_people_served), 0) AS shared_tap,
    ROUND(SUM(CASE WHEN cat.type_of_water_source = 'tap_in_home'
		THEN number_of_people_served ELSE 0 END *100 / pt.total_people_served), 0) AS tap_in_home,
	ROUND(SUM(CASE WHEN cat.type_of_water_source = 'tap_in_home_broken'
		THEN number_of_people_served ELSE 0 END *100 / pt.total_people_served), 0) AS tap_in_home_broken,
    ROUND(SUM(CASE WHEN cat.type_of_water_source = 'well'
		THEN number_of_people_served ELSE 0 END *100 / pt.total_people_served), 0) AS well
FROM
	province_totals pt
    JOIN
    combined_analysis_table cat
    ON pt.province_name = cat.province_name
    GROUP BY 
		pt.province_name,
		pt.town_name
	ORDER BY 
		1;
        
-- 10. OVERVIEW OF TEMP TABLE
SELECT
    *
FROM
	town_aggregated_water_access;

-- 11. RATIO OF PEOPLE WITH TAPS NUT NOT RUNNING WATER
SELECT
	province_name,
	town_name,
	ROUND((((tap_in_home_broken) / (tap_in_home + tap_in_home_broken))*100),0) AS pct_broken_taps
FROM 
	town_aggregated_water_access;
    
-- 12. CREATE A TABLE FRO IMPLEMENTATION
DROP TABLE project_progress;
CREATE TABLE Project_progress (
Project_id SERIAL PRIMARY KEY,
source_id VARCHAR(20) NOT NULL REFERENCES water_source(source_id) ON DELETE CASCADE ON UPDATE CASCADE,
Address VARCHAR(50),
Town VARCHAR(30),
Province VARCHAR(30),
Source_type VARCHAR(50),
Source_status VARCHAR(50) DEFAULT 'Backlog' CHECK (Source_status IN ('Backlog', 'In progress', 'Complete')),
Date_of_completion DATE,
Improvement VARCHAR(50),
Comments TEXT
);

 -- OVERVIEW OF CREATED TABLE
SELECT 
	*
FROM
	project_progress;
    
-- 13. INSERT DATA IN CREATED TABLE

INSERT INTO project_progress (source_id, address, town, province, source_type)
SELECT
	vs.source_id,
    loc.address,
    loc.town_name,
    loc.province_name,
    ws.type_of_water_source
FROM
	location loc
JOIN       
	visits vs
    ON vs.location_id = loc.location_id
JOIN
	water_source ws
    ON vs.source_id = ws.source_id
LEFT JOIN
	well_pollution wp
    ON ws.source_id = wp.source_id
    WHERE
		vs.visit_count = 1
        AND
        (wp.results != 'clean'
        OR
        ws.type_of_water_source IN ('tap_in_home_broken', 'river')
        OR
        ws.type_of_water_source = 'shared_tap' AND vs.time_in_queue >=30);
    
    -- OVERVIEW OF INSERTED DATA
    SELECT 
		*
	FROM
		project_progress;
        
-- 14. UPDATE THE IUMPROVEMENTS
WITH implementations AS (
    SELECT
    province,
    town,
    source_type,
    CASE 
    WHEN wp.results = 'Contaminated: Biological'
		THEN 'Install UV and RO Filters'
	WHEN wp.results = 'Contaminated: Chemical'
		THEN 'RO Filters'
	WHEN pg.source_type = 'river'
		THEN 'DrillWell'
	WHEN pg.source_type = 'Shared_tap'
		THEN CONCAT('Install ', FLOOR(pg.time_in_queue/30) , ' taps nearby')
	WHEN pg.source_type = 'tap_in_home_broken'
		THEN 'Diagnose local infrastructure'
        ELSE NULL
        END AS improvements
	FROM
		(SELECT
			vs.time_in_queue,
            vs.source_id,
            p.source_type,
            p.province,
            p.town
			FROM	
			visits vs
			JOIN
			project_progress p
			ON p.source_id = vs.source_id
			WHERE vs.visit_count = 1) pg
        LEFT JOIN
		well_pollution wp
        ON wp.source_id = pg.source_id
        )
        
        
SELECT 
	improvements,
    COUNT(improvements)
FROM
	implementations
GROUP BY
	improvements
;

SELECT
	*
FROM
	well_pollution
;

CREATE VIEW final AS (
SELECT 
	pg.project_id,
    pg.source_id,
    pg.province,
    pg.town,
    pg.source_type,
    imp.improvements
FROM
	implementations imp
	LEFT JOIN
    project_progress pg
    ON imp.source_type = pg.source_type)
;

SELECT	*
FROM final;
