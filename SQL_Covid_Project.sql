select *
from PortfolioProject.dbo.CovidDeaths$
where continent is not null
order by 3,4

select *
from PortfolioProject.dbo.CovidVaccinations$
order by 3,4 

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.dbo.CovidDeaths$
order by 1,2

--Looking for Total Cases vs Total Deaths
--Shows likelihood of dying if you contract Covid in your country
select Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths$
where Location = 'United States'
order by 1,2

--Looking at Total Cases vs Population
--Shows percentage of population that got COVID
select Location, date, total_cases, population, (total_cases/population)*100 as CovidPercentage
from PortfolioProject.dbo.CovidDeaths$
where Location = 'United States'
order by 1,2

--Looking at countries with highest infection rate compared to population

select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths$
group by Location, population
order by PercentPopulationInfected desc

--Showing countries with highest death count per population
select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths$
where continent is not null
group by Location
order by TotalDeathCount desc

--Break things down by continent
--Showing continents with highest death count per population
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc

--More accurate than above query
select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths$
where continent is null
group by Location
order by TotalDeathCount desc

--Global Numbers
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths$
where continent is not null
--group by date
order by 1,2

--Looking at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over
(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths$ dea
Join PortfolioProject.dbo.CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over
(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths$ dea
Join PortfolioProject.dbo.CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3 
)
select *, (RollingPeopleVaccinated/population)*100
from
PopvsVac

--temp table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccninations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over
(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths$ dea
Join PortfolioProject.dbo.CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3 

select *, (RollingPeopleVaccinated/population)*100
from
#PercentPopulationVaccinated

--Creating View to store data for later visualizations

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over
(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths$ dea
Join PortfolioProject.dbo.CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3 