********************************************************************************
********************************************************************************
*Authors: 
*Coder: Edmundo Arias De Abreu
*Project: HEC Proyecto
*Data: PanelMunicipios_Violencia.xlsx + PanelMunicipios_Votos.xlsx
*Stage: Data Construction

*Last checked: 29.03.2024

/*
********************************************************************************
*                                 Contents                                     *
********************************************************************************

This do will seek to merge both panels as of now constructed: Violencia and 
Votos. 

Inputs:
	- PanelMunicipios_Violencia.xlsx
	- PanelMunicipios_Votos.xlsx
	
Output:
	- Panel1.dta

	

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
*                        Import and Clean 'Violence Panel'                     *
*                                                                              *
********************************************************************************

/// Import excel data: Violencia Panel
import excel "/Users/edmundoarias/Documents/Uniandes/2024-10/HEC/Project/2:_ProcessedData/MergedData/Violence/PanelMunicipios_Violencia.xlsx", sheet("Sheet1") firstrow clear


/// Drop index variables
drop A

///Rename variables
ren (Departamento Municipio Codmun Año) (dep mun id periodo)

/// Re-order and sort
order id mun dep periodo
sort id periodo

/// Set id var as long – for merging
destring id, replace

/// Dropping id-year dups: necessary for 1:1 merge
bysort id periodo: keep if _n == 1


/// Save in CleanedData
save "/Users/edmundoarias/Documents/Uniandes/2024-10/HEC/Project/2:_ProcessedData/CleanedData/ViolencePanel.dta", replace

********************************************************************************
*                                                                              *
*                         Import and Clean 'Votes Panel'                       *
*                                                                              *
********************************************************************************

/// Import excel data: Votes Panel
import excel "/Users/edmundoarias/Documents/Uniandes/2024-10/HEC/Project/2:_ProcessedData/MergedData/Votos/PanelMunicipios_Votos.xlsx", sheet("Sheet1") firstrow clear

/// Drop index variables
drop A


/// Save in CleanedData
save "/Users/edmundoarias/Documents/Uniandes/2024-10/HEC/Project/2:_ProcessedData/CleanedData/VotesPanel.dta", replace



********************************************************************************
*                                                                              *
*                        Merging Violence & Votes Panels                       *
*                                                                              *
********************************************************************************


/// 1:1 Merge on id (municipio identifier) and periodo (year)
merge 1:1 id periodo using "/Users/edmundoarias/Documents/Uniandes/2024-10/HEC/Project/2:_ProcessedData/CleanedData/ViolencePanel.dta"
drop _merge

/// Clean the dataset
order id mun dep periodo NumSecuestros NumATerror NumASelect NumAPob NumABel PARTIDOLIBERALCOLOMBIANO PARTIDOCONSERVADORCOLOMBIANO MOVIMIENTONUEVOLIBERALISMO OTROSPARTIDOOMOVIMIENTOS ALIANZANALPOPULARANAPO UNIONPATRIOTICAUP PARTIDOPATRIANUEVA VOTOSENBLANCO VOTOSNULOS

/// Sort by municipio and year
sort id periodo


// Keep only the specified voting years
keep if periodo == 1972 | periodo == 1974 | periodo == 1976 | periodo == 1978 | ///
periodo == 1980 | periodo == 1982 | periodo == 1984 | periodo == 1986 | ///
periodo == 1990


/// Export data to MergedData
save "/Users/edmundoarias/Documents/Uniandes/2024-10/HEC/Project/2:_ProcessedData/MergedData/Final/Panel_v1.dta", replace



