f = open("C:/Users/allur/PycharmProjects/ThreeClusterHMS/varsForCausalInference.txt", "r")

highestImpact = []
uniqueHImpact = []
for line in f:
    highestImpact.append(line.strip())

for var in highestImpact:
    if var not in uniqueHImpact:
        uniqueHImpact.append(var)

with open('uniqueHImpact.txt', 'w') as file:
    for item in uniqueHImpact:
        file.write(f"{item}\n")