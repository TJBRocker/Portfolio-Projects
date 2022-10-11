-- Queries to use for tableau workbook

--1.

SELECT SUM(new_cases) AS total_cases , SUM(CAST(new_deaths AS float)) AS total_deaths, (SUM(CAST(new_deaths AS float)) / SUM(new_cases)) * 100.0 AS death_percentage
  FROM PortfolioProject..COVIDdeaths
WHERE continent IS NOT NULL AND location NOT LIKE '%income%'
ORDER BY 1,2

--2.

SELECT location, MAX(CAST (total_deaths AS float)) AS total_death_count
  FROM PortfolioProject..COVIDdeaths
WHERE continent IS NULL AND location NOT LIKE '%income%'
GROUP BY location
ORDER BY total_death_count DESC 

--3.

SELECT location, population, MAX(total_cases) AS highest_infection_count,  MAX((total_cases/population)*100.0) AS 
covid_percentage
  FROM PortfolioProject..COVIDdeaths
 WHERE continent IS NOT NULL AND location NOT LIKE '%income%'
GROUP BY location, population
ORDER BY covid_percentage DESC

--3a.

SELECT location, population, date, MAX(total_cases) AS highest_infection_count,  MAX((total_cases/population)*100.0) AS 
covid_percentage
  FROM PortfolioProject..COVIDdeaths
WHERE continent IS NOT NULL AND location NOT LIKE '%income%'
GROUP BY location, population, date


--4. 

 Select dea.continent, dea.location, dea.date, dea.population
, MAX(vax.total_vaccinations) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVax vax
	On dea.location = vax.location
	and dea.date = vax.date
where dea.continent is not null 
group by dea.continent, dea.location, dea.date, dea.population
order by 1,2,3

--5.

SELECT SUM(new_cases) AS total_cases , SUM(CAST(new_deaths AS float)) AS total_deaths, (SUM(CAST(new_deaths AS float)) / SUM(new_cases)) * 100.0 AS death_percentage
  FROM PortfolioProject..COVIDdeaths
WHERE continent IS NOT NULL AND location NOT LIKE '%income%'
ORDER BY 1,2

--6.

Select location, SUM(cast(new_deaths as int)) as total_death_count
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null AND location NOT LIKE '%income%' AND location not in ('World', 'European Union', 'International')
Group by location
order by total_death_count desc

--7.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL AND location NOT LIKE '%income%'
Group by Location, Population
order by PercentPopulationInfected  desc

--8. 

Select Location, date, population, total_cases, total_deaths
From PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL AND location NOT LIKE '%income%'
order by 1,2

--9. 


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


--10. 
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc