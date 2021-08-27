select * from coviddata
order by 3,4


select * from covidVaccinations
order by 3,4
drop table CovidDeath

--select data

select location, date, total_cases, new_cases, total_deaths, population
from CovidData
order by 1,2

--Looking at total cases vs Total Deaths in specefic location

select location, date total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeath
where location like '%states%' 
order by 1,2

--Looking total cases vs population
--shows what percentage of population get covid

select location, total_cases, population, (total_cases/population)*100 as infected_population
from CovidDeath
where location like '%states%'
order by 1, 2

--looking countries with highest infection rate
select location, population, max(total_cases) as HighestInfectionRate, max((total_cases/population))*100 as infected_rate
from CovidDeath
group by location,population
order by infected_rate Desc

--showing countries with the highest death count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeath
where continent is not null
group by location
order by TotalDeathcount Desc

--showing infection by continent
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeath
where continent is not null
group by continent
order by TotalDeathcount Desc

--Showing Global total case number,total death numbers and death percentage group by date

select date sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
	sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from covidDeath
-- location like '%states%'
where continent is not null
group by date
order by 1,2 desc

-- total number of cases, deaths and percentage by far
select  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
	sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from covidDeath
-- location like '%states%'
where continent is not null
order by 1,2 desc

---join 2 tables , coviddeaths and covidvaccinations
-- showing total population vs vaccinations

select deaths.continent, deaths.location, deaths.date, deaths.population, vaccines.new_vaccinations
from covidDeath  deaths
join covidVaccinations  vaccines
	on deaths.location = vaccines.location
	and deaths.date = vaccines.date
where deaths.continent is not null
order by 2,3


--showing total population vs vaccinations
select deaths.continent, deaths.location, deaths.date, deaths.population, vaccines.new_vaccinations,
--partition by locations
sum(convert(int, vaccines.new_vaccinations)) over (partition by deaths.location order by deaths.location, deaths.date)
as TotalVaccinated
from covidDeath  deaths
join covidVaccinations  vaccines
	on deaths.location = vaccines.location
	and deaths.date = vaccines.date
where deaths.continent is not null
order by 2,3

--rate how many people get vaccinated on the basis of their population by using cte
with PopuvsVAcc(continent, Location, Date,Population, new_vaccinations, TotalVaccinated)
as
(
select deaths.continent, deaths.location, deaths.date, deaths.population, vaccines.new_vaccinations,
--partition by locations
sum(convert(int, vaccines.new_vaccinations)) over (partition by deaths.location order by deaths.location, deaths.date)
as TotalVaccinated

from covidDeath  deaths
join covidVaccinations  vaccines
	on deaths.location = vaccines.location
	and deaths.date = vaccines.date
where deaths.continent is not null
)
select *, (TotalVaccinated/population)*100 as vaccinationpercentge
from PopuvsVAcc



--create temprorary table 
create table populationvaccinatedpercent
(Continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
TotalVaccinated numeric
)
insert into populationvaccinatedpercent
select deaths.continent, deaths.location, deaths.date, deaths.population, vaccines.new_vaccinations,
--partition by locations
sum(convert(int, vaccines.new_vaccinations)) over (partition by deaths.location order by deaths.location, deaths.date)
as TotalVaccinated

from covidDeath  deaths
join covidVaccinations  vaccines
	on deaths.location = vaccines.location
	and deaths.date = vaccines.date

select *, (TotalVaccinated/population)*100 as vaccinationpercentge
from populationvaccinatedpercent


--