# HAR GAS Volatility Model(s) by Opschoor & Lucas (2023) from IJF
 
I think every economist has a soft spot for time series econometrics and if you ever wanted to ***model volatility while modelling volatility***, then I guess you are not alone. 

This repo provides a set of functions to estimate HAR models by Opschoor & Lucas (2023) for realised volatility under the GAS framework using ML. Model allows GAS dynamics for any of the parameters of the data generating process and thus shall be quite appealing for modelling higher moments of realised volatility (i.e. skewness and utilise it to further enhance volatility modelling, etc).

To simplify, Opschoor & Lucas (2023) specification relies on the **F distribution** as its data generating process and leverages the GAS framework to obtain dynamic, conditional realised volatility (similar to the traditional HAR), its volatility (scale) and skewness parameters. Model can be outlined with 

$$f(x)=\frac{\Gamma((v_1 + v_2)/2)}{\Gamma(v_1/2)\cdot\Gamma(v_2/2)}\cdot\frac{x^{(v_1-2)/2} \cdot \left(\dfrac{v_1}{\mu (v_2 -2)} \right)^{v_1/2}}{\left(1+\dfrac{v_1}{v_2 -2}\cdot\dfrac{x}{\mu}\right)^{(v_1+v_2)/2}}$$ 

**F probability density function** and dynamic parameters for
```math
\begin{aligned}
\mu_{t+1} &=& \omega_{\mu} + \alpha_{\mu}\cdot S_{\mu,t} + \beta_{\mu_1, t}\cdot \mu_{l_1,t} + \beta_{\mu_2, t}\cdot \mu_{l_2,t} + \beta_{\mu_3, t}\cdot \mu_{l_3,t}; \\
v_{1,t+1} &=& \omega_{v_1} + \alpha_{v_1}\cdot S_{v_1,t} + \beta_{ v_1, t}\cdot v_{1,t}; \\
v_{2,t+1} &=& \omega_{v_2} + \alpha_{v_2}\cdot S_{v_2,t} + \beta_{ v_2, t}\cdot v_{2,t},  
\end{aligned}
```
where 
```math
\begin{aligned}
S_{\mu,t} &=& \frac{v_1 }{v_1+1} \cdot \left(\frac{\dfrac{x(v_1+v_2)}{v_2 - 2}}{1+\dfrac{x \cdot v_1}{\mu_t(v_2 -2)}} - \mu_t\right); \\
S_{v_1,t} &=& \left[\dfrac{1}{2}\psi\left(\frac{v_{1,t} + v_2}{2}\right) - \dfrac{1}{2}\psi\left(\frac{v_{1,t} }{2}\right) + \dfrac{1}{2}\left(\log\left(\dfrac{v_{1,t}}{v_2 - 2}\right) +1\right)  \right]  (v_{1,t} - 2) + \\
          &+& \left[\dfrac{1}{2}\log\left(\dfrac{x}{\mu_t}\right) - \dfrac{1}{2}\log\left(1 + \dfrac{x \cdot v_{1,t}}{\mu_t(v_2 -2)} \right) \right] (v_{1,t} - 2) - \\
          &-& \left[\dfrac{v_{1,t} + v_2}{2}\cdot \dfrac{\frac{x}{\mu_t(v_2 - 2)}}{1+\frac{x \cdot v_{1,t}}{\mu_t(v_2 - 2)}}  \right] (v_{1,t} - 2); \\
S_{v_2,t} &=& \left[ \dfrac{1}{2}\psi\left(\frac{v_{1,t} + v_{2,t}}{2}\right) - \dfrac{1}{2}\psi\left(\frac{v_{2,t} }{2}\right) + \dfrac{v_{1,t}}{2 (v_{2,t}-1)}  \right]  (v_{2,t} - 2) - \\
          &-& \left[ \dfrac{1}{2}\log\left(1 + \dfrac{x \cdot v_{1,t}}{\mu_t(v_{2,t} -2)} \right) \right] (v_{2,t} - 2) + \\
          &+& \left[\dfrac{v_{1,t} + v_{2,t}}{2}\cdot \dfrac{\frac{x \cdot v_{1,t}}{\mu_t(v_{2,t} - 2)^2}}{1+\frac{x \cdot v_{1,t}}{\mu_t(v_{2,t} - 2)}}  \right] (v_{2,t} - 2),
\end{aligned}
```
with $\Gamma$ and $\psi$ denoting standard gamma and digamma mathematical functions, and $v_{1,t} = 2 + \exp(S_{v_{1,t}})$ and $v_{2,t} = 2 + \exp(S_{v_{2,t}})$ to ensure that time-varying degrees of freedom satistfy **F distribution** requirements. Note that $\mu_{l_1,t} = l^{-1} \sum_{i=0}^{l-1} x_{t-i}$ with $l_2 = 12$ and $l_3 = 60$ respectively. By allowing different combinations of parameters to vary over time, the above specification provides several different models under the **F distribution** for realised volatility. Typically the biger (longer) is the sample the more value can be harvested from allowing additional parameters to vary over time; in practice, time varying mean (conditional realised volatility) shall be sufficient in most of the cases. To illustrate, below is the IBM conditional realised volatility and its time-varying density (time-varying first and second parameters of the **F distribution** model specification):

![](https://github.com/ASemeyutin/HAR_GAS/blob/main/comb_gif_r1.gif)

and its second and third moments:

![](https://github.com/ASemeyutin/HAR_GAS/blob/main/comb_gif_r2.gif)

````
Short description of the R files:
1. 0_REAL_VOL_IBM.R produces IBM.csv from the raw IBM intraday prices. Please note that the raw data is not provided.
2. 1_HAR_GAS_FUN.R contains HAR GAS model(s) main functions. 
3. 2_HAR_GAS_EST.R estimates HAR GAS model(s) parameter estimations using the standard BFGS optimisation routine.
4. 3_HAR_GAS_ILL.R replicates the figures above (comb_gif_r1.gif and comb_gif_r2.gif). 
````
Finally, 1_GAS_FUN.R scales the score function with $2\mu_t^2(v_1 + 1)$ in the mean equation to allow for the curvature in the log-conditional density with respect to $\mu_t$ and parametrisizes intercepts in the degrees of freedom equations as the unconditional mean of the time-varying parameters similar to the original paper (other parameter restrictions are arbitrary and are drawn from the Table summarising statistics of the ML parameter estimates).  

Opschoor, A., & Lucas, A. (2023). Time-varying variance and skewness in realized volatility measures. *International Journal of Forecasting, 39*(2), 827-840.
