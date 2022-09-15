/** Applied Statistics Individual Assignment **/

/* Generated Code (IMPORT) */
/* Source File: assignment-individual-data.csv */
/* Source Path: /home/u42888972/BSBA Sem 6 Applied Statistics/AS Indi Assignment */
/* Code generated on: 21/7/2020 */

/*
I start by uploading the assignment-individual-data.csv file to my folder (AS Group Assignment, stated at the Source Path).
Then I created a permanent library called ASINCW20 and path it to the folder.
*/


libname ASINCW20 '/home/u42888972/BSBA Sem 6 Applied Statistics/AS Indi Assignment';


%web_drop_table(ASINCW20.ASINDT20);

FILENAME REFFILE '/home/u42888972/BSBA Sem 6 Applied Statistics/AS Indi Assignment/assignment-individual-data.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=ASINCW20.ASINDT20;
	GETNAMES=YES;
RUN;

%web_open_table(ASINCW20.ASINDT20);


*Created Macro for easier data manipulation;
%let library = ASINCW20;
%let filename = ASINDT20;



/** 1. BASIC DATA EXPLORATION & DATA CLEANING/VALIDATION. **/

/*
Using PROC FORMAT AND FREQ to find out which variables have missing data. 
(I did not use PROC MEAN because it can only be use for num variables.)
*/

PROC CONTENTS DATA = &library..&filename; 
RUN;


PROC FORMAT;
	VALUE $missing_char
		' ' = 'Missing'
		other = 'Present';
	
	VALUE missing_num
		. = 'Missing'
		other = 'Present';
RUN;


TITLE 'Listing of Present and Missing Data for Each Variable';
PROC FREQ DATA = &library..&filename;
	TABLES _all_ / missing;
	FORMAT _character_ $missing_char. _numeric_ missing_num.;
RUN;
TITLE;


options nolabel;
PROC MEANS DATA = &library..&filename N NMISS MIN MAX MEAN;
RUN;



*--------------------------------------------------------------------------------------------;
/** 2. DESCRIPTIVE ANALYSIS. **/

*Figure 1. Descriptive Statistics for assignment data.;
proc means data=ASINCW20.ASINDT20 chartype n nmiss min max mode median mean std vardef=df;
	var CHILDRENCOUNT INCOMETOTAL FAMSIZE;
run;



*Bar Chart1;
*Figure 2. Frequency of customer’s education level by gender.;
ods graphics / reset width=6.4in height=4.8in imagemap;

proc sgplot data=ASINCW20.ASINDT20;
	vbar GENDER / group=EDUCATIONLEVEL groupdisplay=cluster;
	yaxis grid;
run;

ods graphics / reset;



*Pie Chart;
*Figure 3. Percentage of customers who own property by gender.;
proc template;
	define statgraph SASStudio.Pie;
		begingraph;
		layout region;
		piechart category=GENDER / group=OWNPROPERTY groupgap=2% 
			datalabellocation=inside;
		endlayout;
		endgraph;
	end;
run;

ods graphics / reset width=6.4in height=4.8in imagemap;

proc sgrender template=SASStudio.Pie data=ASINCW20.ASINDT20;
run;

ods graphics / reset;



*Bar Chart 2;
*Figure 4. Percentage customer’s marital status by gender.;
ods graphics / reset width=6.4in height=4.8in imagemap;

proc sgplot data=ASINCW20.ASINDT20;
	hbar GENDER / group=MARITALSTATUS groupdisplay=cluster stat=percent;
	xaxis grid;
run;

ods graphics / reset;



*Histogram;
*Figure 5. Distribution of annual income by gender.;
ods graphics / reset width=6.4in height=4.8in imagemap;

proc sort data=ASINCW20.ASINDT20 out=_HistogramTaskData;
	by GENDER;
run;

proc sgplot data=_HistogramTaskData;
	by GENDER;
	title height=14pt "Distribution of IncomeTotal";
	histogram INCOMETOTAL / fillattrs=(color=CX3b4556);
	density INCOMETOTAL;
	yaxis grid;
run;

ods graphics / reset;
title;

proc datasets library=WORK noprint;
	delete _HistogramTaskData;
	run;



*Box Plot;
*Figure 6. Frequency of customer’s annual income by ways of living ordered by gender.;
ods graphics / reset width=6.4in height=4.8in imagemap;

proc sgplot data=ASINCW20.ASINDT20;
	vbox INCOMETOTAL / category=HOUSINGTYPE group=GENDER;
	yaxis grid;
run;

ods graphics / reset;



*Bubble Plot;
*Figure 7. Frequency of customer’s family size by credit loan status controlling for income category and number of children.;
ods graphics / reset width=6.4in height=4.8in imagemap;

proc sgplot data=ASINCW20.ASINDT20;
	bubble x=CREDITSTATUS y=FAMSIZE size=CHILDRENCOUNT/ group=INCOMETYPE 
		bradiusmin=7 bradiusmax=14;
	xaxis grid;
	yaxis grid;
run;

ods graphics / reset;






*--------------------------------------------------------------------------------------------;
/** 3. Analysis of Variance (ANOVA) **/
*This section look into 2 different ANOVA;

*First Linear Models Task: One-way ANOVA;
/*
	HOUSINGTYPE = Categorical variable
	INCOMETOTAL = Dependent variable
*/
TITLE 'First One-Way ANOVA';
ods graphics on;
proc glm data = &library..&filename plots (maxpoints = none) plots = (residuals diagnostics);
	class HOUSINGTYPE; 
	model INCOMETOTAL = HOUSINGTYPE; 
	lsmeans HOUSINGTYPE / adjust=tukey pdiff alpha=.05;
	means HOUSINGTYPE / hovtest=levene;
