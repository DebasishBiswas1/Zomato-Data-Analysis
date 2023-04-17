
# 📊 Zomato Data Analysis

This project is about SQL to perform exploratory data analysis. The data set is a dummy data set much like Zomato and with some minimal data.
This project is basically done to gain some better knowledge and have a more tighter grip upon SQL.
Still more to learn 😄.
For this I have used MySQL Workbench.


## 🗂 Creating Database

Created a database of a food website like Zomato with and inserted some dummy data to do some analysis upon the data.
The database, named zomato_data contains 4 tables:
goldusers_signup, users, sales, and product.

### 1️⃣ creating table goldusers_signup:
```bash
drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date);
```
### 2️⃣ creating table product:
```bash
drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer);
```
### 3️⃣ creating table users:
```bash
drop table if exists users;
CREATE TABLE users(userid integer,signup_date date);
```
### 4️⃣ creating table sales:
```bash
drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer);
```

### 📈 Some Analysis That Are Performed

From next are some important questions based on which analysis is performed.
Some these questions are really important in improving upon any particular product, the business model or any other thing.

#### 1️⃣	What is the total amount each customer spent on Zomato ?
```bash
select a.userid , sum(b.price) total_spent 
from sales a inner join product b on a.product_id = b.product_id
group by a.userid;
```

#### 2️⃣ How many days has each customer visited Zomato ?
```bash
select userid , count(distinct created_date) visited_days
from sales group by userid;
```

#### 3️⃣ What is the most purchased item on the menu and how many times was it purchased by all customers ?
```bash
-- 1st part

select product_id,count( product_id ) as purchase_cnt
 from sales
 group by product_id
 order by purchase_cnt desc 
 limit 1;
```
```bash
--2nd Part

select userid,count(product_id) as purchase_count
from sales 
	where product_id = 
		(  select product_id
		from sales
		group by product_id
		order by count( product_id ) desc limit 1)
	group by userid;
```

#### 4️⃣ Which item was the most popular for each customer ?
```bash
select userid, product_id,purchase_count
from
	(select *, rank() over( partition by userid order by purchase_count desc) rnk
	from (select userid,product_id,count(product_id) as purchase_count
		from sales
		group by userid,product_id) as a) as b
where rnk=1;
```



## 📌 Linkedin

- [Linkedin Post](https://www.linkedin.com/feed/update/urn:li:activity:7044557951272988672/)

