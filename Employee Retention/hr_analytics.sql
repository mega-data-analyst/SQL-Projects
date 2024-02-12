use employee_retention;

SELECT * FROM employee_retention.hr_emp;

alter table hr_emp
rename column ï»¿Emp_ID to Emp_ID;

select count(*) as Total_Emp
from employee_retention.hr_emp;

#KPI

select count(*) as Total_Emp,
sum(case when Attrition='Yes' then 1 else 0 end) as Attrition_Count,
count(*)-sum(case when Attrition='Yes' then 1 else 0 end) as Active_emp,
concat(round((sum(case when Attrition='Yes' then 1 else 0 end)/count(*))*100,2),"%") as Attrition_rate,
round(avg(age)) as Avg_age 
from employee_retention.hr_emp ;

#KPI-1 Average Attrition rate for all Departments

select distinct department,
count(emp_id) as ttl_emp,
sum(case when Attrition='Yes' then 1 else 0 end) as Attrition_count,
concat(round((sum(case when Attrition='Yes' then 1 else 0 end)/count(*))*100,2),"%") as Attrition_rate
from employee_retention.hr_emp
group by department
order by department;

#KPI2- Average Hourly rate of Male Research Scientist

select 
distinct JobRole,
gender,
round(avg(hourlyrate),2) as avg_rate
from employee_retention.hr_emp
where JobRole="Research Scientist" and Gender="Male";

#KPI3- Attrition rate and Monthly income stats

select
distinct department,
round(avg(Monthlyincome),2) as Avg_income,
count(emp_id) as ttl_emp,
sum(case when Attrition="Yes" then 1 else 0 end) as Attrition_Count,
concat(round((sum(case when Attrition='Yes' then 1 else 0 end)/
(select count(*) from employee_retention.hr_emp))*100,2),"%") as Attrition_rate
from employee_retention.hr_emp
group by department
order by department;

#KPI4- Average working years for each Department

select
distinct department,
round(avg(Totalworkingyears),2) as Working_Years,
concat(floor(avg(Totalworkingyears))," Years ",
round((avg(Totalworkingyears)-floor(avg(Totalworkingyears)))*12)," months") as Months
from employee_retention.hr_emp
group by department
order by department;

#KPI5- Job Role and Work life balance

select 
distinct JobRole,
round(avg(WorkLifeBalance),2) as avg_worklife_balance
from employee_retention.hr_emp
group by JobRole
order by JobRole;

#KPI6- Attrition rate and Year since last promotion relation

with frequency as
(select emp_id,
Attrition,
case when YearsSinceLastPromotion <= 5 then "1    <=5 years"
when YearsSinceLastPromotion between 6 and 10 then "2    6-10 years"
when YearsSinceLastPromotion between 11 and 15 then "3    11-15 years"
when YearsSinceLastPromotion between 16 and 20 then "4    16-20 years"
when YearsSinceLastPromotion between 21 and 25 then "5    21-25 years"
when YearsSinceLastPromotion between 26 and 30 then "6    26-30 years"
when YearsSinceLastPromotion between 31 and 35 then "7    31-35 years"
else "8    36-40 years" 
end as years
from employee_retention.hr_emp)
select 
years,
count(emp_id) as ttl_emp,
sum(case when attrition="Yes" then 1 else 0 end) as attrition_count,
concat(round((sum(case when Attrition='Yes' then 1 else 0 end)/count(*))*100,2),"%") as Attrition_rate
from frequency
group by years
order by years;











