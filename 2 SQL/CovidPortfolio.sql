-- ' SELECTING ALL DATA FROM CovidDeaths ORDERED BY LOCATION AND DATE'

SELECT *
FROM PortfolioCovid..CovidDeaths$
ORDER BY 3, 4

-- ' SELECTING COUNTRY DATA : CAMEROON '
SELECT *
FROM PortfolioCovid..CovidDeaths$
WHERE location like '%Cameroon%'
ORDER BY 3, 4

-- ' LIKELIHOOD OF CONTRACTING THE VIRUS IN CAMEROON : INFECTION RATE'
SELECT location, date, new_cases, total_cases, population, (total_cases/population)*100 AS infection_rate
FROM PortfolioCovid..CovidDeaths$
Where location like '%Cameroon%'
Order By 1, 2

-- ' AVERAGE INFECTION RATE IN CAMEROON'
SELECT AVG(population) AS total_Population, MAX(total_cases) AS total_cases, (MAX(total_cases)/AVG(population))*100 AS avg_infection_rate
FROM PortfolioCovid..CovidDeaths$
WHERE location like '%Cameroon%'

-- ' INFECTION RATE PER COUNTRY  '
SELECT location, population, MAX(total_cases) AS total_infections, MAX(total_cases/population)*100 population_infection_rate
FROM PortfolioCovid..CovidDeaths$
GROUP BY location, population
ORDER BY population_infection_rate DESC

-- ' INFECTION RATE PER COUNTRY WITH RESPECT TO TIME '
SELECT location, population, date, MAX(total_cases) AS total_infections, MAX(total_cases/population)*100 population_infection_rate
FROM PortfolioCovid..CovidDeaths$
GROUP BY location, population, date
ORDER BY population_infection_rate DESC

-- ' NUMBER OF DEATHS IN CAMEROON '
SELECT AVG(population) AS population, SUM(CAST(new_deaths AS INT)) AS total_death_count
FROM PortfolioCovid..CovidDeaths$
WHERE location like '%Cameroon%'

-- ' NUMBER OF DEATHS PER CONTINENT '
SELECT location, SUM(CAST(new_deaths AS INT)) AS total_death_count
FROM PortfolioCovid..CovidDeaths$
WHERE continent is null
AND location not in ('World', 'European Union', 'International')
Group by location
ORDER BY total_death_count DESC

-- '  LIKELIHOOD OF DYING UPON CONTRACTING THE VIRUS IN CAMEROON : DEATHRATE  '
SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS DOUBLE PRECISION)/CAST(total_cases AS DOUBLE PRECISION))*100 AS death_rate
FROM PortfolioCovid..CovidDeaths$
WHERE location like '%Cameroon%' 
ORDER BY 1, 2

-- ' AVERAGE DEATHRATE OUT OF POPULATION CAMEROON '
SELECT MAX(total_cases) AS total_cases, MAX(total_deaths) As total_deaths, CAST((MAX(total_deaths)/AVG(population))*100 AS DOUBLE PRECISION) AS death_percentage
FROM PortfolioCovid..CovidDeaths$
WHERE location like '%Cameroon%' 

-- ' AVERAGE DEATHRATE IN THE WORLD
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) As total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS death_rate
FROM PortfolioCovid..CovidDeaths$
WHERE continent is not null
ORDER BY 1,2

-- ' COUNTRIES WITH HIGHEST INFECTION RATE OVERALL COMPARED TO POPULATION FROM HIGHEST TO SMALLEST'
SELECT location AS country, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercentagePopInfected
FROM PortfolioCovid..CovidDeaths$
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentagePopInfected DESC

-- ' CONTINENTS WITH HIGHEST INFECTION RATE OVERALL COMPARED TO POPULATION FROM HIGHEST TO SMALLEST'
SELECT location AS continent, population, CAST(MAX(total_cases) AS INT) AS HighestInfectionCount, CAST(MAX(total_cases/population)*100 AS DOUBLE PRECISION) AS PercentagePopInfected
FROM PortfolioCovid..CovidDeaths$
WHERE continent is null
GROUP BY location, population
ORDER BY PercentagePopInfected DESC

-- ' COUNTRIES WITH HIGHEST DEATHRATE RATE OVERALL COMPARED TO POPULATION FROM HIGHEST TO SMALLEST'
SELECT location AS country, population, CAST(MAX(total_deaths) AS INT) AS HighestDeathsCount, CONVERT(DOUBLE PRECISION,MAX(total_deaths/population))*100 AS PercentagePopDeath
FROM PortfolioCovid..CovidDeaths$
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentagePopDeath DESC

-- ' CONTINENTS WITH HIGHEST DEATHRATE RATE OVERALL COMPARED TO POPULATION FROM HIGHEST TO SMALLEST'
SELECT location AS continent, AVG(population) AS population, CAST(MAX(total_deaths) AS INT) AS HighestDeathsCount, CONVERT(DOUBLE PRECISION,MAX(total_deaths/population))*100 AS PercentagePopDeath
FROM PortfolioCovid..CovidDeaths$
WHERE continent is null
GROUP BY location, population
ORDER BY PercentagePopDeath DESC

-- ' GLOBAL DEATH RATE '
SELECT SUM(CAST(new_cases AS INT)) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS GlobalDeathPercentage
FROM PortfolioCovid..CovidDeaths$
WHERE continent is not null
ORDER BY 1, 2

-- ' COMPARING TOTAL POPULATION TO VACCINATION '
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
FROM PortfolioCovid..CovidDeaths$ cd
JOIN PortfolioCovid..CovidVaccinations$ cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent is not null
ORDER BY 2, 3

