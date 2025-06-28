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

#data_selected = data[columns_of_interest]

diener_sum = data[['diener1', 'diener2', 'diener3', 'diener4', 'diener5', 'diener6', 'diener7', 'diener8']].sum(axis=1)
phq9_sum = data[['phq9_1',
                       'phq9_2', 'phq9_3', 'phq9_4', 'phq9_5', 'phq9_6', 'phq9_7', 'phq9_8', 'phq9_9']].sum(axis = 1)
gad7_sum = data[['gad7_1',
                       'gad7_2', 'gad7_3', 'gad7_4', 'gad7_5', 'gad7_6', 'gad7_7']].sum(axis = 1)


data.insert(0,'Combined_diener',diener_sum)
data.insert(1, 'Combined phq9', phq9_sum)
data.insert(2, 'Combined gad7', gad7_sum)


conditions = [
    data['race_black'] == 1, #1
    data['race_ainaan'] == 1, #2
    data['race_asian'] == 1, #3
    data['race_his'] == 1, #4
    data['race_pi'] == 1, #5
    data['race_mides'] == 1, #6
    data['race_white'] == 1, #7
    data['race_other'] == 1 #8
]
values = [1, 2, 3, 4, 2, 2, 5, 2]
print("there")
# Apply the conditions and values to create the new column
data['race'] = np.select(conditions, values, default=0)



data = data.drop(['race_black', 'race_ainaan', 'race_asian',
                       'race_his', 'race_pi', 'race_mides', 'race_white', 'race_other', 'nrweight', 'responseid'], axis = 1)

# Remove rows with missing values

data_varProp = data

# data_test = data_varProp[['Combined_diener', 'Combined phq9', 'Combined gad7', 'race','gad7_1',
#                        'gad7_2', 'gad7_3', 'gad7_4', 'gad7_5', 'gad7_6', 'gad7_7','phq9_1',
#                        'phq9_2', 'phq9_3', 'phq9_4', 'phq9_5', 'phq9_6', 'phq9_7', 'phq9_8', 'phq9_9','diener1',
#                                     'diener2', 'diener3', 'diener4', 'diener5', 'diener6', 'diener7', 'diener8']]
subsetToDrop = ['Combined_diener', 'Combined phq9', 'Combined gad7', 'race','gad7_1',
                       'gad7_2', 'gad7_3', 'gad7_4', 'gad7_5', 'gad7_6', 'gad7_7','phq9_1',
                       'phq9_2', 'phq9_3', 'phq9_4', 'phq9_5', 'phq9_6', 'phq9_7', 'phq9_8', 'phq9_9','diener1',
                                    'diener2', 'diener3', 'diener4', 'diener5', 'diener6', 'diener7', 'diener8']


data_varProp = data_varProp.dropna(subset=subsetToDrop)


data_varProp = data_varProp.drop(['gad7_1',
                       'gad7_2', 'gad7_3', 'gad7_4', 'gad7_5', 'gad7_6', 'gad7_7','phq9_1',
                       'phq9_2', 'phq9_3', 'phq9_4', 'phq9_5', 'phq9_6', 'phq9_7', 'phq9_8', 'phq9_9','diener1',
                                    'diener2', 'diener3', 'diener4', 'diener5', 'diener6', 'diener7', 'diener8'], axis = 1)

f = open("C:/Users/allur/PycharmProjects/ThreeClusterHMS/uniqueHImpact.txt", "r")
chosenVars = ['Combined_diener', 'Combined phq9', 'Combined gad7', 'race']
for line in f:
    var = line.strip()
    chosenVars.append(var)


print(chosenVars)
#data_varProp = data_varProp[['Combined_diener', 'Combined phq9', 'Combined gad7', 'race', 'age']]
data_varProp = data_varProp[chosenVars]
data_varProp = data_varProp.fillna(29845)
#print(data_varProp)
data_varProp.to_csv("C:/Users/allur/OneDrive - Dartmouth College/Desktop/Marreo Lab Work/Socially Fair K means/HMS/varProp.csv", index = False, header = False)
