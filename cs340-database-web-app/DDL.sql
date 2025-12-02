-- Group 71 Step 5 DDL SQL
-- Online Bookstore Management System
-- Daniel Aguilar and Josh Goben
-- Queries used to DROP existing tables, CREATE tables,
-- INSERT sample data to tables, and define TRIGGERS.

/* ----------------------------------------------------------
    DROP TABLES (in reverse FK order so drops succeed)
    This shouldn't be needed with foreign keys disabled, but
    this will help ensure success.
    ---------------------------------------------------------- */

DROP TABLE IF EXISTS OrderItems;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Books;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Authors;




/* ----------------------------------------------------------
    CREATE TABLES
    ---------------------------------------------------------- */

-- Create author table
CREATE TABLE Authors (
    authorID int(11) NOT NULL AUTO_INCREMENT,
    fName VARCHAR(50) NOT NULL,
    lName VARCHAR(50) NOT NULL,
    country VARCHAR(50),
    birthdate DATE,
    PRIMARY KEY (authorID)
);

-- Create customer table
CREATE TABLE Customers (
    customerID int(11) NOT NULL AUTO_INCREMENT,
    fName VARCHAR(50) NOT NULL,
    lName VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phoneNumber VARCHAR(15),
    city VARCHAR(50),
    state VARCHAR(50),
    UNIQUE (email),
    PRIMARY KEY (customerID)
);

-- Create books table
CREATE TABLE Books (
    bookID int(11) NOT NULL AUTO_INCREMENT,
    title VARCHAR(150) NOT NULL,
    authorID int(11) NOT NULL,
    genre VARCHAR(50),
    price DECIMAL(6,2) NOT NULL,
    stockQuantity INT NOT NULL,
    publishYear YEAR,
    isbn VARCHAR(20) NOT NULL,
    UNIQUE (isbn),
    PRIMARY KEY (bookID),
    FOREIGN KEY (authorID) REFERENCES Authors(authorID)
);

-- Create orders table
CREATE TABLE Orders (
    orderID INT(11) NOT NULL AUTO_INCREMENT,
    customerID INT(11),
    orderDate DATE NOT NULL,
    totalAmount DECIMAL(8,2) NOT NULL DEFAULT 0.00,
    paymentStatus VARCHAR(20),
    PRIMARY KEY (orderID),
    FOREIGN KEY (customerID) REFERENCES Customers(customerID) 
    ON DELETE SET NULL
);

-- Create orderItems table
CREATE TABLE OrderItems (
    orderItemID INT(11) NOT NULL AUTO_INCREMENT,
    orderID INT(11) NOT NULL,
    bookID INT(11) NOT NULL,
    quantity INT(4) NOT NULL,
    subtotal DECIMAL(8,2) NOT NULL,
    PRIMARY KEY (orderItemID, orderID, bookID),
    FOREIGN KEY (orderID) REFERENCES Orders(orderID)
    ON DELETE CASCADE,
    FOREIGN KEY (bookID) REFERENCES Books(bookID)
    ON DELETE CASCADE
);




/* ----------------------------------------------------------
    INSERT SAMPLE DATA
    ---------------------------------------------------------- */

-- INSERT to Authors table
INSERT INTO Authors (fName, lName, country, birthdate)
VALUES
    ("Nora Keita (N.K.)", "Jemisin", "USA", '1972-09-19'),
    ("Brandon", "Sanderson", NULL, '1975-12-19'),
    ("J.R.R.", "Tolkein", "United Kingdom", NULL);

-- INSERT to Customers table
INSERT INTO Customers (fName, lName, email, phoneNumber, city, state)
VALUES
    ("Ford", "Prefect", "hoopy@frood.com", '555-555-1234', "Las Vegas", "Nevada"),
    ("Bob", "Ross", "happy@littletrees.com", NULL, "Orlando", "Florida"),
    ("Bene", "Gesserit", "secret@sisterhood.org", NULL, NULL, NULL);

