Select *
From CovidDeaths
order by 3,4

Select *
From PortfolioProject..CovidVaccinations
order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
--shows the likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, cast((total_deaths) as float)/total_cases *100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location LIKE '%states%'
order by 1,2

--Looking at the total cases vs population
--shows what percentage of popuation got Covid in Nepal
Select location, date, total_cases, population, cast((total_cases) as float)/population *100 as PercentageInfected
From PortfolioProject..CovidDeaths
Where location= 'Nepal'
order by 1,2

--Looking at countries with highest infection rate compared to population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX(cast((total_cases) as float)/population *100) as PercentInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
Order by PercentInfected DESC

--Showing countries with highest death 
Select Location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null --row with continent null has continent as the country
Group by Location
Order by TotalDeathCount desc

--Breaking it out by continent
Select Continent, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null --row with continent null has continent as the country
Group by Continent
Order by TotalDeathCount desc

--Global Numbers by Date
Select date, SUM(total_cases) as Total_Cases, SUM(cast(total_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as float))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not NULL
Group By date 
Order by 1

--Looking at total population vs vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location=vac.LOCATION
    and dea.date=vac.date
where dea.continent is not NULL
order by 2,3 

--Sum of vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location=vac.LOCATION
    and dea.date=vac.date
where dea.continent is not NULL
order by 2,3 

--Using Common Table Expression (CTE)
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location=vac.LOCATION
    and dea.date=vac.date
where dea.continent is not NULL   
)
Select *, (RollingPeopleVaccinated/cast(Population as float))*100
From PopvsVac

--TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location=vac.LOCATION
    and dea.date=vac.date
where dea.continent is not NULL 
Select *, (RollingPeopleVaccinated/cast(Population as float))*100
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations
Create View PercentPopulationVaccinated AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location=vac.LOCATION
    and dea.date=vac.date
where dea.continent is not NULL 
