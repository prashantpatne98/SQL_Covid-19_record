/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

select * 
from Portfolio_Project..['covid_data_deaths']
where continent is not null
order by 3,4


-- Select Data that we are going to be starting with

select location, date, total_cases, new_cases, total_deaths, population 
from Portfolio_Project..['covid_data_deaths']
where continent is not null
order by 1,2


--Total cases vs total deaths
--Shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage 
from Portfolio_Project..['covid_data_deaths']
where location='India' 
and continent is not null
order by 1,2


-- Total cases vs population
-- Shows what percentage of population infected with Covid

select location, date, population,total_cases, (total_cases/population)*100 as percent_population_infected 
from Portfolio_Project..['covid_data_deaths']
where location='India' 
and continent is not null
order by 1,2


--Countries with highest infection rate per population

select location, population,max(total_cases) as highest_infection_count, max((total_cases/population))*100 as percent_population_infected 
from Portfolio_Project..['covid_data_deaths']
where continent is not null
group by population, location
order by percent_population_infected desc


--Countries with highest death count per population

select location,max(cast(total_deaths as int)) as total_death_count
from Portfolio_Project..['covid_data_deaths']
where continent is not null
group by location
order by total_death_count desc


--Continent with highest death count per population

select continent,max(cast(total_deaths as int)) as total_conti_death_count
from Portfolio_Project..['covid_data_deaths']
where continent is not null
group by continent
order by total_conti_death_count desc


--Global death percentage

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage 
from Portfolio_Project..['covid_data_deaths']
where continent is not null
order by death_percentage desc


-- Total population vs total vaccination
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from Portfolio_Project..['covid_data_deaths']  dea
join Portfolio_Project..['covid_vaccination']  vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from Portfolio_Project..['covid_data_deaths']  dea
join Portfolio_Project..['covid_vaccination']  vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from Portfolio_Project..['covid_data_deaths']  dea
join Portfolio_Project..['covid_vaccination']  vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated_1 as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from Portfolio_Project..['covid_data_deaths']  dea
join Portfolio_Project..['covid_vaccination']  vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
