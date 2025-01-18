# ============================================================================ #
#
library(xts)
library(lubridate)
library(highfrequency)
#
IBM = read.csv("IBM.txt")
IBM_date_time = ymd_hm(paste(as.Date(IBM$Date, format = "%m/%d/%Y"), 
                             sub("(.{2})$", ":\\1", IBM$Time)))
IBM = as.xts(IBM$Close, order.by = IBM_date_time)
colnames(IBM) = c("IBM")
rm(IBM_date_time)
#
IBM = aggregatePrice(IBM,
                     alignBy = "minutes",
                     alignPeriod = 5,
                     marketOpen = "09:30:00",
                     marketClose = "16:00:00",
                     fill = FALSE,
                     tz = NULL)
#
IBM = makeReturns(IBM)*100
IBM = rRVar(IBM) # or can use: # IBM = rKernelCov(IBM)
IBM = data.frame(cbind(as.Date(index(IBM)), as.numeric(IBM)))
colnames(IBM) = c("DATE", "RVol")
IBM$DATE = as.Date(IBM$DATE)
IBM = IBM[759:2012,]
#
write.csv(IBM, "IBM.csv", row.names = FALSE)
# ============================================================================ #