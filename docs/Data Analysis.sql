--Data Analysis

--After cleaning we have some views and tables which we will use for analysis.

select top 100 * from CovidProject.dbo.covid_deaths 
select top 100 * from CovidProject.dbo.covid_vaccination;
select top 100 * from CovidProject.dbo.DeathContinentNull;
select top 100 * from CovidProject.dbo.VaccinationConNull;
select top 100 * from CovidProject.dbo.covid_death_view;
select top 100 * from CovidProject.dbo.covid_total_doses_given; 
select top 100 * from CovidProject.dbo.covid_full_vaccinated_people; 

--Total cases worldwide

select sum(max_cases) from (select location,max(total_cases) as max_cases from CovidProject.dbo.covid_death_view group by location) a

select max(total_cases) from CovidProject.dbo.DeathContinentNull where location='World';

--Total Cases per location

select location,max(total_cases) as total_cases from CovidProject.dbo.covid_death_view group by location;

--Total yearly cases 

select infected_year,sum(daily_cases) as yearly_cases from CovidProject.dbo.covid_death_view group by infected_year order by infected_year

-- monthly cases

select infected_year,datepart(month,date) as month,avg(daily_cases) as yearly_cases 
from CovidProject.dbo.covid_death_view group by infected_year,datepart(month,date) order by infected_year,datepart(month,date);

-- Calculating total cases vs population 

select location, infected_date, total_cases, population, (total_cases/population)*100 as total_cases_perc_per_population
from CovidProject.dbo.covid_death_view 
order by 1,2;

--Highest Infected Rate

select location,population, max(total_cases) as total_cases, (max(total_cases)/population)*100 as total_cases_perc_per_population
from CovidProject.dbo.covid_death_view 
group by location,population
order by (max(total_cases)/population)*100 desc;


--Total Deaths Worldwide

select sum(max_deaths) from (select location,max(total_deaths) as max_deaths from CovidProject.dbo.covid_deaths group by location) a

select max(total_deaths) from CovidProject.dbo.DeathContinentNull where location='World';

--Total deaths per location

select location,max(total_deaths) as total_deaths from CovidProject.dbo.covid_death_view group by location order by max(total_deaths) desc

--Total yearly deaths

select infected_year, sum(daily_deaths) from CovidProject.dbo.covid_death_view group by infected_year order by infected_year

-- monthly deaths

select infected_year, datepart(month,date) as month, sum(daily_deaths) as total_deaths from CovidProject.dbo.covid_death_view 
group by infected_year, datepart(month,date)  
order by infected_year, datepart(month,date);

--Total Deaths vs population

select location, infected_date, total_deaths, population, (total_deaths/population)*100 as total_cases_perc_per_population
from CovidProject.dbo.covid_death_view 
order by 1,2;

--Highest Death Rate

select location,population, max(total_deaths) as total_deaths, (max(total_deaths)/population)*100 as total_death_perc_per_population
from CovidProject.dbo.covid_death_view 
group by location,population
order by (max(total_deaths)/population)*100 desc;


--Infected Rate & Death Rate by Continent

select continent, sum(population) as total_population, sum(location_cases) as continent_cases, sum(location_deaths) as continent_deaths,
(sum(location_deaths)/sum(population))*100 as perc_death, (sum(location_cases)/sum(population))*100 as perc_infected from
(select continent,location,population,max(total_cases) as location_cases,max(total_deaths) as location_deaths from 
CovidProject.dbo.covid_death_view 
where continent is not null
group by continent,location,population) a group by continent

--OR

select location as continent, population, sum(new_cases) as total_cases, max(total_deaths) as total_deaths,
(max(total_deaths)/population)*100 as perc_death, (sum(new_cases)/population)*100 as perc_infected
from CovidProject.dbo.DeathContinentNull
group by location,population

--Highest death rate per continent

select continent,sum(highest_death_location)
from (select continent,location, max(total_deaths) as highest_death_location
from CovidProject.dbo.covid_death_view 
where continent is not null
group by continent,location) a group by continent

--Total Vaccinations Worldwide

select sum(max_vaccination) as total_doses_given from (select location,max(total_vaccinations_smoothed) as max_vaccination 
from CovidProject.dbo.covid_total_doses_given group by location) a

select max(total_vaccinations) from CovidProject.dbo.VaccinationConNull where location='World';

--Total vaccinations by location

select location,max(total_vaccinations_smoothed) as total_doses from CovidProject.dbo.covid_total_doses_given group by location order by max(total_vaccinations_smoothed) desc

