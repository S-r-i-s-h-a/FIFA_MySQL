use assignment1;

-- Create the table
CREATE TABLE IF NOT EXISTS departments (
    dept_head_id INT PRIMARY KEY,
    dept_name VARCHAR(100),
    dept_head_name VARCHAR(100)
);

-- Insert data
INSERT INTO departments (dept_head_id, dept_name, dept_head_name) VALUES
(1, 'IT', 'Anil Kumar'),
(2, 'HR', 'Sneha Reddy'),
(3, 'Finance', 'Prakash Mehta');

select * from employees;

-- Find the total salary paid per department and rank them in descending order of total salary.
select department,total_sal ,
dense_rank() over ( order by total_sal desc) as salrank from
(select department, sum(salary) as total_sal from employees
group by department) as tab;


-- .List employees who have worked on more than one project.

select first_name,proj_cnt 
from 
(select first_name, count(project_id) as proj_cnt from projects join employees  on emp_id_no = emp_id 
group by emp_id) as tab
where proj_cnt >1 ;

select * from projects limit 5;

-- Find employees who are working on ongoing projects and order them by salary (highest
-- first).

select trim(first_name), salary,
dense_rank() over ( order by salary desc) as rnk
from 
employees join 
projects on 
emp_id = emp_id_no
where end_date ='00-00-0000';

-- Find the most experienced employee in each department
select * from
(select trim(first_name) as emp_name, department,TIMESTAMPDIFF(MONTH, joining_date, CURDATE()) as total_moe,
dense_rank() over (partition by department order by  TIMESTAMPDIFF(MONTH, joining_date, CURDATE()) desc) as rnk
from employees ) as tbl
where rnk=1;

-- Find employees whose salary is above the average salary of their department.

select trim(first_name) as emp_name,department, salary from employees as e
where
salary > (select avg(salary) from employees where department=e.department); 

use assignment1;
CREATE TABLE Bonus (
    bonus_id INT PRIMARY KEY,
    emp_id INT,
    bonus_amount DECIMAL(10,2),
    bonus_year YEAR
);

LOAD DATA LOCAL INFILE "D:\KSR DataVizon\MySQL\Assignment 1\tbl_bonus.csv"
INTO TABLE bonus
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(bonus_id, emp_id, @bonus_amount, @bonus_year)
SET 
  bonus_amount = NULLIF(@bonus_amount, ''),
  bonus_year   = NULLIF(@bonus_year, '');

select * from bonus;

-- Rank departments based on total salary + bonus, and rank employees within departments
-- based on total compensation
select e.department , e.emp_id, (salary+ifnull(bonus_amount,0))  as gross_sal ,
rank() over (partition by department order by (salary+ifnull(bonus_amount,0)) desc )
from employees e left join bonus b 
on e.emp_id=b.emp_id
JOIN
(select e2.department, sum(e2.salary+b2.bonus_amount) as dept_gross_sal from employees e2 join bonus b2
on e2.emp_id=b2.emp_id
group by e2.department) as dept_sal
on e.department= dept_sal.department
order by dept_sal.dept_gross_sal desc;

-- Rank employees based on number of projects + average project duration and rank
-- departments based on average project duration
SELECT 
    e.department, 
    e.emp_id, 
    dept_tab.avg_dept_dur,
    emp_stat.avg_ind_dur AS avg_ind_duration,
    emp_stat.proj_cnt AS proj_cnt,
    RANK() OVER (
        PARTITION BY e.department 
        ORDER BY emp_stat.avg_ind_dur ASC, emp_stat.proj_cnt DESC
    ) AS emp_rnk
FROM employees e
LEFT JOIN (
    SELECT 
        e1.emp_id,
        AVG(DATEDIFF(p1.end_date, p1.start_date)) AS avg_ind_dur,
        COUNT(p1.project_id) AS proj_cnt
    FROM employees e1
    LEFT JOIN projects p1 
        ON e1.emp_id = p1.emp_id_no
    GROUP BY e1.emp_id
) AS emp_stat
    ON e.emp_id = emp_stat.emp_id
