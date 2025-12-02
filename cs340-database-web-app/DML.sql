-- Group 71 Step 5 DML SQL
-- Online Bookstore Management System
-- Daniel Aguilar and Josh Goben
-- Queries used by the web application UI (Authors, Books, Customers,
-- Orders and Order Details).

/* ----------------------------------------------------------------------
AUTHORS PAGE QUERIES
---------------------------------------------------------------------- */

-- Select all authors
SELECT A.authorID AS id, A.fName, A.lName,
A.country, A.birthdate,
TIMESTAMPDIFF(YEAR, A.birthdate, CURDATE()) AS age 
FROM Authors A
ORDER BY A.lName;

-- Insert a new author
INSERT INTO `Authors` (fName, lName, country, birthdate)
VALUES (p_fName, p_lName, p_country, p_birthdate);




/* ----------------------------------------------------------------------
BOOKS PAGE QUERIES
---------------------------------------------------------------------- */

-- Select all books
SELECT B.bookID AS id, B.title,
CONCAT(Authors.fName, ' ', Authors.lName) AS authorName, B.genre, B.price, 
B.stockQuantity, B.publishYear, B.isbn 
FROM Books B
LEFT JOIN Authors ON B.authorID = Authors.authorID
ORDER BY B.title;

-- Insert a new book
INSERT INTO `Books` (title, authorID, genre, price, 
stockQuantity, publishYear, isbn)
VALUES (p_title, p_authorID, p_genre, p_price, 
p_stockQuantity, p_publishYear, p_isbn);




/* ----------------------------------------------------------------------
CUSTOMERS PAGE QUERIES
---------------------------------------------------------------------- */

-- Select all customers
SELECT C.customerID AS id, C.fName, C.lName,C.email, C.phoneNumber, 
C.city, C.state 
FROM Customers C;

-- Insert a new customer
INSERT INTO `Customers` (fName, lName, email, phoneNumber, city, state)
VALUES (p_fName, p_lName, p_email, p_phoneNumber, p_city, p_state);

-- Delete a customer
DELETE FROM Customers WHERE customerID = p_CustomerID;




/* ----------------------------------------------------------------------
ORDERS AND ORDER ITEMS PAGE QUERIES
---------------------------------------------------------------------- */

-- Select all orders
SELECT O.orderID, CONCAT(Customers.fName, ' ', Customers.lName) AS customerName, 
O.orderDate, O.totalAmount, O.paymentStatus
FROM Orders O
LEFT JOIN Customers ON O.customerID = Customers.customerID
ORDER BY O.orderID DESC;

-- View a single order with its details
SELECT O.orderID, O.orderDate, 
CONCAT(C.fName, ' ', C.lName) AS customerName, 
O.totalAmount, O.paymentStatus
FROM
    Orders AS O
    LEFT JOIN Customers AS C ON O.customerID = C.customerID
WHERE
    O.orderID = p_orderID;

-- View all line items for a single order
SELECT B.title, CONCAT(A.fName, ' ', A.lName) AS authorName, 
B.isbn, OI.quantity, B.price, OI.subtotal, OI.orderItemID
FROM
    Books AS B
    JOIN Authors AS A ON B.authorID = A.authorID
    RIGHT JOIN OrderItems AS OI ON B.bookID = OI.bookID
WHERE
    OI.orderID = p_orderID
ORDER BY OI.orderItemID;

-- View a single order item
SELECT
    OI.orderItemID,
    B.bookID,
    B.title,
    CONCAT(A.fName, ' ', A.lName) AS authorName,
    B.isbn,
    OI.quantity,
    B.price,
    OI.subtotal,
    O.orderID,
    O.orderDate,
    CONCAT(C.fName, ' ', C.lName) AS customerName
FROM
    OrderItems AS OI
    JOIN Orders AS O ON OI.orderID = O.orderID
    JOIN Customers AS C ON O.customerID = C.customerID
    JOIN Books AS B ON OI.bookID = B.bookID
    JOIN Authors AS A ON B.authorID = A.authorID
WHERE
    OI.orderItemID = p_orderItemID;

-- Insert a new order
INSERT INTO
    Orders (
        customerID,
        orderDate,
        paymentStatus
    )
VALUES (
        p_customerID,
        p_orderDate,
        p_paymentStatus
    );

-- Insert a new order line item onto an existing order
-- calculated_subtotal is calculated in the store procedure where this query is used
INSERT INTO
    OrderItems (
        orderID,
        bookID,
        quantity,
        subtotal
    )
VALUES (
        p_orderID,
        p_bookID,
        p_quantity,
        calculated_subtotal
    );

-- Update order total
UPDATE Orders
SET Orders.totalAmount = (SELECT SUM(subtotal) FROM OrderItems WHERE OrderItems.orderID = p_orderID)
WHERE Orders.orderID = p_orderID;

-- Update order item quantity and subtotal
-- calculated_subtotal is calculated in the store procedure where this query is used
UPDATE OrderItems
SET bookID = p_bookID,
    quantity = p_quantity,
    subtotal = calculated_subtotal
WHERE OrderItems.orderItemID = p_orderItemID;

-- Delete an order and all of its line items
DELETE FROM Orders WHERE Orders.orderID = p_orderID;




/* ----------------------------------------------------------------------
DEBUG
---------------------------------------------------------------------- */

-- Delete all order items
DELETE FROM OrderItems;
