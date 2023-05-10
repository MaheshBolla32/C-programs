--SQL Advance Case Study
	SELECT * FROM DIM_LOCATION
	SELECT * FROM DIM_CUSTOMER
	SELECT * FROM DIM_DATE
	SELECT * FROM DIM_MANUFACTURER
	SELECT * FROM DIM_MODEL
	SELECT * FROM FACT_TRANSACTIONS

--Q1--BEGIN 


	SELECT DISTINCT(STATE)
	FROM FACT_TRANSACTIONS T1
	INNER JOIN DIM_LOCATION T2 ON T1.IDLocation = T2.IDLocation
	INNER JOIN DIM_MODEL T3 ON T1.IDModel= T3.IDModel
	WHERE Date BETWEEN '01-01-2005' AND GETDATE()



--Q1--END

--Q2--BEGIN

	SELECT STATE
	FROM DIM_LOCATION
	INNER JOIN FACT_TRANSACTIONS ON DIM_LOCATION.IDLocation = FACT_TRANSACTIONS.IDLocation
	INNER JOIN DIM_MODEL ON FACT_TRANSACTIONS.IDModel = DIM_MODEL.IDModel
	INNER JOIN DIM_MANUFACTURER ON DIM_MANUFACTURER.IDManufacturer = DIM_MODEL.IDManufacturer
	WHERE Manufacturer_Name = 'Samsung'
	GROUP BY STATE
	ORDER BY SUM(Quantity) DESC




--Q2--END

--Q3--BEGIN      
	
	SELECT Model_Name, ZipCode, STATE, 
	COUNT(IDCustomer) AS NO_OF_TRANSACTIONS 
	FROM DIM_LOCATION
	INNER JOIN FACT_TRANSACTIONS ON DIM_LOCATION.IDLocation = FACT_TRANSACTIONS.IDLocation
	INNER JOIN DIM_MODEL ON FACT_TRANSACTIONS.IDModel = DIM_MODEL.IDModel
	GROUP BY Model_Name, ZipCode, STATE



--Q3--END

--Q4--BEGIN

	SELECT TOP 1
	Unit_price, Model_Name
	FROM DIM_MODEL
	ORDER BY Unit_price



--Q4--END

--Q5--BEGIN

	SELECT Manufacturer_Name, Model_Name AS Model, SUM(Quantity) AS Total_quan, SUM(TotalPrice)/SUM(Quantity) AS Average
	FROM FACT_TRANSACTIONS 
	INNER JOIN DIM_MODEL ON FACT_TRANSACTIONS.IDModel = DIM_MODEL.IDModel
	INNER JOIN DIM_MANUFACTURER ON DIM_MODEL.IDManufacturer = DIM_MANUFACTURER.IDManufacturer
	WHERE Manufacturer_Name IN
	(
	SELECT TOP 5 Manufacturer_Name 
	FROM FACT_TRANSACTIONS 
	INNER JOIN DIM_MODEL ON FACT_TRANSACTIONS.IDModel=DIM_MODEL.IDModel 
	INNER JOIN DIM_MANUFACTURER  ON DIM_MODEL.IDManufacturer=DIM_MANUFACTURER.IDManufacturer 
	GROUP BY Manufacturer_Name ORDER BY SUM(Quantity) DESC
	)
	GROUP BY Manufacturer_Name, Model_Name ORDER BY Average



--Q5--END

--Q6--BEGIN

	SELECT Customer_Name, AVG(TotalPrice) AVG_SPENT
	FROM DIM_CUSTOMER
	INNER JOIN FACT_TRANSACTIONS ON DIM_CUSTOMER.IDCustomer = FACT_TRANSACTIONS.IDCustomer
	WHERE YEAR(Date) = 2009 
	GROUP BY Customer_Name
	HAVING AVG(TotalPrice) > 500
	



--Q6--END
	
--Q7--BEGIN  
	
	SELECT DIM_MODEL.IDModel, Model_Name, Manufacturer_Name 
	FROM DIM_MODEL 
	LEFT JOIN DIM_MANUFACTURER ON DIM_MODEL.IDManufacturer = DIM_MANUFACTURER.IDManufacturer
	WHERE DIM_MODEL.IDModel IN
	(
	SELECT IDModel FROM
	(SELECT TOP 5 IDModel, SUM(Quantity) [qty_sold]
	FROM FACT_TRANSACTIONS
	WHERE YEAR(Date)=2008
	GROUP BY IDModel
	ORDER BY SUM(Quantity) DESC) AS t1
	INTERSECT
	SELECT IDModel FROM
	(SELECT TOP 5 IDModel, SUM(Quantity) [qty_sold]
	FROM FACT_TRANSACTIONS
	WHERE YEAR(Date)=2009
	GROUP BY IDModel
	ORDER BY SUM(Quantity) DESC) AS t2
	INTERSECT
	SELECT IDModel FROM
	(SELECT TOP 5 IDModel, sum(Quantity) [qty_sold]
	FROM FACT_TRANSACTIONS
    WHERE YEAR(Date)=2010
	GROUP BY IDModel
	ORDER BY SUM(Quantity) DESC) AS t3
	)





