Select *
From PotfolioProject1..Deaths
Order by 3,4

Select *
From PotfolioProject1..vaccinations
Order by 3,4

-- Selecting the data that is going to be used
Select Location, date, total_cases, new_cases, total_deaths, population
From PotfolioProject1..Deaths
order by 1,2

-- Looking at Total Cases vs Deaths

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PotfolioProject1..Deaths
WHERE total_deaths is not null
order by 1, 2

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PotfolioProject1..Deaths
WHERE location like '%States%'
and total_deaths is not null
order by 1, 2

-- Total Cases vs. Population

SELECT Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationAffected
FROM PotfolioProject1..Deaths
WHERE location like '%States%'
and total_cases is not null
order by 1, 2

-- Highest Infection Rate against the Population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentPopulationInfected
FROM PotfolioProject1..Deaths
WHERE continent is not null
GROUP BY location, population
order by PercentPopulationInfected desc

-- The countries with Highest Death Count per Population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PotfolioProject1..Deaths
WHERE continent is not null
GROUP BY location
order by TotalDeathCount desc

-- Highest Death Count by continent

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PotfolioProject1..Deaths
WHERE continent is not null
GROUP BY continent
order by TotalDeathCount desc

-- Global numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PotfolioProject1..Deaths
WHERE continent is not null
order by 1, 2

-- What is Total Population vs. Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.Date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
FROM PotfolioProject1..Deaths dea
JOIN PotfolioProject1..vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent  is not null
order by 2,3

-- USE CTE

WITH PopvsVac(Continent, Location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.Date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
FROM PotfolioProject1..Deaths dea
JOIN PotfolioProject1..vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- Temp Table

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
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.Date) as RollingPeopleVaccinated
FROM PotfolioProject1..Deaths dea
JOIN PotfolioProject1..vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating View for Visualizations in the future

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.Date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
FROM PotfolioProject1..Deaths dea
JOIN PotfolioProject1..vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated