-- Group 71 Step 5 PL SQL
-- Online Bookstore Management System
-- Daniel Aguilar and Josh Goben
-- Combined Stored Procedures used by the web application 




###############################################################################
##################### AUTHORS SECTION

/* ----------------------------------------------------------------------
sp_select_authors

Get all Authors from the Authors table
---------------------------------------------------------------------- */
-- Remove the old procedure if it exists
DROP PROCEDURE IF EXISTS sp_select_authors;

DELIMITER //

CREATE PROCEDURE sp_select_authors()

BEGIN
    SELECT A.authorID AS id, A.fName, A.lName,
    A.country, A.birthdate,
    TIMESTAMPDIFF(YEAR, A.birthdate, CURDATE()) AS age 
    FROM Authors A
    ORDER BY A.lName;
END //

DELIMITER ;




/* ----------------------------------------------------------------------
sp_insert_author

Insert a new author
Citation: Used from PL/SP CUD Exploration example code
---------------------------------------------------------------------- */
DROP PROCEDURE IF EXISTS sp_insert_author;

DELIMITER //

CREATE PROCEDURE sp_insert_author (
    IN p_fName VARCHAR(50),
    IN p_lName VARCHAR(50),
    IN p_country VARCHAR(50),
    IN p_birthdate DATE,
    OUT p_NewAuthorID INT
)
COMMENT 'Insert new Author and return new id.'
BEGIN
    INSERT INTO `Authors` (fName, lName, country, birthdate)
    VALUES (p_fName, p_lName, p_country, p_birthdate);
    
    SET p_NewAuthorID = LAST_INSERT_ID();
END //

DELIMITER ;




###############################################################################
##################### BOOKS SECTION

/* ----------------------------------------------------------------------
sp_select_books

Get all Books from the Books table
---------------------------------------------------------------------- */
-- Remove the old procedure if it exists
DROP PROCEDURE IF EXISTS sp_select_books;

DELIMITER //

CREATE PROCEDURE sp_select_books()

BEGIN
    SELECT B.bookID AS id, B.title,
    CONCAT(Authors.fName, ' ', Authors.lName) AS authorName, B.genre, B.price, 
    B.stockQuantity, B.publishYear, B.isbn 
    FROM Books B
    LEFT JOIN Authors ON B.authorID = Authors.authorID
    ORDER BY B.title;
END //

DELIMITER ;



/* ----------------------------------------------------------------------
sp_insert_book

Insert a new book
---------------------------------------------------------------------- */
DROP PROCEDURE IF EXISTS sp_insert_book;

DELIMITER //

CREATE PROCEDURE sp_insert_book (
    IN p_title VARCHAR(150),
    IN p_authorID int(11),
    IN p_genre VARCHAR(50),
    IN p_price DECIMAL(6,2),
    IN p_stockQuantity INT,
    IN p_publishYear YEAR,
    IN p_isbn VARCHAR(20),
    OUT p_NewBookID INT
)
COMMENT 'Insert new Book and return new id.'
BEGIN
    INSERT INTO `Books` (title, authorID, genre, price, 
    stockQuantity, publishYear, isbn)
    VALUES (p_title, p_authorID, p_genre, p_price, 
    p_stockQuantity, p_publishYear, p_isbn);
    
    SET p_NewBookID = LAST_INSERT_ID();
END //

DELIMITER ;




###############################################################################
##################### CUSTOMERS SECTION

/* ----------------------------------------------------------------------
sp_select_customers

Get all Customers from the Customers table
---------------------------------------------------------------------- */
-- Remove the old procedure if it exists
DROP PROCEDURE IF EXISTS sp_select_customers;

DELIMITER //

CREATE PROCEDURE sp_select_customers()

BEGIN
    SELECT C.customerID AS id, C.fName, C.lName,C.email, C.phoneNumber, 
    C.city, C.state 
    FROM Customers C;
END //

DELIMITER ;




/* ----------------------------------------------------------------------
sp_insert_customer

Insert a new customer
---------------------------------------------------------------------- */
DROP PROCEDURE IF EXISTS sp_insert_customer;

DELIMITER //

CREATE PROCEDURE sp_insert_customer (
    IN p_fName VARCHAR(50),
    IN p_lName VARCHAR(50),
    IN p_email VARCHAR(100),
    IN p_phoneNumber VARCHAR(15),
    IN p_city VARCHAR(50),
    IN p_state VARCHAR(50),
    OUT p_NewCustomerID INT
)
COMMENT 'Insert new Customer and return new id.'
BEGIN
    INSERT INTO `Customers` (fName, lName, email, phoneNumber, city, state)
    VALUES (p_fName, p_lName, p_email, p_phoneNumber, p_city, p_state);
    
    SET p_NewCustomerID = LAST_INSERT_ID();
