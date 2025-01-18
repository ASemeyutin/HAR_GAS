# ============================================================================= #
#
source("1_HAR_GAS_FUN.R")
source("2_HAR_GAS_EST.R")
#
library(tidyverse)
library(ggplot2)
library(gganimate)
library(magick)
#
for (j in 1:length(IBM_vol_PDFs)){
  if (j==1){
    datum = cbind(rep(IBM$DATE[-c(1:59)][j], 1024),
                  1:1024,
                  IBM_vol_PDFs[[j]],
                  rep(par_t[j,1], 1024),
                  rep(F_vol(par_t[j,1], par_t[j,2], par_t[j,3]), 1024),
                  rep(F_skew(par_t[j,1], par_t[j,2], par_t[j,3]), 1024))
    colnames(datum) = c("date", "x", "f_x", "vol", "vol.vol", "vol.skew")
  }
  datum0 = cbind(rep(IBM$DATE[-c(1:59)][j], 1024),
                 1:1024,
                 IBM_vol_PDFs[[j]],
                 rep(par_t[j,1], 1024),
                 rep(F_vol(par_t[j,1], par_t[j,2], par_t[j,3]), 1024),
                 rep(F_skew(par_t[j,1], par_t[j,2], par_t[j,3]), 1024))
  colnames(datum0) = c("date", "x", "f_x", "vol", "vol.vol", "vol.skew")
  datum = rbind(datum, datum0)
}
#
datum = data.frame(datum)
datum$date = as.Date(datum$date)
row.names(datum) = NULL
#
# ============================================================================= #
vol_density_t = datum %>%
  ggplot() +
  aes(x = x, y = f_x) +
  geom_line() +
  labs(x = "x", y = "f(x)") +
  transition_time(date) +
  shadow_mark(alpha = 0.25) +
  labs(title = "{frame_time}") +
  theme_classic()
#
mean_vol_t = datum %>%
  group_by(date) %>%
  summarise(mvol = mean(vol)) %>%
  ggplot() +
  aes(y=mvol, x = date) + 
  geom_line() +
  labs(x = " ", y = "mean.vol") + 
  transition_reveal(date) +
  theme_classic()
#
vol_vol_t = datum %>%
  group_by(date) %>%
  summarise(mvolvol = mean(vol.vol)) %>%
  ggplot() +
  aes(y=mvolvol, x = date) + 
  geom_line() +
  labs(x = " ", y = "vol.vol") + 
  transition_reveal(date) +
  theme_classic()
#
vol_skew_t = datum %>%
  group_by(date) %>%
  summarise(mvolskew = mean(vol.skew)) %>%
  ggplot() +
  aes(y=mvolskew, x = date) + 
  geom_line() +
  labs(x = " ", y = "vol.skew") + 
  transition_reveal(date) +
  theme_classic()
#
# = = = #
#
vol_density_gif = animate(vol_density_t, 
                          nframes = 100, width = 4, height = 3,
                          units = "in", res = 200, 
                          renderer = magick_renderer())
mean_vol_gif = animate(mean_vol_t, 
                       nframes = 100, width = 4, height = 3,
                       units = "in", res = 200, 
                       renderer = magick_renderer())
vol_vol_gif = animate(vol_vol_t, 
                      nframes = 100, width = 4, height = 3,
                      units = "in", res = 200, 
                      renderer = magick_renderer())
vol_skew_gif = animate(vol_skew_t, 
                       nframes = 100, width = 4, height = 3,
                       units = "in", res = 200, 
                       renderer = magick_renderer())
#
comb_gif_r1 = image_append(c(vol_density_gif[1], mean_vol_gif[1]))
comb_gif_r2 = image_append(c(vol_vol_gif[1], vol_skew_gif[1]))
#
for (k in 2:100){
  comb_k1 = image_append(c(vol_density_gif[k], mean_vol_gif[k]))
  comb_k2 = image_append(c(vol_vol_gif[k], vol_skew_gif[k]))
  #
  comb_gif_r1 = c(comb_gif_r1, comb_k1)
  comb_gif_r2 = c(comb_gif_r2, comb_k2)
}
#
anim_save("comb_gif_r1.gif", comb_gif_r1)
anim_save("comb_gif_r2.gif", comb_gif_r2)
#
# ============================================================================== #