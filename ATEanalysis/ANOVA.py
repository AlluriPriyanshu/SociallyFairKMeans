import sys

import statsmodels
import scikit_posthocs as sp
from scipy.stats import kruskal, median_test
import pandas as pd
import numpy as np
from scipy.stats import f_oneway, chi2_contingency
import warnings
import scipy.stats as stats
from statsmodels.stats.multicomp import pairwise_tukeyhsd
from statsmodels.stats.proportion import proportions_ztest

numberNumeric = 0
# Turn off all warnings
warnings.filterwarnings("ignore")

def perform_median_test(groups):
    stat, p, _, _ = median_test(*groups)
    return p
def has_two_unique_values(df, column_name):
    return df[column_name].nunique() == 2

def is_ordinal(data, column_name):
    unique_values = data[column_name].nunique()
    total_values = len(data[column_name])
    # Arbitrary threshold to distinguish ordinal from numeric
    return unique_values / total_values < 0.1

def perform_chi_square_test(data, race_column, variable):
    contingency_table = pd.crosstab(data[race_column], data[variable])
    chi2, p, dof, expected = chi2_contingency(contingency_table)
    if p < 0.05:
        print(p, "PRIMARY CHI P")
    return p
# Runs one way ANOVA on the variables given in raceVals with p value = 0.05
# raceVals[1] corresponds to White, 2 to Asian, then Black, Hispanic, Other
def checkANOVA(raceVals):
    global numberNumeric
    numberNumeric += 1
    stat, p_val = f_oneway(*raceVals)
    if p_val < 0.05:
        print(p_val, "checkANOVA!")
        return True
    return False

def perform_postHocChi(data, race_column, variable):
    results = []
    for i, j in [(0,2),(0,3),(1,2),(1,3)]:
        dataFiltered = data[data[race_column].isin([i + 1, j + 1])]
        contingency_table = pd.crosstab(dataFiltered[race_column], dataFiltered[variable])
        chi2, p, dof, expected = chi2_contingency(contingency_table)
        results.append(p)
    alphaLevel = 0.05 / len(results)
    if all(p < alphaLevel for p in results):
        # print(results, "POST HOC CHI!")
        return True
    return False

def twoPropZtest(groups):
    results = []
    count = np.array([sum(groups[0]), sum(groups[1]), sum(groups[2]), sum(groups[3]), sum(groups[4])])
    nobs = np.array([len(groups[0]), len(groups[1]), len(groups[2]), len(groups[3]), len(groups[4])])
    numComparisons  = 0
    for counts, nobs in [([count[0], count[2]], [nobs[0], nobs[2]]),
                         ([count[0], count[3]], [nobs[0], nobs[3]]),
                         ([count[1], count[2]], [nobs[1], nobs[2]]),
                         ([count[1], count[3]], [nobs[1], nobs[3]])]:

        numComparisons += 1
        stat, p_value = proportions_ztest(counts, nobs, alternative='two-sided')
        results.append(p_value)

    alphaLevel = 0.05/numComparisons

    if all(p < alphaLevel for p in results):

        return True

    return False
def dunnsTest(dataframe, var, race):
    #dunn_result = sp.posthoc_dunn(dataframe, val_col=var, group_col=race, p_adjust='bonferroni')
    #The bonferroni correction is applied in the main body
    dunn_result = sp.posthoc_dunn(dataframe, val_col=var, group_col=race, p_adjust= None)

    return dunn_result


def rejectNull(comparisons,chosenComparison, tukey_results):
    intComparison = comparisons[chosenComparison]
    idx = np.where((tukey_results.groupsunique == intComparison[0]) | (tukey_results.groupsunique == intComparison[1]))
    rejectNull = tukey_results.reject[idx][0]
    return rejectNull
def checkIndTtest(groups):
    t_statistic, p_value = stats.ttest_ind(groups[0], groups[1])
    if p_value < 0.05:
        return True
    return False

def twoSampleTtest(groups):
    results = []

    for i, j in [(0,2),(0,3),(1,2),(1,3)]:
        t_statistic, p_value = stats.ttest_ind(groups[i], groups[j])
        results.append(p_value)

    #alphaLevel = 0.05
    alphaLevel = 0.05 / len(results)


    if all(p < alphaLevel for p in results):

        return True
    return False

def performTukeyHSD(data, variable, race_column='race'):
    data = data[[race_column, variable]].dropna()
    tukey = pairwise_tukeyhsd(endog=data[variable], groups=data[race_column], alpha=0.05)

    return tukey

filename = "//dartfs-hpc/rc/home/9/f006gq9/HMS/HMSDatasets/HMS 2016-2021combined_file_MDonly.csv"
data = pd.read_csv(filename, low_memory=False, encoding='mac_roman')

header_row = data.iloc[0]
data = data[1:]

# undoes one hot encoding, turning split binary data into one column categorical
conditions = [
    data['race_black'] == 1,  # 1
    data['race_ainaan'] == 1,  # 2
    data['race_asian'] == 1,  # 3
    data['race_his'] == 1,  # 4
    data['race_pi'] == 1,  # 5
    data['race_mides'] == 1,  # 6
    data['race_white'] == 1,  # 7
    data['race_other'] == 1  # 8
]
values = [4, 5, 2, 3, 5, 5, 1, 5]
# White, Asian, Hispanic, Black, Other (in that order)

# creates a new data['race'] column with categorical vars
data['race'] = np.select(conditions, values, default=0)
# removes old one hot encoding
data = data.drop(['race_black', 'race_ainaan', 'race_asian',
                  'race_his', 'race_pi', 'race_mides', 'race_white', 'race_other'], axis=1)

