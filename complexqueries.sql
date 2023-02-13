/* Create an automation that anytime an order_items records are inserted into the databse,the orders table is updated as well
*/
CREATE TRIGGER insert_new_orders
AFTER INSERT ON order_item
FOR EACH ROW

REPLACE INTO order_summary
 SELECT 
       order_id,
       MIN(created_at) AS created_at,
       MIN(website_session_id) AS website_session_id,
       SUM(CASE
           WHEN is_primary_item = 1 THEN product_id
           ELSE NULL 
           END) AS primary_product_id,
		COUNT(order_item_id) AS items_purhcased,
        SUM(price_usd) AS price_usd, 
        SUM(cogs_used) AS cogs_usd
FROM order_item
WHERE order_id = new.order_id
group by 1
order by 1;

/* Define a function that retrieves the largest contract salary value of an employee. Apply it to employee number 11356
In addition, what is the lowest contract salary value of the same employee? You may want to create a new function that to obtain the result
*/
DELIMITER $$
CREATE FUNCTION f_highest_salary (p_emp_no INTEGER) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN

DECLARE v_highest_salary DECIMAL(10,2);

SELECT 
     MAX(s.salary)
INTO v_highest_salary FROM
       employees e
         JOIN
		salaries s ON e.emp_no = s.emp_no
WHERE
    e.emp_no = s.emp_no;
RETURN v_highest_salary;
END$$


DELIMITER ;
select f_highest_salary (11356);

/* Create a procedure that ask you to insert an employee number andt that will obtain an output containing the same number, as well as the numner and name of the last department the employee has worked in
Finally, call the procedure for employee number 10010
*/ 

DELIMITER $$
CREATE PROCEDURE last_dept (IN p_emp_no integer)
BEGIN 
SELECT 
e.emp_no, d.dept_no, d.dept_name
FROM
employees e 
JOIN 
dept_emp de ON e.emp_no = de.emp_no
JOIN
departments d ON de.dept_no = d.dept_no
WHERE 
e.emp_no = p_emp_no
AND de.from_Date = (SELECT 
MAX(from_date)
FROM 
dept_emp
WHERE 
emp_no = p_emp_no);
END $$ 
DELIMITER ; 

call employees.last_dept(10010);

/* Find the average salary of male and female employees in each department alter
*/

SELECT 
    d.dept_name, e.gender, AVG(salary)
FROM
    salaries s
        JOIN
    employees e ON s.emp_no = e.emp_no
        JOIN
    dept_emp de ON e.emp_no = de.emp_no
        JOIN
    departments d ON d.dept_no = de.dept_no
GROUP BY de.dept_no , e.gender
ORDER BY de.dept_no;



