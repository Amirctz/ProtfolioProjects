--COVID-19 in 2021 - Data Exploration

SELECT * FROM CovidDeaths
ORDER BY 1,2

--Select data that we are going to be using
SELECT location,date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

--Looking at Total Cases VS Total Deaths
--Shows liklihood of dying if you contract covid in your country
SELECT location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM CovidDeaths
WHERE location LIKE '%Israel%'
ORDER BY 1,2

--Looking at Total Cases VS Population
--Shows what percentage of population got Covid
SELECT location,date, total_cases, population, (total_deaths/population)*100 as PercetPopulationInfected
FROM CovidDeaths
WHERE location LIKE '%Israel%'
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount,MAX((total_deaths/population))*100 as PercetPopulationInfected
FROM CovidDeaths
GROUP BY  population,location
ORDER BY PercetPopulationInfected DESC

--Showing countries with Highest Death Count per Population
--(We have some problem whth the cotinent column- not null is the support)
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY  population,location
ORDER BY TotalDeathCount DESC

--Showing Continents with Highest Death Count
SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global numbers

--World Cases and Deaths per Date
SELECT 
date, 
SUM(new_cases) as Total_Cases, 
SUM(new_deaths) as TotalDeaths, 
SUM(new_deaths)/SUM(new_cases)*100 as Death_Percentage
--, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--Total World's Cases and Deaths
SELECT  
  SUM(new_cases) as Total_Cases, 
  SUM(new_deaths) as TotalDeaths, 
  SUM(new_deaths)/SUM(new_cases)*100 as Death_Percentage
FROM CovidDeaths
WHERE continent is not null


--Looking at total population VS Vaccinations
SELECT dea.continent,
 dea.location, 
 dea.date, 
 dea.population,
 vac.new_vaccinations, 
 SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--Use CTE
WITH PopVsVac (Continent, Location,date ,Population ,New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent,
 dea.location, 
 dea.date, 
 dea.population,
 vac.new_vaccinations, 
 SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *,(RollingPeopleVaccinated/Population)*100 from PopVsVac


--Temp Table
DROP table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,
 dea.location, 
 dea.date, 
 dea.population,
 vac.new_vaccinations, 
 SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100 
FROM #PercentPopulationVaccinated

SELECT * from  #PercentPopulationVaccinated


--Creating view to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent,
 dea.location, 
 dea.date, 
 dea.population,
 vac.new_vaccinations, 
 SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT * FROM PercentPopulationVaccinated