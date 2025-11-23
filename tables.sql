-- Create database
CREATE DATABASE FinanceDB;
GO

-- Use database
USE FinanceDB;
GO

-- Creating Departments table
-- Departman bilgilerini tutar
CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR(50)
);

-- Creating Expenses table (linked to Departments)
-- Gider kayýtlarýný tutar, Departments tablosuna baðlýdýr
CREATE TABLE Expenses (
    ExpenseID INT PRIMARY KEY,
    DepartmentID INT,
    ExpenseDate DATE,
    ExpenseCategory VARCHAR(50),
    Amount DECIMAL(10,2),
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);

-- Creating Revenues table (linked to Departments)
-- Gelir kayýtlarýný tutar, Departments tablosuna baðlýdýr
CREATE TABLE Revenues (
    RevenueID INT PRIMARY KEY,
    DepartmentID INT,
    RevenueDate DATE,
    RevenueCategory VARCHAR(50),
    Amount DECIMAL(10,2),
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);

-- Import Departments CSV
BULK INSERT Departments
FROM 'C:\data\departments.csv'
WITH (
    FIRSTROW = 2,              -- Skip header row
    FIELDTERMINATOR = ',',     -- Columns separated by comma
    ROWTERMINATOR = '\r\n',    -- Windows line ending
    TABLOCK
);

-- Import Expenses CSV
BULK INSERT Expenses
FROM 'C:\data\expenses.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\r\n',
    TABLOCK
);

-- Import Revenues CSV
BULK INSERT Revenues
FROM 'C:\data\revenues.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\r\n',
    TABLOCK