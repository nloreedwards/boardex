#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Aug 28, 2022

@author: nloreedwards
"""
#%%
import pandas as pd

working_directory = "/export/home/dor/nloreedwards/Documents/Git_Repos/boardex/"
data_directory = "/export/home/dor/nloreedwards/Documents/BoardEx/data/"
#%%
# Load key created by RAs classifying each role
roleKey = pd.read_stata(data_directory + "c-suite_roles_key_formerge_exp.dta")

# Load and append BoardEx data (files by region)
df1 = pd.read_stata(data_directory + "szjadkbqppod3snh.dta")
df2 = pd.read_stata(data_directory + "qlufvmvn2xvizniz.dta")
df3 = pd.read_stata(data_directory + "loqpa6qftokutbrb.dta")
df4 = pd.read_stata(data_directory + "ajpv5zbsoh7tjplg.dta")

df = pd.concat([df1, df2, df3, df4], ignore_index=True)

# Drop duplicates, generate start/end dates
df = df.drop_duplicates()

df['start_year'] = df['DateStartRole'].apply(lambda x: x.year)
df['end_year'] = df['DateEndRole'].apply(lambda x: x.year)

# Drop observations with no start date and no end date
df = df.dropna(how='all', subset=['start_year', 'end_year'])

# Remove additional duplicates
df = df.drop(['CompanyName', 'DirectorID', 'DirectorName', 'DateStartRole', 'DateEndRole'], axis=1)
df = df.drop_duplicates()

#%%
### This section reshapes the data so that we have long data with 1 observation per year, using the date ranges
# Create indicator for each year
for i in range(2000,2021):
    var_name = "year_" + str(i)
    df[var_name] = 0
    df.loc[((df['end_year'] >= i) | (pd.isna(df['end_year']))) & ((df['start_year'] <= i) | (pd.isna(df['start_year']))), var_name] = 1

# Reshape data using year indicator columns
df = pd.melt(df, id_vars=['CompanyID', 'RoleName', 'Seniority', 'start_year', 'end_year'], value_vars=['year_2000', 'year_2001', 'year_2002', 'year_2003', 'year_2004', 'year_2005', 'year_2006', 'year_2007', 'year_2008', 'year_2009', 'year_2010', 'year_2011', 'year_2012', 'year_2013', 'year_2014', 'year_2015', 'year_2016', 'year_2017', 'year_2018', 'year_2019', 'year_2020'], var_name='year', value_name='contains_year', col_level=None, ignore_index=True)

# Drop if observation is not contained in year
df = df[df['contains_year'] == 1]

# Clean up year variable
df['year'] = df['year'].str.slice(start=-4)
df['year'] = df['year'].apply(int)

df = df.drop(['contains_year'], axis=1)
#%%
# Merge in position classifications
df = df.merge(roleKey, on='RoleName', how='left')
positions = ['pos_Chair', 'pos_CAcc', 'pos_CAO', 'pos_CAE', 'pos_CBank', 'pos_CBrand', 'pos_CBus', 'pos_CComm', 'pos_CCommunication', 'pos_CCO_comp', 'pos_CCO_cont', 'pos_CCounsel', 'pos_CCreat', 'pos_CCredit', 'pos_CCustom', 'pos_CDev', 'pos_CDigit', 'pos_CDO', 'pos_CDiv', 'pos_CEO', 'pos_CEthics', 'pos_CFO', 'pos_CGov', 'pos_CHRO', 'pos_CInnov', 'pos_CIO', 'pos_CInvest', 'pos_CKO', 'pos_CLegal', 'pos_CMO', 'pos_CMed', 'pos_CMerch', 'pos_COO', 'pos_CPO', 'pos_CProcure', 'pos_CRev', 'pos_CRisk', 'pos_CSales', 'pos_CSci', 'pos_CSO_sec', 'pos_CStaff', 'pos_CStrat', 'pos_CSO_sus', 'pos_CSupp', 'pos_CTal', 'pos_CTax', 'pos_CTO', 'pos_Chief']

# Keep only observations classified as a C-Suite position
df ['has_pos'] = df[positions].max(axis=1)
df = df[df['has_pos'] == 1]

#%%
# Save data
pd.to_csv(data_directory + "c_suite_data2_exp.csv", index=False)