-- SQL Data CLeaning - AdventureWorks2017 Dataset of Microsoft
-- Skills used: LTRIM/RTRIM, STUFF, FORMAT, SUBSTRING, CONCAT, REPLACE, DATEDIFF, DATEADD, ISNULL


--Remove any spaces before and after email addresses

SELECT EmailAddress,
LTRIM(RTRIM(EmailAddress)) as NEW_Column
FROM Person.EmailAddress; -- removed both leading and trailing spaces in the email addresses



-- Mask email addresses in the report. Mask name with X. Reveal only the characters after the @ symbol.

SELECT EmailAddress,
STUFF(
    EmailAddress, 
    1, 
    LEN(SUBSTRING(EmailAddress, 1, CHARINDEX('@', EmailAddress)-1)),
    REPLICATE('X', LEN(SUBSTRING(EmailAddress, 1, CHARINDEX('@', EmailAddress)-1)))
) AS Masked_Email_Address
FROM Person.EmailAddress;



-- Display the products and date to start selling them in a format of specific to each country - US, India & China. 

SELECT name,
FORMAT(SellStartDate, 'd', 'en-us') as US_SellStartDate,
FORMAT(SellStartDate, 'd', 'hi-in') as India_SellStartDate,
FORMAT(SellStartDate, 'd', 'zh-cn') as China_SellStartDate
FROM Production.Product;



--Extract the username from all email addresses

SELECT EmailAddress, SUBSTRING(EmailAddress, 1, CHARINDEX ('@', EmailAddress) - 1) as User_Name
FROM Person.EmailAddress;



--Format location details of employees with format of State Code - State Name, Country Code

SELECT CONCAT(StateProvinceCode,'-', Name,',', CountryRegionCode) as Location
FROM Person.StateProvince;



--Format HireDate in this specific format: YYYY/MM/DD

SELECT JobTitle, HireDate, REPLACE(HireDate,'-', '/') as Hire_Date_Replaced
FROM HumanResources.Employee;



-- Calculate the age of employment started with the company

SELECT jobtitle, birthdate, HireDate, DATEDIFF(YEAR,birthdate, hiredate) as Age_Employment_Started
FROM HumanResources.Employee
ORDER BY Age_Employment_Started DESC; 



--Find out job anniversary and filter highest to lowest

SELECT LoginID, HireDate, DATEADD(YEAR,1,HireDate) as Anniversary
FROM HumanResources.Employee
ORDER BY Anniversary DESC; 



-- Format FirstName, MiddleName, LastName of the Person with an empty string if no data available.

SELECT 
       ISNULL(FirstName,'') AS FirstName, 
       ISNULL(MiddleName,'') AS MiddleName,
       ISNULL(LastName, '') AS LastName
FROM Person.Person
ORDER BY FirstName;