JOIN (
    SELECT 
        e2.department, 
        AVG(DATEDIFF(p2.end_date, p2.start_date)) AS avg_dept_dur
    FROM employees e2
    JOIN projects p2 
        ON e2.emp_id = p2.emp_id_no
    GROUP BY e2.department
) AS dept_tab
    ON e.department = dept_tab.department
    where proj_cnt >=1 and not isnull(avg_ind_dur)
ORDER BY dept_tab.avg_dept_dur DESC;

-- Rank departments by total bonus distributed, and within each department, rank employees
-- based on bonus received

select e.department,dept_bon.dept_rnk, e.emp_id , ifnull(b.bonus_amount,0), dept_bon.dept_bonus,
rank() over (partition by e.department order by ifnull(b.bonus_amount,0) desc) as emp_rnk
from employees e left join  bonus b on e.emp_id=b.emp_id
LEFT JOIN (select e2.department as dept, ifnull(sum(b2.bonus_amount),0) as dept_bonus, 
rank() over (order by ifnull(sum(b2.bonus_amount),0) desc) as dept_rnk
 from 
employees e2 left join  bonus b2 on e2.emp_id=b2.emp_id
group by  e2.department) as dept_bon
on e.department=dept_bon.dept
order by dept_bon.dept_bonus desc;

-- Rank employees based on years of experience and project count, and rank departments
-- based on average experience

select e.emp_id, e.department,datediff(now(),e.joining_date)/365.25 as total_ind_exp,  
dept_avg_exp.avg_dept_exp/365.25 as avg_dept_exp ,ifnull(emp_proj_stat.proj_cnt,0) as proj_cnt , dept_avg_exp.dept_rnk,
rank() over (partition by e.department order by datediff(now(),e.joining_date) desc, ifnull(emp_proj_stat.proj_cnt,0) desc) as emp_rnk 
from employees e left join (select p1.emp_id_no,count(p1.project_id) as proj_cnt from projects p1 group by p1.emp_id_no)
as emp_proj_stat on e.emp_id=emp_proj_stat.emp_id_no
left join (select e2.department as dept , avg(datediff(now(),e2.joining_date)) as avg_dept_exp,
rank() over (order by avg(datediff(now(),e2.joining_date)) desc) as dept_rnk
 from employees e2
group by e2.department) as dept_avg_exp on e.department = dept_avg_exp.dept
order by dept_avg_exp.avg_dept_exp desc;


-- 1.Write a CTE that retrieves employees along with their department and project details.

with emp_project_details as 
( select emp.emp_id as e_id, emp.first_name as f_n,emp.department as dept,
 proj.project_id as proj_id, proj.project_name as proj_name 
 from employees emp left join projects proj on
 emp.emp_id = proj.emp_id_no)
 select e_id,f_n,dept, proj_id, proj_name
 from emp_project_details;

-- 2.Use a CTE to find employees who have worked on more than one project.
with proj_details as 
(select emp_id_no, count(project_id) as proj_cnt from 
projects 
group by emp_id_no)
select emp_id_no, first_name, department, proj_cnt from employees left join proj_details 
on emp_id_no= emp_id
where proj_cnt >1;


-- 3.Create a CTE to find employees earning more than the average salary of their department.

with avg_sal_by_dept as 
(select department as dept, avg(salary) as avg_sal from employees 
group by department)
select emp_id, first_name, department, avg_sal,salary from employees left join avg_sal_by_dept 
on department=dept
where salary > avg_sal;


-- Use a CTE and JOINs to fetch employees who joined in the last two years along with their
-- project names.

with emp_project_details as 
( select emp.emp_id as e_id, emp.first_name as f_n,emp.department as dept, joining_date,datediff(now(),emp.joining_date)/365.25 as YOE,
 proj.project_id as proj_id, proj.project_name as proj_name 
 from employees emp left join projects proj on
 emp.emp_id = proj.emp_id_no)
 select e_id,f_n, joining_date , proj_name,YOE from emp_project_details
 where YOE <=2 and not isnull(proj_name) ;
 
 
