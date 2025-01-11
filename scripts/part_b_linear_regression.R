# Part B - Linear Regression

# load libraries
library(DBI)
library(RSQLite)

# Create a connection to SQL database
db_path <- "data/ICA_2023.sqlite"
con <- dbConnect(RSQLite::SQLite(), dbname = db_path)

# Use Budget (under Projects) and ExperienceYears (under Developers) to predict success rate with a linear regression

### Calculate the average experience years per every project

queryA <- "
SELECT 
    p.Budget, 
    AVG(d.ExperienceYears) AS AverageExperience
FROM 
    Projects p
JOIN 
    ProjectDevelopers pd ON p.ProjectID = pd.ProjectID
JOIN 
    Developers d ON pd.DeveloperID = d.DeveloperID
GROUP BY 
    p.ProjectID
HAVING 
    p.Budget IS NOT NULL AND AVG(d.ExperienceYears) IS NOT NULL;
"

# Execute the query and store the result in a data frame
SR_data <- dbGetQuery(con, queryA)

print(SR_data)

## Create a success rate variable, which is budget/ExperienceYears

### Load Projects and Developers tables
projects <- dbGetQuery(con, "SELECT ProjectID, Budget FROM Projects")
developers <- dbGetQuery(con, "SELECT DeveloperID, ExperienceYears FROM Developers")

### Load the linking table (merges ProjectID and DeveloperID into one)
project_developers <- dbGetQuery(con, "SELECT ProjectID, DeveloperID FROM ProjectDevelopers")

### Merge the project_developers with developers
merged_LR_data <- merge(project_developers, developers, by = "DeveloperID")

### Now merge with projects
merged_LR_data <- merge(merged_LR_data, projects, by = "ProjectID")

print(merged_LR_data)

# Calculate SuccessRate as ExperienceYears (multiplied by 10000 to make it coherent with budget) divided by Budget, expressed as a percentage
merged_LR_data$SuccessRate <- with(merged_LR_data, ((ExperienceYears * 10000 / Budget) * 100))

# Print the SuccessRate column
print(merged_LR_data$SuccessRate)

## Perform a linear regression to predict the success rate

### Fit a linear regression model
SR_model <- lm(merged_LR_data$SuccessRate ~ Budget + AverageExperience, data = SR_data)

### Summary of the model
summary(SR_model)

# Close the database connection
dbDisconnect(con)