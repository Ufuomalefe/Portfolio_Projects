use PortfolioProject
--Check for accurate loading of data.
SELECT *
FROM PortfolioProject..CovidDeaths$
Order by 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations$
Order by 3,4

--Select Data to be used
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
Order by 1,2

--Looking at Total Cases vs Total Deaths
--Likelihood of death by location if infected
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Order by 1,2

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%states%'
Order by 1,2

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%Nigeria%'
Order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got covid
Select Location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
From PortfolioProject..CovidDeaths$
Where location like '%states%'
Order by 1,2

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%Nigeria%'
Order by 1,2

--Countries with highest infection rate by population
Select Location, population, MAX(total_cases) AS HighestInfectionCount, Max(total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%Nigeria%'
Group by location, population
Order by PercentagePopulationInfected desc

--Countries with highest death count by population
Select Location, MAX(cast(total_deaths as int)) AS TotalDeathCount 
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by location
Order by TotalDeathCount desc  

--Examine Data by Continent

Select location, MAX(cast(total_deaths as int)) AS TotalDeathCount 
From PortfolioProject..CovidDeaths$
Where continent is null
Group by location
Order by TotalDeathCount desc  

--Continent with highest death count
Select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount 
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by continent
Order by TotalDeathCount desc 

--GLOBAL NUMBERS

Select date, SUM(new_cases) as DailyNewCasesGlobally, SUM(cast(new_deaths as int)) as DailyDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage--, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by date
Order by 1,2

Select SUM(new_cases) as DailyNewCasesGlobally, SUM(cast(new_deaths as int)) as DailyDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage--, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
--Group by date
Order by 1,2

--Combining CovidDeaths & CovidVaccination Tables
Select *
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
    On dea.location = vac.location
    and dea.date = vac.date

--Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
    On dea.location = vac.location
    and dea.date = vac.date
Where dea.continent is not null
Order by 1,2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
    On dea.location = vac.location
    and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
    On dea.location = vac.location
    and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

--Use CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
    On dea.location = vac.location
    and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 as RollingPercentageVaccinated
From PopvsVac

--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
    On dea.location = vac.location
    and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/population)*100 as RollingPercentageVaccinated
From #PercentPopulationVaccinated


--Creating view to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
    On dea.location = vac.location
    and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *
From PercentPopulationVaccinated

