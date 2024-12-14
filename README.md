# HAR GAS Volatility Model(s) by Opschoor & Lucas (2023) from IJF
 
I think every economist has a weak spot about time series econometrics and if you ever wanted to ***model volatility while modelling volatility***, then I guess you are not alone. 

This repo provides a set of functions to estimate HAR models by Opschoor & Lucas (2023) for realised volatility under the GAS framework using ML. Model allows GAS dynamics for any of the parameters of the data generating process and thus shall be quite appealing for modelling higher moments of realised volatility (i.e. skewness).

To simplify, Opschoor & Lucas (2023) specification relies on the **F distribution** as data generating process and leverages the GAS framework to obtain dynamic, conditional realised volatility (similar to traditional HAR),  its volatility (scale) and skewness parameters. Model can be outlined with $$f(x)=\frac{\Gamma((v_1 + v_2)/2)}{\Gamma(v_1/2)\cdot\Gamma(v_2/2)}\cdot\frac{x^{(v_1-2)/2} \cdot \left(\dfrac{v_1}{\mu (v_2 -2)} \right)^{v_1/2}}{\left(1+\dfrac{v_1}{v_2 -2}\cdot\dfrac{x}{\mu}\right)^{(v_1+v_2)/2}}$$ **F probability density function** and dynamic parameters for 
$$\mu_{t+1} = \omega_{\mu} + \alpha_{\mu}\cdot S_{\mu,t} + \beta_{\mu_1, t}\cdot \mu_{l_1,t} + \beta_{\mu_2, t}\cdot \mu_{l_2,t} + \beta_{\mu_3, t}\cdot \mu_{l_3,t} ; \\ 
v_{1,t+1} = \omega_{v_1} + \alpha_{v_1}\cdot S_{v_1,t} + \beta_{ v_1, t}\cdot v_{1,t}; \\ 
v_{2,t+1} = \omega_{v_2} + \alpha_{v_2}\cdot S_{v_2,t} + \beta_{ v_2, t}\cdot v_{2,t}, $$ where $$ S_{\mu,t} = \frac{v_1 }{v_1+1} \cdot \left(\frac{\dfrac{x(v_1+v_2)}{v_2 - 2}}{1+\dfrac{v_1\cdot x}{\mu_t(v_2 -2)}} - \mu_t\right); 
\\ S_{v_1,t} = \left[\dfrac{1}{2}\psi\left(\frac{v_{1,t} + v_2}{2}\right) - \dfrac{1}{2}\psi\left(\frac{v_{1,t} }{2}\right) + \dfrac{1}{2}\left(\log\left(\dfrac{v_{1,t}}{v_2 - 2}\right) +1\right)  \right]  (v_{1,t} -2) + \\ +
\\ S_{v_2,t} = $$

will come back tomorrow, writting code is easier than writting readme files for me, why people praise chatgpt at all
