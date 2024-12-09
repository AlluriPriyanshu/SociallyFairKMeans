import pandas as pd
import numpy as np
import sys

filename = "//dartfs-hpc/rc/home/9/f006gq9/HMS/HMSDatasets/HMS 2016-2021combined_file_MDonly.csv"

data = pd.read_csv(filename, low_memory=False, encoding='mac_roman')

header_row = data.iloc[0]
data = data[1:]


columns_of_interest = ['diener1', 'diener2', 'diener3', 'diener4', 'diener5', 'diener6', 'diener7', 'diener8',
                       'phq9_1',
                       'phq9_2', 'phq9_3', 'phq9_4', 'phq9_5', 'phq9_6', 'phq9_7', 'phq9_8', 'phq9_9', 'gad7_1',
                       'gad7_2', 'gad7_3', 'gad7_4', 'gad7_5', 'gad7_6', 'gad7_7', 'race_black', 'race_ainaan',
                       'race_asian',
                       'race_his', 'race_pi', 'race_mides', 'race_white', 'race_other']

data_selected = data[columns_of_interest]

diener_sum = data_selected[['diener1', 'diener2', 'diener3', 'diener4', 'diener5', 'diener6', 'diener7', 'diener8']].sum(axis=1)
phq9_sum = data_selected[['phq9_1',
                       'phq9_2', 'phq9_3', 'phq9_4', 'phq9_5', 'phq9_6', 'phq9_7', 'phq9_8', 'phq9_9']].sum(axis = 1)
gad7_sum = data_selected[['gad7_1',
                       'gad7_2', 'gad7_3', 'gad7_4', 'gad7_5', 'gad7_6', 'gad7_7']].sum(axis = 1)


data_selected.insert(0,'Combined_diener',diener_sum)
data_selected.insert(1, 'Combined phq9', phq9_sum)
data_selected.insert(2, 'Combined gad7', gad7_sum)

race_columns = ['race_black', 'race_ainaan', 'race_asian', 'race_his', 'race_pi', 'race_mides', 'race_white', 'race_other']
data_selected['race_count'] = data_selected[race_columns].sum(axis=1)

conditions = [

    data_selected['race_black'] == 1, #1
    data_selected['race_ainaan'] == 1, #2
    data_selected['race_asian'] == 1, #3
    data_selected['race_his'] == 1, #4
    data_selected['race_pi'] == 1, #5
    data_selected['race_mides'] == 1, #6
    data_selected['race_white'] == 1, #7
    data_selected['race_other'] == 1, #8
    data_selected['race_count'] > 1
]

values = [1, 2, 3, 4, 2, 2, 5, 2, 2]


data_selected['race'] = np.select(conditions, values, default=0)

data_selected = data_selected.drop(['race_black', 'race_ainaan', 'race_asian',
                       'race_his', 'race_pi', 'race_mides', 'race_white', 'race_other'], axis = 1)


# Remove rows with missing values
data_selected = data_selected.dropna()

data_selected = data_selected.drop(['gad7_1',
                       'gad7_2', 'gad7_3', 'gad7_4', 'gad7_5', 'gad7_6', 'gad7_7','phq9_1',
                       'phq9_2', 'phq9_3', 'phq9_4', 'phq9_5', 'phq9_6', 'phq9_7', 'phq9_8', 'phq9_9','diener1',
                                    'diener2', 'diener3', 'diener4', 'diener5', 'diener6', 'diener7', 'diener8'], axis = 1)


svar = data_selected['race']


# Count the number of people in each race category
race_counts = data_selected['race'].value_counts()

data_selected.to_csv("C:/Users/allur/OneDrive - Dartmouth College/Desktop/Marreo Lab Work/Socially Fair K means/HMS/selectedData.csv", index = False, header = False)
svar.to_csv("C:/Users/allur/OneDrive - Dartmouth College/Desktop/Marreo Lab Work/Socially Fair K means/HMS/selectedDataSVAR.csv", index = False, header = False)