import pandas as pd
import numpy as np


# Load data
pwt1001 = pd.read_stata('https://dataverse.nl/api/access/datafile/354098')

# Filter and select relevant columns
data = pwt1001.loc[pwt1001['country'].isin(["France", "Germany", "Canada", "Italy", "Japan", "United Kingdom", "United States"])][['year', 'countrycode', 'rgdpna', 'rkna', 'pop', 'emp', 'avh', 'labsh', 'rtfpna']]
data = data.loc[(data['year'] >= 1995) & (data['year'] <= 2019)].dropna()

# Calculate additional columns
data['L'] = data['emp'] * data['avh']  # L
data['a'] = 1 - data['labsh']  # a(資本分配率)

data['ln_y'] = np.log(data['rgdpna'] / data['L'])
data['ln_A'] = np.log(data['rtfpna'])
data['ln_k'] = np.log(data['rkna'] / data['L'])

# Order by year
data = data.sort_values('year')

# Group by isocode
grouped_data = data.groupby('countrycode')

data['Growth Rate'] = (grouped_data['ln_y'].diff() * 100)  # 労働生産性の成長率(Growth Rate)
data['TFP growth'] = (grouped_data['ln_A'].diff() * 100)  # 技術進歩(TFP growth)
data['Capital Deepening'] = data['a'] * (grouped_data['ln_k'].diff() * 100)  # 資本深化(Capital Deepening)

# Remove missing values
data = data.dropna()

# Calculate summary statistics
summary = data.groupby('countrycode').agg({'dy': 'mean','dA': 'mean','a*dk': 'mean'})

# Print output
print(summary)