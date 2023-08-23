/* 
In this project I will be performing data analysis using
a database from a company which sells scale model cars.
The aim of the project is to extract KPIs (key performance
indicators) to help the company better allocate time and
resources.

The three questions I will be addressing are as follows:

Question 1: Which products should we order more of or less of?
Question 2: How should we tailor marketing and communication strategies to customer behaviors?
Question 3: How much can we spend on acquiring new customers?

The database (stores.db) contains 8 tables, which are listed
below with a brief description of what they pertain to.

The schema, located within this repository, is titled
'stores_schema.png'.

Table Descriptions:
Customers: Customer Data
Employees: All Employee Information
Offices: Sales Office Information
Orders: Customers' Sales Orders
OrderDetails: Sales Order Line for Each Sales Order
Payments: Customers' Payment Records
Products: A List of Scale Model Cars
ProductLines: A List of Product Line Categories */

SELECT '' AS Table_Names, '' AS Num_Attributes, '' AS Num_Rows
 UNION ALL
SELECT 'Customer', 13, (SELECT COUNT(*)
						  FROM customers)
 UNION ALL
SELECT 'Products', 9, (SELECT COUNT(*)
						 FROM Products)
 UNION ALL
SELECT 'ProductLines', 4, (SELECT COUNT(*)
							 FROM ProductLines)
 UNION ALL
SELECT 'Orders', 7, (SELECT COUNT(*)
					   FROM Orders)
 UNION ALL
SELECT 'OrderDetails', 5, (SELECT COUNT(*)
							 FROM OrderDetails)
 UNION ALL
SELECT 'Payments', 4, (SELECT COUNT(*)
						 FROM Payments)
 UNION ALL
SELECT 'Employees', 8, (SELECT COUNT(*)
						  FROM Employees)
 UNION ALL
SELECT 'Offices', 9, (SELECT COUNT(*)
						FROM Offices);
						
-- Question 1: Which products should we order more or less of?
-- Write a query to compute the low stock for each product using a correlated subquery.
SELECT productCode,
       ROUND(SUM(quantityOrdered) * 1.0 / (SELECT quantityInStock
											 FROM products p
											WHERE od.productCode = p.productCode), 2) AS lowStock
  FROM orderdetails od
 GROUP BY productCode
 ORDER BY lowStock
 LIMIT 10;

-- Write a query to compute the product performance for each product.
SELECT productCode, SUM(quantityOrdered * priceEach) AS productPerformance
  FROM orderdetails
 GROUP BY productCode
 ORDER BY productPerformance
 LIMIT 10;
 
-- Combine the previous queries using a Common Table Expression (CTE) to display priority products for restocking using the IN operator.
WITH lowStockProducts AS (
SELECT productCode,
       ROUND(SUM(quantityOrdered) * 1.0 / (SELECT quantityInStock
											 FROM products p
											WHERE od.productCode = p.productCode), 2) AS lowStock
  FROM orderdetails od
 GROUP BY productCode
 ORDER BY lowStock
 LIMIT 10
)

SELECT od.productCode, p.productName, p.productLine, SUM(quantityOrdered * priceEach) AS productPerformance
  FROM products p
  JOIN orderdetails od
    ON p.productCode = od.productCode
 WHERE od.productCode IN (SELECT productCode
							FROM lowStockProducts)
 GROUP BY od.productCode
 ORDER BY productPerformance DESC
 LIMIT 10;
 
-- Question 2: How Should We Match Marketing and Communication Strategies to Customer Behavior?
-- Write a query to join the products, orders, and orderdetails tables to have customers and products information in the same place.
SELECT o.customerNumber,
	   SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)) AS customerProfit
  FROM orders o
  JOIN orderdetails od
    ON o.orderNumber = od.orderNumber
  JOIN products p
    ON od.productCode = p.productCode
 GROUP BY o.customerNumber;
 
-- Write a query to find the top five VIP customers.
WITH customerProfit AS (
SELECT o.customerNumber,
	   SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)) AS profit
  FROM orders o
  JOIN orderdetails od
    ON o.orderNumber = od.orderNumber
  JOIN products p
    ON od.productCode = p.productCode
 GROUP BY o.customerNumber
)

SELECT c.contactLastName, c.contactFirstName, c.city, c.country, cp.profit as profit
  FROM customers c
  JOIN customerProfit cp
    ON c.customerNumber = cp.customerNumber
 ORDER BY profit DESC
 LIMIT 5;
 
-- Similar to the previous query, write a query to find the top five least-engaged customers.
WITH customerProfit AS (
SELECT o.customerNumber,
	   SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)) AS profit
  FROM orders o
  JOIN orderdetails od
    ON o.orderNumber = od.orderNumber
  JOIN products p
    ON od.productCode = p.productCode
 GROUP BY o.customerNumber
)

SELECT c.contactLastName, c.contactFirstName, c.city, c.country, cp.profit as profit
  FROM customers c
  JOIN customerProfit cp
    ON c.customerNumber = cp.customerNumber
 ORDER BY profit
 LIMIT 5;
 
-- Question 3: How Much Can We Spend on Acquiring New Customers?
-- Write a query to compute the average of customer profits using the CTE on the previous screen.

WITH customerProfit AS (
SELECT o.customerNumber,
	   SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)) AS profit
  FROM orders o
  JOIN orderdetails od
    ON o.orderNumber = od.orderNumber
  JOIN products p
    ON od.productCode = p.productCode
 GROUP BY o.customerNumber
)

SELECT AVG(cp.profit) AS LTV
  FROM customerProfit cp;
  
/* Conclusions:

Question 1: Which products should we order more or less of?

Answer: Taking into account products with low stock and high performance,
		classic cars represent six out of the top ten contenders, and therefore
		make the most sense to order more of.
		
Question 2: How should we match marketing and communication strategies to 
			customer behaviors?

Answer: Since we have lists of top five most engaged and top five least engaged
		customers, the best strategy would be to tangibly reward the loyalty of
		the most engaged customers, and inquire as to why less engaged customers
		are in fact less engaged, perhaps by surveying what it is they need from
		the company and what they are and are not willing to spend.
		
Question 3: How much can we spend on acquiring new customers?

Answer: The computed average lifetime value (LTV) of each customer is ~$39,000.
		This number could be used to predict future profit per customer, and 
		therefore can serve as a guideline to how much money should be spent
		on acquisition.
*/