-- 5.Create a CTE to calculate department-wise salary statistics (sum, avg, max).

with sal_stat as 
(select department, sum(salary) as total_salary,avg(salary) as avg_sal, max(salary) as max_salary
from employees
group by department)
select * from sal_stat;


-- 6.Use a CTE with RANK() to find the top 5 highest-paid employees.

with rnk_sal as
(select emp_id, first_name, last_name,department, salary,
dense_rank() over (order by salary desc) as rnk
from employees)
select * from rnk_sal
where rnk <=5;



-- 7.Write a CTE to find employees who have the longest tenure in their department.

with emp_tenure as
(select emp_id, first_name,department, datediff(now(),joining_date)/365.25 as tenure,
dense_rank() over (partition by department order by datediff(now(),joining_date)/365.25 desc) as rnk
from employees )
select * from emp_tenure where rnk=1;


-- Use a CTE with GROUP BY to count employees by department and classify them as Small,
-- Medium, or Large.
with cnt_emp_by_dept as 
(select department, count(distinct emp_id) as cnt from
employees
group by department)
select *, case
when cnt <=2 then "small"
when cnt >2 and cnt <=5 then "medium"
else "large"
end as dept_size
from 
cnt_emp_by_dept;

-- 9. Create a recursive CTE to find employees with a reporting hierarchy.
with recursive heirar_cte as
(select 
dept_head_id, dept_name, dept_head_name,
1 as stage from departments

union all
select employees.emp_id,  employees.department,employees.first_name, heirar_cte.stage+1
from employees join heirar_cte on employees.department=heirar_cte.dept_name where stage = 1)

select * from heirar_cte
order by dept_name, stage;

-- 10. Write a query that uses a CTE, JOINs, and RANK() to find the second-highest-paid
-- employee in each department.
with sal_cte as 
(select emp_id,first_name, department, salary, 
dense_rank() over (partition by department order by salary desc) as rnk
from employees)
select * from sal_cte where rnk=2;

-- 10 Find departments with total compensation (salary + bonus) > 300,000 and rank employees
-- within those departments by compensation.
with dept_300k as 
(select department, sum(salary+ifnull(bonus_amount,0)) as dept_comp from employees left join bonus on employees.emp_id=bonus.emp_id
group by department having sum(salary+ifnull(bonus_amount,0)) >300000)
select employees.emp_id, employees.first_name,employees.department,dept_comp, employees.salary+ifnull(bonus_amount,0),
dense_rank() over (partition by employees.department order by employees.salary desc) as rnk
from employees left join bonus on employees.emp_id=bonus.emp_id 
 join 
dept_300k on  employees.department = dept_300k.department;


-- Find departments where average experience > 3 years and within those departments, rank
-- employees by project count.
with dept_avg_exp as
(select department, avg(datediff(now(),joining_date))/365.25 as avg_exp from employees 
group by  department having avg(datediff(now(),joining_date))/365.25 > 3 ),
 pr as
(select emp_id_no, ifnull(count(project_id),0) as proj_cnt from projects group by emp_id_no) 
select emp.emp_id ,emp.department, emp.first_name, ifnull(pr.proj_cnt,0) as proj_cnt,
dense_rank() over (partition by emp.department order by pr.proj_cnt desc) as rnk
from employees emp left  join  pr on emp.emp_id=pr.emp_id_no
join dept_avg_exp on emp.department=dept_avg_exp.department;

-- Identify project managers (department heads) whose department's total bonus exceeds
-- 50,000, rank departments and rank employees in those departments by bonus

