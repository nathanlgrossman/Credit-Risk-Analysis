
libname mydata '/folders/myfolders/';
options label=no;

/*
   Display data
*/

* title "Data";
* proc print data=mydata.dmagecr;
* run;


/*
   Divide data into training and test data
*/

data training_data;
  set mydata.dmagecr (firstobs=1 obs=700);
run;

* title "Training Data";
* proc print data=training_data;
* run;

data test_data;
  set mydata.dmagecr (firstobs=701 obs=1000);
run;

* title "Test Data";
* proc print data=test_data;
* run;


/*
   Descriptive Statistics of Variables
*/

title "Descriptive Statistics of Numerical Variables";
proc means data=mydata.dmagecr n nmiss mean std median;
var duration amount installp age existcr depends;
run;

title "Descriptive Statistics of Categorical Variables";
proc freq data=mydata.dmagecr;
tables good_bad checking history purpose savings employed marital coapp property
       other housing job;
run;


/*
   Cluster Analysis of Independent Variables
*/

title "Cluster Analysis of Numerical Independent Variables";
proc varclus data=mydata.dmagecr;
var duration amount installp age existcr depends;
run;


/*
   Logistic Regression without Variable Selection
*/

title "Logistic Regression without Variable Selection";
proc logistic data=training_data;
  class checking history purpose savings employed marital coapp property
        other housing job; 
  model good_bad = checking duration history purpose amount savings
                   employed installp marital coapp resident property
                   age other housing existcr job depends telephon foreign;
run;


/*
   Logistic Regression with Variable Selection
*/

title "Logistic Regression with Selection of 12 Variables";
proc logistic data=training_data;
  class checking history purpose savings employed marital coapp property
        other housing job; 
  model good_bad = checking duration history purpose amount savings
                   employed installp marital coapp resident property
                   age other housing existcr job depends telephon foreign
                   / SELECTION=stepwise INCLUDE=12 DETAILS;
run;

title "Logistic Regression with Selection of 11 Variables";
proc logistic data=training_data;
  class checking history purpose savings employed marital coapp property
        other housing job; 
  model good_bad = checking duration history purpose amount savings
                   employed installp marital coapp resident property
                   age other housing existcr job depends telephon foreign
                   / SELECTION=stepwise INCLUDE=11 DETAILS;
run;

title "Logistic Regression with Selection of 10 Variables";
proc logistic data=training_data;
  class checking history purpose savings employed marital coapp property
        other housing job; 
  model good_bad = checking duration history purpose amount savings
                   employed installp marital coapp resident property
                   age other housing existcr job depends telephon foreign
                   / SELECTION=stepwise INCLUDE=10 DETAILS;
run;


/*
   Logistic Regresson with Hard-Coded Variable Selection
*/

title "Logistic Regression with 10 Hard-Coded Variables";
proc logistic data=training_data;
  class checking history purpose savings employed marital coapp; 
  model good_bad = checking duration history purpose amount savings
                   employed installp marital coapp;
run;


/*
   Outliers and Influential Observations
*/

title "Outliers / Influencers";
proc logistic data=training_data
              plots(label)=(influence dfbetas leverage);
  class checking history purpose savings employed marital coapp; 
  model good_bad = checking duration history purpose amount savings
                   employed installp marital coapp;
run;


/*
   Goodness of Fit
*/

title "Hosmer-Lemeshow (HL) Statistic";
proc logistic data=training_data;
  class checking history purpose savings employed marital coapp; 
  model good_bad = checking duration history purpose amount savings
                   employed installp marital coapp / lackfit;
run;


/*
   Predictive Power
*/

title "Generalized R-Squared & ROC Curves";
proc logistic data=training_data
              plots(only)=roc(id=cutpoint);
  class checking history purpose savings employed marital coapp; 
  model good_bad = checking duration history purpose amount savings
                   employed installp marital coapp / rsq;
run;


/*
   Kolmogorov-Smirnov Analysis
*/

title "Logistic Regression to Find the Best Distribution Model";
proc logistic data=training_data;
  class checking history purpose savings employed marital coapp; 
  model good_bad = checking duration history purpose amount savings
                   employed installp marital coapp;
  output out=output_prob p=probability;
run;

title "Kolmogorov-Smirnov Analysis";
proc npar1way data=output_prob;
class good_bad;
var probability;
output out=npar_an;
run;

proc print data=npar_an;
var _D_;
title 'data=npar_an';
run;


/*
   Data Scoring
*/

* title "Storing Model for Data Scoring";
proc logistic data=training_data outmodel=trained_model noprint;
  class checking history purpose savings employed marital coapp; 
  model good_bad = checking duration history purpose amount savings
                   employed installp marital coapp;
run;


title "Training Data Scoring";
proc logistic inmodel=trained_model;
  score data=training_data fitstat out=training_data_score;
run;

* proc print data=training_data_score;
* run;

title "Test Data Scoring";
proc logistic inmodel=trained_model;
  score data=test_data fitstat out=test_data_score;
run;

* proc print data=test_data_score;
* run;


