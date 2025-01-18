# ============================================================================= #
#
# F pdf for estimations with max. log-likelihood
f_pdf = function(par1, par2, par3, data, lg = TRUE){
  #
  if (lg){
    data = data[-c(1:59)]
  }
  #
  m_t = par1 
  v_1 = par2 
  v_2 = par3
  #
  p_1 = (v_1 + v_2)/2
  p_2 = v_1/(m_t * (v_2 - 2))
  #
  d_1 = gamma(p_1) / (gamma(v_1/2) * gamma(v_2/2))
  d_2 = (data ** ((v_1-2)/2)) * ((p_2)**(v_1/2))
  d_3 = (1 + (data * p_2)) ** p_1
  #
  f_d = d_1 * d_2/d_3
  #
  if (lg){
    f_d = log(f_d)
  } 
  return(f_d)
}
#
# dynamic/static parameters 
muff_t = function(par, data, v_1 = NULL, v_2 = NULL, 
                  omega_f1 = NULL, alpha_f1 = NULL, beta_f1 = NULL,
                  omega_f2 = NULL, alpha_f2 = NULL, beta_f2 = NULL,
                  sc.score = TRUE){
  dl1 = data
  dl2 = zoo::rollmean(data, 12, fill=NA, align = "right")
  dl3 = zoo::rollmean(data, 60, fill=NA, align = "right")
  #
  dlHAR = cbind(dl1, dl2, dl3)
  dlHAR = na.omit(dlHAR)
  #
  omega_mu = par[1]
  alpha_mu = par[2]
  beta1_mu = par[3]
  beta2_mu = par[4]
  beta3_mu = par[5]
  #
  t = nrow(dlHAR)
  mu_t = rep(omega_mu, t)
  #
  if (!is.null(v_1)){
    v1_t = rep(v_1, t)
  } else{
    f1_t = rep(omega_f1, t)
    v1_t = 2 + exp(f1_t)
  }
  if (!is.null(v_2)){
    v2_t = rep(v_2, t)
  } else {
    f2_t = rep(omega_f2, t)
    v2_t = 2 + exp(f2_t)
  }
  #
  for (j in 2:t){
    #
    score_mu = ((v1_t[j-1]+v2_t[j-1])/(v2_t[j-1] - 2))*dlHAR[j-1,1]
    score_mu = score_mu / ((v1_t[j-1]*dlHAR[j-1,1])/((v2_t[j-1]-2)*mu_t[j-1]) + 1) 
    score_mu = score_mu - mu_t[j-1]
    score_mu = (v1_t[j-1]/(v1_t[j-1]+1)) * score_mu
    if (sc.score){
      score_mu = score_mu / (2*mu_t[j-1]**2)/(v1_t[j-1]+1)
    }
    #
    mu_t[j] = omega_mu + alpha_mu*score_mu + beta1_mu*dlHAR[j-1,1] +  
              beta2_mu*dlHAR[j-1,2] + beta3_mu*dlHAR[j-1,3]
    #
    if (is.null(v_1)){
      score_f1 = 0.5*digamma((v1_t[j-1]+v2_t[j-1])/2)
      score_f1 = score_f1 - 0.5*digamma(v1_t[j-1]/2)
      score_f1 = score_f1 + 0.5*(log(v1_t[j-1]/(v2_t[j-1]-1))+1)
      score_f1 = score_f1 + 0.5*log(dlHAR[j-1,1]/mu_t[j-1])
      score_f1 = score_f1 - 0.5*log((v1_t[j-1]/(v2_t[j-1]-2)*dlHAR[j-1,1]/mu_t[j-1])+1)
      score_fa = ((v1_t[j-1]+v2_t[j-1])/2)*(dlHAR[j-1,1]/(mu_t[j-1]*(v2_t[j-1]-2)))
      score_fa = score_fa / ((v1_t[j-1]*dlHAR[j-1,1])/(mu_t[j-1]*(v2_t[j-1]-2))+1)
      score_f1 = (score_f1 - score_fa) * (v1_t[j-1]-2)
      #
      f1_t[j] = (1-beta_f1)*omega_f1 + alpha_f1*score_f1 + beta_f1*f1_t[j-1]
      v1_t[j] = 2 + exp(f1_t[j])
    }
    #
    if (is.null(v_2)){
      score_f2 = 0.5*digamma((v1_t[j-1]+v2_t[j-1])/2)
      score_f2 = score_f2 - 0.5*digamma(v2_t[j-1]/2)
      score_f2 = score_f2 - 0.5*(v1_t[j-1]/(v2_t[j-1])-1)
      score_f2 = score_f2 - 0.5*log((v1_t[j-1]/(v2_t[j-1]-2)*dlHAR[j-1,1]/mu_t[j-1])+1)
      score_fb = ((v1_t[j-1]+v2_t[j-1])/2)*((dlHAR[j-1,1]*v1_t[j-1])/(mu_t[j-1]*(v2_t[j-1]-2)**2))
      score_fb = score_fb / (1+((v1_t[j-1]*dlHAR[j-1,1])/(mu_t[j-1]*(v2_t[j-1]-2))))
      score_f2 = (score_f2 + score_fb) * (v2_t[j-1]-2)
      #
      f2_t[j] = (1-beta_f2)*omega_f2 + alpha_f2*score_f2 + beta_f2*f2_t[j-1]
      v2_t[j] = 2 + exp(f2_t[j])
    }
  }
  #
  par_t = cbind(mu_t, v1_t, v2_t)
  return(par_t)
}
#
# log-likelihood function that returns estimated parameters
fllik = function(par, data, model=1){
  if (model == 1){
    pl = length(par)
    if (pl == 7){
      if (any(par<0)){
        f1 = 1e20
      } else if (par[2]>1){
        f1 = 1e20
      } else if (sum(par[3:5])>1){
        f1 = 1e20
      } else {
        dyn_par = muff_t(par = par[1:5], v_1 = par[6], v_2 = par[7], 
                         data = data, sc.score = TRUE)
        f1 = -mean(f_pdf(dyn_par[,1], dyn_par[,2], dyn_par[,3], data, lg = TRUE))
      }
    } else {
      print("Number of parameters for model 1 must be equal to 7")
    } 
  } else if (model == 2){
    pl = length(par)
    if (pl == 9){
      if (any(par<0)){
        f1 = 1e20
      } else if (any(par[c(2,7,8)]>1)){
        f1 = 1e20
      } else if (sum(par[3:5])>1){
        f1 = 1e20
      } else {
        dyn_par = muff_t(par = par[1:5], v_2 = par[9],
                         omega_f1 = par[6], alpha_f1 = par[7], beta_f1 = par[8],  
                         data = data, sc.score = TRUE)
        f1 = -mean(f_pdf(dyn_par[,1], dyn_par[,2], dyn_par[,3], data, lg = TRUE))
      }
    } else {
      print("Number of parameters for model 2 must be equal to 9")
    }
  } else if (model == 3){
    pl = length(par)
    if (pl == 9){
      if (any(par<0)){
        f1 = 1e20
      } else if (any(par[c(2,7,8)]>1)){
        f1 = 1e20
      } else if (sum(par[3:5])>1){
        f1 = 1e20
      } else {
        dyn_par = muff_t(par = par[1:5], v_1 = par[9],
                         omega_f2 = par[6], alpha_f2 = par[7], beta_f2 = par[8],  
                         data = data, sc.score = TRUE)
        f1 = -mean(f_pdf(dyn_par[,1], dyn_par[,2], dyn_par[,3], data, lg = TRUE))
      }
    } else {
      print("Number of parameters for model 3 must be equal to 9")
    }
  } else if (model == 4){
    pl = length(par)
    if (pl==11){
      if (any(par<0)){
        f1 = 1e20
      } else if (any(par[c(2,7,8,10,11)]>1)){
        f1 = 1e20
      } else if (sum(par[3:5])>1){
        f1 = 1e20
      } else {
        dyn_par = muff_t(par = par[1:5],
                         omega_f1 = par[6], alpha_f1 = par[7], beta_f1 = par[8],
                         omega_f2 = par[9], alpha_f2 = par[10], beta_f2 = par[11],
                         data = data, sc.score = TRUE)
        f1 = -mean(f_pdf(dyn_par[,1], dyn_par[,2], dyn_par[,3], data, lg = TRUE))
      }
    } else {
      print("Number of parameters for model 4 must be equal to 11")
    }
  } else {
    print("model choice must be between 1 and 4 as there are only 4 models currently implemented")
  }
  return(f1)
}
#
# ============================================================================= #
# 
# functions for calculating vol-vol & vol-skew
F_vol = function (par1, par2, par3){
  f_v = par2 + par3 - 2
  f_v = f_v / ((par3 - 4)*par2)
  f_v = (par1 ** 2) * f_v * 2
  return(f_v)
}
#
F_skew = function (par1, par2, par3){
  f_s = (par3 - 2)**3
  f_s = f_s * ((2 * par2) + par3 - 2)
  f_s = f_s * sqrt(8 * (par3 - 4))
  f_s = f_s / par3**3
  f_s = f_s / (par2 - 6)
  f_s = f_s / sqrt(par2 * (par2 + par3 - 2))
  f_s = f_s * (par1**3)
  return(f_s)
}
#
# ============================================================================= #