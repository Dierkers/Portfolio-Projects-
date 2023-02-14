USE MyPortfolio

SELECT * 
FROM MyPortfolio..CovidDeaths
ORDER BY 3,4


SELECT 
	location,
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
FROM MyPortfolio..CovidDeaths
ORDER BY 1,2

-- Total Cases vs. Total Deaths
-- The likelihood of death following the contraction of COVID-19

SELECT 
	location, 
	date, 
	total_cases, 
	total_deaths, 
	(total_deaths/total_cases)*100 AS deathpercentage
FROM MyPortfolio..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

-- Total Cases vs. Population 
-- Percentage of people who have contracted COVID-19 

SELECT 
	location, 
	date, 
	population,
	total_cases,  
	(total_cases/population)*100 AS PercentPopulationInfected
FROM MyPortfolio..CovidDeaths
WHERE location like '%states%' AND continent IS NOT NULL
ORDER BY 1,2

-- Countries with Highest Infection Rate vs. Population 

SELECT 
	location, 
	population, 
	MAX(total_cases) AS HighestInfectionCount,
	MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM MyPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Countries with Highest Death Count vs. Population

SELECT 
	location,  
	MAX(cast(total_deaths AS INT)) AS TotalDeathCount 
FROM MyPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Continent Death Count Comparison

SELECT 
	location,  
	MAX(cast(total_deaths AS INT)) AS TotalDeathCount 
FROM MyPortfolio..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Global Death Count/Death Percentage Comparison 

SELECT 
	date,
	SUM(new_cases) AS total_cases,
	SUM(cast(new_deaths AS INT)) AS total_deaths,
	SUM(cast(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM MyPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Total Population vs. Vaccinations 

SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS SumPeopleVaccinated
FROM MyPortfolio..CovidVaccinations vac
JOIN MyPortfolio..CovidDeaths dea
	ON vac.location = dea.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- USE OF CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, SumPeopleVaccinated) AS
(
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS SumPeopleVaccinated
FROM MyPortfolio..CovidVaccinations vac
JOIN MyPortfolio..CovidDeaths dea
	ON vac.location = dea.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (SumPeopleVaccinated/Population)*100 AS PercentPopVaccinated
FROM PopvsVac

-- TEMP Table 

DROP TABLE IF EXISTS PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
SumPeopleVaccinated numeric
)

INSERT INTO PercentPopulationVaccinated
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS SumPeopleVaccinated
FROM MyPortfolio..CovidVaccinations vac
JOIN MyPortfolio..CovidDeaths dea
	ON vac.location = dea.location AND dea.date = vac.date

SELECT *, (SumPeopleVaccinated/population)*100 AS PercentVaccinated
FROM PercentPopulationVaccinated

-- Views for later visualizations

--Shows continent, location, date, population, and calculates the amount of people vaccinated
CREATE VIEW PercentPopVac AS
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS SumPeopleVaccinated
FROM MyPortfolio..CovidVaccinations vac
JOIN MyPortfolio..CovidDeaths dea
	ON vac.location = dea.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

--Shows date, number of cases, total deaths, and calculates death percentage
CREATE VIEW DeathPercentage AS
SELECT 
	date,
	SUM(new_cases) AS total_cases,
	SUM(cast(new_deaths AS INT)) AS total_deaths,
	SUM(cast(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM MyPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date

--Shows total death count by location and continent  
CREATE VIEW DeathCountbyLocation AS
SELECT 
	location,  
	MAX(cast(total_deaths AS INT)) AS TotalDeathCount 
FROM MyPortfolio..CovidDeaths
WHERE continent IS NULL
GROUP BY location


--Shows total death count by country 
CREATE VIEW DeathCountbyCountry AS
SELECT 
	location,  
	MAX(cast(total_deaths AS INT)) AS TotalDeathCount 
FROM MyPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location


--Shows the United States percentage of infection, location, date, population, and total cases 
CREATE VIEW USPercentInfected AS
SELECT 
	location, 
	date, 
	population,
	total_cases,  
	(total_cases/population)*100 AS PercentPopulationInfected
FROM MyPortfolio..CovidDeaths
WHERE location like '%states%' AND continent IS NOT NULL
