-- Cleaning Data In SQL
---------------------------

select * from CovidProject.dbo.covid_deaths;
select * from CovidProject.dbo.covid_vaccination;

-- Standardize Date format(Adding date and year column)

select infected_date, infected_year,CONVERT(date,date) from CovidProject.dbo.covid_deaths;

alter table CovidProject.dbo.covid_deaths add infected_date date;
alter table CovidProject.dbo.covid_deaths add infected_year int;

update CovidProject.dbo.covid_deaths set infected_date=CONVERT(date,date);
update CovidProject.dbo.covid_deaths set infected_year=DATEPART(year,date);

--Checking data type for all columns

--- There are some columns which should be of int data type instead of varchar 

-- Checking first for covid_deaths

alter table CovidProject.dbo.covid_deaths alter column total_deaths int;
alter table CovidProject.dbo.covid_deaths alter column new_deaths int;  
alter table CovidProject.dbo.covid_deaths alter column new_deaths_smoothed float;
alter table CovidProject.dbo.covid_deaths alter column total_deaths_per_million float;
alter table CovidProject.dbo.covid_deaths alter column new_deaths_per_million float;
alter table CovidProject.dbo.covid_deaths alter column new_deaths_smoothed_per_million float;
alter table CovidProject.dbo.covid_deaths alter column reproduction_rate float;
alter table CovidProject.dbo.covid_deaths alter column icu_patients int;
alter table CovidProject.dbo.covid_deaths alter column icu_patients_per_million float;
alter table CovidProject.dbo.covid_deaths alter column hosp_patients int;
alter table CovidProject.dbo.covid_deaths alter column hosp_patients_per_million float;
alter table CovidProject.dbo.covid_deaths alter column weekly_icu_admissions int;
alter table CovidProject.dbo.covid_deaths alter column weekly_icu_admissions_per_million float;
alter table CovidProject.dbo.covid_deaths alter column weekly_hosp_admissions int;
alter table CovidProject.dbo.covid_deaths alter column weekly_hosp_admissions_per_million float;
       
--Now checking for covid_vaccination

alter table CovidProject.dbo.covid_vaccination alter column total_tests bigint ;
alter table CovidProject.dbo.covid_vaccination alter column new_tests int ;
alter table CovidProject.dbo.covid_vaccination alter column total_tests_per_thousand float;
alter table CovidProject.dbo.covid_vaccination alter column new_tests_per_thousand float ;
alter table CovidProject.dbo.covid_vaccination alter column new_tests_smoothed int ;
alter table CovidProject.dbo.covid_vaccination alter column new_tests_smoothed_per_thousand float ;
alter table CovidProject.dbo.covid_vaccination alter column positive_rate float;
alter table CovidProject.dbo.covid_vaccination alter column tests_per_case float;
alter table CovidProject.dbo.covid_vaccination alter column total_vaccinations bigint ;
alter table CovidProject.dbo.covid_vaccination alter column people_vaccinated int;
alter table CovidProject.dbo.covid_vaccination alter column people_fully_vaccinated int;
alter table CovidProject.dbo.covid_vaccination alter column total_boosters int;
alter table CovidProject.dbo.covid_vaccination alter column new_vaccinations int ;
alter table CovidProject.dbo.covid_vaccination alter column new_vaccinations_smoothed int ;
alter table CovidProject.dbo.covid_vaccination alter column total_vaccinations_per_hundred float;
alter table CovidProject.dbo.covid_vaccination alter column people_vaccinated_per_hundred float ;
alter table CovidProject.dbo.covid_vaccination alter column people_fully_vaccinated_per_hundred float ;
alter table CovidProject.dbo.covid_vaccination alter column total_boosters_per_hundred float;
alter table CovidProject.dbo.covid_vaccination alter column new_vaccinations_smoothed_per_million float;
alter table CovidProject.dbo.covid_vaccination alter column new_people_vaccinated_smoothed int;
alter table CovidProject.dbo.covid_vaccination alter column new_people_vaccinated_smoothed_per_hundred float;
alter table CovidProject.dbo.covid_vaccination alter column extreme_poverty float ;
alter table CovidProject.dbo.covid_vaccination alter column female_smokers float;
alter table CovidProject.dbo.covid_vaccination alter column male_smokers float ;
alter table CovidProject.dbo.covid_vaccination alter column excess_mortality_cumulative_absolute float ;
alter table CovidProject.dbo.covid_vaccination alter column excess_mortality_cumulative float;
alter table CovidProject.dbo.covid_vaccination alter column excess_mortality float ;
alter table CovidProject.dbo.covid_vaccination alter column excess_mortality_cumulative_per_million float;
            

-- Checking for continents and location column

select distinct continent from CovidProject.dbo.covid_deaths; --(Continent has null values)

--- Let's check for some values to understand the relationship

