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

# Close the database connection
dbDisconnect(con)

## Create a merged_SR_data to observe the success rate

### Load Projects and Developers tables
projects <- dbGetQuery(con, "SELECT ProjectID, Budget FROM Projects")
developers <- dbGetQuery(con, "SELECT DeveloperID, ExperienceYears FROM Developers")

### Load the linking table (merges ProjectID and DeveloperID into one)
project_developers <- dbGetQuery(con, "SELECT ProjectID, DeveloperID FROM ProjectDevelopers")

### Merge the project_developers with developers
merged_LR_data <- merge(project_developers, developers, by = "DeveloperID")

### Now merge with projects
merged_LR_data <- merge(merged_LR_data, projects, by = "ProjectID")

### Calculate average experience per project
average_experience <- aggregate(ExperienceYears ~ ProjectID + Budget + SuccessRate, 
                                data = merged_data, 
                                FUN = mean, 
                                na.rm = TRUE)

## Perform a linear regression to predict the success rate

### Fit a linear regression model
SR_model <- lm(SuccessRate ~ Budget + AverageExperience, data = SR_data)

### Summary of the model
summary(SR_model)