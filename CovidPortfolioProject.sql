SELECT * 
FROM PortfolioProject..CovidVaccinations$
Order by 3, 4

Select * 
FROM PortfolioProject..CovidDeaths$
Order By 3, 4

SELECT Location, date,total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
Order By 1, 2

--Show the likelihood of dying if contract COVID in Canada
--Total Cases Vs Total Deaths
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
Where Location = 'Canada'
Order By 1, 2

--Show the percentage of the population that contracted COVID in Canada
--Total Cases Vs Population
SELECT Location, date, total_cases, population, (total_cases/population)*100 as InfectedPopulationPercentage
FROM PortfolioProject..CovidDeaths$
Where Location = 'Canada'
Order By 1, 2

--Looking at Countries with Highest Infection Rate Compared to Population
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as InfectedPopulationPercentage
FROM PortfolioProject..CovidDeaths$
GROUP BY Location, population
Order By InfectedPopulationPercentage DESC

--Showing Countries with Highest Death Count per Population
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY Location
Order By TotalDeathCount DESC

--Let's break things down by continent

--SELECT continent, location, MAX(cast(total_deaths as int)) as TotalDeathCount
--FROM PortfolioProject..CovidDeaths$
--WHERE continent is null AND location NOT LIKE '%income%'
--GROUP BY continent, location
--Order By TotalDeathCount DESC

--Showing continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY continent
Order By TotalDeathCount DESC


--GLOBAL NUMBERS
Select Date, SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, sum(new_deaths)/NULLIF(sum(new_cases),0)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
Where continent is not Null
Group By date
Order By 1, 2

--Looking at Total Population vs Total Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location Order By dea.location, dea.date) as AccumulatedPeopleVaccinated
From PortfolioProject..CovidDeaths$ Dea
Join PortfolioProject..CovidVaccinations$ Vac
	On Dea.location = Vac.location
	AND Dea.date = Vac.date
Where Dea.continent is not NULL
Order By 2, 3

--Use CTE

With PopvsVac (continent, location, date, population, new_vaccinations, accumulatedPeopleVaccinated)
As
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location Order By dea.location, dea.date) as AccumulatedPeopleVaccinated
From PortfolioProject..CovidDeaths$ Dea
Join PortfolioProject..CovidVaccinations$ Vac
	On Dea.location = Vac.location
	AND Dea.date = Vac.date
Where Dea.continent is not NULL
--Order By 2, 3
)
Select *, (accumulatedPeopleVaccinated/population)*100 PercentageVaccinated
FROM PopvsVac
Order By 2, 3