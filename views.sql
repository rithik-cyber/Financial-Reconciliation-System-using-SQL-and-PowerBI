/* 
Departman bazýnda aylýk gelir, gider ve net karý hesaplayan görünüm.
View that calculates monthly revenue, expense, and net profit per department.
*/
CREATE VIEW vw_MonthlyProfit AS
SELECT 
    departments.DepartmentName,
    FORMAT(revenues.RevenueDate, 'yyyy-MM') AS YearMonth,
    SUM(revenues.Amount) AS TotalRevenue,
    SUM(expenses.Amount) AS TotalExpense,
    SUM(revenues.Amount) - SUM(expenses.Amount) AS NetProfit
FROM departments
LEFT JOIN revenues
    ON departments.DepartmentID = revenues.DepartmentID
LEFT JOIN expenses 
    ON departments.DepartmentID = expenses.DepartmentID
    AND FORMAT(expenses.ExpenseDate, 'yyyy-MM') = FORMAT(revenues.RevenueDate, 'yyyy-MM')
GROUP BY 
    departments.DepartmentName,
    FORMAT(revenues.RevenueDate, 'yyyy-MM');

GO
/*
Her departman için gider kategorilerini ve aylýk toplam gider tutarlarýný gösteren görünüm.
View that shows total monthly expenses per department and category.
*/
CREATE VIEW vw_DepartmentExpenses AS
SELECT
    departments.DepartmentName,
    FORMAT(expenses.ExpenseDate, 'yyyy-MM') AS YearMonth,
    expenses.ExpenseCategory,
    SUM(expenses.Amount) AS TotalExpense
FROM departments
INNER JOIN expenses
    ON departments.DepartmentID = expenses.DepartmentID
GROUP BY
    departments.DepartmentName,
    FORMAT(expenses.ExpenseDate, 'yyyy-MM'),
    expenses.ExpenseCategory;

GO
/*
Türkçe: Her departman için gelir kategorilerini ve aylýk toplam gelir tutarlarýný gösteren görünüm.
English: View that shows total monthly revenues per department and category.
*/
CREATE VIEW vw_RevenueTrends AS
SELECT
    departments.DepartmentName,
    FORMAT(revenues.RevenueDate, 'yyyy-MM') AS YearMonth,
    revenues.RevenueCategory,
    SUM(revenues.Amount) AS TotalRevenue
FROM departments
INNER JOIN revenues
    ON departments.DepartmentID = revenues.DepartmentID
GROUP BY
    departments.DepartmentName,
    FORMAT(revenues.RevenueDate, 'yyyy-MM'),
    revenues.RevenueCategory;

GO
/*
Türkçe: Her departman için gider kategorilerini ve aylýk toplam gider tutarlarýný gösteren görünüm.
English: View that shows total monthly expenses per department and category.
*/
CREATE VIEW vw_ExpenseTrends AS
SELECT
    departments.DepartmentName,
    FORMAT(expenses.ExpenseDate, 'yyyy-MM') AS YearMonth,
    expenses.ExpenseCategory,
    SUM(expenses.Amount) AS TotalExpense
FROM departments
INNER JOIN expenses
    ON departments.DepartmentID = expenses.DepartmentID
GROUP BY
    departments.DepartmentName,
    FORMAT(expenses.ExpenseDate, 'yyyy-MM'),
    expenses.ExpenseCategory;

GO
/*
Türkçe: Her departman için toplam gelir, gider, net kâr ve iþlem sayýlarýný gösteren özet görünüm.
English: View that shows total revenue, total expense, net profit, and transaction counts per department.
*/
CREATE VIEW vw_DepartmentSummary AS
SELECT
    departments.DepartmentName,
    SUM(revenues.Amount) AS TotalRevenue,
    SUM(expenses.Amount) AS TotalExpense,
    SUM(revenues.Amount) - SUM(expenses.Amount) AS NetProfit,
    COUNT(DISTINCT revenues.RevenueID) AS RevenueTransactions,
    COUNT(DISTINCT expenses.ExpenseID) AS ExpenseTransactions
FROM departments
LEFT JOIN revenues
    ON departments.DepartmentID = revenues.DepartmentID
LEFT JOIN expenses
    ON departments.DepartmentID = expenses.DepartmentID
GROUP BY
    departments.DepartmentName;

GO
/*
Türkçe: Son 12 ayda en fazla gider yapan departmanlarý listeleyen görünüm.
English: View that lists the departments with the highest total expenses in the last 12 months.
*/
CREATE VIEW vw_TopSpendingDepartments AS
SELECT
    departments.DepartmentName,
    SUM(expenses.Amount) AS TotalExpense
FROM departments
INNER JOIN expenses
    ON departments.DepartmentID = expenses.DepartmentID
WHERE expenses.ExpenseDate >= DATEADD(MONTH, -12, GETDATE())
GROUP BY
    departments.DepartmentName

GO
/*
Türkçe: Her departman için aylýk kâr artýþ oranýný hesaplayan görünüm.
English: View that calculates the monthly profit growth rate per department.
*/
CREATE VIEW vw_ProfitGrowth AS
WITH MonthlyProfit AS (
    SELECT
        departments.DepartmentName,
        FORMAT(revenues.RevenueDate, 'yyyy-MM') AS YearMonth,
        SUM(revenues.Amount) - SUM(expenses.Amount) AS NetProfit
    FROM departments
    LEFT JOIN revenues
        ON departments.DepartmentID = revenues.DepartmentID
    LEFT JOIN expenses
        ON departments.DepartmentID = expenses.DepartmentID
        AND FORMAT(expenses.ExpenseDate, 'yyyy-MM') = FORMAT(revenues.RevenueDate, 'yyyy-MM')
    GROUP BY
        departments.DepartmentName,
        FORMAT(revenues.RevenueDate, 'yyyy-MM')
)
SELECT
    DepartmentName,
    YearMonth,
    NetProfit,
    LAG(NetProfit) OVER (PARTITION BY DepartmentName ORDER BY YearMonth) AS PreviousProfit,
    CASE 
        WHEN LAG(NetProfit) OVER (PARTITION BY DepartmentName ORDER BY YearMonth) = 0 THEN NULL
        ELSE ROUND(
            ((NetProfit - LAG(NetProfit) OVER (PARTITION BY DepartmentName ORDER BY YearMonth)) 
              / LAG(NetProfit) OVER (PARTITION BY DepartmentName ORDER BY YearMonth)) * 100, 2
        )
    END AS ProfitGrowthPercent
FROM MonthlyProfit;

GO
/*
Türkçe: Her departman için yýllýk toplam gelir, gider ve net kârý gösteren görünüm.
English: View that shows yearly total revenue, expense, and net profit per department.
*/
CREATE VIEW vw_YearlyComparison AS
SELECT
    departments.DepartmentName,
    YEAR(revenues.RevenueDate) AS Year,
    SUM(revenues.Amount) AS TotalRevenue,
    SUM(expenses.Amount) AS TotalExpense,
    SUM(revenues.Amount) - SUM(expenses.Amount) AS NetProfit
FROM departments
LEFT JOIN revenues
    ON departments.DepartmentID = revenues.DepartmentID
LEFT JOIN expenses
    ON departments.DepartmentID = expenses.DepartmentID
    AND YEAR(expenses.ExpenseDate) = YEAR(revenues.RevenueDate)
GROUP BY
    departments.DepartmentName,
    YEAR(revenues.RevenueDate)
