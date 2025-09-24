CREATE TABLE Customers (
    Customer_ID SERIAL PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Age INT,
    Gender VARCHAR(10) CHECK (Gender IN ('Male', 'Female', 'Other')),
    City VARCHAR(100),
    Registration_Date DATE,
    Total_Spent DECIMAL(10,2) DEFAULT 0.00,
    Purchase_Frequency INT DEFAULT 0
);


CREATE TABLE Products (
    Product_ID SERIAL PRIMARY KEY,
    Product_Name VARCHAR(255) NOT NULL,
    Category VARCHAR(100),
    Price DECIMAL(10,2) NOT NULL,
    Stock_Quantity INT NOT NULL
);


CREATE TABLE Orders (
    Order_ID SERIAL PRIMARY KEY,
    Customer_ID INT,
    Product_ID INT,
    Order_Date DATE,
    Quantity INT NOT NULL,
    Total_Amount DECIMAL(10,2) NOT NULL,
    Order_Status VARCHAR(20) CHECK (Order_Status IN ('Pending', 'Shipped', 'Delivered', 'Cancelled')) DEFAULT 'Pending',
    FOREIGN KEY (Customer_ID) REFERENCES Customers(Customer_ID) ON DELETE CASCADE,
    FOREIGN KEY (Product_ID) REFERENCES Products(Product_ID) ON DELETE CASCADE
);



copy customers (Customer_ID, Name, Age, Gender, City, Registration_Date, Total_Spent, Purchase_Frequency)
FROM 'C:/Users/ASUS/Documents/Data/SwiftCart_Data.csv' DELIMITER ';' CSV HEADER


COPY Products (Product_ID, Product_Name, Category, Price, Stock_Quantity)
FROM 'C:/Users/ASUS/Documents/Data/Products (2).csv'
DELIMITER ';' CSV HEADER;

COPY Orders (Order_ID, Customer_ID, Product_ID, Order_Date, Quantity, Total_Amount, Order_Status)
FROM 'C:/Users/ASUS/Documents/Data/Orders (2).csv' 
DELIMITER ';' CSV HEADER;


ALTER ROLE postgres SUPERUSER;

SELECT conname, consrc 
FROM pg_constraint 
WHERE conrelid = 'orders'::regclass;




ALTER TABLE Orders DROP CONSTRAINT orders_order_status_check;

ALTER TABLE Orders ADD CONSTRAINT orders_order_status_check 
CHECK (Order_Status IN ('Completed', 'Pending', 'Shipped', 'Delivered'));

COPY Orders (Order_ID, Customer_ID, Product_ID, Order_Date, Quantity, Total_Amount, Order_Status)
FROM 'C:/Users/ASUS/Documents/Data/Orders (2).csv' 
DELIMITER ';' CSV HEADER;



ALTER TABLE Orders DROP CONSTRAINT orders_order_status_check;


ALTER TABLE Orders ADD CONSTRAINT orders_order_status_check 
CHECK (Order_Status IN ('Completed', 'Pending', 'Shipped', 'Delivered'));


SELECT p.Product_Name, SUM(o.Quantity) AS Total_Quantity_Sold
FROM Orders o
JOIN Products p ON o.Product_ID = p.Product_ID
GROUP BY p.Product_Name
ORDER BY Total_Quantity_Sold DESC
LIMIT 10;


SELECT c.Name AS Customer_Name, SUM(o.Total_Amount) AS Total_Spent
FROM Orders o
JOIN Customers c ON o.Customer_ID = c.Customer_ID
GROUP BY c.Name
ORDER BY Total_Spent DESC;


SELECT 
    EXTRACT(YEAR FROM o.Order_Date) AS Year,
    EXTRACT(MONTH FROM o.Order_Date) AS Month,
    SUM(o.Total_Amount) AS Total_Sales
FROM Orders o
GROUP BY Year, Month
ORDER BY Year DESC, Month DESC;
