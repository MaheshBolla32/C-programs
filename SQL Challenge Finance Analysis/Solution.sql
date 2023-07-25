---- Finance Analysis

	SELECT * FROM Customers;
	SELECT * FROM Branches;
	SELECT * FROM Accounts;
	SELECT * FROM Transactions;


--Q1. What are the names of all the customers who live in New York?
	SELECT FirstName, LastName 
	FROM Customers
	WHERE State = 'NY';

--Q2. What is the total number of accounts in the Accounts table?
	SELECT COUNT(*) AS TotalAccounts
	FROM Accounts;

--Q3. What is the total balance of all checking accounts?
	SELECT SUM(Balance) AS TotalBalance
	FROM Accounts
	WHERE AccountType = 'Checking';

--Q4. What is the total balance of all accounts associated with customers who live in Los Angeles?
	SELECT SUM(Balance) AS TotalBalance
	FROM Accounts
	WHERE CustomerID IN(
		SELECT CustomerID
		FROM Customers
		WHERE City = 'Los Angeles'
	);

--Q5. Which branch has the highest average account balance?
	SELECT TOP 1 BranchID, AVG(Balance) AS AverageBalance
	FROM Accounts
	GROUP BY BranchID
	ORDER BY AverageBalance DESC;
	
--Q6. Which customer has the highest current balance in their accounts?
	SELECT TOP 1 c.FirstName, c.LastName, MAX(a.Balance) AS HighestBalance
	FROM Customers c
	JOIN Accounts a ON c.CustomerID = a.CustomerID
	GROUP BY c.FirstName, c.LastName
	ORDER BY HighestBalance DESC;

--Q7. Which customer has made the most transactions in the Transactions table?
	SELECT TOP 1 c.FirstName, c.LastName, COUNT(*) AS NoTransaction
	FROM Customers c
	JOIN Accounts a ON c.CustomerID = a.CustomerID
	JOIN Transactions t ON a.AccountID = t.AccountID
	GROUP BY c.FirstName, c.LastName
	ORDER BY NoTransaction DESC;
	
--Q8. Which branch has the highest total balance across all of its accounts?
	SELECT TOP 1 b.BranchID, b.BranchName, SUM(a.Balance) AS TotalBalance
	FROM Branches b
	JOIN Accounts a ON b.BranchID = a.BranchID
	GROUP BY b.BranchID, b.BranchName
	ORDER BY TotalBalance DESC;

--Q9. Which customer has the highest total balance across all of their accounts, including savings and checking accounts?
	SELECT TOP 1 c.FirstName, c.LastName, SUM(a.Balance) AS TotalBalance
	FROM Customers c
	JOIN Accounts a ON c.CustomerID = a.CustomerID
	GROUP BY c.FirstName, c.LastName
	ORDER BY TotalBalance DESC;

--Q10. Which branch has the highest number of transactions in the Transactions table?
	SELECT TOP 1 b.BranchID, b.BranchName, COUNT(*) AS NoTransaction
	FROM Branches b
	JOIN Accounts a ON b.BranchID = a.BranchID
	JOIN Transactions t ON a.AccountID = t.AccountID
	GROUP BY b.BranchID, b.BranchName
	ORDER BY NoTransaction DESC;






 