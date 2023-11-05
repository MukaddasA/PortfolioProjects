-- This is a data exploration project from the COVID19 Dataset.

SELECT *
FROM PortfolioProject..CovidDeaths
order by 1, 2

SELECT *
FROM PortfolioProject..CovidVaccinations
order by 1, 2

-- Select Data that we are going to be using

SELECT location,date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1, 2


-- Total Cases Vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2



-- Total Cases vs Population
-- Shows what percentage of population got covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentofPopulationInfected
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2


-- Countries with higest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HigestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- Countries with the highest death count per population

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC



-- Breakdown by continent
-- Continents with the higest death counts

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Case fatality Rate by country

WITH TotalCasesByCountry AS (
    SELECT location, 
           SUM(CAST(new_cases AS INT)) AS TotalCases, 
           SUM(CAST(new_deaths AS INT)) AS TotalDeaths
    FROM PortfolioProject..CovidDeaths
    GROUP BY location
)
SELECT location, TotalCases, TotalDeaths, 
    CASE 
        WHEN TotalCases = 0 THEN 0
        ELSE (TotalDeaths * 100.0) / TotalCases  -- Ensure at least one operand is a decimal to get a decimal result
    END AS CaseFatalityRate
FROM TotalCasesByCountry
ORDER BY CaseFatalityRate DESC;



SELECT *
FROM PortfolioProject..CovidVaccinations

-- Total Population Vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1, 2, 3


-- Use CTE

WITH PopvsVac as (
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population) * 100
FROM PopvsVac



-- Creating view for visualization

CREATE VIEW PercentageofPeopleVaccinated AS (
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
)

SELECT *
FROM PercentageofPeopleVaccinated
