/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

create database PortfolioProject

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3
	,4

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3
	,4

--Select data that I will be using
SELECT Location
	,DATE
	,total_cases
	,new_cases
	,total_deaths
	,population
FROM PortfolioProject..CovidDeaths
ORDER BY 1
	,2

--Let's look at the Total Cases vs Total Deaths
-- Showing the likelihood of dying if you contract covid in your country
SELECT Location
	,DATE
	,total_cases
	,total_deaths
	,(total_deaths / total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Nicaragua%'
ORDER BY 1
	,2

--Let's look at Total Cases vs Population
--Showing the percentage population got covid
SELECT Location
	,DATE
	,population
	,total_cases
	,(total_deaths / population) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--where location like '%Nicaragua%'
ORDER BY 1
	,2


--Looking at Countries with highest Infection Rate compared to Population
SELECT Location
	,population
	,MAX(total_cases) AS HighestInfectionCount
	,Max((total_cases / population)) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--where location = 'Nicaragua'
GROUP BY location
	,population
ORDER BY PercentPopulationInfected DESC


--Showing Countries with the Highest Death per Population
SELECT Location
	,MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--where not location = 'World' and continent = 'Asia'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


--Let's break em down by Continent
SELECT location
	,MAX(cast(total_deaths AS INT)) AS TotalDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeaths DESC


--Global
SELECT SUM(new_cases) AS total_cases
	,SUM(CAST(new_deaths AS INT)) AS total_deaths
	,SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--Group by date
ORDER BY 1
	,2


--Looking at Total Population vs Vaccination
SELECT dea.continent
	,dea.location
	,dea.DATE
	,dea.population
	,vac.new_vaccinations
	,SUM(CAST(vac.new_vaccinations AS INT)) OVER (
		PARTITION BY dea.location ORDER BY dea.location
			,dea.DATE
		) as RollingPoepleVaccinated
FROM PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea ON dea.location = vac.location
	AND dea.DATE = vac.DATE
WHERE dea.continent IS NOT NULL
ORDER BY 2
	,3


--Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated (
	Continent NVARCHAR(255)
	,Location NVARCHAR(255)
	,DATE DATETIME
	,Population NUMERIC
	,New_vaccination NUMERIC
	,RollingPeopleVaccinated NUMERIC
	)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent
	,dea.location
	,dea.DATE
	,dea.population
	,vac.new_vaccinations
	,SUM(CAST(vac.new_vaccinations AS INT)) OVER (
		PARTITION BY dea.location ORDER BY dea.location
			,dea.DATE
		) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea ON dea.location = vac.location
	AND dea.DATE = vac.DATE
WHERE dea.continent IS NOT NULL

--ORDER BY 2,3
SELECT *
	,(RollingPeopleVaccinated / Population) * 100
FROM #PercentPopulationVaccinated


--Creating view to store data for visualization
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent
	,dea.location
	,dea.DATE
	,dea.population
	,vac.new_vaccinations
	,SUM(CAST(vac.new_vaccinations AS INT)) OVER (
		PARTITION BY dea.location ORDER BY dea.location
			,dea.DATE
		) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea ON dea.location = vac.location
	AND dea.DATE = vac.DATE
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated