use PortfolioProject

select * 
from CovidDeaths$
where continent is not null
order by 3,4

/*select * 
from CovidVaccination$
order by 3,4*/

-- select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths$
order by 1,2


-- looking at the total cases vs total deaths
-- likelihood of dying from covid 

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths$
--where location = 'Indonesia' and total_deaths is not null
order by DeathPercentage desc


-- looking at the total cases vs population
-- shows what percentage of population got covid

select location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
from CovidDeaths$
--where location = 'Indonesia' and total_deaths is not null
order by DeathPercentage desc


-- countries with highest infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population)*100) as 
	PercentageofPopulationInfected
from CovidDeaths$
--where location = 'Indonesia' and total_deaths is not null
group by location, population
order by PercentageofPopulationInfected desc


-- showing the countries with highest death count per population

select location, max(cast(total_deaths as int)) as TotalDeathcount
from CovidDeaths$
--where location = 'Indonesia' and total_deaths is not null
where continent is not null
group by location
order by TotalDeathcount desc


-- break things down by continent

-- showing continents with the highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathcount
from CovidDeaths$
--where location = 'Indonesia' and total_deaths is not null
--where continent is not null
where continent is not null
group by continent
order by TotalDeathcount desc


-- global numbers
-- DeathPercentage per day

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths$
--where location = 'Indonesia' and total_deaths is not null
where continent is not null
group by date
order by 1,2

-- total DeathPercentage
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths$
--where location = 'Indonesia' and total_deaths is not null
where continent is not null
--group by date
order by 1,2


-- looking at total population vs vaccinations

select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations, 
sum(convert(bigint, vac.new_vaccinations)) over (partition by dth.location order by dth.location, dth.date) 
as RollingPeopleVaccinated
from CovidDeaths$ as dth 
join CovidVaccination$ as vac 
	on dth.location = vac.location 
	and dth.date = vac.date
where dth.continent is not null
order by 2,3


-- use CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations, 
sum(convert(bigint, vac.new_vaccinations)) over (partition by dth.location order by dth.location, dth.date) 
as RollingPeopleVaccinated
from CovidDeaths$ as dth 
join CovidVaccination$ as vac 
	on dth.location = vac.location 
	and dth.date = vac.date
where dth.continent is not null
--order by 2,3
)

select * , (RollingPeopleVaccinated/population)*100
from PopvsVac


-- temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations, 
sum(convert(bigint, vac.new_vaccinations)) over (partition by dth.location order by dth.location, dth.date) 
as RollingPeopleVaccinated
from CovidDeaths$ as dth 
join CovidVaccination$ as vac 
	on dth.location = vac.location 
	and dth.date = vac.date
where dth.continent is not null
--order by 2,3

select * , (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- creating view to store data for later visualizations

create view PercentPopulationVaccinated as
select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations, 
sum(convert(bigint, vac.new_vaccinations)) over (partition by dth.location order by dth.location, dth.date) 
as RollingPeopleVaccinated
from CovidDeaths$ as dth 
join CovidVaccination$ as vac 
	on dth.location = vac.location 
	and dth.date = vac.date
where dth.continent is not null
-- order by 2,3


