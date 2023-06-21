-- SQL Data Exploration: AdventureWorks2017 Dataset of Microsoft
-- Skills Used: JOINs, CASE, CTEs, Temp Tables, Aggregate Functions, Converting Data Types, Subqueries


-- List name of the product together with total quatity with descending order

SELECT A.ProductID as ProductID, A.Name, B.ProductId as InventoryID, B.Quantity
FROM Production.Product A
JOIN Production.ProductInventory B
ON A.ProductID = B.ProductID 
ORDER BY B.quantity DESC; 



--List aggregated sales orders of each product type that totals above $20,000

SELECT SalesOrderID, SUM(LineTotal) as Total_Orders_Amount
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
HAVING SUM(LineTotal) > 20000
ORDER BY Total_Orders_Amount ASC;



-- List product with 20+ characters in lenght

SELECT Name, LEN(Name) as Product_Name_Characters
FROM Production.Product
WHERE LEN(Name)>20;



-- Create the product category code as new

SELECT Name, UPPER(CONCAT(REPLICATE(0,LEN(Name)-5), SUBSTRING(Name,1,3))) as CategoryCode
FROM Production.ProductCategory;



-- Display ProductNumber, Name, ProductLine, Sale_Status with data conversion

SELECT ProductNumber, Name, COALESCE(ProductLine, 'N/A') AS ProductLine, 
COALESCE(CONVERT(varchar, DiscontinuedDate), 
CONVERT(varchar, SellEndDate), 'Ongoing Sale') AS Sale_Status
FROM Production.Product;



-- Provide description for the product's listing price shown as below

SELECT ProductID, Name, ListPrice,
       CASE 
              WHEN ListPrice < 20.00 THEN 'Low'
              WHEN ListPrice < 40.00 AND ListPrice < 20.00 THEN 'Medium'
              WHEN ListPrice >= 40.00 THEN 'High'
       END AS PriceRange
FROM Production.Product;



-- Count total number of customers having the same billing and shipping address

SELECT COUNT(CustomerID)
FROM Sales.SalesOrderHeader
WHERE NULLIF(BillToAddressID, ShipToAddressID) IS NULL; 



-- Find out 'Product Name' of each productID along with the workorderid. 

SELECT B.Name, A.ProductID, A.WorkOrderID
FROM Production.WorkOrder A
INNER JOIN Production.Product B
ON A.ProductID = B.ProductID;



--Find out sales orders for all ProductIDs along with the productID, Name, Total Sales.

SELECT A.ProductID, A.Name, B.LineTotal, B.SalesOrderID
FROM Production.Product A
LEFT JOIN Sales.SalesOrderDetail B
ON A.ProductID = B.ProductID;



-- Reviews of products along with the product name.

SELECT B.ProductID, B.Comments, A.Name
FROM Production.Product A 
RIGHT JOIN Production.ProductReview B
ON A.ProductID = B.ProductID;



-- Display sub-category name to which each product belongs - Find out if any sub-category name is not assigned to a product name) 

SELECT A.ProductID, A.Name AS ProductName,B.ProductSubCategoryID AS ProductSubCategoryID, B.Name AS SubCategoryName
FROM Production.Product A
FULL JOIN Production.ProductSubcategory B
ON A.ProductSubcategoryID = B.ProductSubCategoryID;



-- Count total number of online and offline orders placed in 2014. 

SELECT IIF(OnlineOrderFlag=1, 'Online', 'In-Store') AS OrderType, COUNT(SalesOrderID) AS TotalOrders
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) = 2014
GROUP BY OnlineOrderFlag;



--Display the Salesorders along with their Sales region and Sales quarter

SELECT SalesOrderID, OrderDate, 
CHOOSE(TerritoryID, 'Northwest', 'Northeast','Central','Southwest','Southeast','Canada','France','Germany','Australia','United Kingdom') AS SalesRegion, 
CHOOSE(MONTH(OrderDate),'Q1','Q1','Q1','Q2','Q2','Q2','Q3','Q3','Q3','Q4','Q4','Q4') AS SalesQuarter
FROM Sales.SalesOrderHeader;



-- Find details [ProductID, Name, ProductNumber] of products that belong to Category 'Accessories' and subcategory 'Helmets' & 'Locks'

SELECT ProductID, Name, ProductNumber
FROM Production.Product
WHERE ProductSubcategoryID IN 
(
       SELECT ProductCategoryID
       FROM Production.ProductSubcategory
       WHERE ProductCategoryID = 4 AND Name IN ('Helmets', 'Locks')
);



-- Load details of product that belong to Category 'Accessories' and Subcategory 'Helmets' & 'Locks' into a new table named 'CycleAccessories'

CREATE TABLE CycleAccessories
(
       ProductID int,
       Name nvarchar(50),
       ProductNumber nvarchar(25)
) -- creating new table


SELECT *
FROM CycleAccessories; -- checking the table is created


INSERT INTO CycleAccessories
SELECT 
       ProductID, 
       Name, 
       ProductNumber
FROM Production.Product
WHERE ProductSubcategoryID IN 
       (
       SELECT ProductSubcategoryID
       FROM Production.ProductSubcategory
       WHERE ProductCategoryID = 4 AND Name IN ('Helmets', 'Locks')
       ); -- Loading details of the product



--Delete all blue helmets frome the 'Cycleaccessories' table that belong to Category 'Accessories' and subcategory 'helmets'

SELECT *
FROM CycleAccessories

DELETE CycleAccessories
WHERE ProductID IN (
       SELECT ProductID
FROM Production.Product
WHERE ProductSubcategoryID IN 
       (SELECT ProductSubcategoryID
       FROM Production.ProductSubcategory
       WHERE ProductCategoryID = 4 
       AND Name IN ('Helmets')) AND name LIKE '%Blue%')



-- Find the lowest rating for the product 'HL Mountain Pedal'.

WITH cte_rating AS(
SELECT *
FROM Production.ProductReview
WHERE ProductID IN 
(
       SELECT ProductID
       FROM Production.Product
       WHERE Name = 'HL Mountain Pedal'
       )
)
SELECT MIN(Rating) AS Lowest_Rating FROM cte_rating



-- Find the reviews for products and their list price along with their product id and product name.

WITH cte_reviews AS(
       SELECT A.ProductID, A.Name, B.Comments 
       FROM Production.Product A
    RIGHT JOIN Production.ProductReview B
ON A.ProductID = B.ProductID
),
cte_prices AS(
       SELECT A.ProductID, A.Name, B.ListPrice FROM Production.Product A
RIGHT JOIN Production.ProductListPriceHistory B
ON A.ProductID = B.ProductID
)
SELECT C.ProductID, C.Name, C.Comments, D.ListPrice FROM cte_reviews C
INNER JOIN cte_prices D
ON C.ProductID = D.ProductID