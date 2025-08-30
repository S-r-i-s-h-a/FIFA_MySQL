use assignment1;

CREATE TABLE EMP_DETAIL(
emp_id int primary KEY,
first_name VARCHAR(20),
last_name VARCHAR(20),
salary int,
joining_date datetime,
department varchar(20),
gender varchar(20),
job_title varchar(20));

-- 2. Insert sample data into the table.

INSERT INTO EMP_DETAIL (emp_id, first_name, last_name, salary, joining_date, department, gender, job_title)
VALUES (1, 'Alice', 'Smith', 50000, '2020-01-15', 'Admin', 'Female', 'Administrator');

-- 3. Write a query to create a clone of an existing table using Create Command.

create table employees as select * from emp_detail;

-- . Write a query to get all employee detail from "employee" table
select * from employees;


select * from employees limit 1;

#5. Select only top 1 record from employee table
#6. Select only bottom 1 record from employee table
select * from employees order by joining_date desc limit 1;

select * from employees order by emp_id desc limit 1;

# . How to select a random record from a table?
select * from employees 
order by rand()
limit 1;


#. Write a query to get
#“first_name” in upper case as "first_name_upper"
#‘first_name’ in lower case as ‘first_name_lower”
#Create a new column “full_name” by combining “first_name” &
#“last_name” with space as a separator.
# Add 'Hello ' to first_name and display result.

select upper(first_name) as first_name_upper from employees;

select lower(last_name) as last_name_lower from employees;

select concat_ws(" ",first_name,last_name) as full_name from employees;
select concat("Hello ",first_name) as full_name from employees;

#Whose “first_name” is ‘Malli’
#Whose “first_name” present in ("Malli","Meena", "Anjali")
#Whose “first_name” not present in ("Malli","Meena", "Anjali")
#Whose “first_name” starts with “v”
#Whose “first_name” ends with “i”
#Whose “first_name” contains “o”
#Whose "first_name" start with any single character between 'm-v'
#Whose "first_name" not start with any single character between 'm-v'
#Whose "first_name" start with 'M' and contain 5 letters
select * from employees where first_name like "Malli";
select * from employees where first_name in  ("Malli","Meena", "Anjali");
select * from employees where first_name not in  ("Malli","Meena", "Anjali");
select * from employees where first_name like "v%";
select * from employees where first_name like "%i";
select * from employees where first_name like "%o%";
SELECT *
FROM employees
WHERE (first_name) REGEXP '^[m-vM-V]';

SELECT *
FROM employees
WHERE (first_name) not REGEXP '^[m-vM-V]';

SELECT *
FROM employees
WHERE (first_name) REGEXP 'M.{4}$';

# 10. Write a query to get all unique values of"department" from the employee table.
select distinct department from employees; 

#11. Query to check the total records present in a table.
select count(*) from employees;
# 12. Write down the query to print first letter of a Name in Upper Case and all other letter in Lower Case.(EmployDetail table)
select concat(upper(substring(TRIM(first_name),1,1)),lower(substring(TRIM(first_name),2))," ",lower(last_name)) as full_name from employees;

#Write down the query to display all employee name in one cell separated by ','
select group_concat(first_name separator ',') from employees;

#14. Query to get the below values of "salary" from employee table
#Lowest salary
#Highest salary
#Average salary
#Highest salary - Lowest salary as diff_salary
#% of difference between Highest salary and lowest salary. (sample output
#format: 10.5%)

select * from employees order by salary desc limit 1;
select * from employees order by salary limit 1;
select avg(salary) from employees;
select (max(salary) - min(salary)) as diff_salary from employees;
select Concat(ROUND((((max(salary) - min(salary))/(max(salary)))*100),2),"%") as diff_salary from employees;
#15. Select “first_name” from the employee table after removing white spaces from
#Right side spaces
#Left side spaces
#Both right & left side spaces
select ltrim(first_name) from employees;
select rtrim(first_name) from employees;
select trim(first_name) from employees;

#16. Query to check no.of records present in a table where employees having 50k salary.
select count(distinct emp_id) from employees where salary = 50000;

#17. Find the most recently hired employee in each department.
select * from employees as e where joining_date=(select max(joining_date) from employees where e.department = department);

#1 Display first_name and gender as M/F.(if male then M, if Female then F)
select first_name, gender, case
when gender like "Male" then "M"
else "F"
end as M_or_F from employees;

-- Display first_name, salary, and a salary category. (If salary is below 50,000, categorize
-- as 'Low'; between 50,000 and 60,000 as 'Medium'; above 60,000 as 'High')
select first_name, salary, case
when salary < 50000  then "Low"
when salary between 50000 and 60000 then "Medium"
else "High"
end as salary_category from employees;