--Total yearly vaccinations

select datepart(year,date) as infected_year, sum(daily_new_vaccinations) as yearly_vaccinations
from CovidProject.dbo.covid_total_doses_given group by datepart(year,date) order by datepart(year,date)

--monthly vaccinations

select datepart(year,date) as infected_year, datepart(month,date) as month, 
sum(daily_new_vaccinations) as monthly_vaccinations 
from CovidProject.dbo.covid_total_doses_given
group by datepart(year,date), datepart(month,date)  
order by datepart(year,date), datepart(month,date);

--Fully Vaccinated People Worldwide

select sum(cast(fully_vaccinated_loc as bigint)) as Fully_vaccinated_people from (select location,max(fully_vaccinated_smooth) as fully_vaccinated_loc
from CovidProject.dbo.covid_full_vaccinated_people group by location) a

--Fully vaccinated by location

select location,max(fully_vaccinated_smooth) as total_doses from CovidProject.dbo.covid_full_vaccinated_people group by location order by max(fully_vaccinated_smooth) desc

--yearly full vaccinations

select datepart(year,date) as infected_year, sum(cast(daily_fully_vaccinated as bigint)) as yearly__full_vaccinations
from CovidProject.dbo.covid_full_vaccinated_people group by datepart(year,date) order by datepart(year,date)

--monthly full vaccinations

select datepart(year,date) as infected_year, datepart(month,date) as month, 
sum(cast(daily_fully_vaccinated as bigint)) as monthly_full_vaccinations 
from CovidProject.dbo.covid_full_vaccinated_people
group by datepart(year,date), datepart(month,date)  
order by datepart(year,date), datepart(month,date);

--Total vaccinations vs population

select de.location, population, max(total_vaccinations_smoothed) as at_least_one_dose,
max(fully_vaccinated_smooth) as fully_vaccinated,
max(total_boosters) as Additional_dose,
max(fully_vaccinated_smooth)/population*100 as perc_fully_vaccinated,
max(total_boosters)/population*100 as perc_additional_dose,
(max(total_vaccinations_smoothed)-max(fully_vaccinated_smooth)-max(total_boosters))/population*100 as perc_atleast_one
from CovidProject.dbo.covid_death_view de INNER JOIN CovidProject.dbo.covid_total_doses_given do
on de.location=do.location and de.date=do.date INNER JOIN
CovidProject.dbo.covid_full_vaccinated_people va
on do.location=va.location and do.date=va.date
group by de.location,population
order by max(fully_vaccinated_smooth)/population desc

--Global Numbers

with loc_data as
(select de.location,population,
max(total_cases) as cases_location,
max(total_deaths) as deaths_location,
max(total_vaccinations_smoothed) as vaccination_loc,
max(fully_vaccinated_smooth) as fully_vaccination_loc,
max(total_boosters) as additional_loc
from CovidProject.dbo.covid_death_view de INNER JOIN CovidProject.dbo.covid_total_doses_given do
on de.location=do.location and de.date=do.date INNER JOIN
CovidProject.dbo.covid_full_vaccinated_people va
on do.location=va.location and do.date=va.date
group by de.location, population)

select sum(cast(population as bigint)) as Global_Population,
sum(cast(cases_location as bigint)) as Global_cases, 
sum(cast(deaths_location as bigint)) as Global_Deaths,
sum(cast(vaccination_loc as bigint)) as Total_Doses_given,
sum(cast(fully_vaccination_loc as bigint)) as Global_Fully_Vaccinated,
sum(cast(additional_loc as bigint)) as Global_additional_dose,
1.0*sum(cast(cases_location as bigint))/sum(cast(population as bigint))*100 as Perc_Global_Cases,
1.0*sum(cast(deaths_location as bigint))/sum(cast(population as bigint))*100 as Perc_Global_Death,
1.0*(sum(cast(vaccination_loc as bigint))-sum(cast(fully_vaccination_loc as bigint))-sum(cast(additional_loc as bigint)))/sum(cast(population as bigint))*100 as Perc_Global_Vaccination,
1.0*sum(cast(fully_vaccination_loc as bigint))/sum(cast(population as bigint))*100 as Perc_Global_Full_Vaccinated,
1.0*sum(cast(additional_loc as bigint))/sum(cast(population as bigint))*100 as Perc_Additional_Dose
from loc_data


--We will finally visualize the data using BI tool