/* data step version */
data Avgs_data;
	set gas_sorted;
	retain CpRatio_medio EqRatio_medio NOx_medio n m;
		by Fuel;
	if first.Fuel then do;
			n=1;
			CpRatio_medio = CpRatio;
			EqRatio_medio = EqRatio;
			NOx_medio = NOx;
			m = 1;
	end;
	else do;
			n = n + 1;
			CpRatio_medio = CpRatio_medio + CpRatio;
			EqRatio_medio = EqRatio_medio + EqRatio;
			if NOx <> . then do; 
							NOx_medio = NOx_medio + NOx;
							m=m+1;
						end;
	end;
	if last.Fuel then do;
			NOx_medio = NOx_medio/m;
			CpRatio_medio = CpRatio_medio/n;
			EqRatio_medio = EqRatio_medio/n;		
			n=0;
			m=0;
	end;
	if last.Fuel;
	keep Fuel CpRatio_medio EqRatio_medio NOx_medio;
run; 


/* sql step version */
proc sql;
CREATE TABLE Avgs_sql AS 
	SELECT Fuel, 
	AVG(CpRatio) as CpRatio_Medio ,
	AVG(EqRatio) as EqRatio_Medio,
	AVG(NOx) as NOx_Medio
	FROM sashelp.gas
	GROUP BY Fuel;
quit;