-- ' COMPARING TOTAL POPULATION INFECTION AND DEATHS TO VACCINATION WORLWIDE'
SELECT cd.continent, cd.location, cd.date, cd.population, cd.new_cases, cd.total_cases, cd.new_deaths, cd.total_deaths, cv.new_vaccinations
FROM PortfolioCovid..CovidDeaths$ cd
JOIN PortfolioCovid..CovidVaccinations$ cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent is not null
ORDER BY 2, 3

-- ' COMPARING TOTAL POPULATION INFECTION AND DEATHS TO VACCINATION IN CAMEROON'
SELECT cd.continent, cd.location, cd.date, cd.population, cd.new_cases, cd.total_cases, cd.new_deaths, cd.total_deaths, cv.new_vaccinations
FROM PortfolioCovid..CovidDeaths$ cd
JOIN PortfolioCovid..CovidVaccinations$ cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent is not null AND cd.location like '%Cameroon%'
ORDER BY 2, 3

-- ' COMPARING TOTAL POPULATION INFECTION AND DEATHS TO VACCINATION WORLWIDE AND USING ROLLINGCOUNT'
SELECT cd.continent, cd.location, cd.population, cv.new_vaccinations
, SUM(CONVERT(INT,cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
FROM PortfolioCovid..CovidDeaths$ cd
JOIN PortfolioCovid..CovidVaccinations$ cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent is not null
ORDER BY 1, 2

--   ' THESAME CTE WILL BE USED FOR BOTH SELECT STATEMENTS BELOW'
-- ' COMPARING DEATH AND INFECTION RATE IN CAMEROON OBSERVING CORRELATION BETWEEN DEATHS AND VACCINATION RATES'
WITH PopVsVAC( Continent, Location, Date, Population, New_cases, New_vaccinations, Total_cases, New_deaths, Total_vaccinations, Total_deaths, Full_vaccinations, Median_age, Gdp, CardiovascularDeathRate, Diabetes , DeveloptIndex, RollingPeopleVaccinated)
AS(
SELECT cd.continent, cd.location, cd.date, cd.population, cd.new_cases, cv.new_vaccinations, cd.total_cases, cd.new_deaths, cv.total_vaccinations, cd.total_deaths, cv.people_fully_vaccinated, cv.median_age, cv.gdp_per_capita, cv.cardiovasc_death_rate, cv.diabetes_prevalence, cv.human_development_index
, SUM(CONVERT(INT, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
FROM PortfolioCovid..CovidDeaths$ cd
JOIN PortfolioCovid..CovidVaccinations$ cv
	ON cd.location = cv.location
	AND cd.date = cv.date
)

--SELECT Location, Date, Population, New_deaths, Total_deaths, New_vaccinations, Total_vaccinations, Total_deaths/Population*100 AS DeathRate, Total_vaccinations/Population*100 AS VaccinationRate
--FROM PopVsVAC
--WHERE location like '%Cameroon%'

SELECT Location , SUM(New_cases) AS TotalCases, MAX(Total_deaths) AS TotalDeaths, MAX(Total_vaccinations) AS TotalVaccinations, MAX(DeveloptIndex) AS DevelopmentIndex, MAX(Median_age) AS AverageAge
FROM PopVsVAC
Where Continent is not null
GROUP BY Location
ORDER BY 5 DESC -- On average countries with a low develoment index had lower death counts together with low average age


--  ' USING A TEMP TABLE TO GET INSIGHTS TOTAL VACCINATION WITH RELATION TO TOTAL DEATHS'
DROP TABLE IF EXISTS #PopulationVaccinated
CREATE TABLE #PopulationVaccinated
(
Continent nvarchar(255), Location nvarchar(255), Date datetime, Population numeric, New_cases numeric
,New_vaccinations numeric, Total_cases numeric, New_deaths numeric, Total_vaccinations numeric
, Total_deaths numeric, Full_vaccinations numeric, Median_age numeric, Gdp numeric, CardiovascularDeathRate numeric, Diabetes numeric, DeveloptIndex numeric, RollingPeopleVaccinated numeric
)
INSERT INTO #PopulationVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cd.new_cases, cv.new_vaccinations, cd.total_cases, cd.new_deaths, cv.total_vaccinations, cd.total_deaths, cv.people_fully_vaccinated, cv.median_age, cv.gdp_per_capita, cv.cardiovasc_death_rate, cv.diabetes_prevalence, cv.human_development_index
, SUM(CONVERT(INT, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
FROM PortfolioCovid..CovidDeaths$ cd
JOIN PortfolioCovid..CovidVaccinations$ cv
	ON cd.location = cv.location
	AND cd.date = cv.date

Select *
From #PopulationVaccinated
WHERE Total_deaths > 300 AND Total_vaccinations > 300 AND Continent is not null
ORDER BY Total_vaccinations DESC, Total_deaths DESC
-- FROM THIS WE SEE THAT ON AVERAGE COUNTRIES WITH HIGHER MEDIAN AGES, GDP, DEVELOPMENT INDEX
-- DIABETES AND CARDIOVASCULAR DEATH HAD HIGHER DEATH COUNTS DUE TO COVID-19
--ALSO THERE IS LITTLE RELATION BETWEEN VACCINATIONS AND DEATH COUNTS IN HIGH INCOME COUNTRIES
--FINALLY THERE IS CLOSE TO NO RELATION BETWEEN VACCINATIONS AND DEATH COUNT IN LOW INCOME COUNTRIES

CREATE VIEW PerPopVacc as
SELECT cd.continent, cd.location, cd.population, cv.new_vaccinations
, SUM(CONVERT(INT,cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
FROM PortfolioCovid..CovidDeaths$ cd
JOIN PortfolioCovid..CovidVaccinations$ cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent is not null