run;
ods graphics off;
title;


*First ANOVA with Blocking;
*First ANOVA with Data from a Randomized Block Design;
/*
	HOUSINGTYPE = Categorical variable
	INCOMETOTAL = Dependent variable
	CREDITSTATUS = Blocking variable
*/
TITLE 'First One-Way ANOVA with Blocking';
ods graphics on;
proc glm data = &library..&filename plots (maxpoints = none) plots = (residuals diagnostics);
	class CREDITSTATUS HOUSINGTYPE;
	model INCOMETOTAL = CREDITSTATUS HOUSINGTYPE;
run;
ods graphics off;
title;


*First ANOVA Post Hoc Pairwise Comparisons;
/*
	HOUSINGTYPE = Categorical variable
	INCOMETOTAL = Dependent variable
	CREDITSTATUS = Blocking variable
*/
TITLE 'First One-Way ANOVA with Blocking and Post-Hoc Pairwise Comparisons';
ods graphics on;
proc glm data = &library..&filename plots (maxpoints = none) plots = (residuals diagnostics);
	class CREDITSTATUS HOUSINGTYPE;
	model INCOMETOTAL = CREDITSTATUS HOUSINGTYPE;
	lsmeans HOUSINGTYPE / adjust=tukey pdiff alpha=.05;
	lsmeans HOUSINGTYPE / pdiff = control ('Rented apartment'); *Dunnett;
	lsmeans HOUSINGTYPE / adjust = t;
run;
ods graphics off;
title;



*Second Linear Models Task: One-way ANOVA;
/*
	EDUCATIONLEVEL = Categorical variable
	INCOMETOTAL = Dependent variable
*/
TITLE 'Second One-Way ANOVA';
ods graphics on;
proc glm data = &library..&filename plots (maxpoints = none) plots = (residuals diagnostics);
	class EDUCATIONLEVEL;
	model INCOMETOTAL = EDUCATIONLEVEL;
	lsmeans EDUCATIONLEVEL / adjust=tukey pdiff alpha=.05;
	means EDUCATIONLEVEL / hovtest=levene;
run;
ods graphics off;
title;


*Second ANOVA with Blocking;
*Second ANOVA with Data from a Randomized Block Design;
/*
	EDUCATIONLEVEL = Categorical variable
	INCOMETOTAL = Dependent variable
	HOUSINGTYPE = Blocking variable
*/
TITLE 'Second One-Way ANOVA with Blocking';
ods graphics on;
proc glm data = &library..&filename plots (maxpoints = none) plots = (residuals diagnostics);
	class HOUSINGTYPE EDUCATIONLEVEL;
	model INCOMETOTAL = HOUSINGTYPE EDUCATIONLEVEL;
run;
ods graphics off;
title;


*Second ANOVA Post Hoc Pairwise Comparisons;
/*
	EDUCATIONLEVEL = Categorical variable
	INCOMETOTAL = Dependent variable
	HOUSINGTYPE = Blocking variable
*/
TITLE 'Second One-Way ANOVA with Blocking and Post-Hoc Pairwise Comparisons';
ods graphics on;
proc glm data = &library..&filename plots (maxpoints = none) plots = (residuals diagnostics);
	class HOUSINGTYPE EDUCATIONLEVEL;
	model INCOMETOTAL = HOUSINGTYPE EDUCATIONLEVEL;
	lsmeans EDUCATIONLEVEL / adjust=tukey pdiff alpha=.05;
	lsmeans EDUCATIONLEVEL / pdiff = control ('Lower secondary'); *Dunnett;
	lsmeans EDUCATIONLEVEL / adjust = t;
run;
ods graphics off;
title;



*--------------------------------------------------------------------------------------------;
/** 4. Nonparametric One-Way ANOVA **/

*First Nonparametric One-way ANOVA;
/*
	HOUSINGTYPE = Categorical variable
	INCOMETOTAL = Dependent variable
*/
*First Distribution Examination;
title 'First Nonparametric One-way ANOVA Distribution Examination';
ods graphics on;
proc univariate data=&library..&filename normal;
	class HOUSINGTYPE;
	var INCOMETOTAL;
	histogram INCOMETOTAL;
	qqplot INCOMETOTAL;
	inset mean std skewness kurtosis normaltest probn;
run;
title;


*First Kruskal-Wallis Test;
title 'First Nonparametric One-way ANOVA Kruskal-Wallis Test';
ods noproctitle;
proc npar1way data=&library..&filename wilcoxon median plots(only)=(wilcoxonboxplot medianplot);
	class HOUSINGTYPE;
	var INCOMETOTAL;
run;





*Second Nonparametric One-way ANOVA;
/*
	EDUCATIONLEVEL = Categorical variable
	INCOMETOTAL = Dependent variable
*/
*Second Distribution Examination;
title 'Second Nonparametric One-way ANOVA Distribution Examination';
ods graphics on;
proc univariate data=&library..&filename normal;
	class EDUCATIONLEVEL;
	var INCOMETOTAL;
	histogram INCOMETOTAL;
	qqplot INCOMETOTAL;
	inset mean std skewness kurtosis normaltest probn;
run;


*Second Kruskal-Wallis Test;
title 'Second Nonparametric One-way ANOVA Kruskal-Wallis Test';
ods noproctitle;
proc npar1way data=&library..&filename wilcoxon median plots(only)=(wilcoxonboxplot medianplot);
	class EDUCATIONLEVEL;
	var INCOMETOTAL;
run;






