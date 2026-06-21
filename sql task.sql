

CREATE DATABASE abc_inc;
USE abc_inc;

SET SQL_SAFE_UPDATES = 0;



CREATE TABLE Departments (
    DeptId   INT AUTO_INCREMENT PRIMARY KEY,
    DeptName VARCHAR(100) NOT NULL
);

CREATE TABLE Employees (
    EmpId     INT AUTO_INCREMENT PRIMARY KEY,
    FullName  VARCHAR(100) NOT NULL,
    DeptId    INT NULL,
    ManagerId INT NULL,
    HireDate  DATE NOT NULL,
    IsActive  TINYINT(1) NOT NULL DEFAULT 1,
    CONSTRAINT fk_emp_dept    FOREIGN KEY (DeptId)    REFERENCES Departments(DeptId),
    CONSTRAINT fk_emp_manager FOREIGN KEY (ManagerId) REFERENCES Employees(EmpId)
);

CREATE TABLE Salaries (
    SalaryId   INT AUTO_INCREMENT PRIMARY KEY,
    EmpId      INT NOT NULL,
    Amount     DECIMAL(12,2) NOT NULL,
    SalaryType ENUM('Monthly','Annual') NOT NULL,
    CONSTRAINT fk_sal_emp FOREIGN KEY (EmpId) REFERENCES Employees(EmpId)
);

CREATE TABLE Projects (
    ProjectId   INT AUTO_INCREMENT PRIMARY KEY,
    ProjectName VARCHAR(100) NOT NULL
);

CREATE TABLE ProjectAssignments (
    AssignmentId INT AUTO_INCREMENT PRIMARY KEY,
    EmpId        INT NOT NULL,
    ProjectId    INT NOT NULL,
    HoursLogged  DECIMAL(8,2) NOT NULL DEFAULT 0,
    CONSTRAINT fk_pa_emp     FOREIGN KEY (EmpId)     REFERENCES Employees(EmpId),
    CONSTRAINT fk_pa_project FOREIGN KEY (ProjectId) REFERENCES Projects(ProjectId)
);


INSERT INTO Departments (DeptName) VALUES
('Engineering'), ('Sales'), ('Human Resources'), ('Marketing'), ('Research');


INSERT INTO Employees (FullName, DeptId, ManagerId, HireDate, IsActive) VALUES
('Alice Johnson', 1, NULL, '2015-03-01', 1),  
('Bob Smith',     1, 1,    '2018-06-15', 1),
('Carol White',   1, 1,    '2019-01-10', 1),
('David Brown',   2, 1,    '2020-09-01', 1),
('Eve Davis',     2, 4,    '2021-02-20', 1),   
('Frank Miller',  3, NULL, '2017-11-05', 1),   
('Grace Lee',     4, 6,    '2022-07-01', 1),    
('Henry Wilson',  1, 1,    '2023-04-12', 0);   

INSERT INTO Salaries (EmpId, Amount, SalaryType) VALUES
(1, 12000, 'Monthly'), (2, 90000, 'Annual'), (3, 7000, 'Monthly'),
(4, 80000, 'Annual'),  (6, 6000,  'Monthly'), (8, 75000, 'Annual');


INSERT INTO Projects (ProjectName) VALUES
('Apollo'), ('Zephyr'), ('Orion'), ('Nimbus'), ('Helios');
-- Helios (5) will have nobody.

INSERT INTO ProjectAssignments (EmpId, ProjectId, HoursLogged) VALUES
(1,1,120), (2,1,100), (3,1,80), (4,1,60),  
(2,2,40),  (5,2,30),                        
(6,3,50),                                   
(1,4,25);                                   




-- TASK 1 — employee & salary 
SELECT e.FullName, d.DeptName, s.Amount AS Salary, s.SalaryType
FROM Employees e
LEFT JOIN Departments d ON e.DeptId = d.DeptId
LEFT JOIN Salaries    s ON e.EmpId  = s.EmpId
ORDER BY e.FullName;

-- TASK 2 — Dept count (include zero-employee depts)

SELECT d.DeptName, COUNT(e.EmpId) AS EmployeeCount
FROM Departments d
LEFT JOIN Employees e ON d.DeptId = e.DeptId
GROUP BY d.DeptId, d.DeptName
ORDER BY EmployeeCount DESC;

-- TASK 3 — Unassigned employees
SELECT e.FullName, d.DeptName, e.HireDate
FROM Employees e
LEFT JOIN Departments d ON e.DeptId = d.DeptId
left join ProjectAssignments pa on e.EmpId = pa.EmpId
WHERE pa.AssignmentId is null; 

-- TASK 4 — Department salary summary
SELECT d.DeptName,
       SUM(s.Amount)           AS TotalSalary,
       AVG(s.Amount)           AS AvgSalary,
       COUNT(DISTINCT e.EmpId) AS EmployeeCount
FROM Departments d
LEFT JOIN Employees e ON d.DeptId = e.DeptId
LEFT JOIN Salaries  s ON e.EmpId  = s.EmpId
GROUP BY d.DeptId, d.DeptName
ORDER BY TotalSalary DESC;

-- TASK 5 — Employee & manager
SELECT e.FullName AS Employee, m.FullName AS Manager
FROM Employees e
LEFT JOIN Employees m ON e.ManagerId = m.EmpId
ORDER BY e.FullName;

-- TASK 6 — High-participation 
SELECT p.ProjectName,
       COUNT(pa.EmpId)     AS EmployeeCount,
       SUM(pa.HoursLogged) AS TotalHours
