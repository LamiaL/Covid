
/*
Covid 19 Data Exploration
les données sont téléchargés à partir de ce site
https://ourworldindata.org/covid-deaths
*/

--Montrer tous les données ordonnées par  et pay
Select *
From PortfolioProject.dbo.covid_death
Where continent is not null 
order by 3,4

-- Selecter quelques données qui semblent intrestant
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.covid_death
Where continent is not null 
order by 1,2

--Comparer les cas totals VS les cas cas de décies
--Voir la probailité de décie si tu contact covid dans le pay selectioné
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.covid_death
Where location like 'algeria'
and continent is not null 
order by 1,2


--Comparer les cas totals VS la population de pay
--Voir le percentage de population qui ont contactes Covid
Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject.dbo.covid_death
--Where location like 'algeria'
order by 1,2


--les pays qui ont la plus grand poursantage d'infection par rapport à la Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject.dbo.covid_death
--Where location like '%algeria%'
Group by Location, Population
order by PercentPopulationInfected desc

--les pays qui ont la plus grand nombre des décies par rapport à la Population
--use cast(Total_deaths as int) if total_cases isnt int
Select Location, MAX(Total_deaths) as TotalDeathCount
From PortfolioProject.dbo.covid_death
--Where location like '%%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc



--MONTRE DES RESULTATS PAR CONTINENT

--les continents qui ont la plus grand nombre des décies par rapport à la Population
Select location, MAX(Total_deaths) as TotalDeathCount
From PortfolioProject.dbo.covid_death
--Where location like '%%'
Where continent is null 
Group by location
order by TotalDeathCount desc



-- DES CHIFFRES GLOBALES 

--le nb totales des cas, le nb totales des décies et le pourcentage de décie
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject.dbo.covid_death
--Where location like '%%'
where continent is not null 
--and total_deaths is not null
--Group By date
order by 1,2



-- Population vs Vaccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.covid_death dea
Join PortfolioProject.dbo.covid_vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Montre le Pourcentage de Population qu'on au mois un vaccine de Covid (on est besoin d'utiliser un CTE ou un table temp)
--  1- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject.dbo.covid_death dea
Join PortfolioProject.dbo.covid_vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentageOfRollingPeopleVaccinated
From PopvsVac



-- 2- Using Temp Table to perform Calculation on Partition By in previous query

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
From PortfolioProject.dbo.covid_death dea
Join PortfolioProject.dbo.covid_vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creation d'un vue pour enregistrer les données pour la visualization
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.covid_death dea
Join PortfolioProject.dbo.covid_vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

