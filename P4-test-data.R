library(dplyr)
library(openxlsx)


# create random data ----

# block group size
SIZE = 100
# population data
pop = sample(x=600:3000, size=SIZE)
# mileage data
mileage_per_capita = sample(x=1:100, size=SIZE)
mileage = pop * mileage_per_capita

df = data.frame(pop = pop, VMT = mileage)


write.xlsx(df, "sample_data.xlsx")
