# ENERGY 191/291 P4
# P4 Sample model structure for project "California Charging Infrastructure"

# Spencer Zhang
# Department of Energy Resources Engineering
# Stanford University
# File version 1
# Updated May 30 2023

####################################
######### Initialize tools #########
####################################

import Pkg

Pkg.add("Cbc")
Pkg.add("Plots")
Pkg.add("XLSX")
Pkg.add("DataFrames")
Pkg.add("PrettyTables")
Pkg.add("JuMP")
Pkg.add("GLPK")
Pkg.add("CSV")

# Initialize JuMP to allow mathematical programming models
using JuMP

# Initialize MILP solver Cbc
using Cbc
using GLPK

using CSV, DataFrames
using XLSX
using PrettyTables
using Random

###############################
######### Define Sets #########
###############################

# charger type: Level1, Level2, Super Charger
ChargerTypes = ["L1", "L2", "SC"]
nTypes = length(ChargerTypes)

###################################################
############ Define parameters and data ###########
###################################################

# The maximum number of stations
StationMax = 250000

# The safety distance to a fault [km]
Distance = 100

# Extract the X-block and Y-block columns and convert them to vectors
#x_blocks = XLSX.readdata("sample_data.xlsx", "Sheet1", "C2:C101")
#y_blocks = XLSX.readdata("sample_data.xlsx", "Sheet1", "D2:D101")
pop_blocks = XLSX.readdata("sample_data.xlsx", "Sheet 1", "A2:A101")
VMT_blocks = XLSX.readdata("sample_data.xlsx", "Sheet 1", "B2:B101")
#line_blocks = XLSX.readdata("sample_data.xlsx", "Sheet1", "G2:G101")
#energy_blocks = XLSX.readdata("sample_data.xlsx", "Sheet1", "H2:H101")
#cost_blocks = XLSX.readdata("sample_data.xlsx", "Sheet1", "I2:I101")

# A 10x10 block grid for sample model run
num_rows = 10
num_cols = 10

# Charger Cost by type in $1,000
ChargerCost = [1.5, 2.5, 43]

# Charging capacity by type in 1,000kWh
ChargingCapacity = [1, 2, 3]

# Commericial Use Case time series for each hour in a sample week
#CommericialChargingSchedule = XLSX.readdata("sample_ts_data.xlsx", "Sheet1", "C2:C168")
#ResidentialChargingSchedule = XLSX.readdata("sample_ts_data.xlsx", "Sheet1", "D2:D168")

# Conversion unit from VMT to kWh required
VMTtokWh = 100

# Energy demand
Demand = zeros(num_rows, num_cols)
Demand = reshape(pop_blocks, num_rows, :) .* reshape(VMT_blocks, num_rows, :) * VMTtokWh

####################################
########## Declare model  ##########
####################################

# Define the model name and solver. In this case, model name is "m"
m = Model(Cbc.Optimizer)

####################################
######## Decision variables ########
####################################

# Number of chargers put in each block grid
@variable(m, ChargerLocation[1:nTypes, 1:num_rows, 1:num_cols], Int)

######################################
######## Objective Functions #########
######################################

# Single objective for minimizing cost
@objective(m, Min, sum(sum(sum(ChargerLocation[k, i, j] * ChargerCost[k] for k = 1:nTypes) for i = 1:num_rows) for j = 1:num_cols))

######################################
############# Constraints ############
######################################

# Number of new charging station constraint
@constraint(m, sum(sum(sum(ChargerLocation[k, i, j] for k = 1:nTypes) for i = 1:num_rows) for j = 1:num_cols) < StationMax)

# Energy demand/supply constraint
# The 3x3 grid surrounding a grid should supply 9 times of what the inner grid requires.
@constraint(m, [l = 1:num_rows, p = 1:num_cols], sum(sum(sum(ChargerLocation[k, i, j] * ChargingCapacity[k] for k = 1:nTypes) for j = max(1, l - 2):min(num_cols, p + 2)) for j = i = max(1, p - 2):min(num_rows, l + 2)) >= 9 * Demand[l, p])

######################################
########### Print and solve ##########
#####################################
print(m)

optimize!(m)

ObjValue = objective_value(m);
OptimalSites = value.(ChargerLocation);

print(ObjValue)

######################################
############ Plot results ############
######################################
# Plotting script using "Plots" package

using Plots
gr()
heatmap(OptimalSites, c=:thermal)