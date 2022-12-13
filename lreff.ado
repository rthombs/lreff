***************
*	      *
*   lreff     *
*	      *
***************

*! Version 1.1 Ryan Thombs 12/13/22

* Programs lreff works with: 
* 
* - Works with any program that returns e(depvar), which all eclass programs should include. 
* - Homogeneous panel estimators, won't be correct with mean group estimation. 
* - Most recent estimated model is a Dynamic model that uses Stata's time series operator (L.) 
* 
* Confirmed Programs: 
* - reg
* - xtreg, fe
* - xtabond
* - xtdpd
* - xtdpdsys
* - xtdpdbc
* - xtdpdgmm
* - xtdpdml
* - xtdpdqml
* - xtivreg
* - xtivdfreg (pooled coefficients only)
* - xtdcce2 (pooled coefficients only)


capture program drop lreff
program define lreff, rclass 
	version 15
	syntax varlist(min=1) [,ecm]
	
loc dv = e(depvar) // grab DV for ARDL 
loc dve = subinstr("`dv'", "D.", "", .) // grab DV for ECM

loc cmd = e(cmd)
loc ee = e(estimator)
loc ep = e(pooled)



loc nvar : word count `dv'
loc nm : word count `varlist'

if `nvar' > 1 {
di as error "There is more than one dependent variable."
exit 198
}


if strmatch("`dv'","`varlist'") == 1  {
di as error "Dependent variable cannot be included in varlist."
exit 198
}


if strmatch("`dve'","`varlist'") == 1  {
di as error "Dependent variable cannot be included in varlist."
exit 198
}


if "`cmd'" == "xtdcce2" & strmatch("`ep'","*`varlist'*") == 0  {
di as error "Mean group estimation performed. Estimated effects are incorrect."
exit 198
}


if "`cmd'" == "xtivdfreg" & "`ee'" == "mg" {
di as error "Mean group estimation performed. Estimated effects are incorrect."
exit 198
}


if "`cmd'" == "sem" & "`ecm'" != "" {
di as error "ecm option not available with xtdpdml."
exit 198
}



loc iv : colnames e(b) // local macro of the independent variables




if "`ecm'" == "" & strmatch("`dv'", "D.*") == 1 {
	di as error "Dependent variable is differenced, use the ecm option."
	exit 198
}


if "`ecm'" != "" & strmatch("`dv'", "D.*") == 0 {
	di as error "Dependent variable is not differenced, do not use ecm option."
	exit 198
}



// for ECM 
if "`cmd'" != "sem" {
if "`ecm'" != "" {
	

// capture independent variables of interest
foreach e of local varlist { 
  foreach v of local iv {
  if strmatch("`v'","L*.`e'") == 1 & strmatch("`v'","L*D.`e'") == 0 local i_`e' `i_`e'' _b[`v'] 
  loc i_`e' = subinstr("`i_`e''", " ", "+", .)
  }
  }


  
  
// capture dependent variable 
foreach v of local iv {
  if strmatch("`v'","L*.`dve'") == 1 & strmatch("`v'","L*D.`dve'") == 0 local d_`dve' `d_`dve'' _b[`v'] 
   loc d_`dve' = subinstr("`d_`dve''", " ", "+", .)
  }  
  

  
  
// local containing ECM LR estimate
foreach v of local varlist {
	loc lr `lr' (`v': -(`i_`v'')/(`d_`dve''))
}





// perform calculation
capture {
	nlcom `lr'
}
if _rc != 0 {
	local rc = _rc
	error `rc'
}
di ""
di in smcl "Estimates of Long-Run Effects"
di ""
di "     ""{ul:Variable-Specific Calculation}:" 
nlcom `lr'
}




else {




// capture independent variables of interest
foreach j of local varlist { 
  foreach v of local iv {
  if strmatch("`v'","`j'") == 1 & strmatch("`v'","L*D.`j'") == 0 local i_`j' `i_`j'' _b[`v'] 
  if strmatch("`v'","L*.`j'") == 1 & strmatch("`v'","L*D.`j'") == 0 local i_`j' `i_`j'' _b[`v'] 
  loc i_`j' = subinstr("`i_`j''", " ", "+", .)
  }
  }

  
  
// capture dependent variable 
foreach v of local iv {
  if strmatch("`v'","L*.`dv'") == 1 & strmatch("`v'","L*D.`dv'") == 0 local d_`dv' `d_`dv'' _b[`v'] 
   loc d_`dv' = subinstr("`d_`dv''", " ", "-", .)
  }
  

  
  
  
// local containing ARDL LR estimate
foreach v of local varlist {
	loc lr `lr' (`v': (`i_`v'')/(1-`d_`dv''))
}



// perform calculation
capture {
	nlcom `lr'
}
if _rc != 0 {
	local rc = _rc
	error `rc'
}
di ""
di in smcl "Estimates of Long-Run Effects"
di ""
di "     ""{ul:Variable-Specific Calculation}:" 
nlcom `lr'
}


}



// for xtdpdml

if "`cmd'" == "sem" {
loc s_iv = e(oyvars) 
loc nv = e(nvars)


mat a = e(b)[1,1..`nv']

loc s2 : colnames a


foreach v of local s2 {
	  loc y = substr("`v'", 1,length("`v'")-1) + "_" + substr("`v'", length("`v'"),.)
	  loc sem_iv `sem_iv' `y'
	}



// capture dependent variable 
foreach v of local sem_iv {
  if strmatch("`v'","`dv'_*") == 1 local d_`dv' `d_`dv'' _b[`v'] 
  loc d_`dv' = subinstr("`d_`dv''", " ", "-", .)
  loc d_`dv' = subinstr("`d_`dv''", "_", "", .)
  loc d_`dv' = subinstr("`d_`dv''", "b", "_b", .)
  }  
  





// capture independent variables of interest
foreach j of local varlist { 
  foreach v of local sem_iv {
  if strmatch("`v'","`j'_*") == 1 local i_`j' `i_`j'' _b[`v'] 
  loc i_`j' = subinstr("`i_`j''", " ", "+", .)
  loc i_`j' = subinstr("`i_`j''", "_", "", .)
  loc i_`j' = subinstr("`i_`j''", "b", "_b", .)
  }
  }

  
  
// local containing ARDL LR estimate
foreach v of local varlist {
	loc lr `lr' (`v': (`i_`v'')/(1-`d_`dv''))
}



// perform calculation
capture {
	nlcom `lr'
}
if _rc != 0 {
	local rc = _rc
	error `rc'
}
di ""
di in smcl "Estimates of Long-Run Effects"
di ""
di "     ""{ul:Variable-Specific Calculation}:" 
nlcom `lr'

}




matrix results = J(5,`nm',.)

forval i = 1/`nm' {
matrix results[1,`i'] = r(b)[1,`i']
matrix results[2,`i'] = sqrt(el(r(V),`i',`i'))
matrix results[3,`i'] = r(b)[1,`i']/sqrt(el(r(V),`i',`i'))
matrix results[4,`i'] = el(r(b),1,`i') - 1.959964*sqrt(el(r(V),`i',`i'))
matrix results[5,`i'] = el(r(b),1,`i') + 1.959964*sqrt(el(r(V),`i',`i'))
}


matrix colnames results = `varlist'
matrix rownames results = b se z ll ul


local N = r(N)
local Level = r(level)
matrix b = r(b)
matrix V = r(V)


return scalar N = `N'
return scalar Level = `Level'
return matrix b = b
return matrix V = V
return matrix results = results

end 