with dept_bon as
(select department, sum(bonus_amount) as tot_bon from employees left join bonus on employees.emp_id=bonus.emp_id
group by department),
dept_heads as
(select dept_head_id, dept_name, dept_head_name, tot_bon as total_bonus,
dense_rank() over (order by   tot_bon) as dept_rank
from departments join dept_bon on dept_name=department where tot_bon >5000)
select emp.emp_id as eid,emp.first_name as emp_name, emp.department as dept, 
dept_head_name,dept_rank , bonus_amount ,
dense_rank() over (partition by emp.department order by bonus_amount) as emp_rank
from employees emp join bonus on emp.emp_id = bonus.emp_id 
join dept_heads on emp.department=dept_heads.dept_name
order by dept_rank;

-- Find top 2 departments based on avg project duration and rank employees within
-- departments based on joining date (experience).

with top_dept as
(select department , avg(datediff(end_date,start_date)) as avg_duration_days,
dense_rank() over (order by avg(datediff(end_date,start_date)) ) as rnk
from employees join projects on emp_id=emp_id_no
group by department
having not isnull(avg(datediff(start_date,end_date))))

select td.department, rnk as dept_rank, emp_id,first_name, datediff(now(),joining_date)/365.25 as YOE,
dense_rank() over (partition by employees.department order by datediff(now(),joining_date)/365.25 desc) as emp_rnk
from employees  join top_dept td on employees.department=td.department 
where rnk<=2 
order by rnk ;

-- Find employees who worked on more than one completed project, belong to departments
-- with avg salary > 55k, and rank them by salary and project count.
with avg_55k_dept as
(select department , avg(salary) as dept_avg_sal from employees group by department having avg(salary)>55000),
emp_gt_1_proj as
(select emp_id_no, count(project_id) as proj_cnt from projects where not end_date = "0000-00-00" group by emp_id_no having count(project_id)>1)
select emp_id, salary,dept_avg_sal, employees.department,
dense_rank() over ( partition by employees.department order by salary,proj_cnt ) as rnk
from employees join emp_gt_1_proj on employees.emp_id=emp_gt_1_proj.emp_id_no 
join avg_55k_dept on  employees.department = avg_55k_dept.department;


-- Find departments where total number of employees > 5 and rank employees by total
-- compensation (salary + bonus) & experience.
with large_dept as
(select department as dept, count(emp_id) as emp_cnt from employees group by department having count(emp_id)>5)
select employees.emp_id,first_name, department,emp_cnt,salary+ ifnull(bonus_amount,0) as tot_sal, datediff(now(),joining_date)/365.25 as YOE ,
dense_rank() over (partition by department order by  salary+ ifnull(bonus_amount,0) desc, datediff(now(),joining_date)/365.25 desc) as rnk
from employees left join bonus on employees.emp_id=bonus.emp_id join large_dept on employees.department=large_dept.dept;


-- Identify employees who worked in more than 2 projects, belong to departments where
-- the dept head name starts with 'M', and rank by salary & number of projects.
with emp_gt_2_proj as
(select emp_id_no as e_id, count(project_id) as cnt_proj from projects group by emp_id_no having count(project_id) >= 2),
head_starts_with_m as 
(select dept_name from departments where lower(dept_head_name) like "a%")

select emp_id, department , cnt_proj, salary ,
dense_rank() over (partition by department order by salary desc, cnt_proj desc) as rnk
from employees  join emp_gt_2_proj on emp_id=e_id 
join 
head_starts_with_m on trim(department) = trim(dept_name);


-- Find departments where total project count > 5, calculate average project duration, rank
-- departments by duration, and rank employees within departments by number of
-- completed projects.

with proj_cnt as
(select department as dept, avg(datediff(end_date, start_date)) as avg_dur_days,count(project_id) as dept_proj_cnt,
dense_rank() over (order by avg(datediff(end_date, start_date)))  as dept_rank
 from employees  join projects on emp_id=emp_id_no
 group by department having count(project_id)>5 ),
