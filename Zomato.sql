drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid int,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
(3,'04-21-2017');

drop table if exists users;
CREATE TABLE users(userid int,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');

drop table if exists sale;
CREATE TABLE sale(userid int,created_date date,product_id int); 

INSERT INTO sale(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);

drop table if exists product;
CREATE TABLE product(product_id int,product_name text,price int); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);

select * from sale;
select * from product;
select * from goldusers_signup;
select * from users;

--1. Total Amount Spent by Each Customer on Zomato
select s.userid,sum(p.price) as Total_Amount_Spent
from sale s join product p
on s.product_id=p.product_id
group by s.userid ;

--2. How many days has each customer visited zomato?
select userid,count(distinct created_date) as Distinct_Days
from sale
group by userid;

--3. First Product bought by each customer
select * from(select *,
rank() over(partition by userid order by created_date asc) rnk 
from sale) a
where a.rnk=1;

--4. Most Purchased item on the Menu
select userid,product_id,count(product_id) cnt from sale where product_id=(select top 1 product_id
from sale
group by  product_id
order by count(product_id) desc)
group by userid,product_id;

--5. Which item was most popular for each customer
select * from(
select *,rank() over(partition by userid order by Favourite_Product desc) rnk from(
select userid,product_id,count(product_id) as Favourite_Product
from sale
group by userid,product_id)a)b
where rnk=1;

--6. Which item was purchased by customer after they became a member?
select * from(select c.*,rank() over(partition by userid order by created_date asc) rnk from(
select s.userid,s.created_date,s.product_id,g.gold_signup_date
from sale s inner join goldusers_signup g
on s.userid=g.userid
and s.created_date>=g.gold_signup_date)c)d
where d.rnk=1;

--7. Which item was purchased just before the customer becoming a member
select * from(select c.*,rank() over(partition by userid order by created_date desc) rnk from(
select s.userid,s.created_date,s.product_id,g.gold_signup_date
from sale s inner join goldusers_signup g
on s.userid=g.userid
and s.created_date<g.gold_signup_date)c)d
where d.rnk=1;

--8. Total orders and Amount spent by each use before becoming a member?
select userid,count(created_date) as Order_Purchased,sum(price) as Total_Amount_Spent from(
select c.*,p.price from(
select s.userid,s.created_date,s.product_id,g.gold_signup_date
from sale s inner join goldusers_signup g
on s.userid=g.userid
and s.created_date<g.gold_signup_date)c inner join  product p on c.product_id=p.product_id)e
group by userid;

--9. If buying each product generates points for eg 5rs-2 zomato point and
   --each product has different purchasing points for eg for p1 5rs-1 zonato point, 
   --for p2 10rs-5zomato point and p3 5rs-1 zomato point.
   --Calculate points collected by each customer and for which product most points have been guven tiil now.
   select userid,sum(Pointss) as Points_Earned from(
   select e.*,Total_Amount/Points as Pointss from(
   select d.*,case when product_id=1 then 5 when product_id=2 then 2 when product_id=3  then 5 else 0 end as Points from(
   select c.userid,c.product_id,sum(price) as Total_Amount from
   (select s.*,p.price from sale s inner join product p
   on s.product_id=p.product_id)c
   group by c.userid,c.product_id)d)e)f
   group by userid;

   select * from(
   select*,rank() over(order by Points_Earned desc) as Rnk from(
   select product_id,sum(Pointss) as Points_Earned from(
   select e.*,Total_Amount/Points as Pointss from(
   select d.*,case when product_id=1 then 5 when product_id=2 then 2 when product_id=3  then 5 else 0 end as Points from(
   select c.userid,c.product_id,sum(price) as Total_Amount from
   (select s.*,p.price from sale s inner join product p
   on s.product_id=p.product_id)c
   group by c.userid,c.product_id)d)e)f
   group by product_id)g)h
   where h.Rnk=1;

--10. In the first one year after a customer joins the gold program (including their join date) 
--irrespective of what the customer has purchased they earn 5 zomato points for every 10 rs spent
--who earned more 1 or 3 and what was their points earnings in thier first yr?
--1zp=2rs
--0.5zp=1rs

select c.*,p.price *0.5 as Total_Ponts_Earned from(
select s.userid,s.created_date,s.product_id,g.gold_signup_date
from sale s inner join goldusers_signup g
on s.userid=g.userid
and s.created_date>=g.gold_signup_date and created_date<=dateadd(year,1,gold_signup_date))c
inner join product p on c.product_id=p.product_id;

--11. Rank all the transactions of the customers
select *,
rank() over(partition by userid order by created_date asc) rnk from sale;

--12. Rank all the transactions for each customer whenever they are a zomato gold member,
--for every non gold member transaction mark as na
select e.*,case when rnk=0 then 'N/A' else rnk end as rnkk from(
select c.*,cast(case when gold_signup_date is null then 0 else rank() over(partition by userid order  by created_date desc) end  as varchar) as rnk from(
select s.userid,s.created_date,s.product_id,g.gold_signup_date
from sale s left join goldusers_signup g
on s.userid=g.userid
and s.created_date>=g.gold_signup_date)c)e;