SELECT *
FROM PortfolioProject..['covid da$']
Where continent is not null
order by 3,4

--SELECT *
--FROM PortfolioProject..['covid vacinations$']
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..['covid da$']
order by 1,2
--looking at total cases vs total deaths
--shows likelihood of dying if you contact covid inyour country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..['covid da$']
Where location like '%states%'
order by 1,2

--looking at total cases vs population
--shows what percentage of population got covid

Select Location, date, population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..['covid da$']
--Where location like '%states%'
order by 1,2

--looking at countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..['covid da$']
--Where location like '%states%'
Group by Location, population
order by PercentPopulationInfected desc




--showing countries with highest death count per population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['covid da$']
--Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

--let's break things down by continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['covid da$']
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..['covid da$']
--Where location like '%states%'
Where continent is null
Group by location
order by TotalDeathCount desc


--showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['covid da$']
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc



--Global Numbers
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage--, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..['covid da$']
--Where location like '%states%'
Where continent is not null
Group By date
order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage--, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..['covid da$']
--Where location like '%states%'
Where continent is not null
--Group By date
order by 1,2

--looking at total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..['covid da$'] dea
Join PortfolioProject..['covid vacinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3
 
 
 --USE CTE
With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['covid da$'] dea
Join PortfolioProject..['covid vacinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['covid da$'] dea
Join PortfolioProject..['covid vacinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3


Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


-- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['covid da$'] dea
Join PortfolioProject..['covid vacinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
SELECT *
FROM PercentPopulationVaccinated