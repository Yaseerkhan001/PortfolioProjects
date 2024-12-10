select * from dbo.CovidDeaths
order by 3,4


--select * from dbo.CovidVaccinations
--order by 3,4

--select data that we are going to be use
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.dbo.CovidDeaths
order by 1,2

--Looking at total cases vs total deaths
--shows the percentage of death by cases
select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from dbo.CovidDeaths
where location = 'India'
and continent is not null
order by 1,2

--Looking at total cases vs total deaths
--shows what percentage of population got covid
select location, date, population, total_cases, (total_cases/population) * 100 as PercentPopulationInfected
from dbo.CovidDeaths
--where location = 'India'
order by 1,2

--Looking at the countries with Highest Infected rate compared to population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population)) * 100 as PercentPopulationInfected
from dbo.CovidDeaths
--where location = 'India'
where continent is not null
group by location, population
order by PercentPopulationInfected desc

--Showing countries with highest death count per population
select location, max(cast(total_deaths as int)) as DeathCount
from dbo.CovidDeaths
where continent is not null
group by location
order by DeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

--showing continents with the highest death count per population

select continent, max(cast(total_deaths as int)) as DeathCount
from dbo.CovidDeaths
where continent is not null
group by continent
order by DeathCount desc


--GLOBAL NUMBERS
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) total_deaths, 
sum(cast(new_deaths as int)) / sum(new_cases) * 100 as DeatPercentage
from dbo.CovidDeaths


--Looking at total	population vs vaccination



select d.continent, d.location, d.date, d.population, c.new_vaccinations,
SUM(cast(new_vaccinations as int)) over(partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population) * 100
from dbo.CovidDeaths as d
join dbo.CovidVaccinations as c
	on d.location = c.location
	and d.date = c.date
where d.continent is not null
order by 2,3


--USE CTE

with PopvsVac(Continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
as
(
select d.continent, d.location, d.date, d.population, c.new_vaccinations,
SUM(cast(new_vaccinations as int)) over(partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population) * 100
from dbo.CovidDeaths as d
join dbo.CovidVaccinations as c
	on d.location = c.location
	and d.date = c.date
where d.continent is not null
)

select *, (RollingPeopleVaccinated / population) * 100 
from PopvsVac


--TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(	
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
select d.continent, d.location, d.date, d.population, c.new_vaccinations,
SUM(cast(new_vaccinations as int)) over(partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population) * 100
from dbo.CovidDeaths as d
join dbo.CovidVaccinations as c
	on d.location = c.location
	and d.date = c.date
--where d.continent is not null



select * --, (RollingPeopleVaccinated / population) * 100 
from #PercentPopulationVaccinated