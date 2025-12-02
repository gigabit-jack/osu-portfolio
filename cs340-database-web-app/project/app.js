// Code is adapted from the Starter code provided in the CS 340 bsg_db.sql file
// Code was imported in November 2025 from Canvas and then heavily adapted
// Stored procedures were converted to use parameterized queries per:
// https://blogs.oracle.com/mysql/parameterizing-mysql-queries-in-node


// ########################################
// ########## SETUP

// NPM INSTALL COMMAND
// npm install mysql2 express nodemon forever express-handlebars dotenv moment

// Express
require("dotenv").config();
const express = require("express");
const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static("public"));

// Sets the web port to pull from .env
const PORT = process.env.WEB_PORT;

// Database
const db = require("./database/db-connector");

// Handlebars
/*
  Used GitHub Copilot to add a "moment" helper to Handlebars for date formatting
  Prompt: Add a "moment" helper to handlebars to use YYYY-MM-DD date formatting
  This requires using the "shortdate" helper in the Handlebars files
*/
const moment = require("moment");
const { engine } = require("express-handlebars"); // Import express-handlebars engine
app.engine(".hbs", engine({ 
  extname: ".hbs",
  helpers: {
    shortDate: (date) => moment(date).format('YYYY-MM-DD')
  }
})); // Create instance of handlebars
app.set("view engine", ".hbs"); // Use handlebars engine for *.hbs files.

// ########################################
// ########## ROUTE HANDLERS

// READ ROUTES
app.get("/", async (req, res) => {
  try {
    res.render("home"); // Render the home.hbs file
  } catch (error) {
    console.error("Error rendering page:", error);
    // Send a generic error message to the browser
    res.status(500).send("An error occurred while rendering the page.");
  }
});

app.get("/authors", async (req, res) => {
  try {
    // In query1, we simply gather and display all authors
    // The SP returns an array of arrays, so we need to expand it
    const query1 = "CALL sp_select_authors();";
    const [rows] = await db.query(query1);
    const authors = rows[0]; // Use the first result from set of arrays

    // Render the authors.hbs file
    res.render("authors", { authors: authors });
  } catch (error) {
    console.error("Error executing queries:", error);
    // Send a generic error message to the browser
    res
      .status(500)
      .send("An error occurred while executing the database queries.");
  }
});

app.get("/books", async (req, res) => {
  try {
    // In query1, we use a JOIN clause to display the names of the books and their authors
    // In query2, we just get the authors and send to render the dropdowns for the INSERT
    const query1 = "CALL sp_select_books();"
    const query2 = "CALL sp_select_authors();"

    // Parse the returned arrays
    const [rows1] = await db.query(query1);
    const [rows2] = await db.query(query2);

    // Define our actual constants we'll send to the renderer
    // Use the first result from set of arrays
    const books = rows1[0]; 
    const authors = rows2[0]; 


    // Render the books.hbs file
    res.render("books", { books: books, authors: authors });
  } catch (error) {
    console.error("Error executing queries:", error);
    // Send a generic error message to the browser
    res
      .status(500)
      .send("An error occurred while executing the database queries.");
  }
});

app.get("/customers", async (req, res) => {
  try {
    // In query1, we simply return all customer records from the Customers table
    const query1 = "CALL sp_select_customers();"
    const [rows] = await db.query(query1);
    const customers = rows[0]; // Use the first result from set of arrays

    // Render the customers.hbs file
    res.render("customers", { customers: customers });
  } catch (error) {
    console.error("Error executing queries:", error);
    // Send a generic error message to the browser
    res
      .status(500)
      .send("An error occurred while executing the database queries.");
  }
});

app.get("/order_details", async (req, res) => {
  try {
    // First, we grab the orderID from the request parameters
    const orderID = req.query.orderID;
    
    // In query1, we JOIN Orders with Customers to get details about who placed an order a JOIN clause to display the names of the books and their authors
    // In query2, we JOIN Books, Authors, and OrderItems to get the line items in the order
    // In query3, we get ALL orders to use for the select dropdown menu
    // In query4, we get ALL books to use for the select dropdown menu
    const query1 = "CALL sp_select_orderDetails(?);"
    const query2 = "CALL sp_select_orderItems(?);"
    const query3 = "CALL sp_select_orders();"
    const query4 = "CALL sp_select_books();"
    
    // Parse the returned arrays
    const [rows1] = await db.query(query1, [orderID]);
    const [rows2] = await db.query(query2, [orderID]);
    const [rows3] = await db.query(query3);
    const [rows4] = await db.query(query4);

    // Define our actual constants we'll send to the renderer
    // Use the first result from set of arrays
    const orderDetails = rows1[0]; 
    const orderItems = rows2[0]; 
    const orders = rows3[0]; 
    const books = rows4[0]; 

    // Render the order_details.hbs file, and also send the renderer
    //  objects that contains our Order Details, OrderItems, and all Orders
    res.render("order_details", {
      orderDetails: orderDetails[0],
      orderItems: orderItems,
      orders: orders,
      books: books
    });
  } catch (error) {
    console.error("Error executing queries:", error);
    // Send a generic error message to the browser
    res
      .status(500)
      .send("An error occurred while executing the database queries.");
  }
});

