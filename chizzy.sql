CREATE TABLE product_table (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100),
	product_category VARCHAR(100),
    price NUMERIC(10, 2),
	stock_quanity FLOAT
);

CREATE TABLE customer_table (
    customer_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(100),
	domain_valid BOOLEAN,
	street_address VARCHAR(100),
	city VARCHAR(100),
	state VARCHAR(100),
	zip VARCHAR(100)
);

CREATE TABLE sales_table (
    sale_id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES product_table(product_id),
    customer_id INTEGER REFERENCES customer_table(customer_id),
    sale_date DATE,
    sales_amount FLOAT
	
);

--importing the csv file into postgre
COPY "product_table" FROM 'C:\cizzy/product_table.csv' DELIMITER ',' CSV HEADER;
COPY "customer_table" FROM 'C:\cizzy/customer_table.csv' DELIMITER ',' CSV HEADER;
COPY "sales_table" FROM 'C:\cizzy/sales_table.csv' DELIMITER ',' CSV HEADER;


select * from customer_table
select * from product_table
select * from sales_table


-- Joining all tables together
SELECT  
    c.customer_id, customer_name, email, Street_address, city, state, zip, 
	p.product_id, product_name, product_category,price, stock_quantity,
	s.sales_id, sale_date,sales_amount
FROM 
	sales_table as s 
FULL JOIN 
	customer_table as c ON c.customer_id = s.customer_id
FULL JOIN 
	product_table as p ON p.product_id = s.product_id
		
		
-- changing the column names to avoid inconsistent data
ALTER TABLE product_table RENAME COLUMN stock_quanity TO stock_quantity;
ALTER TABLE sales_table RENAME COLUMN sale_id TO sales_id;


--Most expensive products are laptop, refrigerator, Treamill, Washing machine and smartphone recording about 
--999.99,799.99,599.99,579.99 and 499.99 respectively
SELECT 
  product_name, price
FROM 
  product_table
ORDER by 
  price desc
LIMIT 5


--Most expensive goods per unit price
ALTER TABLE product_table
ADD COLUMN unit_price NUMERIC;
UPDATE product_table
SET unit_price = price / stock_quantity;


SELECT * FROM product_table --the above code didn't work because some were zero


ALTER TABLE product_table
ADD COLUMN unit_price NUMERIC;
UPDATE product_table
SET unit_price = CASE WHEN stock_quantity = 0 THEN 0 ELSE price / stock_quantity END;


ALTER TABLE product_table      --- cast here is used to carter for the non- numeric output of the case function so that round function works
ADD COLUMN unit_price NUMERIC;
UPDATE product_table
SET unit_price = ROUND(CAST(CASE WHEN stock_quantity = 0 THEN 0 ELSE price / stock_quantity END AS NUMERIC), 2);


SELECT * FROM product_table -- new column inserted



--Best selling product(product_id, product_name, sales _amount and group by sales amount)
--  My output initially came out in multple decimal places and made my data inconsistent. i had to introduce a ROUND statement to take care of that
SELECT
  product_name,ROUND(CAST(SUM(sales_amount) AS NUMERIC), 2) AS total_salesamount
FROM 
  sales_table as s 
FULL JOIN
  product_table as p ON s.product_id = p.product_id
GROUP BY product_name


'''
SELECT p.product_id, sales_id, product_name, sales_amount
FROM sales_table as s
FULL JOIN
  product_table as p ON s.product_id = p.product_id
WHERE product_name = 'Electric Heater'
'''
  
  
  
--What is the most profitable produt
SELECT
    s.product_id, product_name, 
    ROUND(CAST(SUM(sales_amount) AS NUMERIC),2) AS total_sales_amount,
    COUNT(s.product_id) AS sales_count,
    unit_price * COUNT(s.product_id)  AS total_potential_revenue,
    ROUND(CAST(SUM(s.sales_amount) AS NUMERIC),2) - unit_price * COUNT(s.product_id)  AS profit
FROM
    sales_table AS s
FULL JOIN
    product_table AS p ON s.product_id = p.product_id
GROUP BY
    p.product_name,
    p.unit_price,
	s. product_id;


--what geogrsphy trends exist (The highest revenue for the company came from CA Califonia. This means that the business can establish more presence in CA )
SELECT 
  state, sum(sales_amount) as total_salesamount
FROM
  sales_table as s
JOIN
  customer_table as c ON c.customer_id = s.customer_id
GROUP BY state
ORDER BY sum(sales_amount) desc