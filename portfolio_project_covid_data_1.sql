select * 
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--select * 
--from PortfolioProject..CovidVaccinations$
--order by 3,4

--select Data that we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1, 2

--Looking at total cases vs total deaths
--Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%mexico%'
order by 1, 2

--Looking at total cases vs population
--shows what perntage of population got covid
Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
where location like '%mexico%'
order by 1, 2

--Looking at countries with highest infection rate compared to population
Select Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
--where location like '%mexico%'
Group by Location, Population
order by PercentPopulationInfected desc

--Showing the countries with the highest DeatC oubt per population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths$
--where location like '%mexico%'
where continent is not null
Group by Location
order by TotalDeathCount desc

--By continent



--showing the continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths$
--where location like '%mexico%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) /SUM(new_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths$
--where location like '%mexico%'
where continent is not null
--group by date
order by 1, 2

--looking at total popuylation vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations )) 
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac 
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3


--use CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations )) 
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac 
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
select * , (RollingPeopleVaccinated/population)*100 
from PopvsVac

--TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations )) 
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac 
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

select * , (RollingPeopleVaccinated/population)*100 
from #PercentPopulationVaccinated


--creating view to store data for later visualization
create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations )) 
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac 
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3


select * from PercentPopulationVaccinated