data = data[data['race'] != 0]

supportedVars = []
# loops through each column

for column_name in data.columns:
    # if the column isn't race, and the data is numeric
    if column_name != 'race' and pd.api.types.is_numeric_dtype(data[column_name]):
        raceList = []
        # creates a new 2 col dataframe. One col is race, and the other is the variable vals
        dataTemp = data[['race', column_name]]
        dataTemp = dataTemp.dropna()  # drops all entries where a val is missing

        # loops through each race
        for i in range(1, 6):
            # checks to make sure that there is at least one instance of each race represented
            if len(dataTemp[dataTemp['race'] == i][column_name]) > 0:
                # calculates the mean for each race and appends to raceList
                mean_value = dataTemp[dataTemp['race'] == i][column_name].mean()
                raceList.append(mean_value)

        # checks to make sure that every race has been appended to raceList
        if len(raceList) == 5:
            supportedVars.append(column_name)

positivePrimaryHit = []
failedKruskal = []
medianTest = []

numANOVA = 0
numChiSquare = 0
numKruskal = 0
# for each var identified above
numberVars = 0
numberBinary = 0
numberOrdinal = 0


for var in supportedVars:
    numberVars += 1
    valsByRace = []
    # creates a 2 col df with race as one col and var val as another col
    dataTemp = data[['race', var]]
    dataTemp = dataTemp.dropna()

    # loops through each race and drops any empty entries
    for race in range(1, 6):
        r = dataTemp[dataTemp['race'] == race][var].dropna().tolist()
        valsByRace.append(r)

    if has_two_unique_values(dataTemp,var):
        numberBinary += 1
        if perform_chi_square_test(data,'race',var) < 0.05:
            #print(var, "PRIMARY CHI")
            positivePrimaryHit.append(var)
            numChiSquare += 1

    elif is_ordinal(dataTemp,var):
        numberOrdinal += 1
        groups = [dataTemp[dataTemp['race'] == race][var].values for race in range(1, 6)]
        try:
            stat, p = kruskal(*groups)
            if p < 0.05:
                #print(var, "KRUSKAL WITH P ", p)
                positivePrimaryHit.append(var)
                numKruskal += 1

        except ValueError:
            failedKruskal.append(var)

    elif checkANOVA(valsByRace): # if the checkANOVA identified a pval < 0.05
        #print(var, "ANOVA")
        numANOVA += 1
        positivePrimaryHit.append(var)

print(numberVars, "NumberVars")
print(numberNumeric, "NumberNumeric")
print(numberOrdinal, "NumberOrdinal")
print(numberBinary, "NumberBinary")
sys.exit()
# print(numKruskal, "numKruskal")
# print(numChiSquare, "numChi")
# print(numANOVA, "numANOVA")


posIndTtest = []
passedCompOne = []
passedCompTwo = []

counterZ, counterDunn, counterTukey, counterT, counterPreTukey,counterTwoSampleT, counterPostHocChi = 0,0,0,0,0,0,0
preDunn,preTwoZ, preTwoT = 0,0,0
prePostHocChi = 0

for var in positivePrimaryHit:
    valsByGroupTemp = []
    # creates a 2 col df with race as one col and var val as another col
    dataTemp = data[['race', var]]
    dataTemp = dataTemp.dropna()

    # loops through each race and drops any empty entries
    for race in range(1, 6):
        r = dataTemp[dataTemp['race'] == race][var].dropna().tolist()
        valsByGroupTemp.append(r)

    valsByGroup = []
    valsByGroup.append(valsByGroupTemp[0] + valsByGroupTemp[1])
    valsByGroup.append(valsByGroupTemp[2] + valsByGroupTemp[3] + valsByGroupTemp[4])

    if has_two_unique_values(dataTemp,var):
        # preTwoZ += 1
        prePostHocChi += 1
        if perform_postHocChi(dataTemp, 'race', var):
            # print(var, "POST HOC CHI!")
            posIndTtest.append(var)
            counterPostHocChi += 1
        # if twoPropZtest(valsByGroupTemp):
        #     posIndTtest.append(var)
        #     counterZ += 1


    elif is_ordinal(dataTemp,var):
        dunnsResult = dunnsTest(dataTemp,var,'race')
        p_vals = []
        p_vals.append(dunnsResult.iloc[0, 1])
        p_vals.append(dunnsResult.iloc[0, 3])
        p_vals.append(dunnsResult.iloc[1, 2])
        p_vals.append(dunnsResult.iloc[1, 3])

        preDunn += 1

        alphaLevel = 0.05
        if all(p < alphaLevel for p in p_vals):
            # print(var, "DUNNS!", p_vals, "PVALS!!")
            posIndTtest.append(var)
            counterDunn +=1

    elif not is_ordinal(dataTemp, var):
        preTwoT += 1
        if performTukeyHSD(dataTemp, var):
            counterTwoSampleT += 1
        if twoSampleTtest(valsByGroupTemp):
            posIndTtest.append(var)
            counterTwoSampleT += 1

sys.exit()

print("Length of Positive Primary hit = ", len(positivePrimaryHit))
print("Counter Dunn = ", counterDunn)
print("Counter two Sample T = ", counterTwoSampleT)

print("Pre Two Dunn = ", preDunn)
print("Pre Two T = ", preTwoT)
print("Counter T Test before elifs = ", counterT)

print("Pre Post Chi = ", prePostHocChi)
print("Post Post Chi = ", counterPostHocChi)


with open('posIndTtest.txt', 'w') as file:
    for item in posIndTtest:
        file.write(f"{item}\n")
