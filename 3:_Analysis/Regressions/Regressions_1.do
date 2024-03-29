********************************************************************************
********************************************************************************
*Authors: 
*Coder: Edmundo Arias De Abreu
*Project: HEC Proyecto
*Data: PanelMunicipios_Violencia.xlsx + PanelMunicipios_Votos.xlsx
*Stage: Regression Analysis

*Last checked: 29.03.2024

/*
********************************************************************************
*                                 Contents                                     *
********************************************************************************

This do outlines a procedure for estimating Two-Way Fixed Effects (TWFE) 
regressions using the Panel_v1.dta dataset. Our primary objective is to quantify
 the causal impact of violent attacks on the political attitudes of Colombian 
 municipalities. This analysis will be reflected through changes in the voting 
 patterns observed in local 'Concejo' elections, specifically examining the 
 number of votes cast for each political party within these municipalities.

Inputs:
	- Panel_v1.dta
	
Output:
	- TWFE Estimation Graphs – see 4/_Output -> Results

	

********************************************************************************
*/

*Prepare the terminal
clear
cls

*Set graph format
set scheme s2mono
grstyle init
grstyle set plain, horizontal box
grstyle color background white
grstyle set color navy gs5 gs10
grstyle set color gs10: major_grid
grstyle set lp solid dash dot 
grstyle set symbol circle triangle diamond X
grstyle set legend 6, nobox
graph set window fontface "Garamond"


********************************************************************************
*                                                                              *
*                           Event Study Design Set Up                          *
*                                                                              *
********************************************************************************

/// Import dataset
use "/Users/edmundoarias/Documents/Uniandes/2024-10/HEC/Project/2:_ProcessedData/MergedData/Final/Panel_v1.dta", clear

/// Declare panel
xtset id periodo

/// Gen Total Violence var
egen violencia = rowtotal(NumSecuestros NumATerror NumASelect NumAPob NumABel)
order id mun dep periodo NumSecuestros NumATerror NumASelect NumAPob NumABel violencia

/// Violence indicator
gen violencia_dummy = (violencia != 0)


/// Gen First-Treat variable: year of first 'violencia'
by id: egen firsttreat = min(cond(violencia_dummy == 1, periodo, .))
tab firsttreat

/// Create dummy treatment variable specific on date
gen Dit = (periodo >= firsttreat & firsttreat!=0)
tab Dit

/// Create relative periods (t-t_0)
gen rel_time=periodo-firsttreat

tab rel_time, gen(evt) // dummies for each period
 *-> I have 18 leads & 18 lags !
 

