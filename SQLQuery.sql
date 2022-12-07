select *
from PortfolioProject..CovidDeaths
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

Select Location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2   --based on location and date

Select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like 'india'
order by 1,2   --based on location and date

Select Location,date,population,total_deaths,(total_deaths/population)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like 'india'
order by 1,2   --based on location and date

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
group by location,population
order by PercentPopulationInfected desc

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null		--in the table,where c is null location is continent
group by location				--used aggregate function
order by TotalDeathCount desc

--CONTINENT
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is null		--in the table,where c is null location is continent
group by location			--used aggregate function
order by TotalDeathCount desc

Select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2   --based on location and date

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
	sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
	dea.date) as RollingPeoplevaccinated
	--,(vac.RollingPeopleVaccinated/dea.population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidDeaths vac
	on dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

--CTE

with PopvsVac(continent,location,date,population,new_vaccinations,RollingPeoplevaccinated)
as(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
	sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
	dea.date) as RollingPeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidDeaths vac
	on dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
)
select *,(RollingPeopleVaccinated/population)*100 as Precent_RollingPeoplevaccinated
from PopvsVac

--TEMP TABLE

drop table if exists T
Create Table T(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into T
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
	sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
	dea.date) as RollingPeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidDeaths vac
	on dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
select *,(RollingPeopleVaccinated/population)*100 as Precent_RollingPeoplevaccinated
from T
