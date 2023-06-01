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

###############################
######### Define Sets #########
###############################

# charger type: Level1, Level2, Super Charger
ChargerTypes = ["L1", "L2", "SC"]

###################################################
############ Define parameters and data ###########
###################################################

# The maximum number of stations
StationMax = 250000

# The safety distance to a fault [km]
Distance = 100

# The population limit around an EGS project [people]
PopulationMax = 100000

# read local data
data = XLSX.readdata("sample_data.xlsx", "Sheet1", "C2:I4929")
#print(data)

# Extract the X-block and Y-block columns and convert them to vectors
x_blocks = XLSX.readdata("sample_data.xlsx", "Sheet1", "C2:C101")
y_blocks = XLSX.readdata("sample_data.xlsx", "Sheet1", "D2:D101")
pop_blocks = XLSX.readdata("sample_data.xlsx", "Sheet1", "E2:E101")
mileage_blocks = XLSX.readdata("sample_data.xlsx", "Sheet1", "F2:F101")
line_blocks = XLSX.readdata("sample_data.xlsx", "Sheet1", "G2:G101")
energy_blocks = XLSX.readdata("sample_data.xlsx", "Sheet1", "H2:H101")
cost_blocks = XLSX.readdata("sample_data.xlsx", "Sheet1", "I2:I101")

