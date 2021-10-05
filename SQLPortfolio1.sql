select * 
from PortfolioProject1..Covid_deaths$ 
where continent is not null
order by 3,4


--select * 
--from PortfolioProject1..Covid_vaccination$ 
--order by 3,4

-- selecting data

select location, date,total_cases,new_cases,total_deaths, population
from PortfolioProject1..Covid_deaths$
where continent is not null
order by 1,2

-- looking at Total cases vs Total deaths
--- likelihood of death percentage in India
select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject1..Covid_deaths$
where location like '%India%'
and continent is not null
order by 1,2

-- looking at total case vs population
-- shows what % of population got Covid in India
select location, date, total_cases, population, (total_cases/population)*100 as InfectionPercentage
from PortfolioProject1..Covid_deaths$
where location like '%India%'
and continent is not null
order by 1,2

-- looking at countries with highest infection rate compared to Population
select location, population, MAX(total_cases) as HighestInfectionCount, 
MAX((total_cases/population)*100) as PercentPopulationInfected 
from
PortfolioProject1..Covid_deaths$
where continent is not null
group by location,population
order by PercentPopulationInfected desc

-- looking at countries with highest death count compared to Population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from
PortfolioProject1..Covid_deaths$
where continent is not null
group by location
order by TotalDeathCount desc

-- LETS DO THIS BY CONTINENT
-- looking at continents with highest death counts
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from
PortfolioProject1..Covid_deaths$ 
where continent is  null
group by continent
order by TotalDeathCount desc

-- Global numbers

select  date, sum(new_cases) as total_Newcases, SUM(cast(new_deaths as int)) as total_Newdeaths, 
SUM(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentageWorldWide
from PortfolioProject1..Covid_deaths$
--where location like '%India%'
where continent is not null
group by date
order by 1,2

-- Looking at Total Population Vs. Vaccination in India

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location,dea.date) as Total_vaccination
from PortfolioProject1..Covid_deaths$ dea
JOIN PortfolioProject1..Covid_vaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--and dea.location like '%India%'
order by 2,3

-- With CTE

With PopVsVac (continent, location, date, population,new_vaccinations, Total_vaccination)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location,dea.date) as Total_vaccination
from PortfolioProject1..Covid_deaths$ dea
JOIN PortfolioProject1..Covid_vaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--and dea.location like '%India%'
)
select *, (Total_vaccination/population)*100 as Total_vaccination_perc
from PopVsVac
where location like '%India%'

-- TEMP table
DROP TABLE IF exists #perPopVac
create table #perPopVac(continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric,
new_vaccinations numeric, 
Total_vaccination numeric)

Insert into #perPopVac
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location,dea.date) as Total_vaccination
from PortfolioProject1..Covid_deaths$ dea
JOIN PortfolioProject1..Covid_vaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--and dea.location like '%India%'

select *, (Total_vaccination/population)*100 as Total_vaccination_perc
from #perPopVac
where location like '%India%'

-- Creating View for later viz


Create View percPopVacView as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location,dea.date) as Total_vaccination
from PortfolioProject1..Covid_deaths$ dea
JOIN PortfolioProject1..Covid_vaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select * from percPopVacView