app.get("/orders", async (req, res) => {
  try {
    // In query1, we gather all the Orders and add the customer first & last name
    // Query 2 gets the list of customers and sends their names to the Orders page
    // This is for the Customers drop-down selection
    const query1 = "CALL sp_select_orders();"
    const query2 = "CALL sp_select_customers();"

    // Run both queries
    const [rows1] = await db.query(query1);
    const [rows2] = await db.query(query2);

    // Parse both queries
    // Use the first result from set of arrays
    const orders = rows1[0];
    const customers = rows2[0];

    // Render the orders.hbs file with both queries
    res.render("orders", { orders: orders, customers: customers });
  } catch (error) {
    console.error("Error executing queries:", error);
    // Send a generic error message to the browser
    res
      .status(500)
      .send("An error occurred while executing the database queries.");
  }
});




// INSERT ROUTES
app.post("/authors", async (req, res) => {
    try {
      // grab the parameters from the post request
      const {firstName, lastName, country} = req.body;

      // specify birthdate to be either null or entered
      // this is needed to support null birthdates from the form
      const birthDate = req.body.birthDate || null;

      // craft the query and use ? as variable parameters
      const query1 = "CALL sp_insert_author(?, ?, ?, ?, @newAuthorID);";

      // send the query and use our req.body variables as the parameters
      await db.query(query1, [firstName, lastName, country, birthDate]);
      res.redirect("/authors");
  } catch (err) {
    console.error("Error executing PL/SQL:", err);
    res.status(500).render("error", { message: "Author insert failed." });
  }
});

app.post("/books", async (req, res) => {
    try {
      // grab the parameters from the post request
      const {title, authorName, genre, price, publishYear, isbn} = req.body;
      // specify stockQuantity to be either 0 or entered
      const stockQuantity = req.body.stockQuantity || 0;

      // craft the query and use ? as variable parameters
      const query1 = "CALL sp_insert_book(?, ?, ?, ?, ?, ?, ?, @newBookID);";

      // send the query and use our req.body variables as the parameters
      await db.query(query1, [title, authorName, genre, price, stockQuantity, publishYear, isbn]);
      res.redirect("/books");
  } catch (err) {
    console.error("Error executing PL/SQL:", err);
    res.status(500).render("error", { message: "Book insert failed." });
  }
});

app.post("/customers", async (req, res) => {
    try {
      // grab the parameters from the post request
      const {fname, lname, email, phone, city, state} = req.body;

      // craft the query and use ? as variable parameters
      const query1 = "CALL sp_insert_customer(?, ?, ?, ?, ?, ?, @newCustomerID);";

      // send the query and use our req.body variables as the parameters
      await db.query(query1, [fname, lname, email, phone, city, state]);
      res.redirect("/customers");
  } catch (err) {
    console.error("Error executing PL/SQL:", err);
    res.status(500).render("error", { message: "Customer insert failed." });
  }
});

app.post("/orders", async (req, res) => {
    try {
      // grab the parameters from the post request
      const {customerID, orderDate, paymentStatus} = req.body;

      // craft the query and use ? as variable parameters
      const query1 = "CALL sp_insert_order(?, ?, ?, @newOrderID);";

      // send the query and use our req.body variables as the parameters
      await db.query(query1, [customerID, orderDate, paymentStatus]);
      res.redirect("/orders");
  } catch (err) {
    console.error("Error executing PL/SQL:", err);
    res.status(500).render("error", { message: "Order insert failed." });
  }
});

app.post("/order_details", async (req, res) => {
    try {
      // grab the parameters from the post request
      const {orderID, bookID, quantity, } = req.body;

      // craft the query and use ? as variable parameters
      const query1 = "CALL sp_insert_orderItem(?, ?, ?, @newOrderItemID);";

      // send the query and use our req.body variables as the parameters
      await db.query(query1, [orderID, bookID, quantity]);

      // craft our redirect URL with the orderID we're working with
      const redirectURL = "/order_details?orderID=" + orderID;
      res.redirect(redirectURL)
  } catch (err) {
    console.error("Error executing PL/SQL:", err);
    res.status(500).render("error", { message: "Order insert failed." });
  }
});




