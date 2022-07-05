

Select*
From Portfolio.dbo.CovidDeath
Where continent is not null
Order by 3,4

--Select*
--From Portfolio.dbo.CovidVaccinations
--Order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From Portfolio.dbo.CovidDeath
Order by 1,2 

---Total Cases VS Total Deaths
--Likelyhood of dying if you get COVID

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio.dbo.CovidDeath
Where continent is not null
Order by 1,2 

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio.dbo.CovidDeath
Where location like '%states%'
Where continent is not null
Order by 1,2 

--Total Cases VS Population
--% of Population that got COVID

Select location, date, total_cases, population, (total_cases/population)*100 as COVIDContraction
From Portfolio.dbo.CovidDeath
Where location like '%states%'
Where continent is not null
Order by 1,2 

Select location, date, total_cases, population, (total_cases/population)*100 as COVIDContraction
From Portfolio.dbo.CovidDeath
Where continent is not null
Order by 1,2 

--Highest infection rates compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as HighestInfection
From Portfolio.dbo.CovidDeath
Where continent is not null
Group By location, population
Order by HighestInfection desc

--Highest Death Count Per Population
   
Select location, MAX(Cast(total_deaths as int)) as TotalDeathCount
From Portfolio.dbo.CovidDeath
Where continent is not null
Group By location
Order by TotalDeathCount desc

--By continent


Select continent, MAX(Cast(total_deaths as int)) as TotalDeathCount
From Portfolio.dbo.CovidDeath
Where continent is null
Group By continent
Order by TotalDeathCount desc

--Showing continents with highest death per population

Select continent, MAX(Cast(total_deaths as int)) as TotalDeathCount
From Portfolio.dbo.CovidDeath
Where continent is not null
Group By continent
Order by TotalDeathCount desc

--Highest infection rates compared to population(continent)

Select continent, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as HighestInfection
From Portfolio.dbo.CovidDeath
Where continent is not null
Group By continent, population
Order by HighestInfection desc

--Total Cases VS Population
--% of Population that got COVID

Select continent, date, total_cases, population, (total_cases/population)*100 as COVIDContraction
From Portfolio.dbo.CovidDeath
Where continent is not null
Order by 1,2 

--Global #'s

Select date, Sum(new_cases) as total_cases, Sum(Cast(New_deaths as int)) as total_deaths,Sum(Cast(New_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From Portfolio.dbo.CovidDeath
Where continent is not null
group by date 
Order by 1,2 

-- Total population V Total Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..CovidDeath dea
Join Portfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3




-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio.dbo.CovidDeath dea
Join Portfolio.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
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
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..CovidDeath dea
Join Portfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Portfolio..CovidDeath dea
Join Portfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


--Queries 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Portfolio..CovidDeath
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From Portfolio..CovidDeath
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Portfolio..CovidDeath
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Portfolio..CovidDeath
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc