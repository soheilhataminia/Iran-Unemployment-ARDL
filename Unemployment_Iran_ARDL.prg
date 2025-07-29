'====================================================================
'  PROJECT  :  UNEMPLOYMENT IN IRAN – NATURAL CAPITAL & ENERGY
'  DATASET  :  1991‑2024, 11 variables (full table supplied by user)
'  SOFTWARE :  EViews 13
'  PURPOSE  :  End‑to‑end replication script (ARDL‑ECM with diagnostics)
'====================================================================

'----------------------------------------------------------
' 1) CREATE AN ANNUAL WORKFILE (1991–2024)
'----------------------------------------------------------
wfcreate unemp_ann a 1991 2024
' 34 annual observations now available

'----------------------------------------------------------
' 2) IMPORT THE CSV DATA  (includes YEAR column)
'----------------------------------------------------------
import "C:\Iran_Unemp_FullData.csv" colhead=1 @datecol=YEAR @freq A
' --- Resulting series in the workfile:
' UNEMP NET_MIG INF GDPPC ELECT CO2 POPG TB NAT_CAP WATER AGRI_LAND

'----------------------------------------------------------
' 3) DESCRIPTIVE STATISTICS & JARQUE–BERA  (optional Table 1)
'----------------------------------------------------------
show stats UNEMP NET_MIG INF GDPPC ELECT CO2 POPG TB NAT_CAP WATER AGRI_LAND
for %v UNEMP NET_MIG INF GDPPC ELECT CO2 POPG TB NAT_CAP WATER AGRI_LAND
   show histogram {%v} (normal, stats)
next

'----------------------------------------------------------
' 4) UNIT‑ROOT TESTS (ADF & PP)
'----------------------------------------------------------
for %v UNEMP NET_MIG INF GDPPC ELECT CO2 POPG TB NAT_CAP WATER AGRI_LAND
   adf {%v} 0 1 C
   pp  {%v} 0 1 C
   adf d({%v}) 0 1 C
   pp  d({%v}) 0 1 C
next

'----------------------------------------------------------
' 5) ARDL MODEL ESTIMATION
'     • Dependent variable  : UNEMP
'     • Lags (chosen by AIC/SIC in manuscript):
'         – 2 for UNEMP
'         – 1 for every regressor
'----------------------------------------------------------
equation ardl01.ardl 2 1 1 1 1 1 1 1 1 1 1 UNEMP NET_MIG INF GDPPC ELECT CO2 POPG TB NAT_CAP WATER AGRI_LAND

'----------------------------------------------------------
' 6) BOUNDS TEST FOR COINTEGRATION
'----------------------------------------------------------
ardl01.cointtest f

'----------------------------------------------------------
' 7) LONG‑RUN, SHORT‑RUN COEFFICIENTS & ECM
'----------------------------------------------------------
ardl01.longrun
ardl01.shortrun
ardl01.ecm         ' ECM(‑1) should be negative & significant

'----------------------------------------------------------
' 8) MODEL DIAGNOSTICS
'----------------------------------------------------------
ardl01.residtest(lm,2)       ' Breusch‑Godfrey up to lag 2
ardl01.residtest(jarque)     ' residual normality
ardl01.residtest(white)      ' White/Breusch‑Pagan heteroskedasticity
ardl01.stability(cusum)      ' CUSUM
ardl01.stability(cusumsq)    ' CUSUMSQ

'----------------------------------------------------------
' 9) SAVE KEY OUTPUTS FOR THE PAPER
'----------------------------------------------------------
export ardl01 output="C:\ARDL_Full_Results.rtf"
freeze(fig_cusum) ardl01.stability(cusum)
fig_cusum.save(t=png) "C:\CUSUM_Test.png"

'----------------------------------------------------------
' 10) SAVE THE PROGRAM (OPTIONAL)
'----------------------------------------------------------
save "C:\Unemp_ARDL_Project.prg"

'=============================  END  ===============================