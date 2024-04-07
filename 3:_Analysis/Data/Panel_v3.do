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
	- PanelMunicipios_Violencia Extended.xlsx
	- PanelMunicipios_Votos All.xlsx
	
Output:
	- Panel_v3.dta

	

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
import excel "/Users/edmundoarias/Documents/Uniandes/2024-10/HEC/Political-Attitudes/2:_ProcessedData/MergedData/Violence/PanelMunicipios_Violencia Extended.xlsx", sheet("Sheet1") firstrow


/// Drop index variables
drop A

///Rename variables
ren (Departamento Municipio Periodo) (dep mun periodo)

/// Re-order and sort
order id mun dep periodo
sort id periodo

/// Dropping id-year dups: necessary for 1:1 merge
bysort id periodo: keep if _n == 1


/// Save in CleanedData
save "/Users/edmundoarias/Documents/Uniandes/2024-10/HEC/Political-Attitudes/2:_ProcessedData/CleanedData/ViolencePanel Extended.dta", replace

********************************************************************************
*                                                                              *
*                         Import and Clean 'Votes Panel'                       *
*                                                                              *
********************************************************************************

/// Import excel data: Votes Panel
import excel "/Users/edmundoarias/Documents/Uniandes/2024-10/HEC/Political-Attitudes/2:_ProcessedData/MergedData/Votos/PanelMunicipio_VotosAll.xlsx", sheet("Sheet1") firstrow clear

/// Drop index variables
drop A

/// String ID
tostring id, format(%05.0f) gen(id_s)
	drop id
	ren id_s id


/// Save in CleanedData
save "/Users/edmundoarias/Documents/Uniandes/2024-10/HEC/Political-Attitudes/2:_ProcessedData/CleanedData/VotesPanelExtended.dta", replace



********************************************************************************
*                                                                              *
*                        Merging Violence & Votes Panels                       *
*                                                                              *
********************************************************************************


/// 1:1 Merge on id (municipio identifier) and periodo (year)
merge 1:1 id periodo using "/Users/edmundoarias/Documents/Uniandes/2024-10/HEC/Political-Attitudes/2:_ProcessedData/CleanedData/ViolencePanel Extended.dta"
drop _merge

/// Clean the dataset
order id periodo dep mun Violencia V_Guerrilla V_Estado V_Paramilitar V_Desmovilizados V_GruposArma PARTIDOLIBERALCOLOMBIANO PARTIDOCONSERVADORCOLOMBIANO MOVIMIENTONUEVOLIBERALISMO OTROSPARTIDOOMOVIMIENTOS ALIANZANALPOPULARANAPO UNIONPATRIOTICAUP PARTIDOPATRIANUEVA VOTOSENBLANCO VOTOSNULOS

/// Sort by municipio and year
sort id periodo


// Keep only the specified voting years
keep if periodo == 1972 | periodo == 1974 | periodo == 1976 | periodo == 1978 | ///
periodo == 1980 | periodo == 1982 | periodo == 1984 | periodo == 1986 | ///
periodo == 1990 | periodo == 1992 | periodo == 1994 | periodo == 1997 | ///
periodo == 2000 | periodo == 2003 | periodo == 2007


/// Export data to MergedData
save "/Users/edmundoarias/Documents/Uniandes/2024-10/HEC/Political-Attitudes/2:_ProcessedData/MergedData/Final/Panel_v3.dta", replace
