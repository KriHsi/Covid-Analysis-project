
USE PortfolioProject
SELECT *
FROM CovidVaccinations
ORDER BY Location, date

--Select Data that we are going to be using: 
--join tables covidDeath and CovidVaccination
--looking at total population vs vaccination


USE PortfolioProject 
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(CONVERT(BIGINT, v.new_vaccinations )) OVER (Partition by d.location Order by d.location, d.date ) AS RollingPeopleVaccinated
FROM CovidDeaths D
JOIN CovidVaccinations V
ON  D.location = v.location
and d.date = v.date
WHERE d.continent is not null
ORDER BY d.location, d.date


-- Looking at Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
AND continent IS NOT NULL
ORDER BY location, date


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
ORDER BY location, date


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(cast(Total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Showing Continents with the highest death count per population

SELECT continent, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Global Numbers

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY total_cases, total_deaths


-- Looking at Total Population vs Vaccinations

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(INT,v.new_vaccinations)) 
	OVER (Partition by d.location ORDER BY d.location, d.date) AS NumPeopleVaccinated
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent is not null
ORDER BY d.location, d.date


-- USE CTE

With PopVsVac (Continent, location, date, population, new_vaccination, rollingpeoplevaccinated)
as
(
SELECT d.continent,d.location,d.date,d.population, v.new_vaccinations, SUM(CONVERT(bigint, v.new_vaccinations)) 
	OVER (Partition by d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent is not null
)
SELECT *, (rollingpeoplevaccinated/population) * 100 AS Percentage_vaccinated
FROM PopVsVac



--Temp table

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT d.continent,d.location,d.date,d.population, v.new_vaccinations, SUM(CONVERT(bigint, v.new_vaccinations)) 
	OVER (Partition by d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent is not null
SELECT *, (rollingpeoplevaccinated/population) * 100 AS Percentage_vaccinated
FROM #PercentPopulationVaccinated



--Creating view to store data for later visualizations. 

CREATE VIEW PercentPopulationVaccinated
AS 
SELECT d.continent,d.location,d.date,d.population, v.new_vaccinations, SUM(CONVERT(bigint, v.new_vaccinations)) 
	OVER (Partition by d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent is not null


SELECT *
FROM PercentPopulationVaccinated

