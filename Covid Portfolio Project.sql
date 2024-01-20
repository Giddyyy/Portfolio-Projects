
SELECT *
FROM CovidDeaths
Order by 3, 4


--Selecting needed data
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
Order by 1, 2

---Total cases vs Total deaths
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 as DeathPercentage
FROM CovidDeaths
Where location like '%states'
Order by 1, 2

--Total cases vs Population
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, Max(total_cases/population) *100 as CaseToPopulation
FROM CovidDeaths
--Where location like '%states'
Group by location, population
Order by CaseToPopulation desc

--Highest Death count by Population
SELECT Location, population, MAX(total_deaths) as HighestInfectionCount, Max(total_deaths/population) *100 as DeathsToPopulation
FROM CovidDeaths
Group by location, population
Order by DeathsToPopulation desc

--Sorting by Continent
--'cast' is used to convert the datatype
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
Where continent is null
Group by location
Order by TotalDeathCount desc

--'cast' is used to convert the datatype
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
Where continent  is not NULL
Group by location
Order by TotalDeathCount desc

--DeathCount by Continents
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
Where continent = 'Africa'
Group by location
Order by TotalDeathCount desc

--Global Numbers
-- encountered aggregate functions issues for group by date
SELECT date, SUM(new_cases) as TotalNewCases, SUM(cast(new_deaths as int)) as TotalNewDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases)) *100 as NewDeathPercentage
FROM CovidDeaths
Where continent is not null
--Group by location
Group by date
--Order by DeathPercentage desc
Order by 1, 2

SELECT SUM(new_cases) as TotalNewCases, SUM(cast(new_deaths as int)) as TotalNewDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases)) *100 as NewDeathPercentage
FROM CovidDeaths
Where continent is not null
--Group by location
--Group by date
--Order by DeathPercentage desc
Order by 1, 2


SELECT continent, location
FROM CovidVaccinations
Where location = 'Canada'
Order by 1, 2

--Total population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingVaccinatedPeople
From CovidDeaths as dea
Join CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2, 3

--Using CTE

With PopvsVac (Continent, Location, Date, Population,New_vaccinations, RollingVaccinatedPeople)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingVaccinatedPeople
From CovidDeaths as dea
Join CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2, 3
)
Select *, (RollingVaccinatedPeople/Population) *100 as VacPercentage
From PopvsVac

--Using Temp table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinatedPeople numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingVaccinatedPeople
From CovidDeaths as dea
Join CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2, 3

Select *, (RollingVaccinatedPeople/Population) *100 as VacPercentage
From #PercentPopulationVaccinated

--Creating View to store data for later

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingVaccinatedPeople
From CovidDeaths as dea
Join CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2, 3

--Play around with more views creations

Select *
From PercentPopulationVaccinated

