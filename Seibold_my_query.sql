-- In this refactored version, the conditions for applicable sections have been consolidated using an OR operator. This helps simplify the logic and reduce redundancy in the query.
-- This version also enhances the readability and maintainability of the query while keeping the logic intact. 
SELECT DISTINCT
	dp.dir_uid AS username,
	de.mail AS email,
	CASE
		WHEN dp.primaryaffiliation = 'Student' THEN 'Student'
		WHEN dp.primaryaffiliation = 'Staff' OR dp.primaryaffiliation = 'Officer/Professional' THEN 'Faculty/Staff'
		WHEN dp.primaryaffiliation = 'Faculty' THEN 
			CASE
				WHEN daf.edupersonaffiliation = 'Faculty' AND daf.description = 'Student Faculty' THEN 'Student'
			ELSE 'Faculty/Staff'
			END
		WHEN dp.primaryaffiliation = 'Employee' AND daf.edupersonaffiliation = 'Employee' THEN
			CASE 
				WHEN daf.description = 'Student Employee' OR daf.description = 'Student Faculty' THEN 'Student'
			ELSE 'Faculty/Staff'
			END
		WHEN dp.primaryaffiliation = 'Affiliate' AND daf.edupersonaffiliation = 'Affiliate' AND (daf.description = 'Student Employee' OR daf.description = 'Continuing Ed Non-Credit Student') THEN 'Student'
		WHEN dp.primaryaffiliation = 'Member' AND daf.edupersonaffiliation = 'Member' AND daf.description = 'Faculty' THEN 'Faculty/Staff'
	ELSE 'Student'
	END AS person_type
FROM dirsvcs.dir_person dp 
	INNER JOIN dirsvcs.dir_affiliation daf
		ON daf.uuid = dp.uuid
		AND daf.campus = 'Boulder Campus' 
		AND dp.primaryaffiliation <> ('Not currently affiliated', 'Retiree', 'Affiliate', 'Member')
		AND daf.description <> (
		  'Admitted Student', 'Alum', 'Confirmed Student', 'Former Student',
		  'Member Spouse', 'Sponsored', 'Sponsored EFL', 'Retiree', 'Boulder3'
		)
		AND daf.description NOT LIKE 'POI%'
	LEFT JOIN dirsvcs.dir_email de
		ON de.uuid = dp.uuid
		AND de.mail_flag = 'M'
		AND de.mail IS NOT NULL
        AND LOWER(de.mail) NOT LIKE '%cu.edu'
			WHERE dp.primaryaffiliation <> 'Student'
			  OR (
				dp.primaryaffiliation = 'Student'
				AND EXISTS (
				  SELECT 'x' FROM dirsvcs.dir_acad_career WHERE uuid = dp.uuid
				)
			)
;