-- Display first_name, department, and a department classification. (If department is
-- 'IT', display 'Technical'; if 'HR', display 'Human Resources'; if 'Finance', display
-- 'Accounting'; otherwise, display 'Other')
select first_name, department, case
when department like "IT"  then "Technical"
when department like "HR" then "Human resources"
when department like "Finance" then "Accounting"
else "Other"
end as departemnt_classification from employees;

-- Display first_name, salary, and eligibility for a salary raise. (If salary is less than
-- 50,000, mark as 'Eligible for Raise'; otherwise, 'Not Eligible')
select first_name, salary, case
when salary < 50000  then "Eligible for raise"
else "Not eligible"
end as eligibility_for_raise from employees;

-- Display first_name, joining_date, and employment status. (If joining date is before
-- '2022-01-01', mark as 'Experienced'; otherwise, 'New Hire')
select first_name,joining_date,case
when joining_date < '2022-01-01' then "Experienced"
else "New hire"
end as employment_status 
from employees;

-- Display first_name, salary, and bonus amount. (If salary is above 60,000, add10%
-- bonus; if between 50,000 and 60,000, add 7%; otherwise, 5%)
select first_name, salary, case
when salary > 60000 then salary+(salary*0.1)
when salary between 50000 and 60000 then salary+(salary*0.07)
else salary+(salary*.05)
end as salary_with_bonus 
from employees;

-- .Display first_name, salary, and seniority level.
-- (If salary is greater than 60,000, classify as 'Senior'; between 50,000 and 60,000 as
-- 'Mid-Level'; below 50,000 as 'Junior')

select first_name, salary, case
when salary > 60000 then "senior"
when salary between 50000 and 60000 then "mid-level"
else "senior"
end as seniority_level 
from employees;


--  Display first_name, department, and job level for IT employees. (If department is 'IT'
-- and salary is greater than 55,000, mark as 'Senior IT Employee'; otherwise, 'Other').
select trim(first_name),department, case 
when department like "IT" and salary >55000 then "Senior IT"
else "other"
end as job_level_forIT_employees
from employees;

-- Display first_name, joining_date, and recent joiner status. (If an employee joined
-- after '2024-01-01', label as 'Recent Joiner'; otherwise, 'Long-Term Employee')
select first_name , joining_date, case
when joining_date > '2024-01-01' then "recent joiner"
else "Long term emloyee"
end as  recent_joiner_status from 
employees;