-- INSERT to Books table
INSERT INTO Books (title, authorID, genre, price, stockQuantity, publishYear, isbn)
VALUES
    (
        "Mistborn: The Final Empire",
        (SELECT authorID FROM Authors
            WHERE fName = "Brandon" AND lName = "Sanderson"),
        "Fantasy",
        26.99,
        17,
        '2006',
        "0-7653-1178-X"
    ),
    (
        "The Fifth Season",
        (SELECT authorID FROM Authors
            WHERE fName = "Nora Keita (N.K.)" AND lName = "Jemisin"),
        NULL,
        35.00,
        99,
        '2015',
        "978-0-356-50819-1"
    ),
    (
        "White Sand I",
        (SELECT authorID FROM Authors
            WHERE fName = "Brandon" AND lName = "Sanderson"),
        "Graphic Novel",
        53.00,
        22,
        NULL,
        "978-1606908853"
    ),
    (
        "The Hobbit",
        (SELECT authorID FROM Authors
            WHERE fName = "J.R.R." AND lName = "Tolkein"),
        NULL,
        19.99,
        97,
        NULL,
        "978-0547928227"
    );

-- INSERT to Orders table
INSERT INTO Orders (customerID, orderDate, totalAmount, paymentStatus)
VALUES
    ((SELECT customerID FROM Customers
        WHERE fName = "Ford" AND lName = "Prefect"),
        '2023-01-02', 19.99, NULL),
    ((SELECT customerID FROM Customers
        WHERE fName = "Bob" AND lName = "Ross"),
        '2024-03-14', 79.99, "Paid"),
    ((SELECT customerID FROM Customers
        WHERE fName = "Bene" AND lName = "Gesserit"),
        '2025-08-08', 105.00, "Pending");

-- INSERT to OrderItems table
INSERT INTO OrderItems (orderID, bookID, quantity, subtotal)
VALUES
    (
        (SELECT orderID FROM Orders
            WHERE customerID = (SELECT customerID FROM Customers
                                WHERE fName = "Ford" AND lName = "Prefect")),
        (SELECT bookID FROM Books WHERE isbn = "978-0547928227"),
        1,
        '19.99'
    ),
    (
        (SELECT orderID FROM Orders
            WHERE customerID = (SELECT customerID FROM Customers
                                WHERE fName = "Bob" AND lName = "Ross")),
        (SELECT bookID FROM Books WHERE isbn = "0-7653-1178-X"),
        '1',
        '26.99'
    ),
    (
        (SELECT orderID FROM Orders
            WHERE customerID = (SELECT customerID FROM Customers
                                WHERE fName = "Bob" AND lName = "Ross")),
        (SELECT bookID FROM Books WHERE isbn = "978-1606908853"),
        '1',
        '53.00'
    ),
    (
        (SELECT orderID FROM Orders
            WHERE customerID = (SELECT customerID FROM Customers
                                WHERE fName = "Bene" AND lName = "Gesserit")),
        (SELECT bookID FROM Books WHERE isbn = "978-0-356-50819-1"),
        '3',
        '105.00'
    );
    

    
    
/* ----------------------------------------------------------
    CREATE TRIGGERS
    -- Cited on 29 November 2025 from:
    -- https://dev.mysql.com/doc/refman/8.4/en/trigger-syntax.html
    ---------------------------------------------------------- */

/* ----------------------------------------------------------------------
trig_update_order_total_after_insert

Updates an Order with a new total amount after INSERTING a new OrderItem
---------------------------------------------------------------------- */
DROP TRIGGER IF EXISTS trig_update_order_total_after_insert;

DELIMITER //

CREATE TRIGGER trig_update_order_total_after_insert
AFTER INSERT ON OrderItems
FOR EACH ROW
BEGIN
    CALL sp_update_order_total(NEW.orderID);
END //

DELIMITER ;




/* ----------------------------------------------------------------------
trig_update_order_total_after_update

Updates an Order with a new total amount after UPDATING a new OrderItem
---------------------------------------------------------------------- */
DROP TRIGGER IF EXISTS trig_update_order_total_after_update;

DELIMITER //

CREATE TRIGGER trig_update_order_total_after_update
AFTER UPDATE ON OrderItems
FOR EACH ROW
BEGIN
    CALL sp_update_order_total(NEW.orderID);
END //

DELIMITER ;




/* ----------------------------------------------------------------------
trig_update_order_total_after_delete

Updates an Order with a new total amount after DELETING a new OrderItem
---------------------------------------------------------------------- */
DROP TRIGGER IF EXISTS trig_update_order_total_after_delete;

DELIMITER //

CREATE TRIGGER trig_update_order_total_after_delete
AFTER DELETE ON OrderItems
FOR EACH ROW
BEGIN
    CALL sp_update_order_total(OLD.orderID);
END //

DELIMITER ;