--testing the two tables 
Select *
FROM Portfolio_Project.dbo.CovidDeaths
Order by 3,4
--testing the two tables 
Select *
FROM Portfolio_Project.dbo.CovidVaccinations 
Order by 3,4


--vaccine and death tables joined
Select *
FROM Portfolio_Project.dbo.CovidDeaths
INNER JOIN Portfolio_Project.dbo.CovidVaccinations
ON CovidDeaths.location = CovidVaccinations.location

-- PEOPLE FULL VACCINATED AND DEATHS FOR PAKISTAN
--Select Location, total_Deaths,people_fully_vaccinated_per_hundred
--FROM Portfolio_Project.dbo.CovidVaccinations
--WHERE total_deaths >= 1 AND location = 'Pakistan' AND people_fully_vaccinated_per_hundred >= 10.00

--DEATH PERCENTAGE
--trying to run death percentage but code doesnt run because the data in these tables isnt varchar so the divide operator doesnt work
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)
FROM Portfolio_Project.dbo.CovidDeaths

-- Convert total_deaths column to int
ALTER TABLE Portfolio_Project.dbo.CovidDeaths
ALTER COLUMN total_deaths INT;

-- Convert total_cases column to int
ALTER TABLE Portfolio_Project.dbo.CovidDeaths
ALTER COLUMN total_cases float;

--Code to check the data type
SELECT *
FROM Portfolio_Project.dbo.CovidDeaths

EXEC sp_help 'dbo.CovidDeaths';

--DEATH PERCENTAGE (Total cases vs Total Deaths) after changing the data types of the table
 Select location, date, population, new_cases, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Portfolio_Project.dbo.CovidDeaths
WHERE location = 'Pakistan' 
Order by 1,2

Select *, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Portfolio_Project.dbo.CovidDeaths
WHERE location = 'Pakistan' 
Order by 1,2

--countries with the Highest Infection rate compared to Population

Select location, Population, MAX(total_cases) AS HighestInfectionCount, 
	Max((total_cases/population))*100 AS PopulationInfected_percent
	FROM Portfolio_Project.dbo.CovidDeaths
	Group by location, population
	Order by HighestInfectionCount DESC;

--Continent Data, with other data such as 'High Income', 'Upper middle income', 'Lower middle income', 'Low Income'
 Select location, MAX(cast(Total_deaths as int)) AS TotalDeathCount
 FROM Portfolio_Project..CovidDeaths
 Where continent is null
 Group by location
 order by TotalDeathCount desc

 --seperating unrelated data into 'Other' 
  SELECT 
	CASE 
		WHEN location IN ('High Income', 'Upper middle income', 'Lower middle income', 'European Union', 'Low Income') THEN 'Other'
		ELSE location 
	END AS Location_Category, 
	MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM Portfolio_Project..CovidDeaths
WHERE continent IS NULL
Group by CASE 
		WHEN location IN ('High Income', 'Upper middle income', 'Lower middle income', 'European Union', 'Low Income') THEN 'Other'
		ELSE location 
	END 
 ORDER BY TotalDeathCount desc
 
--Continent + Europen Union Data 
--'Other' data Removed, but it created a duplicated table for location 
	SELECT 
    location AS Original_Location,
    CASE 
        WHEN location IN ('High Income', 'Upper middle income', 'Lower middle income', 'Low Income') THEN 'Other'
        ELSE location 
    END AS Location_duplicate,
    MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM 
    Portfolio_Project..CovidDeaths
WHERE 
    continent IS NULL
GROUP BY 
    location,
    CASE 
        WHEN location IN ('High Income', 'Upper middle income', 'Lower middle income', 'Low Income') THEN 'Other'
        ELSE location 
    END
HAVING
    CASE 
        WHEN location IN ('High Income', 'Upper middle income', 'Lower middle income', 'Low Income') THEN 'Other'
        ELSE location 
    END != 'Other'
ORDER BY 
    TotalDeathCount DESC;

	--Contintent only Data
Select continent, MAX(cast(Total_deaths as int)) AS TotalDeathCount
 FROM Portfolio_Project..CovidDeaths
 Where continent is not null
 Group by continent 
 order by TotalDeathCount desc

 --Global Numbers 

SELECT  
       SUM(new_cases) AS TotalNewCases, 
       SUM(new_deaths) AS TotalNewDeaths, 
       CASE 
           WHEN SUM(new_cases) = 0 THEN 0 -- Handle divide by zero error
           ELSE SUM(new_deaths) / SUM(new_cases) * 100 
       END AS DeathPercentageGlobal
FROM Portfolio_Project..CovidDeaths 
WHERE continent IS NOT NULL 
ORDER BY 1,2

-- looking at total population vs vaccination 

SELECT dea.continent, dea.location, dea.date, vax.new_vaccinations 
FROM [Portfolio_Project ]..CovidDeaths AS Dea
JOIN [Portfolio_Project ]..CovidVaccinations AS Vax
	ON dea.location = Vax.location 
	AND vax.date = vax.date 
WHERE vax.new_vaccinations IS NOT NULL AND dea.continent = 'North America'
ORDER BY 2,3

---- looking at total population vs vaccination (United States)  

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaxNumbers) AS (
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vax.new_vaccinations,
        SUM(CONVERT(bigint,vax.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingVaxNumbers
    FROM 
        [Portfolio_Project]..CovidDeaths AS Dea
    JOIN 
        [Portfolio_Project]..CovidVaccinations AS Vax ON dea.location = Vax.location AND dea.date = vax.date
    WHERE 
        dea.continent IS NOT NULL AND 
        vax.new_vaccinations IS NOT NULL AND 
        dea.location = 'United States'
)

SELECT 
    Continent, 
    Location, 
    Date, 
    Population, 
    New_Vaccinations, 
    RollingVaxNumbers,
    (RollingVaxNumbers / Population) * 100 AS Vaccination_Percentage 
FROM 
    PopvsVac
ORDER BY Vaccination_Percentage DESC;




	













