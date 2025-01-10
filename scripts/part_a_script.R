# Part A - SQL

# Install SQL package
install.packages("DBI")
install.packages("RSQLite")

# load libraries
library(DBI)
library(RSQLite)

# Create a connection to SQL database
db_path <- "data/ICA_2023.sqlite"
con <- dbConnect(RSQLite::SQLite(), dbname = db_path)

dbListTables(con)

projects_table <- dbGetQuery(con, "SELECT * FROM Projects")
assets_table <- dbGetQuery(con, "SELECT * FROM Assets")
timelines_table <- dbGetQuery(con, "SELECT * FROM Timelines")
customers_table <- dbGetQuery(con, "SELECT * FROM Customers")
developers_table <- dbGetQuery(con, "SELECT * FROM Developers")
projectdevelopers_table <- dbGetQuery(con, "SELECT * FROM ProjectDevelopers")
assetsdevelopers_table <- dbGetQuery(con, "SELECT * FROM AssetsDevelopers")

# SQL Tasks

### Budget allocated for project by each country and number of project per country (JOIN Projects and Customers)

query1 <- "
SELECT 
  CustomerCountry AS Country, SUM(Budget) AS TotalBudget, COUNT(ProjectID) AS ProjectCount
FROM 
  Projects
JOIN
  Customers
GROUP BY 
  CustomerCountry
ORDER BY 
  TotalBudget DESC;
"
result1 <- dbGetQuery(con, query1)
print(result1)

### Average development time per project, by assets used

query2 <- "
SELECT 
  Projects.ProjectID, 
  COUNT(AssetID) AS AssetCount, 
  AVG(JULIANDAY(EndDate) - JULIANDAY(StartDate)) AS AvgDevelopmentTime
FROM 
  Projects
JOIN 
  Assets ON 
    Projects.ProjectID = Assets.ProjectID
GROUP BY 
  Projects.ProjectID;
"

# Execute the grouped query
result2 <- dbGetQuery(con, query2)
print(result2)

### Top 3 developers based on successful projects (JOIN Projects and Developers Table)

query3 <- "
SELECT 
  DeveloperID, COUNT(ProjectID) AS SuccessfulProjects
FROM 
  Projects
JOIN
  Developers
WHERE
  Status = 'Completed'
GROUP BY 
  DeveloperID
ORDER BY 
  SuccessfulProjects DESC
LIMIT 
  3;
"
result3 <- dbGetQuery(con, query3)
print(result3)


# SQL concepts

### SELECT with LIKE and OR

query_like_or <- "
SELECT 
  ProjectName
FROM 
  Projects
WHERE 
  ProjectName LIKE '%Game%' OR ProjectName LIKE '%Adventure%';
"
result_like_or <- dbGetQuery(con, query_like_or)
print(result_like_or)

### SELECT with DISTINCT and ORDER BY

query_distinct_order <- "
SELECT 
  DISTINCT 
    StartDate
FROM 
  Projects
ORDER BY 
  StartDate;
"
result_distinct_order <- dbGetQuery(con, query_distinct_order)
print(result_distinct_order)

### Subquery with SELECT 

query_subquery <- "
SELECT 
  DeveloperID
FROM 
  Projects
JOIN
  Developers
WHERE 
  Budget > (SELECT AVG(Budget) FROM Projects);
"
result_subquery <- dbGetQuery(con, query_subquery)
print(result_subquery)

# Closing SQL database connection
dbDisconnect(con)


