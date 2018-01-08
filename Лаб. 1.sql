/*
1.����������� ������� �������� �� ������ ��������� � ������� ��������.
*/
/************************1************************/
SELECT [function], SUM(salary)/COUNT(*) AS result
FROM employee
JOIN job ON job.job_id = employee.job_id
GROUP BY [function]
ORDER BY result DESC

SELECT [function], AVG(salary) AS result
FROM employee
JOIN job ON job.job_id = employee.job_id
GROUP BY [function]
ORDER BY result DESC
/************************1************************/
--SELECT COUNT(DISTINCT [function]) FROM job
--JOIN employee ON job.job_id = employee.job_id
--2.��� ������� ������, � ������� ���������� ����� �����, ������� ���������� �����������, ������������� � ��� �� ������.
/************************2************************/
SELECT location_id, regional_group, COUNT(customer.name) AS quantity_customers
FROM location
LEFT JOIN customer ON city = regional_group
WHERE location_id IN 
	(SELECT DISTINCT location.location_id
	FROM location
	JOIN department ON department.location_id = location.location_id)
GROUP BY location_id, regional_group
ORDER BY quantity_customers DESC
/************************2************************/

--3.������� ����� ����� �������, ���������� �� ������ 'ACE TENNIS NET'. (������� ���������� �� ���� ������� ������ �� ���� ���� �����������)
/************************3************************/
SELECT SUM(item.total - min_price*quantity)
FROM product 
JOIN item ON item.product_id = product.product_id
JOIN sales_order ON sales_order.order_id = item.order_id
JOIN price ON price.product_id = product.product_id
WHERE description = 'ACE TENNIS NET' AND (end_date IS NULL OR order_date BETWEEN start_date AND end_date)
/************************3************************/
--4.������� ���������� �� ������� (Dallas), ������� ����� ���������� ���� ������.
/************************4************************/
SELECT first_name, last_name, datediff(day,hire_date, getdate())/365 AS experience
FROM employee
WHERE datediff(day,hire_date, getdate()) / 365 =
	(SELECT MAX(datediff(day,hire_date, getdate()) / 365)
	FROM employee   
	JOIN department ON employee.department_id = department.department_id
	JOIN location ON location.location_id = department.location_id
	WHERE regional_group = 'DALLAS')
/************************4************************/
SELECT * FROM employee