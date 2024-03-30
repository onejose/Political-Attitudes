********************************************************************************
********************************************************************************
*Authors: 
*Coder: Edmundo Arias De Abreu
*Project: HEC Proyecto
*Data: Municipios_Violencia.xlsx (all Years)
*Stage: Data Construction

*Last checked: 30.03.2024

/*
********************************************************************************
*                                 Contents                                     *
********************************************************************************
This Do will create a new dataset which will extend the years to study (original
dataset went from 1972 to 1990, this new one will go from 1978 to 2007). This is
done for 2 reasons. First, we want to see persistence effects of an increase in 
the conservative votes results evidenced from the first dataset. Secondly, 
extending the period will allow us to access more variation, as in subsequent 
years (1990 to 2000s) there were more violent attacks registered.

	Inputs
		- Votes (1978 - 2007): PanelMunicipio_VotosAll.xlsx
		- Violence: ViolencePanel.dta

	Output
		- Panel_v2.dta
		

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
*                                 Data Merging                                 *
*                                                                              *
********************************************************************************


/// Load Votes Data for extended Years (1978 to 2007)
import excel "/Users/edmundoarias/Documents/Uniandes/2024-10/HEC/Project/2:_ProcessedData/MergedData/Votos/PanelMunicipio_VotosAll.xlsx", sheet("Sheet1") firstrow clear

/// Drop vars
drop A

/// Merge 1:1 with Violence Panel (same as always)
merge 1:1 id periodo using "/Users/edmundoarias/Documents/Uniandes/2024-10/HEC/Project/2:_ProcessedData/CleanedData/ViolencePanel.dta"
drop _merge


/// Gen 'Violence' Variable & Dummy variable
egen Violencia = rowtotal(NumSecuestros NumATerror NumASelect NumAPob NumABel)
gen D_Violencia = (Violencia != 0)
tab D_Violencia

/// Keep relevant years (1978 - 2007)
keep if periodo > 1977 & periodo < 2008
keep if PARTIDOLIBERALCOLOMBIANO !=.                       /// keep years with voting data

/// order & sort data
sort id periodo
order id mun dep periodo Violencia D_Violencia
 
/// Gen a continuos variable to indicate periods (useful for calculating rel time)
egen seq = group(periodo)
order id mun dep periodo seq

/// Save dataset
save "/Users/edmundoarias/Documents/Uniandes/2024-10/HEC/Project/2:_ProcessedData/MergedData/Final/Panel_v2.dta", replace