select sum(cases_location) from (select location,max(total_cases) as cases_location from CovidProject.dbo.covid_deaths where continent='Asia' group by location) a; --182323509

select max(total_cases) from CovidProject.dbo.covid_deaths where location='Asia'; --182323509

select max(total_deaths) from CovidProject.dbo.covid_deaths where location='Asia'; --1478469

select sum(death_location) from (select location,max(total_deaths) as death_location from CovidProject.dbo.covid_deaths where continent='Asia' group by location) a;

--1478469

---So we could say that the column in which continent is null, contains aggregated data for overall continent. We could make a separate table for the same and delete that data from here.

select * into CovidProject.dbo.DeathContinentNUll from CovidProject.dbo.covid_deaths where continent is null;

delete from CovidProject.dbo.covid_deaths where continent is null;

select * from CovidProject.dbo.covid_deaths;

--- We will make another table for vaccinations where continent is null

select * into CovidProject.dbo.VaccinationConNull from CovidProject.dbo.covid_vaccination where continent is null;

delete from CovidProject.dbo.covid_vaccination where continent is null;


-- Checking for accuracy of data

--Checking for first table

select * from CovidProject.dbo.covid_deaths where location='Albania' order by infected_date ;

select * from CovidProject.dbo.covid_deaths where total_cases is null ;

select location,max(total_cases), sum(new_cases),sum(new_cases)-max(total_cases) from CovidProject.dbo.covid_deaths group by location;

select location,max(total_deaths),sum(new_deaths) ,max(total_deaths)-sum(new_deaths) from CovidProject.dbo.covid_deaths group by location

--Using this we found that there were some missing values(NULL) in new_cases which causes difference in both columns. 
--After further investigation we found that all the null values in new_cases col were 0. So we would replace the same and use the new_cases column for daily cases
--For showing total_cases we will use total_cases column

select location,infected_date,total_cases,new_cases,
sum(new_cases) over(order by infected_date) as new_cases_running_sum,
sum(new_cases) over(order by infected_date)-total_cases as cases_diff_per_day
from CovidProject.dbo.covid_deaths 
where location='Kyrgyzstan' order by infected_date;

select location,infected_date,total_cases,
ISNULL(new_cases,0) from CovidProject.dbo.covid_deaths;

--In case of deaths the new_deaths column contains some missing data. We can substitute that data using the difference bewteen previous day to find new deaths.
--total_deaths column some data which has a declining value from previous day. As the difference cannot be negative, we would substitute those days values as 0.

select location,infected_date,total_deaths,new_deaths,
sum(new_deaths) over(order by infected_date) as new_deaths_running_sum,
sum(new_deaths) over(order by infected_date)-total_deaths as death_diff_per_day
from CovidProject.dbo.covid_deaths 
where location='India' order by infected_date;

with cte as (select *,
CASE WHEN (total_deaths-prev)<0 then 0 else total_deaths-prev end as daily_deaths
from 
(select location,infected_date,total_deaths,lag(total_deaths,1) over(partition by location order by date) as prev,new_deaths
from CovidProject.dbo.covid_deaths) a)

--Using below query, we verify that the difference between total_deaths and daily_deaths has now been reduced.

select location,max(total_deaths),sum(new_deaths) ,sum(daily_deaths),max(total_deaths)-sum(new_deaths),max(total_deaths)-sum(daily_deaths) from 
cte group by location

-- Lets take the useful columns into a view

USE CovidProject;
GO
CREATE VIEW dbo.covid_death_view as 
select d.iso_code,d.continent,d.location,d.date,d.infected_date,d.infected_year,d.population,
d.total_cases,ISNULL(d.new_cases,0) as daily_cases,
de.total_deaths,de.daily_deaths
from CovidProject.dbo.covid_deaths d
JOIN
(select *,
CASE WHEN (total_deaths-prev)<0 then 0 else total_deaths-prev end as daily_deaths
from 
(select location,infected_date,total_deaths,lag(total_deaths,1) over(partition by location order by date) as prev,new_deaths
from CovidProject.dbo.covid_deaths) a) de
ON d.location=de.location and d.infected_date=de.infected_date;

select * from CovidProject.dbo.covid_death_view;

---Lets do some cleaning for another table

select location,
max(total_tests) as max_total_tests,
sum(new_tests) as sum_new_tests,
max(total_tests)-sum(new_tests) as tests_diff 
from CovidProject.dbo.covid_vaccination group by location

select total_tests,new_tests from CovidProject.dbo.covid_vaccination where location='Albania' order by date ;

select location,date,total_tests,new_tests,
sum(new_tests) over(order by date) as new_tests_running_sum,
total_tests-sum(new_tests) over(order by date) as tests_diff_per_day
from CovidProject.dbo.covid_vaccination
where location='India' order by date;

