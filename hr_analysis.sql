## DATA CLEANING
SELECT * FROM hr_analytics.`human resources`;

#rename column
alter table hr_analytics.`human resources`
change column ï»¿id emp_id varchar(20) null ;

describe hr_analytics.`human resources` ;

SET sql_safe_updates=0;

select birthdate from hr_analytics.`human resources`;
#birthdates are not in the same format. ie.'06-04-91','6/29/1984'--change date format
Update hr_analytics.`human resources`
set birthdate = CASE
	WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y/%m/%d')
    WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate,'%m-%d-%Y'),'%Y/%m/%d')
    ELSE null
    END;
    
    #But still the data type of birthdate is text ---chnange it to date
    alter table hr_analytics.`human resources`
    modify column birthdate date;
    
    Update hr_analytics.`human resources`
	set hire_date = CASE
		WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y/%m/%d')
		WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date,'%m-%d-%Y'),'%Y/%m/%d')
    ELSE null
    END;
    alter table hr_analytics.`human resources`
    modify column hire_date date;
    
    select termdate from hr_analytics.`human resources`;
    #there are null values and date also includes time---fill the null values & change datetime to date format
    
    update hr_analytics.`human resources`
    SET termdate = date(str_to_date(termdate,'%Y-%m-%d %H:%i:%s UTC'))
    WHERE termdate is not null and termdate!=' ';
    Alter table hr_analytics.`human resources`
    modify column termdate date;
    
    Alter table hr_analytics.`human resources` add column Age int; 
    Update hr_analytics.`human resources`
    Set Age=timestampdiff(year,birthdate,curdate());
    
    Select min(Age),max(Age) from hr_analytics.`human resources`;
    #min age is -46 which is incorrect
    select count(*) from hr_analytics.`human resources` where Age<18;
    delete from hr_analytics.`human resources`
    where age<18;
    
    ## DATA ANALYSIS
-- 1.WHAT IS THE GENDER BREAKDOWN OF EMPLOYEES IN COMPANY?
Select gender,count(*) as count from hr_analytics.`human resources`
WHere termdate='0000-00-00'
group by gender
;
# Male= 8911 #Female=8090 #Non-Conforming-481

-- 2.WHAT IS THE RACE/ETHINICITY BREAKDOWN OF EMPLOYEES IN COMPANY?
Select race,count(*) as count from hr_analytics.`human resources` 
WHere termdate='0000-00-00'
group by race;

-- 3.WHAT IS THE AGE DISTRIBUTION OF EMPLOYEES IN THE COMPANY
Select min(Age),max(Age) from hr_analytics.`human resources`
where termdate='0000-00-00';
#min age= 20 & max_age=57

select case
	when Age >=18 AND Age <=24 THEN '18-24'
    when Age >=25 AND Age <=34 THEN '25-34'
    when Age >=35 AND Age <=44 THEN '35-44'
    when Age >=45 AND Age <=54 THEN '45-54'
    when Age >=55 AND Age <=64 THEN '55-64'
	ELSE '65+'
END as age_group,
count(*) as count
from hr_analytics.`human resources`
where termdate='0000-00-00'
group by age_group
order by age_group;

select case
	when Age >=18 AND Age <=24 THEN '18-24'
    when Age >=25 AND Age <=34 THEN '25-34'
    when Age >=35 AND Age <=44 THEN '35-44'
    when Age >=45 AND Age <=54 THEN '45-54'
    when Age >=55 AND Age <=64 THEN '55-64'
	ELSE '65+'
END as age_group,
count(*) as count,gender
from hr_analytics.`human resources`
where termdate='0000-00-00'
group by age_group,gender
order by age_group,gender;

-- 4. HOW MANY EMPLOYESS WORKS AT HEADQUARTERS VS REMOTE LOCATION
Select distinct location  from hr_analytics.`human resources`;
Select location,count(*) as count from hr_analytics.`human resources`
where termdate='0000-00-00'
group by location;

-- 5.WHAT IS THE AVERAGE LENGTH OF EMPLOYEEMENT WHO HAVE BEEN TERMINATED
Select round(avg(datediff(termdate,hire_date))/365,0)  as avg_employment 
from hr_analytics.`human resources`
where termdate !='0000-00-00' and termdate <=curdate();

-- 6.How does the gender distribution vary accross departments and job titles?
Select department,gender,count(*)gender from hr_analytics.`human resources`
where termdate ='0000-00-00'
group by gender,department
order by department;

-- 7.What is the distribution of job titles accross the company?
select jobtitle,count(*) as countt from hr_analytics.`human resources`
where termdate ='0000-00-00'
group by jobtitle
order by  jobtitle desc;

-- 8.Which department has highest termination rate?
select department,total_count,terminated_count,terminated_count/total_count as termination_rate
	from (
			select department,count(*) as total_count,
			sum(CASE WHEN termdate != '0000-00-00' and termdate <=curdate() THEN 1 ELSE 0 END) AS terminated_count 
	FROM hr_analytics.`human resources`
    group by department) 
    AS SUBQUERY
    Order by termination_rate desc;
    
-- 9.What is distribution of employees across locations by city and state
select location_state,count(*) as count from hr_analytics.`human resources`
where termdate='0000-00-00'
group by location_state
order by count desc;

-- 10. How has companys employee count changed over time based on hire and term date
select year,hires,termination,hires-termination as net_change,
round((hires-termination)/hires *100,2) as net_change_percent
from
	(select Year(hire_date)as year,COUNT(*) AS hires,
    sum(CASE WHEN termdate !='0000-00-00' AND termdate <= CURDATE() THEN 1 ELSE 0 END)AS termination
    from hr_analytics.`human resources`
    group by year(hire_date)
    )
    AS SUBQUERY
    Order by year asc;
    
    
-- 11.What is the tenure distribution of each department
select department, round(avg(datediff(termdate,hire_date)/365),0) as avg_tenure
from hr_analytics.`human resources`
where termdate !='0000-00-00' and termdate <=curdate()
group by department
    
    