--Q7--END	
--Q8--BEGIN

	SELECT res2.*
    FROM
    (
    SELECT *,
        DENSE_RANK() OVER (
    ORDER BY res1.price ) rank_
    FROM
        (
        SELECT
           DIM_DATE.YEAR,
            DIM_MODEL.IDManufacturer,
            SUM(FACT_TRANSACTIONS.TotalPrice) price
        FROM
            FACT_TRANSACTIONS
        JOIN DIM_DATE ON
            DIM_DATE.DATE = FACT_TRANSACTIONS.Date
        JOIN DIM_MODEL ON
            DIM_MODEL.IDModel = FACT_TRANSACTIONS.IDModel
        WHERE
            DIM_DATE.YEAR = 2009

        GROUP BY
           DIM_DATE.YEAR,
           DIM_MODEL.IDManufacturer ) res1 ) res2
    WHERE rank_ = 2

	UNION ALL

	SELECT res2.*
    FROM
    (
    SELECT *,
        DENSE_RANK() OVER (
    ORDER BY res1.price ) rank_
    FROM
        (
        SELECT
           DIM_DATE.YEAR,
            DIM_MODEL.IDManufacturer,
            SUM(FACT_TRANSACTIONS.TotalPrice) price
        FROM
            FACT_TRANSACTIONS
        JOIN DIM_DATE ON
            DIM_DATE.DATE = FACT_TRANSACTIONS.Date
        JOIN DIM_MODEL ON
            DIM_MODEL.IDModel = FACT_TRANSACTIONS.IDModel
        WHERE
            DIM_DATE.YEAR = 2010

        GROUP BY
           DIM_DATE.YEAR,
           DIM_MODEL.IDManufacturer ) res1 ) res2
    WHERE rank_ = 2





--Q8--END
--Q9--BEGIN
	
	SELECT Manufacturer_Name
	FROM DIM_MANUFACTURER 
	INNER JOIN DIM_MODEL ON DIM_MANUFACTURER.IDManufacturer = DIM_MODEL.IDManufacturer
	INNER JOIN FACT_TRANSACTIONS ON DIM_MODEL.IDModel = FACT_TRANSACTIONS.IDModel
	WHERE YEAR(Date) = 2010 

	EXCEPT 
	
	SELECT Manufacturer_Name
	FROM DIM_MANUFACTURER 
	INNER JOIN DIM_MODEL  ON DIM_MANUFACTURER.IDManufacturer = DIM_MODEL.IDManufacturer
	INNER JOIN FACT_TRANSACTIONS  ON DIM_MODEL.IDModel= FACT_TRANSACTIONS.IDModel
	WHERE YEAR(Date) = 2009





--Q9--END

--Q10--BEGIN
	
	SELECT 
    T1.Customer_Name, T1.Year, T1.Avg_Price,T1.Avg_Qty,
    CASE
        WHEN T2.Year IS NOT NULL
        THEN FORMAT(CONVERT(DECIMAL(8,2),(T1.Avg_Price-T2.Avg_Price))/CONVERT(DECIMAL(8,2),T2.Avg_Price),'p') ELSE NULL 
        END AS 'YEARLY_%_CHANGE'
    FROM
        (SELECT t2.Customer_Name, YEAR(t1.DATE) AS YEAR, AVG(t1.TotalPrice) AS Avg_Price, AVG(t1.Quantity) AS Avg_Qty FROM FACT_TRANSACTIONS AS t1 
        left join DIM_CUSTOMER as t2 ON t1.IDCustomer=t2.IDCustomer
        where t1.IDCustomer in (select top 10 IDCustomer from FACT_TRANSACTIONS group by IDCustomer order by SUM(TotalPrice) desc)
        group by t2.Customer_Name, YEAR(t1.Date)
        )T1
    left join
        (SELECT t2.Customer_Name, YEAR(t1.DATE) AS YEAR, AVG(t1.TotalPrice) AS Avg_Price, AVG(t1.Quantity) AS Avg_Qty FROM FACT_TRANSACTIONS AS t1 
        left join DIM_CUSTOMER as t2 ON t1.IDCustomer=t2.IDCustomer
        where t1.IDCustomer in (select top 10 IDCustomer from FACT_TRANSACTIONS group by IDCustomer order by SUM(TotalPrice) desc)
        group by t2.Customer_Name, YEAR(t1.Date)
        )T2
        on T1.Customer_Name=T2.Customer_Name and T2.YEAR=T1.YEAR-1 

	



--Q10--END

	