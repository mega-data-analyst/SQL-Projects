/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

select *
from Covid..CovidDeaths
where continent is not null
order by 3,4

--select data that we are going to be using

select 
location, 
date, 
total_cases,
new_cases,
total_deaths,
population
from Covid..CovidDeaths
where continent is not null
order by 1,2

-- Total Cases vs Total Deaths
-- shows likelihood of dying if you contract covid in your country

select 
location,
date, 
total_cases,
total_deaths,
(total_deaths/total_cases)*100 as DeathPercentage
from Covid..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2


-- Total Cases vs Population
-- shows what percentage of population got covid

select 
location, 
date,
population, 
total_cases,
(total_cases/population)*100 as PercentPopulationInfected
from Covid..CovidDeaths
where location like '%states%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population

select 
location,
population,
max(total_cases) as HighestInfectioncount,
max((total_cases/population))*100 as PercentPopulationInfected
from Covid..CovidDeaths
group by location,population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

select 
location,
Max(cast(total_deaths as int)) as TotalDeathcount
from Covid..CovidDeaths
where continent is not null
group by location
order by TotalDeathcount desc


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

select 
continent,
Max(cast(total_deaths as int)) as TotalDeathcount
from Covid..CovidDeaths
where continent is not null
group by continent
order by TotalDeathcount desc

-- GLOBAL NUMBERS

select
sum(new_cases)as total_cases,
sum(cast(new_deaths as int)) as total_deaths,
(sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from Covid..CovidDeaths
where continent is not null
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select 
d.continent,
d.location,
d.date,
d.population,
v.new_vaccinations,
SUM(convert(int,v.new_vaccinations)) over(partition by d.location order by d.location,d.date) as rollingpeoplevaccinated
from Covid..CovidDeaths d
join Covid..CovidVaccinations v
on  d.location = v.location
and d.date = v.date
where d.continent is not null
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

with popvsvac 
as
(select 
d.continent,
d.location,
d.date,
d.population,
v.new_vaccinations,
SUM(convert(int,v.new_vaccinations)) over(partition by d.location order by d.location,d.date) as rollingpeoplevaccinated
from Covid..CovidDeaths d
join Covid..CovidVaccinations v
on  d.location = v.location
and d.date = v.date
where d.continent is not null)
select *,
(rollingpeoplevaccinated/population)*100 as PercentPopulationVaccinated
from popvsvac

-- Using Temp Table to perform Calculation on Partition By in previous query

create table percentpopulationvaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric)

insert into percentpopulationvaccinated
select 
d.continent,
d.location,
d.date,
d.population,
v.new_vaccinations,
SUM(convert(int,v.new_vaccinations)) over(partition by d.location order by d.location,d.date) as rollingpeoplevaccinated
from Covid..CovidDeaths d
join Covid..CovidVaccinations v
on  d.location = v.location
and d.date = v.date

select *,
(rollingpeoplevaccinated/population)*100 as PercentPopulationVaccinated
from percentpopulationvaccinated


-- Creating View to store data for later visualizations

create view Percent_PopulationVaccinated as
select 
d.continent,
d.location,
d.date,
d.population,
v.new_vaccinations,
SUM(convert(int,v.new_vaccinations)) over(partition by d.location order by d.location,d.date) as rollingpeoplevaccinated
from Covid..CovidDeaths d
join Covid..CovidVaccinations v
on  d.location = v.location
and d.date = v.date
where d.continent is not null

select *
from Percent_PopulationVaccinated


