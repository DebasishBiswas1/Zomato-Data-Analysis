

-- 1. What is the total amount each customer spent on Zomato ?

select a.userid , sum(b.price) total_spent 
from sales a inner join product b on a.product_id = b.product_id
group by a.userid;

-- 2. How many days has each customer visited Zomato ?

select userid , count(distinct created_date) visited_days
from sales group by userid;

-- 3. What was the First product purchased by each of the customers ? 

select * from
	( select *,rank() 
			   over( partition by userid order by created_date) as rnk 
	  from sales ) as a
where rnk = 1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers ?

-- 1st part
 
 select product_id,count( product_id ) as purchase_cnt
 from sales
 group by product_id
 order by purchase_cnt desc 
 limit 1;

-- 2nd part 

select userid,count(product_id) as purchase_count
from sales 
	where product_id = 
		(  select product_id
		from sales
		group by product_id
		order by count( product_id ) desc limit 1)
	group by userid;
    
-- 5. Which item was the most populer for each customer ?

select userid, product_id,purchase_count
from
	(select *, rank() over( partition by userid order by purchase_count desc) rnk
	from (select userid,product_id,count(product_id) as purchase_count
		from sales
		group by userid,product_id) as a) as b
where rnk=1;

-- 6. Which item was first purchased by the customer after they took gold membership ?

select * from
	(select *, rank() over( partition by userid order by created_date ) as rnk 
	from
		 (select a.userid,a.created_date,a.product_id,b.gold_signup_date
		 from sales as a
		 inner join goldusers_signup as b
		 on a.userid=b.userid
		 where a.created_date>=b.gold_signup_date) as c) as d
 where rnk=1;
 
 -- 7. Which item was purchased just before the customer became a gold memeber ?
 
 select * from
	(select *, rank() over( partition by userid order by created_date desc) as rnk 
	from
		 (select a.userid,a.created_date,a.product_id,b.gold_signup_date
		 from sales as a
		 inner join goldusers_signup as b
		 on a.userid=b.userid
		 where a.created_date<b.gold_signup_date) as c) as d
 where rnk=1;
 
 -- 8. What is the total orders and amount spent by each member before they became gold members ?
 
 select userid,count(created_date) as total_orders,sum(price) as total_amount
 from
	 (select c.* , p.price from
		( select a.userid,a.created_date,a.product_id,b.gold_signup_date
				 from sales as a
				 inner join goldusers_signup as b
				 on a.userid=b.userid
				 where a.created_date<b.gold_signup_date) as c
		inner join product p 
		on c.product_id = p.product_id) as d
	group by userid order by userid;


    
-- 9. If buying each product generates points for example 5rs=2 zomato points and each product has different purchasing points for example
-- for p1 5rs=1 point, for p2 10rs=5 points, for p3 5rs=1 point
-- calculate points collected by each customer and for which product most points have been given till now ?

-- 1st part
 
select f.userid,sum(total_points_earned) from
(select e.*, amt div points as total_points_earned
from
	(select d.*, case
		when product_id=1 then 5
		when product_id=2 then 2
		when product_id=3 then 5
		else 0
		end
		as points 
	from
		(select c.userid,c.product_id ,sum(price) as amt 
		from
			(select a.*,b.price
			from sales a inner join product b
			on a.product_id=b.product_id) as c
		group by userid,product_id) as d) as e
order by userid) as f group by userid;
    
-- 2nd part

select * from
(select p.*,rank() over( order by total_points desc) as rnk
from
(select f.product_id,sum(total_points_earned) as total_points from
(select e.*, amt div points as total_points_earned
from
	(select d.*, case
		when product_id=1 then 5
		when product_id=2 then 2
		when product_id=3 then 5
		else 0
		end
		as points 
	from
		(select c.userid,c.product_id ,sum(price) as amt 
		from
			(select a.*,b.price
			from sales a inner join product b
			on a.product_id=b.product_id) as c
		group by userid,product_id) as d) as e) as f 
        group by product_id) p) as g
where rnk=1;


-- 10. In the first year after a customer joins a gold program (including their join date) irrespective of what the customer has purchased
-- they earn 5 zomato points for every 10rs spent who earned more 1 or 3 and what was their point earnings in their first year ?
-- 1zp = 2rs    =>      0.5zp=1rs 

select c.*,truncate(d.price*0.5,0) as points from
(select a.userid,a.created_date,a.product_id,b.gold_signup_date
		 from sales as a
		 inner join goldusers_signup as b
		 on a.userid=b.userid
		 where a.created_date>=b.gold_signup_date 
         and a.created_date<=date_add(b.gold_signup_date,interval 1 year)) c
inner join product d on c.product_id=d.product_id;

-- 11. rank all transactions of the customers

select *,rank() over( partition by userid order by created_date) 
as rnk from sales; 

-- 12. rank all the transctions for each member whenever they are a zomato gold member and for every non-gold memeber transaction mark as 0

select e.userid,e.created_date,e.product_id,e.required_rank from
(select d.* ,case when rnk=0 then 'na' else rnk end as required_rank from
(select c.*, cast((case when gold_signup_date is null then 0 else rank()
 over( partition by userid order by created_date desc) end) as char) as rnk from
(select a.*,b.gold_signup_date from sales a 
left join goldusers_signup b on a.userid=b.userid and created_date>=gold_signup_date)as c)as d)e;


    
    
