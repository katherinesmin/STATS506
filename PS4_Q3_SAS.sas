/*Import the Data*/
filename recs2020 '/home/u63650722/recs2020_public_v5.csv';

proc import datafile=recs2020
	out=recs
	dbms=csv
	replace;
	getnames=yes;
run;

/*Check the data*/
proc print data=recs(obs=5);     
    var DOEID NWEIGHT REGIONC;

    
proc means data=recs NMISS; /*few missing values but ignore*/
run;

/*Part A*/
/* Create a summary of the number of complete records by state */
proc freq data=recs;
    tables state_name / out=state_summary;
    weight nweight;
run;

proc sort data=state_summary;
   by descending count;
run;

/*MICHIGAN*/
data michigan;
	set state_summary;
	where state_name = "Michigan";
run;

/*Part B*/
proc print data=recs(obs=5);      
    var DOLLAREL;  
    

/* Total electricity cost in kilowatt-hours (KWH) for records with strictly positive costs */
proc univariate data=recs noprint;
    var DOLLAREL;
    where DOLLAREL>0;
    histogram DOLLAREL;
run;

/*Part C*/
/*Log of Electricity cost*/
data recs;
    set recs; 
    where DOLLAREL>0;
    log_electricity_cost = log(DOLLAREL);
run;

proc univariate data=recs noprint;
    var log_electricity_cost;
    histogram log_electricity_cost;
run;

/*part d*/
/* Create a binary variable for garage (yes/no) based on SIZEOFGARAGE */

data recs_weight;
    set recs;
    weight=nweight;
run;


/* Fit the linear regression model */
proc reg data=recs_weight; /*glm*/
    model log_electricity_cost = TOTROOMS PRKGPLC1;
    output out=reg_results predicted=predicted_values residual=residuals;
run;

/*part e*/

/* Calculate the actual electricity cost (unlog the predicted values) */
data reg_results_e;
    set reg_results;
    Actual_Electricity_Cost = exp(log_electricity_cost);
    Predicted_Electricity_Cost = exp(predicted_values);
run;

/* Create a scatterplot of predicted vs. actual electricity cost */
proc sgplot data=reg_results_e;
    scatter x=Actual_Electricity_Cost y=Predicted_Electricity_Cost / markerattrs=(symbol=CircleFilled);
    title 'Scatterplot of Predicted vs. Actual Electricity Cost';
    xaxis label='Actual Electricity Cost';
    yaxis label='Predicted Electricity Cost';
run;







