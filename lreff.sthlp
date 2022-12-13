{smcl}
{* *! Version 1.1 13Dec2022}
{hi:help lreff}{right: Version 1.1 December 13, 2022}
{hline}
{title:Title}

{phang}
{bf:lreff {hline 2} Compute Long-Run Effects After Estimating a Dynamic Model.}

{title:Syntax}

{phang}
{cmd:lreff} [{varlist}(min=1)] [{cmd:,} {cmd:ecm}]

{title:Description}

{p 4 4}{cmd:lreff} computes the long-run effect for each variable specified 
after estimating a dynamic model using Stata's time series operators (e.g., L.).
The command assumes that an autoregressive distributed lag (ARDL) model is 
estimated. To compute the long-run effect after estimating an error-correction
model (ECM), the user should specify the {cmd:ecm} option. 

{title:Options}

{phang}{opt ecm} specifies that an ECM is estimated.

{title:Compatibility}

{p 4 4}{cmd:lreff} can be used when the most recent estimated model is a dynamic
model that uses Stata's time series operators (e.g., L.). In terms of panel data, it only works with homogeneous panel estimators.
The estimates are incorrect after mean group estimation. 

{p 4 4}{cmd:lreff} is confirmed to work with the following programs: 

{p 8} - reg {p_end}
{p 8} - xtreg, fe {p_end}
{p 8} - xtabond {p_end}
{p 8} - xtdpd {p_end}
{p 8} - xtdpdsys {p_end}
{p 8} - xtdpdbc {p_end}
{p 8} - xtdpdgmm {p_end}
{p 8} - xtdpdml* {p_end}
{p 8} - xtdpdqml {p_end}
{p 8} - xtivreg {p_end}
{p 8} - xtivdfreg (pooled coefficients only) {p_end}
{p 8} - xtdcce2 (pooled coefficients only) {p_end}


{p 4 6} * The coefficients are stored by time period in e(b) after using {cmd:xtdpdml} and
are reported as var(t) for contemporaneous coefficients and var(t-lag) for the lags.
{cmd:lreff} computes the long-run effects using the first time period and reports the
coefficients based on their names stored in e(b). The {opt ecm} option is not compatible
with {cmd:xtdpdml}.

{title:Examples}

{cmd:lreff} works after time series and panel commands. The examples below are based on a U.S. state-level dataset found {browse "https://github.com/rthombs/lreff/blob/main/state_data.dta":here}. 

{p 4}{ul:{cmd:xtreg} ARDL(1,1) example:}  

{p 8}{stata xtreg L(0/1).(lnff lny lnpop) i.year, fe r} 

{p 8}{stata lreff lny lnpop} 

{p 4}{ul:{cmd:xtreg} ECM(1,1) example:}  

{p 8}{stata xtreg d.lnff l.lnff d.lny l.lny d.lnpop l.lnpop i.year, fe r} 

{p 8}{stata lreff lny lnpop, ecm} 

{p 4}{ul:{cmd:reg} ARDL(2,1,0) example:}  

{p 8}{stata reg L(0/2).(lnff) L(0/1).(lny) lnpop if state=="Ohio"} 

{p 8}{stata lreff lny lnpop} 

{marker about}{title:Author}

{p 4}Ryan Thombs (Boston College){p_end}
{p 4}Email: {browse "mailto:thombs@bc.edu":thombs@bc.edu}{p_end}
{p 4}Web: {browse "www.ryanthombs.com":ryanthombs.com}{p_end}
{p 4}GitHub: {browse "https://github.com/rthombs":https://github.com/rthombs}{p_end}