* Loop for lead variables (before treatment, -18 to -2)
forvalues i = 1/9 {
    local relative_time = -18 + (`i' - 1) * 2
    local newname = "evtl" + string((-1 * `relative_time') / 2, "%02.0f")
    local label = "`relative_time'"
    
    rename evt`i' `newname'
    label variable `newname' "`label'"
}

* Special handling for the treatment year (relative time 0)
rename evt10 evtl0
label variable evtl0 "0"

* Loop for lag variables (after treatment, 2 to 18)
forvalues i = 11/19 {
    local relative_time = (`i' - 10) * 2
    local newname = "evtf" + string(`relative_time' / 2, "%02.0f")
    local label = "`relative_time'"
    
    rename evt`i' `newname'
    label variable `newname' "`label'"
}

/// Base period to be ommited becuase of perfect multicollinearity:
replace evtl0=0
 

********************************************************************************
*                                                                              *
*                                Regressions                                   *
*                                                                              *
********************************************************************************


********************           Voto Conservador               ******************  

/// Define as logarithm: easier to interpret and more effective to capture an effect
gen VotoCons = log(PARTIDOCONSERVADORCOLOMBIANO)

/// Event Study – TWFE
reghdfe VotoCons evtl08 evtl07 evtl06 evtl05 evtl04 evtl03 evtl02 evtl01 evtl0 evtf01 evtf02 evtf03 evtf04 evtf05 evtf06 evtf07 evtf08 evtf09, abs(id periodo) vce(cluster id)
	estimates store coefs_i 

*) Graph
coefplot coefs_i, omitted														///
	vertical 																	///
	label drop(_cons)															///
	yline(0, lpattern(dash) lwidth(*0.5))   							 		///
	ytitle("Votos hacia el Partido Conservador (log)")                          ///
	xtitle("Años Relativo al Ataque", size(medsmall))			 		        ///
	xlabel(, labsize(small) nogextend labc(black)) 	 				 			///
	ylabel(,nogrid nogextend labc(black) format(%9.2f)) 				 		///
	msymbol(O) 														 			///
	mlcolor(black) 													 			///
	mfcolor(black) 													 			///
	msize(vsmall) 													 			///
	levels(95) 														 			///
	xline(9, lpattern(dash) lwidth(*0.5))										///
	ciopts(lcol(black) recast(rcap) lwidth(*0.8)) 					 			///
	plotregion(lcolor(black) fcolor(white))  							 		///
	graphregion(lcolor(black) fcolor(white))  						 			///
	yscale(lc(black)) 												 			///
	xscale(lc(black)) 												 			///
	name(TWFE1, replace)
 graph export "/Users/edmundoarias/Documents/Uniandes/2024-10/HEC/Project/4:_Output/Results/TWFE_1.pdf", replace
*--> Effect! Violence on municipalities increases Conservative votes
 



********************            Voto Liberal                 ******************  

/// Define as logarithm: easier to interpret and more effective to capture an effect
gen VotoLib = log(PARTIDOLIBERALCOLOMBIANO)

/// Event Study – TWFE
reghdfe VotoLib evtl08 evtl07 evtl06 evtl05 evtl04 evtl03 evtl02 evtl01 evtl0 evtf01 evtf02 evtf03 evtf04 evtf05 evtf06 evtf07 evtf08 evtf09, abs(id periodo) vce(cluster id)
	estimates store coefs_i 

*) Graph
coefplot coefs_i, omitted														///
	vertical 																	///
	label drop(_cons)															///
	yline(0, lpattern(dash) lwidth(*0.5))   							 		///
	ytitle("Votos hacia el Partido Liberal (log)")                              ///
	xtitle("Años Relativo al Ataque", size(medsmall))			 		        ///
	xlabel(, labsize(small) nogextend labc(black)) 	 				 			///
	ylabel(,nogrid nogextend labc(black) format(%9.2f)) 				 		///
	msymbol(O) 														 			///
	mlcolor(black) 													 			///
	mfcolor(black) 													 			///
	msize(vsmall) 													 			///
	levels(95) 														 			///
	xline(9, lpattern(dash) lwidth(*0.5))										///
	ciopts(lcol(black) recast(rcap) lwidth(*0.8)) 					 			///
	plotregion(lcolor(black) fcolor(white))  							 		///
	graphregion(lcolor(black) fcolor(white))  						 			///
	yscale(lc(black)) 												 			///
	xscale(lc(black)) 												 			///
	name(TWFE1, replace)
 graph export "/Users/edmundoarias/Documents/Uniandes/2024-10/HEC/Project/4:_Output/Results/TWFE_2.pdf", replace
*--> No Effect! Violence on municipalities has no effect on liberal voting patterns
 


********************           Voto en Blanco                 ******************  

/// Define as logarithm: easier to interpret and more effective to capture an effect
gen VotoBlanco = log(VOTOSENBLANCO)

/// Event Study – TWFE
reghdfe VotoBlanco evtl08 evtl07 evtl06 evtl05 evtl04 evtl03 evtl02 evtl01 evtl0 evtf01 evtf02 evtf03 evtf04 evtf05 evtf06 evtf07 evtf08 evtf09, abs(id periodo) vce(cluster id)
	estimates store coefs_i 

