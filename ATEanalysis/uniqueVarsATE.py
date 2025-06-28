import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LinearRegression, LogisticRegression
from econml.dml import LinearDML
import numpy as np
import sys
from sklearn.preprocessing import StandardScaler
import matplotlib.pyplot as plt

filename = "//dartfs-hpc/rc/home/9/f006gq9/HMS/HMSDatasets/HMS 2016-2021combined_file_MDonly.csv"

data = pd.read_csv(filename, low_memory=False, encoding='mac_roman')

conditions = [
    data['race_black'] == 1,  # 1
    data['race_ainaan'] == 1,  # 2
    data['race_asian'] == 1,  # 3
    data['race_his'] == 1,  # 4
    data['race_pi'] == 1,  # 5
    data['race_mides'] == 1,  # 6
    data['race_white'] == 1,  # 7
    data['race_other'] == 1   # 8
]
values = [4, 5, 2, 3, 5, 5, 1, 5]

data['race'] = np.select(conditions, values, default=0)

data = data.drop(['race_black', 'race_ainaan', 'race_asian',
                  'race_his', 'race_pi', 'race_mides', 'race_white', 'race_other'], axis=1)

diener_sum = data[['diener1', 'diener2', 'diener3', 'diener4', 'diener5', 'diener6', 'diener7', 'diener8']].sum(axis=1)
phq9_sum = data[['phq9_1', 'phq9_2', 'phq9_3', 'phq9_4', 'phq9_5', 'phq9_6', 'phq9_7', 'phq9_8', 'phq9_9']].sum(axis=1)
gad7_sum = data[['gad7_1', 'gad7_2', 'gad7_3', 'gad7_4', 'gad7_5', 'gad7_6', 'gad7_7']].sum(axis=1)

data.insert(0, 'combined_diener', diener_sum)
data.insert(1, 'combined_phq9', phq9_sum)
data.insert(2, 'combined_gad7', gad7_sum)

highestImpact = []
dienerHImpact = []
phqHImpact = []
gadHImpact = []

onlyVars = []
f = open("C:/Users/allur/PycharmProjects/ThreeClusterHMS/uniqueVars_Nonfair.txt", "r")

for line in f:
    var = line.strip()

    df = data[[var, 'combined_diener', 'combined_phq9', 'combined_gad7']]
    df = df.dropna()
    Y = df[['combined_diener', 'combined_phq9', 'combined_gad7']]

    model_y = [
        LinearRegression(),  # for combined_diener
        LinearRegression(),  # for combined_phq9
        LinearRegression()  # for combined_gad7
    ]
    model_t = LogisticRegression()
    dfBackup = df

    unique_values = df[var].value_counts()
    for i in range(len(unique_values)):
        df = data[[var, 'combined_diener', 'combined_phq9', 'combined_gad7']]
        df = df.dropna()
        if unique_values.iloc[i] > 20:
            T0 = unique_values.index[i]
            T1 = T0-1
            df[var] = df[var].apply(lambda x: T1 if x != T0 else x)
            print("RUN")
            if df[var].value_counts().iloc[1] < 20:
                print("CONTINUED")
                continue

            T = df[var]

            dml = LinearDML(model_y=model_y, model_t=model_t, discrete_treatment=True)
            try:
                dml.fit(Y, T)
            except:
                print("T0 is", T0)
                print("T1 is", T1)
                print("These are the unique values:", df[var].value_counts())
                df = dfBackup
                print('\n')
                print("These are the unique values in orig df:", df[var].value_counts)
                df[var] = df[var].apply(lambda x: T1 if x != T0 else x)
                print(df[var].value_counts())

                df = data[['age', var, 'combined_diener', 'combined_phq9', 'combined_gad7']]
                df = df.dropna()
                print("NOW UPDATED")
                print(df[var])
                print(df[var].value_counts())
            # Estimate the ATE for each outcome
            ate = dml.ate(T0=T0, T1=T1)
            ate_diener = ate[0]
            ate_phq = ate[1]
            ate_gad = ate[2]

            sum_abs_ate = np.sum(np.abs(ate))

            if 1 > 0:
                appendVars = (var, sum_abs_ate)
                onlyVars.append(appendVars)
                temp = (var + " tv: " + str(unique_values.index[i]) + " diener_ate: " + str(ate_diener) + " Sample Size: " +str(unique_values.iloc[i]), ate_diener)
                dienerHImpact.append(temp)
                temp = (var + " tv: " + str(unique_values.index[i]) + " phq_ate: " + str(
                    ate_phq) + " Sample Size: " + str(unique_values.iloc[i]), ate_phq)
                phqHImpact.append(temp)
                temp = (var + " tv: " + str(unique_values.index[i]) + " gad_ate: " + str(
                    ate_gad) + " Sample Size: " + str(unique_values.iloc[i]), ate_gad)
                gadHImpact.append(temp)




diener_sorted = sorted(dienerHImpact, key=lambda x: abs(x[1]), reverse=True)
phq_sorted = sorted(phqHImpact, key=lambda x: abs(x[1]), reverse=True)
gad_sorted = sorted(gadHImpact, key=lambda x: abs(x[1]), reverse=True)
onlyVars = sorted(onlyVars, key=lambda x: abs(x[1]), reverse=True)

with open('DienerHImpact_uniqueVarsNonfair.txt', 'w') as file:
    for item in diener_sorted:
        file.write(f"{item[0]}\n")

with open('PhqHImpact_uniqueVarsNonfair.txt', 'w') as file:
    for item in phq_sorted:
        file.write(f"{item[0]}\n")

with open('GadHImpact_uniqueVarsNonfair.txt', 'w') as file:
    for item in gad_sorted:
        file.write(f"{item[0]}\n")

with open('onlyVars_uniqueVarsNonfair.txt', 'w') as file:
    for item in onlyVars:
        file.write(f"{item[0]}\n")

