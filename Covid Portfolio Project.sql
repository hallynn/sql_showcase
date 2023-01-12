use Projects
SELECT * 
FROM Projects..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT * 
--FROM Projects..CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Projects..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


--looking at Total Cases vs Total Deaths
--shows lilihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Deathpercentage
FROM Projects..CovidDeaths2
WHERE location LIKE '%states'
and continent is not null
ORDER BY 1,2


--Total Cases vs Population
--shows what percentage of population got covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentOfPopInfected
FROM Projects..CovidDeaths2
WHERE location LIKE '%states'
and continent is not null
ORDER BY 1,2


--countries with highest infection rate

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS PercentOfPopInfected
FROM Projects..CovidDeaths2
--WHERE location LIKE '%states'
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentOfPopInfected DESC


--showing countries with highest death count per population

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM Projects..CovidDeaths2
--WHERE location LIKE '%states'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC


--showing continents with highest death count

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM Projects..CovidDeaths2
--WHERE location LIKE '%states'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC


--GLOBAL NUMBERS

SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths as int)) AS TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS Deathpercentage
FROM Projects..CovidDeaths2
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


--Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location 
  ORDER by dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM projects..CovidDeaths2 dea
JOIN projects..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location 
  ORDER by dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM projects..CovidDeaths2 dea
JOIN projects..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null and dea.location LIKE '%states'
--ORDER BY 2,3
)
SELECT * , (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- TEMP TABLE

DROP TABLE IF EXISTS PercentPopulationVaccinated
Create Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location 
  ORDER by dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM projects..CovidDeaths2 dea
JOIN projects..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT * , (RollingPeopleVaccinated/Population)*100
FROM PercentPopulationVaccinated



-- creating View to store later for visualizations

Create View PercentofPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location 
  ORDER by dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM projects..CovidDeaths2 dea
JOIN projects..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


SELECT *
FROM PercentofPopulationVaccinated




