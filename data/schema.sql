-- ==========================================================================
-- E-Commerce Time-Series Dataset — Schema
--
-- Tables:
--   customers    – customer_id, signup_date, segment
--   products     – product_id, name, category, unit_price (list price)
--   orders       – order_id, customer_id (FK), order_date, status
--   order_items  – order_item_id, order_id (FK), product_id (FK),
--                  quantity, unit_price (price at time of purchase)
--
-- Load order: customers & products first, then orders, then order_items.
-- ==========================================================================

DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS customers CASCADE;

CREATE TABLE customers (
    customer_id  INT         PRIMARY KEY,
    signup_date  DATE        NOT NULL,
    segment      VARCHAR(20) NOT NULL
);

CREATE TABLE products (
    product_id  INT            PRIMARY KEY,
    name        VARCHAR(100)   NOT NULL,
    category    VARCHAR(30)    NOT NULL,
    unit_price  NUMERIC(10,2)  NOT NULL
);

CREATE TABLE orders (
    order_id     INT         PRIMARY KEY,
    customer_id  INT         NOT NULL REFERENCES customers(customer_id),
    order_date   DATE        NOT NULL,
    status       VARCHAR(20) NOT NULL
);

CREATE TABLE order_items (
    order_item_id  INT            PRIMARY KEY,
    order_id       INT            NOT NULL REFERENCES orders(order_id),
    product_id     INT            NOT NULL REFERENCES products(product_id),
    quantity       INT            NOT NULL,
    unit_price     NUMERIC(10,2)  NOT NULL
);

-- Load data from CSV files.
-- Adjust file paths as needed, or use \copy in psql.

\copy customers FROM '/data/customers.csv' CSV HEADER;
\copy products FROM '/data/products.csv' CSV HEADER;
\copy orders FROM '/data/orders.csv' CSV HEADER;
\copy order_items FROM '/data/order_items.csv' CSV HEADER;