FROM Projects p
JOIN ProjectAssignments pa ON p.ProjectId = pa.ProjectId
GROUP BY p.ProjectId, p.ProjectName
HAVING COUNT(pa.EmpId) > 3
ORDER BY TotalHours DESC;

-- TASK 7 — Dept

SELECT d.DeptName, p.ProjectName, COUNT(pa.EmpId) AS EmployeeCount
FROM Departments d
CROSS JOIN Projects p
LEFT JOIN Employees e           ON e.DeptId = d.DeptId
LEFT JOIN ProjectAssignments pa ON pa.EmpId = e.EmpId AND pa.ProjectId = p.ProjectId
GROUP BY d.DeptId, d.DeptName, p.ProjectId, p.ProjectName
ORDER BY d.DeptName, p.ProjectName;

-- =====================================================================
--  PART 2 — Functions, Procedures, Transactions
DELIMITER //
CREATE FUNCTION fn_get_emp_tenure(p_emp_id INT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_hire DATE;
    SELECT HireDate INTO v_hire FROM Employees WHERE EmpId = p_emp_id;
    RETURN TIMESTAMPDIFF(YEAR, v_hire, CURDATE());
END //
DELIMITER ;


SELECT FullName, fn_get_emp_tenure(EmpId) AS TenureYears FROM Employees;

-- TASK 9 —
DELIMITER //
CREATE FUNCTION fn_annual_salary(p_emp_id INT)
RETURNS DECIMAL(12,2)
READS SQL DATA
BEGIN
    DECLARE v_annual DECIMAL(12,2);   -- defaults to NULL if no row found
    SELECT CASE WHEN SalaryType = 'Monthly' THEN Amount * 12 ELSE Amount END
      INTO v_annual
    FROM Salaries WHERE EmpId = p_emp_id;
    RETURN COALESCE(v_annual, 0);     -- Eve & Grace -> 0
END //
DELIMITER ;

-- test
SELECT FullName, fn_annual_salary(EmpId) AS AnnualSalary FROM Employees;

-- TASK 10 — "Department employee list" for ALL departments

CREATE VIEW vw_dept_employees AS
SELECT d.DeptId, d.DeptName, e.EmpId, e.FullName,
       fn_annual_salary(e.EmpId)  AS AnnualSalary,
       fn_get_emp_tenure(e.EmpId) AS TenureYears
FROM Departments d
JOIN Employees e ON e.DeptId = d.DeptId;

SELECT * FROM vw_dept_employees ORDER BY DeptName, FullName;


SELECT d.DeptName, f.FullName, f.AnnualSalary, f.TenureYears
FROM Departments d
JOIN LATERAL (
    SELECT e.FullName,
           fn_annual_salary(e.EmpId)  AS AnnualSalary,
           fn_get_emp_tenure(e.EmpId) AS TenureYears
    FROM Employees e
    WHERE e.DeptId = d.DeptId
) f
ORDER BY d.DeptName, f.FullName;

-- TASK 11 — Stored procedure: dept salary report
-- Returns a result set AND scalar values via OUT params.
-- Uses fn_annual_salary so totals are correctly normalized.
DELIMITER //
CREATE PROCEDURE sp_dept_salary_report(
    IN  p_dept   INT,
    OUT p_count  INT,
    OUT p_total  DECIMAL(12,2),
    OUT p_avg    DECIMAL(12,2),
    OUT p_top    VARCHAR(100)
)
BEGIN
    -- result set: employees in the department, by salary desc
    SELECT e.FullName, fn_annual_salary(e.EmpId) AS AnnualSalary
    FROM Employees e
    WHERE e.DeptId = p_dept
    ORDER BY AnnualSalary DESC;

    -- aggregates -> OUT params
    SELECT COUNT(*),
           SUM(fn_annual_salary(e.EmpId)),
           AVG(fn_annual_salary(e.EmpId))
      INTO p_count, p_total, p_avg
    FROM Employees e
    WHERE e.DeptId = p_dept;

    -- highest earner name -> OUT param
    SELECT e.FullName
      INTO p_top
    FROM Employees e
    WHERE e.DeptId = p_dept
    ORDER BY fn_annual_salary(e.EmpId) DESC
    LIMIT 1;
END //
DELIMITER ;


CALL sp_dept_salary_report(1, @cnt, @total, @avg, @top);
SELECT @cnt AS EmpCount, @total AS TotalSalary, @avg AS AvgSalary, @top AS TopEarner;

-- TASK 12 — 
DELIMITER //
CREATE PROCEDURE sp_give_raise(
    IN p_dept    INT,
    IN p_percent DECIMAL(5,2)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;   -- propagate the original error message to the caller
    END;

    IF p_percent < 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Percentage cannot be negative.';
    END IF;

    START TRANSACTION;
        UPDATE Salaries s
        JOIN Employees e ON s.EmpId = e.EmpId
        SET s.Amount = s.Amount * (1 + p_percent / 100.0)
        WHERE e.DeptId = p_dept AND e.IsActive = 1;
    COMMIT;

    SELECT 'Raise applied successfully.' AS Status;
END //
DELIMITER ;

-- test: 10% raise for Engineering
CALL sp_give_raise(1, 10);
SELECT e.FullName, s.Amount, s.SalaryType
FROM Employees e JOIN Salaries s ON e.EmpId = s.EmpId
WHERE e.DeptId = 1;
