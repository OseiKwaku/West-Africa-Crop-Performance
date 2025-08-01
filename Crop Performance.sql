-- West Africa Crop Performance

-- Key Questions asked

-- Top 5 crops by total production
-- Most productive crops by average yield per hectare
-- Annual production trend per crop
-- Year-over-year growth rate in production
-- Crop-wise area harvested trend
-- Top 5 countries by total production
-- Average yield per hectare by country
-- Which countries consistently rank highest in croop productivity
-- Country vs regional average yield comparison

-- Data Cleaning
-- Remove null or missing value
delete from Crop_data
where Value is null 

-- Add a new float column to store clean values
alter table Crop_data add value_clean float

-- Convert and store numeric values
update Crop_data
set value_clean = CAST(REPLACE(Value, ',','') as float)
WHERE Value is not null and Value not like '%[^0-9.,]%';

-- Standardize crop name
update Crop_data
set Item ='Cassava'
where Item in ('Cassava, fresh', 'cassava', 'Cassava (Fresh)')

-- Pivot elements into columns
create view crop_data_pivoted as
select Area as Country,
	Item as Crop,
	year,
	MAX(case when Element = 'Area harvested' then value_clean end)as Area_harvested,
	MAX(case when Element = 'Yield' then value_clean end)as Yield,
	MAX(case when Element = 'Production' then value_clean end)as Production
from Crop_data
group by Area, Item, Year


SELECT *
FROM Crop_data

-- Top 5 crops by total production
SELECT Crop, round(SUM(production),2) AS total_production
FROM crop_data_pivoted
GROUP BY Crop
ORDER BY total_production desc

-- Most productive crops by average yield per hectare
select Crop, round(avg(yield),2) as avg_yield
from crop_data_pivoted
group by Crop
order by avg_yield

-- Annual production trend per crop
select year, Crop, sum(production) as annual_production
from crop_data_pivoted
group by year, Crop
order by year asc

-- Year-over-year growth rate in production
select crop, year, sum(production) as current_year_production,
lag(sum(production)) over (partition by crop order by year) as previous_year_production
from crop_data_pivoted
group by Crop,Year


-- Crop-wise area harvested trend
select crop, year, sum(area_harvested) as total_area
from crop_data_pivoted
group by Crop, year
order by year asc;

-- Top 5 countries by total production
select country, crop, sum(production) as total_production
from crop_data_pivoted
group by Country, Crop
order by Crop, total_production desc

-- Average yield per hectare by country
select country,round(avg(yield),2) as avg_yield
from crop_data_pivoted
group by Country
order by avg_yield desc

-- Which countries consistently rank highest in crop productivity
select country,round(avg(yield),2) as avg_yield
from crop_data_pivoted
where Crop = 'Cassava'
group by Country
order by avg_yield desc

-- Country vs regional average yield comparison
-- Country Average
select country, round(avg(yield),2) as country_avg_yield
from crop_data_pivoted
where Crop = 'Millet'
group by Country

--Regional Average
select round(avg(yield),2) as regional_avg_yield
from crop_data_pivoted
where Crop= 'Cassava'

select *
from crop_data_pivoted