--We can see that there is a positive difference in the total_tests and new_tests column and some of the cells have null values in them. 
--This might be beacuse the data could not be collected on that day, as there is a positive difference and as we compared some locations with actual data
--Lets check for some more columns

select location,
max(total_tests) as max_total_tests
,sum(cast(new_tests_smoothed as bigint)) as sum_new_tests_smoothed,
max(total_tests)-sum(cast(new_tests_smoothed as bigint)) as diff_tests_smoothed
from CovidProject.dbo.covid_vaccination
group  by location


select location,date,new_tests,new_tests_smoothed ,
sum(new_tests) over(order by date) as new_tests_running_sum,
sum(new_tests_smoothed) over(order by date) as smoothed_tests_running_sum
from CovidProject.dbo.covid_vaccination
where location='India' order by date;

-- As we checked further the new_tests_smoothed makes more sense as it is more continuous and there are no discontinuity in the data, so we will use new_tests_smoothed for our analysis.

-- This shows that there are different tests_units recorded in data as per location. But if we take a close look there is only one unit per location and 0 if the data is not available for tests
-- This would help in our analysis

select distinct tests_units from CovidProject.dbo.covid_vaccination

select location,count(distinct tests_units) from CovidProject.dbo.covid_vaccination group by location;

select * from CovidProject.dbo.covid_vaccination where location='Cook Islands' order by date ;

-- Lets check for vaccinations columns

--total_vaccinations ,new_vaccinations, new_vaccinations_smoothed
--As we checked from original data from google, the total_vaccinations column is more accurate instead of new_vaccinations and new_vaccinations_smoothed. So we will use that for analysis.

select location,max(total_vaccinations) as total_vaccinations,
sum(cast(new_vaccinations as bigint)) as sum_total_vaccinations,
sum(cast(new_vaccinations_smoothed as bigint)) as total_vacations_smoothed,
max(total_vaccinations)-sum(cast(new_vaccinations_smoothed as bigint))
from CovidProject.dbo.covid_vaccination group by location;

select date,total_vaccinations,new_vaccinations
from CovidProject.dbo.covid_vaccination 
where location='India' order by date;

select date,total_vaccinations,new_vaccinations,
sum(new_vaccinations) over(order by date) as running_sum_new_vaccinations,
total_vaccinations-sum(new_vaccinations) over(order by date) as total_vaccination_diff
from CovidProject.dbo.covid_vaccination 
where location='Afghanistan' order by date;

--The column total_vaccinations contains some null values i.e. missing data for that date. For analysis purpose we will fill those values with previous day values considering no data is available for that date.
--We will use total_vaccinations_smoothed column and daily_new_vaccinations columns  in our analysis. We will also create a view for the same.

USE CovidProject;
GO
CREATE VIEW dbo.covid_total_doses_given as 
with grp as (select date,location,
total_vaccinations,count(total_vaccinations) over(partition by location order by date) as grp
from CovidProject.dbo.covid_vaccination)

,vaccination_smooth as (select date,location,total_vaccinations,total_vaccinations_smoothed,
lag(total_vaccinations_smoothed,1,total_vaccinations_smoothed) over(partition by location order by date) as prev 
from
(select *,
first_value(case when grp=0 then 0 else total_vaccinations end) over(partition by location,grp order by date) as total_vaccinations_smoothed
from grp) a)

select date,location,total_vaccinations,total_vaccinations_smoothed,total_vaccinations_smoothed-prev as daily_new_vaccinations from vaccination_smooth;

--Using above query we found the total vaccinations and daily new vaccinations for a particular date. We can verify the same using the below query.

select location,max(total_vaccinations),max(total_vaccinations_smoothed),sum(daily_new_vaccinations) from covid_total_doses_given group by location

--Fully vaccinated column also contains null values so doing the same thing for this column too

select date,location,people_fully_vaccinated from CovidProject.dbo.covid_vaccination where location='India' order by date

USE CovidProject;
GO
CREATE view dbo.covid_full_vaccinated_people as
with grp as (select date,location,people_fully_vaccinated,total_boosters,
count(people_fully_vaccinated) over(partition by location order by date) as grp 
from CovidProject.dbo.covid_vaccination)

,smooth as
(select *, lag(fully_vaccinated_smooth,1,fully_vaccinated_smooth) over(partition by location order by date) as prev from
(select *, 
first_value(case when grp=0 then 0 else people_fully_vaccinated end) over(partition by location,grp order by date) as fully_vaccinated_smooth
from grp) a)

select date,location,people_fully_vaccinated,fully_vaccinated_smooth,
fully_vaccinated_smooth-prev as daily_fully_vaccinated,total_boosters
from smooth

--Verifying all the columns

select location,max(people_fully_vaccinated),max(fully_vaccinated_smooth),sum(daily_fully_vaccinated) from covid_full_vaccinated_people group by location



select * from CovidProject.dbo.covid_vaccination where location='India' order by date