compl_proj as
(select emp_id_no , count(project_id) as compl_prj_cnt from projects where not end_date ="0000-00-00" 
group by emp_id_no)
select emp_id, department, dept_rank, dept_proj_cnt , compl_prj_cnt,
dense_rank() over (partition by department order by compl_prj_cnt desc) as proj_cnt_rnk_by_emp
from employees   join compl_proj on emp_id=emp_id_no
 join proj_cnt on department=dept
 order by dept_rank ;
 
 -- Find employees who received bonuses greater than department average bonus, rank
-- departments by total bonus, and rank employees by salary + bonus.

with avg_dept_bonus as 
(select e.department as dept,avg(b.bonus_amount) as avg_bonus, sum(bonus_amount),
dense_rank() over (order by sum(b.bonus_amount) desc) as dept_bon_rnk
 from employees e join bonus b on e.emp_id=b.emp_id
 group by e.department)
 
 select e.emp_id , e.first_name, e.department,e.salary, b.bonus_amount, 
 dense_rank() over (partition by department order by e.salary+ b.bonus_amount desc) as emp_rank
 from employees e join bonus b on e.emp_id=b.emp_id 
 join avg_dept_bonus adb on e.department=adb.dept
 where b.bonus_amount> adb.avg_bonus
 order by dept_bon_rnk,emp_rank;
 
--  Find departments where the department head's name contains 'a', average employee
-- experience > 4 years, and rank employees within those departments by project count and
-- total compensation (salary + bonus).

with head_name_a as
(select dept_name, dept_head_name from departments
where lower(dept_head_name) like "a%"),
depts as
(select e.department as dept, avg(datediff(now(),e.joining_date)/365.25) as dept_avg_yoe
from employees e join head_name_a hna on e.department = hna.dept_name  group by e.department having avg(datediff(now(),e.joining_date)/365.25) >4),
project_counts as
(select emp_id_no,count(project_id) as proj_cnt from projects group by emp_id_no)
select e.emp_id, e.first_name, e.department,e.salary+ifnull(b.bonus_amount,0) as tot_sal, proj_cnt,
dense_rank() over (partition by department order by proj_cnt desc, e.salary+ifnull(b.bonus_amount,0) desc) as rnk

from employees e left join bonus b on e.emp_id=b.emp_id 
join  project_counts on e.emp_id=emp_id_no
join depts on e.department=depts.dept 
;

-- .Employee Experience Categorization & Bonus Status
-- Create a stored procedure that fetches each employee's full name,
-- their years of experience (calculated using the joining date), and
-- categorizes their experience level as 'Senior' (more than 5 years),
-- 'Mid-Level' (2 to 4 years), or 'Junior' (less than 2 years). Additionally,
-- include a column to check whether the employee has received a
-- bonus or not. Use CASE statements to implement categorization
-- and status display. This procedure should involve a LEFT JOIN
-- between emp_table and bonus

delimiter $$
create procedure GetEmpDetails()
begin
select e.emp_id, concatws(" ",trim(first_name),trim(last_name)) as full_name, datediff(now(),e.joining_date)/365.25 as yoe, case
when datediff(now(),e.joining_date)/365.25 < 2 then "Junior"
when datediff(now(),e.joining_date)/365.25 >=2 and datediff(now(),e.joining_date)/365.25 <=5 then "Mid-level"
else "Senior"
end as Level_of_Expereince,
not isnull(b.bonus_amount) as bonus_status
from employees e left join bonus b on e.emp_id = b.emp_id;

END $$




-- Develop a stored procedure that generates a department-level
-- summary report. The output should include the department name,
-- total salary paid to employees, total bonuses distributed, and the
-- number of employees in each department. Implement GROUP BY
-- and aggregation functions, and use appropriate JOINs between
-- emp_table and bonus tables.
delimiter $$
create procedure get_dept_details()
begin

select e.department as dept , sum(e.salary) as total_sal , sum(ifnull(b.bonus_amount,0)) as total_bonus ,count(e.emp_id) as no_of_members 
from employees e  left join bonus b on e.emp_id=b.emp_id
group by e.department;

end $$
delimiter ;

