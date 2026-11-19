-- SQL Sales Database Analysis
PRAGMA foreign_keys = ON;

CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    customer_name TEXT NOT NULL,
    city TEXT NOT NULL,
    signup_date TEXT NOT NULL
);
CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category TEXT NOT NULL,
    unit_price REAL NOT NULL CHECK (unit_price >= 0)
);
CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    order_date TEXT NOT NULL,
    status TEXT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
CREATE TABLE order_items (
    order_item_id INTEGER PRIMARY KEY,
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price REAL NOT NULL CHECK (unit_price >= 0),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO customers VALUES
(1,'Aarav Sharma','Bengaluru','2025-01-10'),
(2,'Diya Patel','Mumbai','2025-01-15'),
(3,'Rohan Verma','Delhi','2025-02-01'),
(4,'Ananya Rao','Bengaluru','2025-02-12'),
(5,'Kabir Singh','Hyderabad','2025-03-05'),
(6,'Meera Nair','Chennai','2025-03-18'),
(7,'Ishaan Gupta','Pune','2025-04-02'),
(8,'Sara Khan','Mumbai','2025-04-20');

INSERT INTO products VALUES
(101,'Laptop','Electronics',65000),(102,'Wireless Mouse','Accessories',1200),
(103,'Keyboard','Accessories',2500),(104,'Smartphone','Electronics',30000),
(105,'Office Chair','Furniture',8500),(106,'Desk','Furniture',12000),
(107,'Headphones','Electronics',4500),(108,'USB-C Hub','Accessories',2200);

INSERT INTO orders VALUES
(1001,1,'2025-05-01','Delivered'),(1002,2,'2025-05-03','Delivered'),
(1003,3,'2025-05-05','Cancelled'),(1004,1,'2025-05-12','Delivered'),
(1005,4,'2025-05-15','Delivered'),(1006,5,'2025-06-02','Shipped'),
(1007,6,'2025-06-08','Delivered'),(1008,2,'2025-06-11','Delivered'),
(1009,7,'2025-06-18','Pending'),(1010,8,'2025-06-22','Delivered'),
(1011,4,'2025-07-01','Delivered'),(1012,5,'2025-07-04','Delivered');

INSERT INTO order_items VALUES
(1,1001,101,1,65000),(2,1001,102,2,1200),(3,1002,104,1,30000),
(4,1002,107,1,4500),(5,1003,105,1,8500),(6,1004,103,2,2500),
(7,1004,108,1,2200),(8,1005,106,1,12000),(9,1005,105,2,8500),
(10,1006,101,1,65000),(11,1006,107,2,4500),(12,1007,102,3,1200),
(13,1007,103,1,2500),(14,1008,104,1,30000),(15,1008,108,2,2200),
(16,1009,105,1,8500),(17,1010,107,1,4500),(18,1010,102,1,1200),
(19,1011,101,1,65000),(20,1011,106,1,12000),(21,1012,103,2,2500),
(22,1012,108,2,2200);

-- 1. Revenue from delivered orders
SELECT ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue
FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'Delivered';

-- 2. Revenue by product
SELECT p.product_name, SUM(oi.quantity) AS units_sold,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'Delivered'
GROUP BY p.product_id, p.product_name
ORDER BY revenue DESC;

-- 3. Revenue by category
SELECT p.category, ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'Delivered'
GROUP BY p.category ORDER BY revenue DESC;

-- 4. Top customers
SELECT c.customer_name, c.city,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'Delivered'
GROUP BY c.customer_id, c.customer_name, c.city
ORDER BY total_spent DESC LIMIT 5;

-- 5. Monthly revenue
SELECT strftime('%Y-%m', o.order_date) AS order_month,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'Delivered'
GROUP BY strftime('%Y-%m', o.order_date)
ORDER BY order_month;