END //

DELIMITER ;




/* ----------------------------------------------------------------------
sp_delete_customer

Delete a new customer
Adopted from Exploration: PL/SQL part 2, Stored Procedures for CUD 
on 29 November 2025
---------------------------------------------------------------------- */
DROP PROCEDURE IF EXISTS sp_delete_customer;

DELIMITER //

CREATE PROCEDURE sp_delete_customer(
    IN p_CustomerID INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Rollback the transaction in case of any error
        ROLLBACK;
        SELECT 'Error! Customer not deleted.' AS Result;
    END;

    -- Start the transaction
    START TRANSACTION;

    -- Check if the customer exists
    IF EXISTS (SELECT 1 FROM Customers WHERE customerID = p_CustomerID) THEN
        -- Delete from movie-Rentals table
        DELETE FROM Customers WHERE customerID = p_CustomerID;

        -- Commit the transaction
        COMMIT;

        -- Return success message
        SELECT 'Customer deleted' AS Result;
    ELSE
        -- Rollback the transaction if customer does not exist
        ROLLBACK;
        SELECT 'Error! Customer not deleted.' AS Result;
    END IF;
END //

DELIMITER ;




###############################################################################
##################### ORDERS SECTION

/* ----------------------------------------------------------------------
sp_select_orders

Browse all orders with customer name
---------------------------------------------------------------------- */
DROP PROCEDURE IF EXISTS sp_select_orders;

DELIMITER //

CREATE PROCEDURE sp_select_orders()

BEGIN
    SELECT O.orderID, CONCAT(Customers.fName, ' ', Customers.lName) AS customerName, 
    O.orderDate, O.totalAmount, O.paymentStatus
    FROM Orders O
    LEFT JOIN Customers ON O.customerID = Customers.customerID
    ORDER BY O.orderID DESC;
END //

DELIMITER ;




/* ----------------------------------------------------------------------
sp_select_orderDetails

View a single order and its line items
This is used on the Order Details page
---------------------------------------------------------------------- */
DROP PROCEDURE IF EXISTS sp_select_orderDetails;

DELIMITER //

CREATE PROCEDURE sp_select_orderDetails (
    IN p_orderID INT
)

BEGIN
    SELECT O.orderID, O.orderDate, 
    CONCAT(C.fName, ' ', C.lName) AS customerName, 
    O.totalAmount, O.paymentStatus
    FROM
        Orders AS O
        LEFT JOIN Customers AS C ON O.customerID = C.customerID
    WHERE
        O.orderID = p_orderID;
END //

DELIMITER ;




/* ----------------------------------------------------------------------
sp_select_orderItems

View a single order and its line items
This is used on the Order Details page
---------------------------------------------------------------------- */
DROP PROCEDURE IF EXISTS sp_select_orderItems;

DELIMITER //

CREATE PROCEDURE sp_select_orderItems (
    IN p_orderID INT
)

BEGIN
    SELECT B.title, CONCAT(A.fName, ' ', A.lName) AS authorName, 
    B.isbn, OI.quantity, B.price, OI.subtotal, OI.orderItemID
    FROM
        Books AS B
        JOIN Authors AS A ON B.authorID = A.authorID
        RIGHT JOIN OrderItems AS OI ON B.bookID = OI.bookID
    WHERE
        OI.orderID = p_orderID
    ORDER BY OI.orderItemID;
END //

DELIMITER ;




/* ----------------------------------------------------------------------
sp_select_orderItem

View a single order item 
This is used on the Edit Order Item
---------------------------------------------------------------------- */
DROP PROCEDURE IF EXISTS sp_select_orderItem;

DELIMITER //

CREATE PROCEDURE sp_select_orderItem (
    IN p_orderItemID INT
)

BEGIN
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
END //

DELIMITER ;




/* ----------------------------------------------------------------------
sp_insert_order

Insert a new order
---------------------------------------------------------------------- */
DROP PROCEDURE IF EXISTS sp_insert_order;

DELIMITER //

CREATE PROCEDURE sp_insert_order (
    IN p_customerID INT,
    IN p_orderDate VARCHAR(50),
    IN p_paymentStatus VARCHAR(20),
    OUT p_NewOrderID INT
)
COMMENT 'Insert new Order and return new id.'
BEGIN
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

    SET p_NewOrderID = LAST_INSERT_ID();
END //

DELIMITER ;




/* ----------------------------------------------------------------------
sp_insert_orderItem

Insert a new order line item onto an existing order
---------------------------------------------------------------------- */
DROP PROCEDURE IF EXISTS sp_insert_orderItem;

DELIMITER //

CREATE PROCEDURE sp_insert_orderItem (
    IN p_orderID INT,
    IN p_bookID INT,
    IN p_quantity INT,
    OUT p_NewOrderItemID INT
)
COMMENT 'Insert new Order Item and return new id.'
BEGIN
 
    DECLARE book_price DECIMAL(6,2);
    DECLARE calculated_subtotal DECIMAL(8,2);

    SELECT price 
    FROM Books
    WHERE Books.bookID = p_bookID
    INTO book_price;

    SET calculated_subtotal = book_price * p_quantity;

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

    SET p_NewOrderItemID = LAST_INSERT_ID();
END //

DELIMITER ;




/* ----------------------------------------------------------------------
sp_update_order_total

Update an order's totalAmount value with the sum of all included subtotals
---------------------------------------------------------------------- */
DROP PROCEDURE IF EXISTS sp_update_order_total;

DELIMITER //

CREATE PROCEDURE sp_update_order_total (
        IN p_orderID INT
) 
BEGIN
    UPDATE Orders
    SET Orders.totalAmount =
        COALESCE( 
        (SELECT SUM(subtotal) FROM OrderItems WHERE OrderItems.orderID = p_orderID),
        0.00
        )
    WHERE Orders.orderID = p_orderID;
END //
DELIMITER ;




/* ----------------------------------------------------------------------
sp_update_orderItem

Update an order item's quantity and subtotal
---------------------------------------------------------------------- */
DROP PROCEDURE IF EXISTS sp_update_orderItem;

DELIMITER //

CREATE PROCEDURE sp_update_orderItem (
    IN p_orderItemID INT,
    IN p_bookID INT,
    IN p_quantity INT
)
COMMENT 'Update existing Order Item with new book and quantity.'
BEGIN
    DECLARE book_price DECIMAL(6,2);
    DECLARE calculated_subtotal DECIMAL(8,2);

    SELECT price 
    FROM Books
    WHERE Books.bookID = p_bookID
    INTO book_price;

    SET calculated_subtotal = book_price * p_quantity;
    
    UPDATE OrderItems
    SET bookID = p_bookID,
        quantity = p_quantity,
        subtotal = calculated_subtotal
    WHERE OrderItems.orderItemID = p_orderItemID;
END //

DELIMITER ;


/* ----------------------------------------------------------------------
sp_delete_order

Delete an order and all of its line items
Uses DELETE CASCADE in the OrderItems table
COMMITS only after successfully removing Order
---------------------------------------------------------------------- */
DROP PROCEDURE IF EXISTS sp_delete_order;

DELIMITER //

CREATE PROCEDURE sp_delete_order (
    IN p_orderID INT
)
COMMENT 'Delete an Order if it is found in the database.'
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Rollback the transaction in case of any error
        ROLLBACK;
        SELECT 'Error! Order not deleted.' AS Result;
    END;

    START TRANSACTION;
        DELETE FROM Orders
        WHERE Orders.orderID = p_orderID;
    COMMIT;
END //

DELIMITER ;




/* ----------------------------------------------------------------------
trig_update_order_total_after_insert

Updates an Order with a new total amount after INSERTING a new OrderItem
Cited on 29 November 2025 from:
https://dev.mysql.com/doc/refman/8.4/en/trigger-syntax.html
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




###############################################################################
##################### DEBUG AND DB RESET SECTION

/* ----------------------------------------------------------------------
sp_delete_all_orderItems

Delete all Order Items
This is used to validate successful deletion
---------------------------------------------------------------------- */
-- Remove the old procedure if it exists
DROP PROCEDURE IF EXISTS sp_delete_all_orderItems;

DELIMITER //

CREATE PROCEDURE sp_delete_all_orderItems()
BEGIN
    DELETE FROM OrderItems;
END //

DELIMITER ;




/* ----------------------------------------------------------------------
sp_reset_bookstore

Reset the database and repopulate initial data
Drops all existing tables then recreates from scratch
Initial sample data is then inserted
---------------------------------------------------------------------- */

-- Defines sp_reset_bookstore() which drops/recreates all tables
-- and reloads the sample data.

-- Remove the old procedure if it exists
DROP PROCEDURE IF EXISTS sp_reset_bookstore;

DELIMITER //

CREATE PROCEDURE sp_reset_bookstore()
BEGIN

    -- Disable foreign key checks for the duration
    SET FOREIGN_KEY_CHECKS=0;

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
       RECREATE SCHEMA
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
       SAMPLE DATA
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

    -- Re-enable foreign key checks now that we're done with the procedure
    SET FOREIGN_KEY_CHECKS=1;

END //

DELIMITER ;