-- 3. Employee Project Completion Status
-- Design a procedure to retrieve the list of all employees along with
-- their respective project names and current status. Use a CASE
-- statement to convert the project status into more readable values:
-- 'Done' for completed projects, 'In Progress' for ongoing projects,
-- and 'Unknown' if no project is assigned. This procedure should
-- involve JOINs between emp_table and projects.

delimiter $$
create procedure get_proj_status()
begin
select e.emp_id,trim(e.first_name),ifnull(p.project_name,"unassiggned"), case
when p.status like "C%" then "Done"
when p.status like "O%" then "In progress"
else "Unknown"
end as proj_stat
from employees e left join projects p on e.emp_id= p.emp_id_no ;

end $$


-- 4. Above-Average Salary Employees
-- Create a stored procedure that identifies employees earning above
-- the average salary in their department. You need to implement a
-- correlated subquery to calculate the department-wise average
-- salary and compare each employee's salary accordingly.
delimiter $$
create procedure above_avg_earners()
begin

select e.emp_id,trim(e.first_name) as emp_name,e.department, e.salary,avg_sal_dept.dept_avg_sal from
employees e left join (select department as dept, avg(salary) as dept_avg_sal from employees group by department) as avg_sal_dept
on e.department = avg_sal_dept.dept where e.department = avg_sal_dept.dept and e.salary > avg_sal_dept.dept_avg_sal
order by e.department;

end $$
delimiter ;

-- 5.Formatted Employee Names and Joining Month
-- Construct a procedure to display employees' names formatted
-- properly (first letter uppercase, rest lowercase). Additionally,
-- extract and display the month name from the employee's joining
-- date using DATE functions. This will require using String Functions
-- like UPPER(), LOWER(), CONCAT(), and date extraction functions.

delimiter $$

create procedure format_names()
begin
select concat(upper(substring(trim(first_name),1,1)),lower(substring(trim(first_name),2)) ," ",upper(substring(trim(last_name),1,1)),lower(substring(trim(last_name),2)))
as emp_full_name,
monthname(joining_date) as month_of_joining  from employees;
end $$
delimiter ;



-- 6. Employees under Department Heads Starting with 'M
-- Write a procedure to list all employees who are part of
-- departments headed by department heads whose names start with
-- the letter 'M'. This requires JOINing the emp_table and
-- department_head tables and applying a LIKE filter.
delimiter $$

create procedure starts_with_m()

begin
select  e.emp_id ,trim(e.first_name) as emp_name, e.department from employees e join
(select dept_name,dept_head_name from departments where dept_head_name like "m%") as depts on
e.department=depts.dept_name;

end $$

-- 7. Department-wise Average Employee Experience Summary
-- Develop a stored procedure to summarize the average experience
-- of employees in each department. You should calculate the
-- difference in years between the current date and the joining date.
-- The procedure should display the department name, average
-- experience in years, and employee count. GROUP BY and DATE
-- functions will be used here.
DELIMITER $$

CREATE PROCEDURE DeptAvgExperience()
BEGIN
    SELECT 
        department,
        ROUND(AVG(DATEDIFF(NOW(), joining_date)/365.25), 2) AS avg_dept_exp_years,
        COUNT(emp_id) AS emp_count
    FROM employees
    GROUP BY department
    ORDER BY department;
END $$

DELIMITER ;


-- 8. Employee Compensation Ranking Using CTE
-- Design a stored procedure that calculates each employee’s total
-- compensation by adding salary and bonus. Use a Common Table
-- Expression (CTE) to prepare the data, then apply a Ranking Function
-- to rank employees within their department based on total
-- compensation. Involve JOINs between emp_table and bonus.
DELIMITER $$