// UPDATE ROUTES
app.get("/edit-line-item/:orderItemID", async (req, res) => {
  try {
    // grab the orderItemID from the route parameter
    const orderItemID = req.params.orderItemID;

    // craft the queries and use ? as variable parameters
    const query1 = "CALL sp_select_orderItem(?);"
    const query2 = "CALL sp_select_books();"

    // Run the queries
    // Returns an array with a nested array
    const [rows1] = await db.query(query1, [orderItemID]);
    const [rows2] = await db.query(query2);

    // Parse the queries
    // Use the first result from set of arrays
    const orderItem = rows1[0];
    const books = rows2[0];

    // Render the edit page with the orderItems and books
    res.render("edit-line-item", { orderItem: orderItem[0], books: books });
  } catch (err) {
  console.error("Error executing PL/SQL:", err);
  res.status(500).render("error", { message: "An error occurred while executing the database queries." });
  }
});

app.post("/edit-line-item/:orderItemID", async (req, res) => {
    try {
      // grab the parameters from the post request
      const { orderItemID, orderID, bookID, quantity } = req.body;

      // craft the query and use ? as variable parameters
      const query1 = "CALL sp_update_orderItem(?, ?, ?);";

      // send the query and use our req.body variables as the parameters
      await db.query(query1, [orderItemID, bookID, quantity]);

      // craft our redirect URL with the orderID we're working with
      const redirectURL = "/order_details?orderID=" + orderID;
      res.redirect(redirectURL)
  } catch (err) {
    console.error("Error executing PL/SQL:", err);
    res.status(500).render("error", { message: "Line item update failed." });
  }
});





// DELETE ROUTES
app.post("/customers/delete", async (req, res) => {
  try {
    // grab the customerID from the body
    const {customerID} = req.body;

    // craft the query and use ? as variable parameters
    const query1 = "CALL sp_delete_customer(?);";

    // send the query and use the customerID as the parameter
    await db.query(query1, [customerID]);
    res.redirect("/customers");
  } catch (err) {
  console.error("Error executing PL/SQL:", err);
  res.status(500).render("error", { message: "Customer deletion failed." });
  }
});

app.post("/orders/delete", async (req, res) => {
  try {
    // grab the orderID from the body
    const {orderID} = req.body;

    // craft the query and use ? as variable parameters
    const query1 = "CALL sp_delete_order(?);";

    // send the query and use the orderID as the parameter
    await db.query(query1, [orderID]);
    res.redirect("/orders");
  } catch (err) {
  console.error("Error executing PL/SQL:", err);
  res.status(500).render("error", { message: "Order deletion failed." });
  }
});



// DEBUG AND DB RESET ROUTES

// Delete all order items
app.post("/api/delete-all-order-items", async (req, res) => {
  try {
    const query1 = "CALL sp_delete_all_orderItems();";
    await db.query(query1);
    res.redirect(303, "/orders");
  } catch (err) {
    console.error("Error executing PL/SQL:", err);
    res.status(500).render("error", { message: "Deletion failed." });
  }
});

// Reset the database
app.post("/api/reset-database", async (req, res) => {
  try {
    const query1 = "CALL sp_reset_bookstore();";
    
    // recreates INSERT trigger since we can't put triggers in SPs
    const query2 = `DROP TRIGGER IF EXISTS trig_update_order_total_after_insert;`;
    const query3 = `
      CREATE TRIGGER trig_update_order_total_after_insert
      AFTER INSERT ON OrderItems
      FOR EACH ROW
      BEGIN
          CALL sp_update_order_total(NEW.orderID);
      END;`;
    
    // recreates UPDATE trigger since we can't put triggers in SPs
    const query4 =`DROP TRIGGER IF EXISTS trig_update_order_total_after_update;`;
    const query5 =`
      CREATE TRIGGER trig_update_order_total_after_update
      AFTER UPDATE ON OrderItems
      FOR EACH ROW
      BEGIN
          CALL sp_update_order_total(NEW.orderID);
      END;`;

    // recreates DELETE trigger since we can't put triggers in SPs
    const query6 =`DROP TRIGGER IF EXISTS trig_update_order_total_after_delete;`;
    const query7 =`
      CREATE TRIGGER trig_update_order_total_after_delete
      AFTER DELETE ON OrderItems
      FOR EACH ROW
      BEGIN
          CALL sp_update_order_total(OLD.orderID);
      END;`;

    // run all DB RESET queries
    await db.query(query1);
    await db.query(query2);
    await db.query(query3);
    await db.query(query4);
    await db.query(query5);
    await db.query(query6);
    await db.query(query7);

    // redirect back to the home page
    res.redirect(303, "/");
  } catch (error) {
    console.error("Error executing PL/SQL:", error);
    // Send a generic error message to the browser
    res.status(500).send("An error occurred while executing the PL/SQL.");
  }
});

app.listen(PORT, function () {
  console.log(
    "Express started on http://localhost:" +
      PORT +
      "; press Ctrl-C to terminate."
  );
});