-- Display first_name, joining_date, and leave entitlement. (If joined before '2021-01-
-- 01', assign '10 Days Leave'; between '2021-01-01' and '2023-01-01', assign '20 Days
-- Leave'; otherwise, '25 Days Leave')

select first_name , joining_date, case
when joining_date < '2021-01-01' then "10 days leave"
when joining_date between '2021-01-01' and '2023-01-01' then "20 days leave"
else "25 days leave"
end as  leave_entitlement from 
employees;

-- Display first_name, salary, department, and promotion eligibility. (If salary is above
-- 60,000 and department is 'IT', mark as 'Promotion Eligible'; otherwise, 'Not Eligible')

select first_name, salary, department, case
when salary >60000 and department like "IT" then "promotion eligible"
else "Not eligible"
end as promotion_eligibility
from employees;

--  Display first_name, salary, and overtime pay eligibility. (If salary is below 50,000,
-- mark as 'Eligible for Overtime Pay'; otherwise, 'Not Eligible'

select first_name, salary, case 
when salary < 50000 then "eligible for overtime pay"
else "not eligible"
end as overtime_pay_eligibility
from employees;

-- Display first_name, department, salary, and job title. (If department is 'HR' and salary
-- is above 60,000, mark as 'HR Executive'; if department is 'Finance' and salary is above
-- 55,000, mark as 'Finance Manager'; otherwise, 'Regular Employee')

select first_name , department , salary, case 
when department like"HR" and salary > 60000 then "HR executive"
when department like "Finance" and salary > 55000 then "Finance Manager"
else "regular employee"
end as job_title
from employees;

-- Display first_name, salary, and salary comparison to the company average. (If salary is
-- above the company’s average salary, mark as 'Above Average'; otherwise, 'Below
-- Average'

select first_name , salary, case 
when salary > (select avg(salary) from employees) then "above average"
else "below average"
end as company_avg
from employees;

# group by
-- Write the query to get the department and department wise total(sum) salary,
-- display it in ascending and descending order according to salary.

select department, sum(salary) from employees
group by department;

alter table employees
add primary key (emp_id);

CREATE TABLE projects (
    project_id INT PRIMARY KEY,
    emp_id_no INT,
    project_name VARCHAR(255),
    start_date DATE,
    end_date DATE,
    status VARCHAR(50),
    CONSTRAINT fk_emp FOREIGN KEY (emp_id_no) REFERENCES employees(emp_id)
    on delete cascade
    on update cascade
);

-- write down the query to fetch Project name assign to more than one Employee
SELECT project_name ,count(*) as cnt from projects 
group by project_name having count(*) >1;

-- Write the query to get the department, total no. of departments, total(sum) salary
-- with respect to department from "employee table" table.
select department, count(distinct emp_id) as emp_cnt, sum(salary) as sum_salary from employees 
group by department;

-- 4.Get the department-wise salary details from the "employee table" table:
-- What is the average salary? (Order by salary ascending)
-- What is the maximum salary? (Order by salary ascending)

select department, sum(salary) as tot_sal,avg(salary) avg_sal, max(salary) from employees
group by department order by avg(salary), max(salary);

-- Display department-wise employee count and categorize based on size. (If a department
-- has more than 5 employees, label it as 'Large'; between 3 and 5 as 'Medium'; otherwise,
-- 'Small'

select department, count(distinct emp_id) as emp_cnt, case
when count(distinct emp_id) > 5 then "large"
when count(distinct emp_id) between 3 and 5 then "medium"
else "small"
end as size
from employees
group by department;

-- Display department-wise average salary and classify pay levels. (If the average salary in a
-- department is above 60,000, label it as 'High Pay'; between 50,000 and 60,000
-- as 'Medium Pay'; otherwise, 'Low Pay').

select department , avg(salary) as avg_salary , case
when avg(salary) >60000 then "High Pay"
when avg(salary) between 50000 and 60000 then "medium pay"
else "low pay"
end as pay_level
from employees
group by department;

-- 7. Display department, gender, and count of employees in each category. (Group by
-- department and gender, showing total employees in each combination)

SELECT department,gender,COUNT(*) AS total_employees
FROM employees
GROUP BY department, gender
ORDER BY department, gender;

-- Display the number of employees who joined each year and categorize hiring trends. (If a
-- year had more than 5 hires, mark as 'High Hiring'; 3 to 5 as 'Moderate Hiring'; otherwise,
-- 'Low Hiring'

select year(joining_date) as joining_year , count(distinct emp_id) as emp_cnt , case
when count(distinct emp_id) > 5 then "High Hiring"
when count(distinct emp_id) between 3 and 5 then "moderate hiring"
else "low hiring"
end as hiring_trends
from employees
group by year(joining_date);

-- Display department-wise highest salary and classify senior roles. (If the highest salary in a
-- department is above 70,000, label as 'Senior Leadership'; otherwise, 'Mid-Level')

select department , max(salary) as higgest_salary,
case
when max(salary) >= 70000 then "senior leadership"
else "Mid level"
end as classify_senior_roles
from employees group by department;

-- Display department-wise count of employees earning more than 60,000. (Group
-- employees by department and count those earning above 60,000, labeling departments
-- with more than 2 such employees as 'High-Paying Team')

select department, count(*) as High_paid_count , case 
when count(*) >2 then "High paying team"
else "Low paying team"
end as pay_scale
from employees
where salary >60000
group by department;


-- Query to extract the below things from joining_date column. (Year, Month, Day, Current
-- Date)
select year(joining_date) as join_year, month(joining_date) as join_month,day(joining_date) as join_day, current_date() as today_date from employees;

-- Create two new columns that calculate the difference between joining_date and the
-- current date. One column should show the difference in months, and the other should
-- show the difference in days

select (TIMESTAMPDIFF(month,joining_date,current_date())) as month_diff, TIMESTAMPDIFF(day,joining_date,current_date())  as day from employees;

-- .Get all employee details from the employee table whose joining year is 2020.
select * from employees where year(joining_date) = "2020";

-- Get all employee details from the employee table whose joining month is Feb
select * from employees where date_format(joining_date,'%b') ="Feb";


-- Get all employee details from employee table whose joining date between "2021-01-01"
-- and "2021-12-01"
select * from employees where joining_date between "2021-01-01"
and "2021-12-01";


-- Get the employee name and project name from the "employee table" and
-- "ProjectDetail" for employees who have been assigned a project, sorted by first name.

select employees.first_name,projects.project_name from employees  join projects on employees.emp_id = projects.emp_id_no;


-- Get the employee name and project name from the "employee table" and
-- "ProjectDetail" for all employees, including those who have not been assigned a project,
-- sorted by first name.

select trim(employees.first_name) as emp_name, projects.project_name as proj_name from employees left join projects on employees.emp_id = projects.emp_id_no 
order by trim(emp_name);

-- Get the employee name and project name from the "employee table" and
-- "ProjectDetail" for all employees. If an employee has no assigned project, display "-No
-- Project Assigned," sorted by first name.
select trim(employees.first_name) as emp_name, IFnull(projects.project_name,"No project") as proj_name from employees left join projects on employees.emp_id = projects.emp_id_no 
order by trim(emp_name);

-- Get all project names from the "ProjectDetail" table, even if they are not linked to any
-- employee, sorted by first name from the "employee table" and "ProjectDetail" table.
select  projects.project_name as proj_name, trim(employees.first_name) as emp_name from projects left join employees on  projects.emp_id_no = employees.emp_id
where isnull(trim(employees.first_name))
order by trim(emp_name), proj_name;

-- Get the employee name and project name for employees who are assigned to more than
-- one project.
select employees.first_name ,projects.project_name from employees left join projects on employees.emp_id = projects.emp_id_no
where employees.emp_id in (select projects.emp_id_no from projects group by projects.emp_id_no having count(*) > 1);

-- Get the project name and the employee names of employees working on projects that
-- have more than one employee assigned

select projects.project_name , employees.first_name from projects left join employees on projects.emp_id_no = employees.emp_id
where projects.project_name in 
(select projects.project_name from projects group by projects.project_name having count(projects.emp_id_no) >1);

-- Get records from the "ProjectDetail" table where the corresponding employee ID does
-- not exist in the "employee table."
select * from projects l join employees on projects.emp_id_no = employees.emp_id where emp_id_no not in (select emp_id from employees);

-- 1 Assign a row number to each employee within their department based on salary in
-- descending order
select *, row_number() over (order by salary desc) as r_number
 from employees;
 
 
--  Rank employees within each department based on salary using RANK()
select *, rank() over (order by salary desc) as salary_rank
 from employees;
 
--  Rank employees within each department based on salary using DENSE_RANK()

select trim(first_name) as first_name,department,salary, 
dense_rank() over (partition by department order by salary desc) as salary_rank  from employees;

-- Find the highest-paid employee in each department using RANK()
select trim(first_name) as first_name, department, salary 
from (select first_name, department, salary, 
rank() over (partition by department order by salary desc) as rnk from employees) as der_emp_tab
where rnk=1;

-- Find the second highest-paid employee in each department using RANK().
select trim(first_name) as first_name, department, salary ,rnk
from (select first_name, department, salary, 
rank() over (partition by department order by salary desc) as rnk from employees) as der_emp_tab
where rnk=2;

-- .Rank employees based on their years of experience within each department.
select trim(first_name) , department, round(datediff(now(),joining_date)/365,2) as exp, 
dense_rank() over (partition by department order by round(datediff(now(),joining_date)/365,2) desc) 
as seniority_rank from employees;

-- .Find the employee with the earliest join date in each department using RANK()
select trim(first_name) as first_name, department, joining_date ,rnk
from (select first_name, department, joining_date, 
rank() over (partition by department order by joining_date ) as rnk from employees) as der_emp_tab
where rnk=1;


-- Find the employees who earn more than the average salary of their department.
select trim(first_name) as first_name, salary, department from employees 
as e where salary > (select avg(salary) from employees where e.department = department);

-- Rank employees within each job title in every department based on salary

select trim(first_name), department,job_title, salary,
rank() over (partition by department,job_title order by salary) as rnk
from employees;

-- .Find the top 3 highest-paid employees in each department.

select trim(first_name) as emp_name,salary,department,rnk from (
select first_name,salary, department, 
dense_rank() over (partition by department order by salary desc) as rnk 
from employees) 
as rnk_tab
where rnk in (1,2,3);

-- Find employees who belong to the top 10% earners within their department using
-- PERCENT_RANK().

select * from (select trim(first_name) as emp_name,department, salary , 
percent_rank() over (partition by department order by salary desc) as perc_rnk
from employees)
ranked 
where perc_rnk <= 0.10;

-- Assign row numbers to employees based on their joining year using PARTITION BY
-- YEAR(join_date).
select trim(first_name) as emp_name,joining_date,
row_number() over (partition by year(joining_date) order by year(joining_date) ) as r_n
from employees;

-- Rank employees based on the number of projects handled within each department.

select trim(first_name) as emp_name, proj_cnt, department,
dense_rank() over (partition by department order by proj_cnt desc) as rnk
from
(select count(project_id) as proj_cnt,first_name,department from projects join employees  on emp_id=emp_id_no
group by emp_id,first_name,department) as der_table;

-- Find employees who are the only ones in their department (departments with only one
-- employee).

select trim(first_name) as emp_name from employees
where department in
(select department from employees 
group by department having count(emp_id) =1 );

-- Find the highest-paid employee in each job role within a department.
select trim(first_name) as emp_name,job_title,department from
 (select first_name,job_title,department, ROW_NUMBER() over (partition by job_title,department order by salary desc) as rnk from employees) as der_tab
 where rnk=1;
 
--  9.Find employees who have been working in the company the longest in each department.
select trim(first_name) as emp_name, department from(select first_name, department,
dense_rank() over (partition by department order by datediff(now(),joining_date) desc) as rn from employees) as der_tab
where rn=1;