CREATE PROCEDURE EmpCompensationRanking()
BEGIN
    WITH cte AS (
        SELECT 
            e.emp_id AS e_id,
            CONCAT(TRIM(e.first_name), ' ', TRIM(e.last_name)) AS emp_name,
            e.department AS dept,
            e.salary + IFNULL(b.bonus_amount, 0) AS tot_salary
        FROM employees e
        LEFT JOIN bonus b ON e.emp_id = b.emp_id
    )
    SELECT *,
           DENSE_RANK() OVER (PARTITION BY dept ORDER BY tot_salary DESC) AS rnk
    FROM cte
    ORDER BY dept, rnk;
END $$

DELIMITER ;


-- 9. Employees with More Than One Project
-- Create a procedure to list employees who have been assigned to
-- more than one project. Include their names and the count of
-- projects they have worked on. This will require JOINing the
-- emp_table and projects tables, applying GROUP BY, and using the
-- HAVING clause to filter employees with more than one project.
delimiter $$

create procedure gt_1_proj()

begin

select e.emp_id, trim(e.first_name) as emp_name, p.project_cnt from employees e
 join (select emp_id_no, count(project_id) as project_cnt from projects group by emp_id_no having count(project_id)>1) as p
on e.emp_id=p.emp_id_no;


end $$

delimiter ;


-- 10. Yearly Salary Growth Simulation
-- Create a stored procedure that projects the salary for the next year
-- based on the following criteria:
-- If the current salary is less than 50,000, increase by 10%.
-- If the salary is between 50,000 and 70,000, increase by 7%.
-- If the salary is above 70,000, increase by 5%.
delimiter $$

create procedure projections()

begin

select emp_id, trim(first_name) as emp_name, salary as current_sal,case
when salary < 50000 then salary+(salary*.1)
when salary >=50000 and salary <=70000 then salary+(salary*0.07)
else salary+(salary*0.05)
end as sal_projection
from employees;

end $$


-- 1.Employee Full Name with Department Head
-- Create a view that combines employee details and department head information. The
-- view should display each employee’s full name (first + last name), department, and the
-- name of the department head. Implement JOINs and string concatenation.

create view emp_with_head as
select concat(upper(substring(trim(e.first_name),1,1)),lower(substring(trim(e.first_name),2)) ," ",
upper(substring(trim(e.last_name),1,1)),lower(substring(trim(e.last_name),2)))
as full_name,
e.department as dept,
 d.dept_head_name
from employees e join departments d on
e.department=d.dept_name;


select * from emp_with_head;

-- 2.Department-wise Bonus Summary View
-- Develop a view that summarizes the total bonuses distributed in each department. Utilize
-- JOINs between emp_table and bonus and GROUP BY department.

create view bonus_info as
select e.department, sum(b.bonus_amount) as tot_bon  from
employees e join bonus b on e.emp_id= b.emp_id group by e.department;

select * from bonus_info;

-- 3.Formatted Employee Names and Experience View
-- Create a view that displays employees' names in a properly formatted style (capitalized
-- first letters) along with their years of experience calculated from their joining date.
-- create view YOE as
select concat(upper(substring(trim(first_name),1,1)),lower(substring(trim(first_name),2)) ," ",
upper(substring(trim(last_name),1,1)),lower(substring(trim(last_name),2))) as emp_name,
datediff(now(),joining_date)/365.25 as YOE
from employees;

select * from yoe;


-- 4.Employee Compensation Summary View
-- Design a view to display each employee’s salary, bonus, and total compensation. JOIN
-- emp_table and bonus, and use COALESCE to handle cases where no bonus is assigned.
create view gross_salary as
select e.emp_id, trim(e.first_name) as emp_name , e.salary+COALESCE(b.bonus_amount,0) as tot_sal from 
employees e left join bonus b on e.emp_id=b.emp_id;

select * from gross_salary;


-- 5. Project Details Summary View
-- Create a view combining project and employee data. Display project name, employee
-- name, employee department, and project status. Use JOINs between projects and
-- emp_table.
-- -- create view proj_status as 
-- -- select emp_id, trim(first_name) as first_name , department, project_name, status
-- -- from employees join projects on emp_id=emp_id_no;

select * from  proj_status;