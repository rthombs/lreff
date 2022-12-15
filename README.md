# `lreff`
A Stata command to compute long-run effects after estimating a dynamic model.

# Description 
`lreff` computes the long-run effect for each variable specified after estimating a dynamic model
using Stata's time series operators (e.g., L.). The command assumes that an autoregressive distributed
lag (ARDL) model is estimated. To compute the long-run effect after estimating an error-correction model
(ECM), the user should specify the `ecm` option. Standard errors are estimated using the [delta method](https://www.stata.com/support/faqs/statistics/delta-method/) 
by collecting the coefficients and passing 
them to Stata's [`nlcom`](https://www.stata.com/manuals/rnlcom.pdf) command. 

# Syntax

     lreff varlist(min=1) [, ecm]

# Options

`ecm` specifies that an ECM is estimated.

# Compatibility

`lreff` can be used when the most recent estimated model is a dynamic model that uses Stata's time series
operators (e.g., L.). In terms of panel data, it only works with homogeneous panel estimators. The estimates are
incorrect after mean group estimation. 

`lreff` is confirmed to work with the following programs: 

- `reg` 
- `xtreg, fe` 
- `xtabond`
- `xtdpd`
- `xtdpdsys`
- `xtdpdbc` 
- `xtdpdgmm`
- `xtdpdml`[^1]
- `xtdpdqml` 
- `xtivreg`
- `xtivdfreg` (pooled coefficients only) 
- `xtdcce2` (pooled coefficients only)

[^1]: The coefficients are stored by time period in e(b) after using `xtdpdml` and are reported as var(t) for
contemporaneous coefficients and var(t-lag) for the lags. `lreff` computes the long-run effects using the 
first time period and reports the coefficients based on their names stored in e(b). The `ecm` option is not compatible
with `xtdpdml`.

# Examples

`lreff` works after time series and panel commands. The examples below are based on a U.S. state-level dataset found [here](https://github.com/rthombs/lreff/blob/main/state_data.dta). 

**`xtreg` ARDL(1,1) example:**  

     xtreg L(0/1).(lnff lny lnpop) i.year, fe r

     lreff lny lnpop

**`xtreg` ECM(1,1) example:**  

     xtreg d.lnff l.lnff d.lny l.lny d.lnpop l.lnpop i.year, fe r

     lreff lny lnpop, ecm 

**`reg` ARDL(2,1,0) example:** 

     reg L(0/2).(lnff) L(0/1).(lny) lnpop if state=="Ohio"

     lreff lny lnpop
     
The results are stored in **r(results)**, which can be displayed with `matlist r(results)`. 

# Install 

`lreff` can be installed by typing the following in Stata:

    net install lreff, from("https://raw.githubusercontent.com/rthombs/lreff/main") replace

# Author

[**Ryan P. Thombs**](ryanthombs.com)  
**(Boston College)**  
**Contact Me: [thombs@bc.edu](mailto:thombs@bc.edu)**





