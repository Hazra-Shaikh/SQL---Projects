-- RETAILMART SQL PROJECT

SET SQL_SAFE_UPDATES = 0;

CREATE DATABASE RetailMart;
USE RetailMart;

CREATE TABLE Customers(
CustomerID INT Primary Key,
Customer_Name VARCHAR(50) Not Null,
City VARCHAR(30),
State VARCHAR(30),
Email VARCHAR(60),
Phone VARCHAR(15),
JoinDate DATE
);

CREATE TABLE Employees (
EmployeeID INT Primary Key,
Employee_Name VARCHAR(50) Not Null,
Department VARCHAR(30),
Designation VARCHAR(30),
Salary INT,
HireDate DATE,
ManagerID INT,
FOREIGN KEY (ManagerId) REFERENCES Employees (EmployeeId)
);

INSERT INTO employees VALUES
(1 ,'Ramesh Gupta',	'Sales', 'Sales Manager',	65000, '2021-01-10',NULL),
(2 ,'Kavita Menon',	'Sales', 'Sales Executive',	45000, '2021-06-15', 1),
(3 ,'Sanjay Patil',	'Sales', 'Sales Executive',	42000, '2022-02-20', 1),
(4 ,'Pooja Reddy',	'Support',	'Support Lead', 50000, '2021-03-05',NULL),
(5 ,'Rahul Bhatt',	'Support',	'Support Executive', 38000,	'2022-07-11', 4),
(6 ,'Farah Sheikh',	'Sales', 'Sales Executive',	43000,	'2022-09-01', 1);

CREATE TABLE Products(
ProductID INT Primary Key,
ProductName VARCHAR(50) Not Null,
Category VARCHAR(30),
Price INT,
StockQty INT
);

CREATE TABLE Orders(
OrderID INT Primary Key,
CustomerID INT, 
EmployeeID INT, 
OrderDate DATE ,
ShipCity VARCHAR(30),
Status VARCHAR(20) CHECK (Status IN ('Delivered',  'Pending' , 'Cancelled')),
FOREIGN KEY (CustomerId) REFERENCES Customers (CustomerId),
FOREIGN KEY (EmployeeId) REFERENCES Employees (EmployeeId)
);

CREATE TABLE OrderDetails(
OrderDetailID INT Primary Key,
OrderID INT ,
ProductID INT ,
Quantity INT,
UnitPrice INT,
Discount INT CHECK (Discount BETWEEN 0 AND 100),
FOREIGN KEY (OrderId) REFERENCES Orders (orderId),
FOREIGN KEY (ProductId) REFERENCES Products (ProductId)
);

-- Q1
SELECT Customer_name, city 
FROM Customers
WHERE state = 'Maharashtra'; 

-- Q2
SELECT ProductName , Price
FROM products
where price > 1000
ORDER BY Price DESC;

-- Q3
SELECT OrderID, OrderDate,status 
FROM Orders
WHERE Shipcity='Pune';

-- Q4
SELECT Employee_Name,department,Salary
FROM Employees
WHERE Department = 'sales' AND Salary > 40000;

-- Q5
SELECT Customer_name, Email, Joindate
FROM Customers
WHERE Joindate > '2023-03-01';

-- Q6
SELECT CustomerId,
COUNT(*) AS TotalOrders
FROM Orders
GROUP BY CustomerId;

-- Q7
SELECT ProductId,
SUM(Quantity) AS Total_Quantity
FROM Orderdetails
GROUP BY ProductId
ORDER BY Total_Quantity DESC;

-- Q8
SELECT Department,
AVG(Salary) AS Average_Salary
FROM Employees
GROUP BY Department;

-- Q9
SELECT status ,SUM(OrderId) AS Total_Orders
FROM Orders
GROUP BY Status;

-- Q10
SELECT Category, AVG(Price) AS AveragePrice
FROM Products
GROUP BY Category
HAVING AveragePrice > 1000;

-- Q11
SELECT O.OrderId, C.Customer_Name, O.OrderDate
FROM Orders O
JOIN Customers C
ON O.CustomerId = C.CustomerID;

-- Q12
SELECT O.OrderId , E.Employee_Name
FROM Orders O
JOIN Employees E
ON O.EmployeeId = E.EmployeeId;

-- Q13
SELECT P.ProductName ,SUM(Quantity * UnitPrice) AS Total_Revenue
FROM Products P
JOIN OrderDetails O
ON P.ProductId = O.ProductId
GROUP BY ProductName
ORDER BY Total_Revenue DESC;

-- Q14
SELECT O.OrderId,C.Customer_name, SUM(od.Quantity * od.UnitPrice) AS Bill_Amount
FROM  Orders O
JOIN Customers C
ON C.CustomerId = O.CustomerId
JOIN OrderDetails Od
ON od.OrderId = O.OrderId
GROUP BY OrderId, C.customer_name;

-- Q15
SELECT  C.Customer_Name, O.orderId
FROM  Customers C
LEFT JOIN  Orders O
ON C.CustomerId = O.CustomerId
WHERE O.OrderId IS NULL;

-- Q16
SELECT c.CustomerID,
       c.Customer_Name,
       COUNT(o.OrderID) AS TotalOrders
FROM Customers c
JOIN Orders o
ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.Customer_Name
HAVING COUNT(o.OrderID) > (
    SELECT AVG(OrderCount)
    FROM (
        SELECT CustomerID,
               COUNT(OrderID) AS OrderCount
        FROM Orders
        GROUP BY CustomerID
    ) AS AvgOrders
);

-- Q17
SELECT E.Employee_Name,
	COUNT(O.orderID) AS TotalOrders
FROM Employees E
JOIN Orders O
ON O.EmployeeId = E.EmployeeId
GROUP BY e.Employee_Name
ORDER BY TotalOrders DESC
LIMIT 1;

-- Q18
SELECT o.OrderID,
SUM(od.Quantity * od.UnitPrice) AS TotalValue,
	CASE
        WHEN SUM(od.Quantity * od.UnitPrice) > 5000 THEN 'HIGH VALUE'
		WHEN SUM(od.Quantity * od.UnitPrice) BETWEEN 2000 AND 5000 THEN 'HIGH VALUE'
        ELSE 'LOW'
	END AS Ordercategory
FROM Orders O
JOIN OrderDetails od
ON o.OrderID = od.OrderID
GROUP BY o.OrderID;

-- Q19
SELECT p.ProductID,
       p.ProductName
FROM Products p
WHERE NOT EXISTS (
    SELECT productId
    FROM OrderDetails od
    WHERE p.ProductID = od.ProductID
);

-- Q20
SELECT C.CustomerID,
       C.Customer_Name,
       (
         SELECT SUM(od.Quantity * od.UnitPrice)
         FROM Orders O
         JOIN OrderDetails od
           ON o.OrderID = od.OrderID
         WHERE o.CustomerID = c.CustomerID
           AND o.Status = 'Delivered'
       ) AS TotalSpent
FROM Customers C
ORDER BY TotalSpent DESC
LIMIT 3;