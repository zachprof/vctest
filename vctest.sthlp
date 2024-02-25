{smcl}
{* *! version 1.1  Published February 25, 2024}{...}
{p2colset 2 12 14 28}{...}
{right: Version 1.1 }
{p2col:{bf:vctest} {hline 2}}Vuong and Clarke tests for nonnested model selection{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{phang}
Use {help regress} to estimate regressions underlying Vuong and Clarke tests

{p 8 18 2}
{cmdab:vctest} [:] {opt reg:ress} {depvar} {cmd:(}{indepvars:_in_model_a}{cmd:)} {cmd:(}{indepvars:_in_model_b}{cmd:)} {ifin}
[{cmd:,} {it:options}]

{phang}
Use {help boxcox} to estimate regressions underlying Vuong and Clarke tests

{p 8 18 2}
{cmdab:vctest} [:] {opt boxcox} {depvar} {cmd:(}{indepvars:_in_model_a}{cmd:)} {cmd:(}{indepvars:_in_model_b}{cmd:)} {ifin}
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt show:reg}}show regression output tables{p_end}
{synopt:{opt nocons:tant}}suppress constant terms{p_end}
{synopt:{opt successb}}Define Clarke test successes as # of obs. for which model b outperforms model a{p_end}
{synopt:{opt r:oundto(#)}}set number of decimal places to round to; # must be integer between zero and 6; default is # = 2{p_end}
{synopt:{opt rsqr:oundto(#)}}overrides option {cmd:roundto(#)} for R2; # must be integer between zero and 6; default is # = 2 or # specified by option {cmd:roundto(#)}; R2 suppressed when {help boxcox} used to estimate models{p_end}
{synopt:{opt llr:oundto(#)}}overrides option {cmd:roundto(#)} for log-likelihoods; # must be integer between zero and 6; default is # = 2 or # specified by option {cmd:roundto(#)}{p_end}
{synopt:{opt zr:oundto(#)}}overrides option {cmd:roundto(#)} for z-statistics; # must be integer between zero and 6; default is # = 2 or # specified by option {cmd:roundto(#)}{p_end}
{synopt:{opt pr:oundto(#)}}overrides option {cmd:roundto(#)} for p-values; # must be integer between zero and 6; default is # = 2 or # specified by option {cmd:roundto(#)}{p_end}
{synopt:{opt successpct(#)}}Define Clarke test successes as a % rounded to # decimal places; # must be integer between zero and 6; # has no default and must be specified{p_end}
{synoptline}


{p2colreset}{...}
{marker description}{...}
{title:Description}

{p 4 4 2}
  {opt vctest} estimates Vuong and Clarke tests for nonnested model selection.
{p_end}


{marker remarks}{...}
{title:Remarks}

{p 4 6 2}
  This code can be used to replicate all Vuong and Clarke tests in King (2024).
  {p_end}

{p 4 6 2}
  Vuong and Clarke tests are implemented using the standard approaches in Dechow (1994) and Clarke and Signorino (2010) with the Schwarz (1978) adjustment.
  {p_end}


{marker examples}{...}
{title:Examples}

{pstd}
Examples will be provided in the future at {browse "www.zach.prof":zach.prof}
{p_end}


{marker contact}{...}
{title:Author}

{pstd}
Zachary King{break}
Email: {browse "mailto:me@zach.prof":me@zach.prof}{break}
Website: {browse "www.zach.prof":zach.prof}{break}
SSRN: {browse "https://papers.ssrn.com/sol3/cf_dev/AbsByAuth.cfm?per_id=2623799":https://papers.ssrn.com}
{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:vctest} stores the following in {cmd:e()}:

{synoptset 23 tabbed}{...}
{p2col 5 23 26 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(r2a)}}R-squared for model a; no saved result if {help boxcox} used to estimate models{p_end}
{synopt:{cmd:e(r2b)}}R-squared for model b; no saved result if {help boxcox} used to estimate models{p_end}
{synopt:{cmd:e(adjr2a)}}adjusted R-squared for model a; no saved result if {help boxcox} used to estimate models{p_end}
{synopt:{cmd:e(adjr2b)}}adjusted R-squared for model b; no saved result if {help boxcox} used to estimate models{p_end}
{synopt:{cmd:e(lnLa)}}log likelihood for model a{p_end}
{synopt:{cmd:e(lnLb)}}log likelihood for model b{p_end}
{synopt:{cmd:e(lnLadja)}}log likelihood for model a after Schwarz (1978) adjustment{p_end}
{synopt:{cmd:e(lnLadjb)}}log likelihood for model b after Schwarz (1978) adjustment{p_end}
{synopt:{cmd:e(LR)}}likelihood ratio{p_end}
{synopt:{cmd:e(LRadj)}}likelihood ratio after Schwarz (1978) adjustment{p_end}
{synopt:{cmd:e(z)}}z-statistic from Vuong test{p_end}
{synopt:{cmd:e(vp2)}}two-sided p-value from Vuong test{p_end}
{synopt:{cmd:e(vp1a)}}one-sided p-value from Vuong test for model a > model b{p_end}
{synopt:{cmd:e(vp1b)}}one-sided p-value from Vuong test for model a < model b{p_end}
{synopt:{cmd:e(successes)}}number of successes from Clarke test{p_end}
{synopt:{cmd:e(cp2)}}two-sided p-value from Clarke test{p_end}
{synopt:{cmd:e(cp1a)}}one-sided p-value from Clarke test for model a > model b{p_end}
{synopt:{cmd:e(cp1b)}}one-sided p-value from Clarke test for model a < model b{p_end}


{marker references}{...}
{title:References}

{p 4 6 2}
Clarke, K. A. 2007. {browse "https://doi.org/10.1093/pan/mpm004":A simple distribution-free test for nonnested model selection}. {it:Political Analysis}, 15(3), 347-363.
  {p_end}

{p 4 6 2}
Clarke, K. A. and C. S. Signorino. 2010. {browse "https://doi.org/10.1111/j.1467-9248.2009.00813.x":Discriminating methods: Tests for non-nested discrete choice models}. {it:Political Studies}, 58(2), 368-388.
  {p_end}

{p 4 6 2}
Dechow, P. M. 1994. {browse "https://doi.org/10.1016/0165-4101(94)90016-7":Accounting earnings and cash flows as measures of firm performance: The role of accounting accruals}. {it:Journal of Accounting and Economics}, 18(1), 3-42.
  {p_end}

{p 4 6 2}
King, Z. 2024. {browse "https://ssrn.com/abstract=3722902":A New Perspective on R&D Accounting}. SSRN Working Paper.
  {p_end}

{p 4 6 2}
Schwarz, G. 1978. {browse "https://doi.org/10.1214/aos/1176344136":Estimating the dimension of a model}. {it:The Annals of Statistics}, 6(2), 461-464.
  {p_end}

{p 4 6 2}
Vuong, Q. H. 1989. {browse "https://doi.org/10.2307/1912557":Likelihood ratio tests for model selection and non-nested hypotheses}. {it:Econometrica}, 57(2), 307-333.
  {p_end}