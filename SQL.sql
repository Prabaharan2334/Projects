create database canteen;
use canteen;
-- Students table
CREATE TABLE Students (
    StudentID VARCHAR(10) PRIMARY KEY,
    Name VARCHAR(50),
    Department VARCHAR(50),
    Year INT,
    JoinDate DATE
);
-- Food Menu
CREATE TABLE FoodMenu (
    ItemID VARCHAR(10) PRIMARY KEY,
    ItemName VARCHAR(50),
    Category VARCHAR(20),
    Price DECIMAL(5, 2)
);
-- Orders table
CREATE TABLE Orders (
    OrderID VARCHAR(10) PRIMARY KEY,
    StudentID VARCHAR(10),
    OrderDate DATETIME,
    TotalAmount DECIMAL(7, 2),
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID)
);
-- Order Details
CREATE TABLE OrderDetails (
    OrderID VARCHAR(10),
    ItemID VARCHAR(10),
    Quantity INT,
    Price DECIMAL(5,2),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ItemID) REFERENCES FoodMenu(ItemID)
);

-- Students
INSERT INTO Students VALUES 
('S001', 'Prabhu', 'IT', 4, '2021-08-01'),
('S002', 'Kiran', 'CSE', 3, '2022-06-15'),
('S003', 'Meena', 'ECE', 2, '2023-07-01');

-- Food Menu
INSERT INTO FoodMenu VALUES 
('F001', 'Chicken Roll', 'Non-Veg', 60.00),
('F002', 'Veg Sandwich', 'Veg', 30.00),
('F003', 'Cold Coffee', 'Beverage', 40.00),
('F004', 'Egg Puff', 'Non-Veg', 25.00),
('F005', 'Lemon Tea', 'Beverage', 15.00);

-- Orders
INSERT INTO Orders VALUES 
('O001', 'S001', '2025-06-05 09:15:00', 90.00),
('O002', 'S001', '2025-06-06 13:05:00', 60.00),
('O003', 'S002', '2025-06-05 17:30:00', 40.00),
('O004', 'S003', '2025-06-05 10:45:00', 55.00);

-- Order Details
INSERT INTO OrderDetails VALUES 
('O001', 'F001', 1, 60.00),
('O001', 'F002', 1, 30.00),
('O002', 'F003', 1, 40.00),
('O002', 'F005', 1, 20.00),
('O003', 'F003', 1, 40.00),
('O004', 'F002', 1, 30.00),
('O004', 'F004', 1, 25.00);

SELECT 
    s.Department,
    f.ItemName,
    COUNT(*) AS OrderCount
FROM Orders o
JOIN Students s ON o.StudentID = s.StudentID
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN FoodMenu f ON od.ItemID = f.ItemID
GROUP BY s.Department, f.ItemName
ORDER BY s.Department, OrderCount DESC;

SELECT 
    HOUR(OrderDate) AS Hour,
    COUNT(*) AS Orders
FROM Orders
GROUP BY Hour
ORDER BY Orders DESC;

SELECT 
    StudentID,
    COUNT(OrderID) AS TotalOrders,
    CASE 
        WHEN COUNT(OrderID) > 1 THEN 'Frequent Buyer'
        ELSE 'Occasional Buyer'
    END AS BuyerType
FROM Orders
GROUP BY StudentID;

SELECT 
    StudentID,
    DATE_FORMAT(OrderDate, '%Y-%m') AS Month,
    ROUND(AVG(TotalAmount), 2) AS AvgMonthlySpend
FROM Orders
GROUP BY StudentID, Month
ORDER BY StudentID, Month;
DELIMITER $$

CREATE PROCEDURE AddNewOrder(
    IN p_OrderID VARCHAR(10),
    IN p_StudentID VARCHAR(10),
    IN p_OrderDate DATETIME,
    IN p_Item1ID VARCHAR(10),
    IN p_Quantity1 INT,
    IN p_Item2ID VARCHAR(10),
    IN p_Quantity2 INT
)
BEGIN
    DECLARE item1_price, item2_price DECIMAL(5,2);
    DECLARE total_price DECIMAL(7,2);
    
    -- Get item prices
    SELECT Price INTO item1_price FROM FoodMenu WHERE ItemID = p_Item1ID;
    SELECT Price INTO item2_price FROM FoodMenu WHERE ItemID = p_Item2ID;
    
    -- Calculate total
    SET total_price = (item1_price * p_Quantity1) + (item2_price * p_Quantity2);
    
    -- Insert into Orders
    INSERT INTO Orders (OrderID, StudentID, OrderDate, TotalAmount)
    VALUES (p_OrderID, p_StudentID, p_OrderDate, total_price);
    
    -- Insert into OrderDetails
    INSERT INTO OrderDetails (OrderID, ItemID, Quantity, Price)
    VALUES 
    (p_OrderID, p_Item1ID, p_Quantity1, item1_price),
    (p_OrderID, p_Item2ID, p_Quantity2, item2_price);
    
END $$

DELIMITER ;



