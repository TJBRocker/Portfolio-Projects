SELECT *
  FROM PortfolioProject..COVIDdeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

--SELECT *
--  FROM PortfolioProject..COVIDVax
--ORDER BY 3,4

-- SELECT Data that we are going to be using:

SELECT location, date, total_cases, new_cases, total_deaths, population
  FROM PortfolioProject..COVIDdeaths
WHERE continent IS NOT NULL
ORDER BY location, date

-- Looking at total cases vs total deaths
-- Shows likelihood of dying if you contract CV19

SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100.0, 2) AS 
death_percentage
  FROM PortfolioProject..COVIDdeaths
WHERE location = 'United Kingdom' AND continent IS NOT NULL
ORDER BY location, date

-- total cases vs population
-- shows % of pop with covid

SELECT location, date, population, total_cases,  (total_cases/population)*100.0 AS 
covid_percentage
  FROM PortfolioProject..COVIDdeaths
--WHERE location = 'United Kingdom' 
ORDER BY location, date

-- Looking at countries with highest infection rate vs population

SELECT location, population, MAX(total_cases) AS highest_infection_count,  MAX((total_cases/population)*100.0) AS 
covid_percentage
  FROM PortfolioProject..COVIDdeaths
 WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY covid_percentage DESC

-- Showing Countries with the highest death count per population, removing continent as not null as was showing aggregate of total continents and world

SELECT location, MAX(CAST (total_deaths AS float)) AS total_death_count
  FROM PortfolioProject..COVIDdeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC

-- breaking things down by continent

SELECT location, MAX(CAST (total_deaths AS float)) AS total_death_count
  FROM PortfolioProject..COVIDdeaths
WHERE continent IS NULL AND location NOT LIKE '%income%'
GROUP BY location
ORDER BY total_death_count DESC 

-- Global Numbers

SELECT date, SUM(new_cases) AS total_cases , SUM(CAST(new_deaths AS float)) AS total_deaths, (SUM(CAST(new_deaths AS float)) / SUM(new_cases)) * 100.0 AS death_percentage
  FROM PortfolioProject..COVIDdeaths
WHERE continent IS NOT NULL AND location NOT LIKE '%income%'
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) AS total_cases , SUM(CAST(new_deaths AS float)) AS total_deaths, (SUM(CAST(new_deaths AS float)) / SUM(new_cases)) * 100.0 AS death_percentage
  FROM PortfolioProject..COVIDdeaths
WHERE continent IS NOT NULL AND location NOT LIKE '%income%'
ORDER BY 1,2

-- looking at total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, CAST(vax.new_vaccinations AS int) AS new_vaccinations, 
SUM(CONVERT(bigint,vax.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_number_vaccinated
  FROM PortfolioProject..COVIDdeaths AS dea
LEFT JOIN PortfolioProject..COVIDVax AS vax
	ON dea.location = vax.location
	AND dea.date = vax.date
WHERE dea.continent IS NOT NULL AND dea.location NOT LIKE '%income%'
ORDER BY 1,2,3

-- Use CTE

WITH population_vs_vaccination AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, CAST(vax.new_vaccinations AS int) AS new_vaccinations, 
SUM(CONVERT(bigint,vax.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_number_vaccinated
  FROM PortfolioProject..COVIDdeaths AS dea
LEFT JOIN PortfolioProject..COVIDVax AS vax
	ON dea.location = vax.location
	AND dea.date = vax.date
WHERE dea.continent IS NOT NULL AND dea.location NOT LIKE '%income%'
--ORDER BY 1,2,3
)

SELECT *, (rolling_number_vaccinated / population)*100.0 AS percentage_of_pop_vaxxed
  FROM population_vs_vaccination
ORDER BY 1,2,3

-- Temp table
DROP TABLE IF EXISTS #percentage_population_vaccinated
CREATE TABLE #percentage_population_vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinatons numeric,
rolling_number_vaccinated numeric
)

INSERT INTO #percentage_population_vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, CAST(vax.new_vaccinations AS int) AS new_vaccinations, 
SUM(CONVERT(bigint,vax.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_number_vaccinated
  FROM PortfolioProject..COVIDdeaths AS dea
LEFT JOIN PortfolioProject..COVIDVax AS vax
	ON dea.location = vax.location
	AND dea.date = vax.date
WHERE dea.continent IS NOT NULL AND dea.location NOT LIKE '%income%'

SELECT *
FROM #percentage_population_vaccinated

-- Creating view for later visulisations
CREATE VIEW percentage_population_vaccinated AS

SELECT dea.continent, dea.location, dea.date, dea.population, CAST(vax.new_vaccinations AS int) AS new_vaccinations, 
SUM(CONVERT(bigint,vax.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_number_vaccinated
  FROM PortfolioProject..COVIDdeaths AS dea
LEFT JOIN PortfolioProject..COVIDVax AS vax
	ON dea.location = vax.location
	AND dea.date = vax.date
WHERE dea.continent IS NOT NULL AND dea.location NOT LIKE '%income%'