*) Graph
coefplot coefs_i, omitted														///
	vertical 																	///
	label drop(_cons)															///
	yline(0, lpattern(dash) lwidth(*0.5))   							 		///
	ytitle("Votos en Blanco (log)")                              ///
	xtitle("Años Relativo al Ataque", size(medsmall))			 		        ///
	xlabel(, labsize(small) nogextend labc(black)) 	 				 			///
	ylabel(,nogrid nogextend labc(black) format(%9.2f)) 				 		///
	msymbol(O) 														 			///
	mlcolor(black) 													 			///
	mfcolor(black) 													 			///
	msize(vsmall) 													 			///
	levels(95) 														 			///
	xline(9, lpattern(dash) lwidth(*0.5))										///
	ciopts(lcol(black) recast(rcap) lwidth(*0.8)) 					 			///
	plotregion(lcolor(black) fcolor(white))  							 		///
	graphregion(lcolor(black) fcolor(white))  						 			///
	yscale(lc(black)) 												 			///
	xscale(lc(black)) 												 			///
	name(TWFE3, replace)
 graph export "/Users/edmundoarias/Documents/Uniandes/2024-10/HEC/Project/4:_Output/Results/TWFE_3.pdf", replace
*--> No Effect! Violence on municipalities has no effect on 'Voto en Blanco' voting patterns
 

********************           Voter Turnout                  ******************  

/// Define Total Votes
egen VotoTotal = rowtotal(PARTIDOLIBERALCOLOMBIANO PARTIDOCONSERVADORCOLOMBIANO MOVIMIENTONUEVOLIBERALISMO OTROSPARTIDOOMOVIMIENTOS ALIANZANALPOPULARANAPO UNIONPATRIOTICAUP PARTIDOPATRIANUEVA VOTOSENBLANCO VOTOSNULOS)

/// Set as logarithm
gen l_VotoTotal = log(VotoTotal)

/// Event Study – TWFE
reghdfe l_VotoTotal evtl08 evtl07 evtl06 evtl05 evtl04 evtl03 evtl02 evtl01 evtl0 evtf01 evtf02 evtf03 evtf04 evtf05 evtf06 evtf07 evtf08 evtf09, abs(id periodo) vce(cluster id)
	estimates store coefs_i 

*) Graph
coefplot coefs_i, omitted														///
	vertical 																	///
	label drop(_cons)															///
	yline(0, lpattern(dash) lwidth(*0.5))   							 		///
	ytitle("Votos Totales (log)")                              ///
	xtitle("Años Relativo al Ataque", size(medsmall))			 		        ///
	xlabel(, labsize(small) nogextend labc(black)) 	 				 			///
	ylabel(,nogrid nogextend labc(black) format(%9.2f)) 				 		///
	msymbol(O) 														 			///
	mlcolor(black) 													 			///
	mfcolor(black) 													 			///
	msize(vsmall) 													 			///
	levels(95) 														 			///
	xline(9, lpattern(dash) lwidth(*0.5))										///
	ciopts(lcol(black) recast(rcap) lwidth(*0.8)) 					 			///
	plotregion(lcolor(black) fcolor(white))  							 		///
	graphregion(lcolor(black) fcolor(white))  						 			///
	yscale(lc(black)) 												 			///
	xscale(lc(black)) 												 			///
	name(TWFE3, replace)
 graph export "/Users/edmundoarias/Documents/Uniandes/2024-10/HEC/Project/4:_Output/Results/TWFE_4.pdf", replace
*--> No Effect! Violence on municipalities has no effect on voter turnout

**# BIG TAKEAWAY #1:
/*
Violent attacks on municipalities increases votes towards conservatives, while
maintaining the votes on other parties and voter turnout as a whole constant.

This (to me) seems as direct evidence that political attitudes shifted in favor
of conservatives due to the violent attacks at the municipality level.

*/


 




