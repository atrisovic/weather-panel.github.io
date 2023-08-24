## setwd("~/groups/weatherpanels/weather-panel.github.io/example/data")

library(dplyr)
library(lfe)
library(ggplot2)
source("~/projects/research-common/R/felm-tools.R")

clim <- read.csv("../data/climate_data/agg_vars.csv")
df <- read.csv("../data/cmf/merged.csv")

df2 <- df %>% left_join(clim, by=c('fips'='FIPS', 'year'))

df2$deathrate <- 100000 * df2$deaths / df2$pop
df2$deathrate[df2$deathrate == Inf] <- NA

df2$state <- as.character(floor(df2$fips / 1000))
df2$year <- as.numeric(df2$year)

mod <- felm(deathrate ~ tas_adj + tas_sq | factor(state) : year +  factor(fips) | 0 | fips, data=df2)

plotdf <- data.frame(tas=seq(-20, 40))
plotdf$tas_adj <- plotdf$tas - 20
plotdf$tas_sq <- plotdf$tas^2 - 20^2

preddf <- predict.felm(mod, plotdf, interval='confidence')

plotdf2 <- cbind(plotdf, preddf)

ggplot(plotdf2, aes(tas, fit)) +
    geom_line() + geom_ribbon(aes(ymin=lwr, ymax=upr), alpha=.5) +
    scale_x_continuous(name="Daily temperature (deg. C)", expand=c(0, 0)) +
    ylab("Deaths per 100,000 people") +
    ggtitle("Excess death rate as a function of temperature") + theme_bw()
ggsave("../../tutorial-content/content/images/doseresp.png", width=5.7, height=3.8)
