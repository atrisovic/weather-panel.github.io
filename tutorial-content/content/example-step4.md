# Weather Mortality in the United States, Step 4: Producing results

## Loading the data

Here we sum across all races and ages and merge the mortality and
population data.

```R
library(dplyr)

df.mort <- read.fwf("~/groups/weatherpanels/weather-panel.github.io/example/data/cmf/Mort7988.txt",
   c(5, 4, 10, 4), col.names=c('fips', 'year', 'ignore', 'deaths'))

df2.mort <- df.mort %>% group_by(fips, year) %>% summarize(deaths=sum(deaths))

df.pop <- read.fwf("~/groups/weatherpanels/weather-panel.github.io/example/data/cmf/Pop7988.txt",
   c(5, 4, 9, rep(8, 12), 25, 1), col.names=c('fips', 'year',
   'ignore', paste0('pop', 1:12), 'county', 'type'))

df2.pop <- df.pop %>% group_by(fips, year) %>% summarize(pop=sum(pop1 +
    pop2 + pop3 + pop4 + pop5 + pop6 + pop7 + pop8 + pop9 + pop10 +
    pop11 + pop12), type=type[1])

df3 <- df2.pop %>% left_join(df2.mort, by=c('fips', 'year'))
df3$deaths[is.na(df3$deaths)] <- 0

df4 <- subset(df3, type == 3)

write.csv(df4[, -which(names(df4) == 'type')], "~/groups/weatherpanels/weather-panel.github.io/example/data/cmf/merged.csv", row.names=F)
```

## Constructing annual polynomials summed over days



## Merging weather and outcome data

## Running the regression

