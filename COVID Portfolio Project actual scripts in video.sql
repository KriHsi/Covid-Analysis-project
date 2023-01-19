USE PortfolioProject
SELECT *
FROM CovidVaccinations
ORDER BY 3, 4n

--join tables covidDeath and CovidVaccination
--looking at total population vs vaccination
--partition is summing up number of new_vaccinations

USE PortfolioProject 
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(CONVERT(BIGINT, v.new_vaccinations )) OVER (Partition by d.location Order by d.location, d.date ) AS RollingPeopleVaccinated
FROM CovidDeaths D
JOIN CovidVaccinations V
ON  D.location = v.location
and d.date = v.date
WHERE d.continent is not null
ORDER BY d.location, d.date

--RollingPeopleVaccinated is an alisa, cannot be call(query), need to set up a CTE:PopVsVac
--CTE(common table expression to query RollingPeopleVaccinated)
--CTE column name must be same as SELECT column name
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

--views are permanant tables, can be query directly:
SELECT *
FROM PercentPopulationVaccinated