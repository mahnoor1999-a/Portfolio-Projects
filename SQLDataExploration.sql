
Select * 
From SQLPortfolioProject..CovidDeaths
Order By 3,4

-- data to be used
Select location, date, total_cases, new_cases, total_deaths, population
From SQLPortfolioProject..CovidDeaths
Order By 1,2

-- death percentage
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
from SQLPortfolioProject..CovidDeaths
where location LIKE '%king%'
Order By 1,2

-- cases percentage
select location, date, population, total_cases, (total_cases/population)*100 AS CovidPercentage
from SQLPortfolioProject..CovidDeaths
where location LIKE '%king%'
Order By 1,2

-- countries highest covid infection rate
select location, population, MAX(total_cases) as HighestInfectionCount, (MAX(total_cases)/population)*100 AS HighestInfectionRate
from SQLPortfolioProject..CovidDeaths
Group By location, population
Order By HighestInfectionRate DESC

-- countries highest death count
select location, population, MAX(cast(total_deaths as int)) as HighestDeathCount
from SQLPortfolioProject..CovidDeaths
where continent is not null
Group By location, population
Order By HighestDeathCount DESC
	-- continent count
		select continent, MAX(cast(total_deaths as int)) as HighestDeathCount
		from SQLPortfolioProject..CovidDeaths
		where continent is not null
		Group By continent
		Order By HighestDeathCount DESC
		-- another way is combining the numbers like this
		select location, MAX(cast(total_deaths as int)) as HighestDeathCount
		from SQLPortfolioProject..CovidDeaths
		where continent is null
		Group By location
		Order By HighestDeathCount DESC


-- global percentages
select /*date, */ SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
from SQLPortfolioProject..CovidDeaths
where continent is not null
--Group By date
Order By 1



-- total population vaccinated

with PopvsVacCTE (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
	SUM(Convert(int, vacc.new_vaccinations)) OVER (Partition By death.location Order by death.location, death.date) AS RollingPeopleVaccinated
from SQLPortfolioProject..CovidDeaths death
join SQLPortfolioProject..CovidVaccinations vacc
	On death.location = vacc.location
	and death.date = vacc.date
	where death.continent is not null
)

Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVacCTE

------

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
	Continent nvarchar(500),
	Location nvarchar(500),
	Date datetime,
	Population numeric,
	NewVaccinations numeric,
	RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
	select death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
		SUM(Convert(int, vacc.new_vaccinations)) OVER (Partition By death.location Order by death.location, death.date) AS RollingPeopleVaccinated
	from SQLPortfolioProject..CovidDeaths death
	join SQLPortfolioProject..CovidVaccinations vacc
		On death.location = vacc.location
		and death.date = vacc.date
		where death.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

------

Create View PercentPopulationVaccinated
as
	select death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
		SUM(Convert(int, vacc.new_vaccinations)) OVER (Partition By death.location Order by death.location, death.date) AS RollingPeopleVaccinated
	from SQLPortfolioProject..CovidDeaths death
	join SQLPortfolioProject..CovidVaccinations vacc
		On death.location = vacc.location
		and death.date = vacc.date
		where death.continent is not null

Select * from PercentPopulationVaccinated

