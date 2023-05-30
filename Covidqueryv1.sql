select *
from Portfolio..CovidDeaths
order by 2,3

--select *
--from Portfolio..CovidVaccinations
--order by 2,

-- select data that we are going to be using.

select Location, date, total_cases, new_cases, total_deaths, population_density
from Portfolio..CovidDeaths
order by 1,2

-- looking at total_cases VS Total_deaths

-- shows likelihood of dying if you contract Covid in your country

select Location, date, total_cases, total_deaths, (Convert(float,total_deaths)/convert ( float,total_cases))*100 as DeathPercentage
from Portfolio..CovidDeaths
where location like '%states%'
order by 1,2

-- total cases vs population
-- shows the percentage of population got Covid

select Location, date, total_cases, population,  (Convert(float,total_cases)/convert ( float,population))*100 as PercentPopulationInfected
from Portfolio..CovidDeaths
--where location like '%states%'
order by 1,2

-- countries with highest infection rates compared to population.


select Location, max(total_cases), population, max( (Convert(float,total_cases)/convert ( float,population))*100) as PercentPopulationInfected
from Portfolio..CovidDeaths
group by location, population
order by PercentPopulationInfected desc

-- showing countries with highest death count per population

select location, max(total_deaths) as maximumdeaths, population, max((Convert(float,total_deaths)/convert(float,population))*100) as PercentPopulationDeath
from Portfolio..CovidDeaths
where continent is not null
group by location, population 
order by PercentPopulationDeath desc 

--lets break things down by continent.
-- showing the continent with the highest death count per population

select continent, max(total_deaths) as maximumdeaths,  max((Convert(float,total_deaths)/convert(float,population))*100) as PercentPopulationDeath
from Portfolio..CovidDeaths
where continent is not null
group by continent
order by PercentPopulationDeath desc



-- GLOBAL NUMBERS // overall data 

select   sum(convert(float,new_cases)) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(convert(float,total_cases)))*100 as DeathPercentage -- sum(total_deaths), (Convert(float,total_deaths)/convert ( float,total_cases))*100 as DeathPercentage
from Portfolio..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2



-- look at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio..CovidDeaths dea
join Portfolio..CovidVaccinations vac
	on dea.location = vac.location and dea.date = vac.date 
where dea.continent is not null
order by 1,2,3


-- Temp Table

create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio..CovidDeaths dea
join Portfolio..CovidVaccinations vac
	on dea.location = vac.location and dea.date = vac.date 
where dea.continent is not null
order by 1,2,3


select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated



-- Creating view to store data for later visualizatinons.

create view PercentPopulationVaccinatedd as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio..CovidDeaths dea
join Portfolio..CovidVaccinations vac
	on dea.location = vac.location and dea.date = vac.date 
where dea.continent is not null
--order by 2,3

