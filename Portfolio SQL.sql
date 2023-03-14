use projectportfolio;
select *
from `covid deaths_sql`
where continent is not null
order by 3,4;
-- select* 
-- from `covid vaccinations_sql`
-- order by 3,4
-- Select Data that we are going to be using

select Location, date, total_cases, new_cases, total_deaths, population_density
from `covid deaths_sql`
order by 1,2;

-- Looking at the Total cases vs Total Deaths
-- shows the likelyhood of dying if you contract covid in your country
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from `covid deaths_sql`
where location like '%Afghanistan%'
order by 1,2;


-- Looking at the Total cases vs population
-- Shows what percentage of population got Covid
select Location, date, population_density, total_cases, total_deaths, (total_cases/population_density)*100 as PercentagePopulationInfected
from `covid deaths_sql`
where location like '%Afghanistan%'
order by 1,2;

-- Looking at Countries with highest infection rate compared to population
select Location, population_density, max(total_cases) as highestInfectionCount, max((total_cases/population_density))*100 as PercentPopulationInfected
from `covid deaths_sql`
-- where location like '%Afghanistan%'
group by Location, population_density
order by PercentPopulationInfected desc;

-- Showing Countries with the highest Death Count per Population

select Location, max(total_deaths) as totalDeathCount
from `covid deaths_sql`
-- where location like '%Afghanistan%'
where continent is not null
group by Location
order by totalDeathCount desc;

-- Creating views for visualizations later exercise3
create view TotalDealthCount as 
select Location, max(total_deaths) as totalDeathCount
from `covid deaths_sql`
-- where location like '%Afghanistan%'
where continent is not null
group by Location
order by totalDeathCount desc

-- Breaking things down by continent
-- Showing the continents with the highest deathcounts

select continent, max(total_deaths) as totalDeathCount
from `covid deaths_sql`
-- where location like '%Afghanistan%'
where continent is not null
group by continent
order by totalDeathCount desc;

-- Global Numbers
select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases) as Death_Percentage
from `covid deaths_sql`
-- where location like '%Afghanistan%'
where continent is not null
group by date, total_deaths
order by 1,2;

-- Total Global deaths 
select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases) as Death_Percentage
from `covid deaths_sql`
-- where location like '%Afghanistan%'
where continent is not null
order by 1,2;

-- Creating views for visualizations later exercise2
create view GlobalDeaths as 
select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases) as Death_Percentage
from `covid deaths_sql`
-- where location like '%Afghanistan%'
where continent is not null
order by 1,2;

-- Looking at the Total Population vs Vaccination (new vaccination per day)

select dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by location order by dea.location, dea.date)
as RollingPeopleVaccinated
from `covid deaths_sql`dea
join `covid vaccinations_sql`vac 
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3;



-- Either Use CTE

with popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by location order by dea.location, dea.date)
as RollingPeopleVaccinated
from `covid deaths_sql`dea
join `covid vaccinations_sql`vac 
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
select *, (RollingPeopleVaccinated/population) * 100
from popvsvac;


-- or use temp table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent varchar(255),
Location varchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from `covid deaths_sql`dea
join `covid vaccinations_sql`vac 
on dea.location = vac.location
and dea.date = vac.date
-- where dea.continent is not null
-- order by 2,3

select * , (RollingPeopleVaccinated/population) * 100
from #PercentPopulationVaccinated

-- creating View to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from `covid deaths_sql`dea
join `covid vaccinations_sql`vac 
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
-- order by 2,3


select * 
from PercentPopulationVaccinated
