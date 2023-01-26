#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Jan 26 12:48:26 2023

@author: nloreedwards
"""

#%%
import pandas as pd

working_directory = "/export/home/dor/nloreedwards/Documents/Git_Repos/boardex/"
data_directory = "/export/home/dor/nloreedwards/Documents/BoardEx/data/"
#%%

df1 = pd.read_csv(data_directory + "Compustat Global 8-30")
df2 = pd.read_csv(data_directory + "Compustat US 8-30")

df = pd.concat([df1, df2], ignore_index=True)

df.dropna(subset='isin', inplace=True)
drop if isin == ""
collapse at emp revt, by(gvkey fyear exchg isin sedol conm fic stko indfmt consol popsrc datafmt tic cusip curcd cik costat naics sic)

rename fyear year