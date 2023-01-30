/*

Queries used for Tableau Project

*/


-- 1. 
-- get the sum of new cases, sum of total deaths and death percentage

USE PortfolioProject
Select SUM(new_cases) AS total_cases, 
       SUM(cast(new_deaths AS int)) AS total_deaths, 
	   SUM(cast(new_deaths AS int))/SUM(New_Cases)*100 AS DeathPercentage
From CovidDeaths
WHERE continent is not null 
ORDER BY total_cases, total_deaths



-- 2. 
-- Remove inconsistent/repeated data: 
--   location categorize under 'World', 'European Union', 'International', 
--   'High Income', 'Low income', 'Lower middle income', 'Upper middle income'' 

USE PortfolioProject
SELECT location, SUM(cast(new_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent is null 
   and location not in ('World', 'European Union', 'International', 'High Income', 'Low income', 'Lower middle income', 'Upper middle income')
GROUP BY location
ORDER BY TotalDeathCount DESC



-- 3.
--Data to include continents and separate countries
--categories in international, world, european union, and various income levels are remove for data consistency. 

USE PortfolioProject
SELECT Location, 
       Population, 
	   MAX(total_cases) AS HighestInfectionCount,  
	   Max(total_cases/population)*100 AS PercentPopulationInfected
FROM CovidDeaths
WHERE location not in ('World', 'European Union', 'International', 'High Income', 'Low income', 'Lower middle income', 'Upper middle income')
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC



-- 4.

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc






