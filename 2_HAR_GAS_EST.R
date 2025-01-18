# ============================================================================= #
#
# load functions and libraries for estimations
source("1_HAR_GAS_FUN.R")
library(zoo)
library(data.table)
#
# load data and estimate a GAS HAR model parameters (just an example)
IBM = fread("IBM.csv")
par1 = optim(c(0.5, 0.5, 0.8, 0.1, 0.05, 2.75, 0.2, 0.8, 15),                   # starting values were taken from the original paper
             fllik, 
             data = IBM$RVol, model = 2, 
             method = "BFGS", control = c(maxit = 10000, trace=1))
#
# obtain actual dynamic parameters;
# note that here I only use mean and one of the d.f. parameters as time-varying
# it shall be more than enough to use static d.f. (both) for most applications 
par_t = muff_t(par1$par[1:5], v_2 = par1$par[9], 
               omega_f1 =par1$par[6], alpha_f1 = par1$par[7], 
               beta_f1 = par1$par[8], data = IBM$RVol)
#
# e.g. you can explore the dynamic d.f. parameter from below, but it is easy to 
# note that it's rather static ... 
IBM_vol_PDFs = lapply(1:nrow(par_t), 
                      function(k) f_pdf(par_t[k,1],
                                        par_t[k,2],
                                        par_t[k,3],
                                        data = seq(0, 4, length.out = 1024), 
                                        FALSE))
#
# ============================================================================= #

