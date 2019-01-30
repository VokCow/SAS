/* data step version */

data CommitedSal_Dat;
	set sashelp.baseball (keep = Name Salary nError);
	format level $20. pay $20.;
	if nError ge 0 and nError le 5 
		then level = 'Very good';
		else if nError ge 6 and nError le 10 then level = 'Good';
		else if nError ge 11 and nError le 20 then level = 'Average';
		else if nError ge 21 and nError le 25 then level = 'Bad';
		else if nError ge 26 then level = 'Very bad';
	/* Then clasify salary status*/
	if Salary = . then pay = 'Unknown';
		else if Salary le 80 then pay = 'Low';
		else if Salary ge 81 and Salary le 90 then pay = 'Average';
		else if Salary ge 91 then pay = 'High';
	if (pay = 'High' and level = 'Very bad') or (pay = 'Low' and level = 'Very good');
	drop Salary nError;
run;


/* proc sql step version */

proc SQL;
	create table CommitedSal_sql as
	SELECT Name,
		   (
		CASE
			WHEN nError ge 0 and nError le 5 THEN 'Very good'
			WHEN nError ge 6 and nError le 11 THEN 'Good'
			WHEN nError ge 11 and nError le 21 THEN 'Average'
			WHEN nError ge 21 and nError le 25 THEN 'Bad'
			WHEN nError ge 26 THEN 'Very bad'
			ELSE 'Not Info avalible'
			END) as level,
			
			(
		CASE 
			WHEN Salary = . THEN 'Not Info avalible' 
			WHEN Salary le 80 then 'Low'
			WHEN Salary ge 81 and Salary le 90 THEN 'Average'
			WHEN Salary ge 91 then 'High'
			ELSE 'Excp.'
			END) as pay
			
		FROM SASHELP.BASEBALL
		WHERE (calculated pay='Low' and calculated level='Very good')
		or (calculated pay='High' and calculated level='Very bad')
		;
quit;

/*	 Format Level version	*/

proc format;
	value level 
		LOW - 5 = 'Very good'
		5 <- 11 = 'Good'
		11 <- 21 = 'Average'
		21 <- 25 = 'Bad'
		26 - HIGH  = 'Very bad'
		;
	value pay
		LOW - 80 = 'low'		
		81 <- 90 = 'average'
		91 - HIGH = 'high'
		. = 'Unknown';
run;

data CommitedSal_frm1;
	set sashelp.baseball (keep = Name nError Salary
						rename = (nError=level Salary=pay)
						where = ( pay <> . 
						and 
								( (level le 5 and pay le 80) or (level ge 26 and pay ge 91) ) 
								)	
						);
	format Name $10. level level. pay pay.; 
run;
