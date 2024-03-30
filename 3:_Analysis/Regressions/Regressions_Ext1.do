********************************************************************************
********************************************************************************
*Authors: 
*Coder: Edmundo Arias De Abreu
*Project: HEC Proyecto
*Data: Panel_v2.dta (Extended Years)
*Stage: Analysis

*Last checked: 30.03.2024

/*
********************************************************************************
*                                 Contents                                     *
********************************************************************************
This Do will analyze the Panel_v2.dta dataset which contains data for municipios'
voting patterns and violent attacks in an extended period of time (1978 - 2007).
It will allows us to see persistence effects of the attacks and to exploit more
variation in terms of the violent attacks perpetrated against them

	Inputs
		- Panel_v2.dta

	Output
		- TWFE_Ext1 -> Net decrease in liberal votes
		

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
*                            Event Study Design Set Up                         *
*                                                                              *
********************************************************************************

/// Load Data
use "/Users/edmundoarias/Documents/Uniandes/2024-10/HEC/Project/2:_ProcessedData/MergedData/Final/Panel_v2.dta", clear

/// First-Treat variable: year of first 'violencia'
by id: egen firsttreat = min(cond(D_Violencia == 1, seq, .))
tab firsttreat

/// Create dummy treatment variable specific on date
gen Dit = (seq >= firsttreat & firsttreat!=0)
tab Dit

/// Create relative periods (t-t_0)
gen rel_time=seq-firsttreat

tab rel_time, gen(evt) // dummies for each period
 *-> I have 11 leads & 11 lags !
 

	 ** Leads
	forvalues x = 1/11 {
		
		local j= 12-`x'
		ren evt`x' evt_l`j'
		cap label var evt_l`j' "-`j'" 
	}

	**  Lags
	forvalues x = 0/11 {
		
		local j= 12+`x'
		ren evt`j' evt_f`x'
		cap label var evt_f`x' "`x'"  
	}

** Base period to be ommited becuase of perfect multicollinearity:
replace evt_l1=0
 


********************************************************************************
*                                                                              *
*               Regressions for Persistence Effects  (1978 – 2007)             *
*                                                                              *
********************************************************************************
xtset id seq
 
********************             Voto Liberal                ******************  

gen VotoLib = log(PARTIDOLIBERALCOLOMBIANO)
reghdfe VotoLib Dit, nocon abs(id seq) vce(cluster id)                       
*--> TWFE model associates violence with decrease in liberal votes           /// Significant
 
gen VotoCons = log(PARTIDOCONSERVADORCOLOMBIANO)
reghdfe VotoCons Dit, nocon abs(id seq) vce(cluster id)
*--> TWFE model associates violence with (lower) decrease in conservative votes
 
gen VotoBlanco = log(VOTOSENBLANCO)
reghdfe VotoBlanco Dit, nocon abs(id seq) vce(cluster id)
*--> TWFE model associates violence with Increase in White votes             /// Significant

gen Voto_Otros = log(OTROSPARTIDOOMOVIMIENTOS)
reghdfe Voto_Otros Dit, nocon abs(id seq) vce(cluster id)                    /// Non-significant
*--> TWFE model associates violence with decrease (non-significant) in other votes 


/// Event Study
reghdfe VotoLib evt_l11 evt_l10 evt_l9 evt_l8 evt_l7 evt_l6 evt_l5 evt_l4 evt_l3 evt_l2 evt_l1 evt_f0 evt_f1 evt_f2 evt_f3 evt_f4 evt_f5 evt_f6 evt_f7 evt_f8 evt_f9 evt_f10, nocon absorb(id seq) vce(cluster id)
	estimates store coefs_i

*) Graph
coefplot coefs_i, omitted														///
	vertical 																	///
	label drop(_cons)															///
	yline(0, lpattern(dash) lwidth(*0.5))   							 		///
	ytitle("Votos hacia el Partido Liberal (log)")                              ///
	xtitle("Años Relativos al Ataque", size(medsmall))			 		///
	xlabel(, labsize(small) nogextend labc(black)) 	 				 			///
	ylabel(,nogrid nogextend labc(black) format(%9.2f)) 				 		///
	msymbol(O) 														 			///
	mlcolor(black) 													 			///
	mfcolor(black) 													 			///
	msize(vsmall) 													 			///
	levels(95) 														 			///
	xline(11, lpattern(dash) lwidth(*0.5))										///
	ciopts(lcol(black) recast(rcap) lwidth(*0.8)) 					 			///
	plotregion(lcolor(black) fcolor(white))  							 		///
	graphregion(lcolor(black) fcolor(white))  						 			///
	yscale(lc(black)) 												 			///
	xscale(lc(black)) 												 			///
	name(TWFE_Ext_1, replace)
	
graph export "/Users/edmundoarias/Documents/Uniandes/2024-10/HEC/Project/4:_Output/Results/TWFE_Ext1.pdf"
 
*--> Decrease in (log) liberal votes after a violent attacks when we increase period of study !

**# BIG TAKEAWAY #2
/*
The previously presented pooled regressions show that there was a significant 
and much more higher decrease in liberal votes due to violence than of other 
political parties.

Why? We can explain this by saying that an uptick in conservative votes (our 
initial result from Panel_v1.dta) in previous periods led to a net negative 
decline in liberal votes... again, why? find out !

*/
 











