import pandas as pd
import numpy as np
from linearmodels.panel import PanelOLS
from scipy.stats import t
import matplotlib.pyplot as plt

# Read data
clim = pd.read_csv("../data/climate_data/agg_vars.csv")
df = pd.read_csv("../data/cmf/merged.csv")

# Merge datasets
df2 = pd.merge(df, clim, how='left', left_on=['fips', 'year'], right_on=['FIPS', 'year'])

# Create new variable
df2['deathrate'] = 100000 * df2['deaths'] / df2['pop']
df2.loc[df2['deathrate'] == float("inf"), 'deathrate'] = np.nan

# Categories and numbers
df2['state'] = (df2['fips'] / 1000).astype(int).astype(str)

# Drop rows with missing values
df2 = df2.dropna(subset=['deathrate', 'tas_adj', 'tas_sq'])

df2 = df2.set_index(['FIPS', 'year'])

# Create separate columns for state-specific trends using dummy variable expansion
state_dummies = pd.get_dummies(df2['state'], prefix='state')
state_trends = state_dummies.mul(df2.index.get_level_values('year'), axis=0)

# Fixed effects regression

# Merge the state-specific trends with the exogenous variables
exog = pd.concat([df2[['tas_adj', 'tas_sq']], state_trends], axis=1)

mod = PanelOLS(df2.deathrate, exog, entity_effects=True)
clustered = mod.fit(cov_type='clustered', cluster_entity=True)

# Prediction dataframe
plotdf = pd.DataFrame({'tas': range(-20, 41)})
plotdf['tas_adj'] = plotdf['tas'] - 20
plotdf['tas_sq'] = plotdf['tas']**2 - 20**2

# Point estimate prediction
coefficients = clustered.params[0:2]
preds = plotdf[['tas_adj', 'tas_sq']]
prediction = np.dot(preds, coefficients)

# Confidence interval prediction
vcov = clustered.cov.iloc[0:2, 0:2]
ses = np.sqrt(np.diag(np.dot(np.dot(preds, vcov), np.transpose(preds))))
degfree = len(df2) - len(clustered.params) - clustered.df_model - 1
ci_upper = prediction + t.ppf(0.975, degfree) * ses
ci_lower = prediction + t.ppf(0.025, degfree) * ses

# Create final dataframe for visualization
plotdf2 = pd.concat([plotdf, pd.DataFrame({'y': prediction, 'cilo': ci_lower, 'cihi': ci_upper})], axis=1)

# Plotting
plt.figure(figsize=(10, 6))
plt.plot(plotdf2.tas.values, plotdf2.y.values)

# Confidence interval
plt.fill_between(plotdf2.tas, plotdf2.cilo, plotdf2.cihi, color='grey', alpha=.5)

plt.xlabel('Daily temperature (C)')
plt.ylabel("Deaths per 100,000 people")
plt.title('Excess death rate as a function of temperature')
plt.grid(True)
plt.show()
