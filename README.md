# Zomato-SQL
 This project focuses on analyzing the Zomato dataset.
 
 **Overview:**
 
 This project involves analyzing the Zomato dataset to gain insights into customer behavior, product popularity, and the impact of the Zomato Gold membership program.
 The SQL queries used in this analysis cover various aspects such as total spending, visit frequency, and product preferences of customers. 
 The project aims to provide valuable insights that can help understand and optimize customer engagement and product offerings.

**Key Features:**

1.Total Amount Spent by Each Customer:
Calculate the total amount spent by each customer on Zomato.
![image](https://github.com/user-attachments/assets/a440f555-ea80-4023-b0d8-e2c90d4e32af)


2.Determine how many distinct days each customer visited Zomato.
![image](https://github.com/user-attachments/assets/20b4bd06-7b26-4ba4-ad7f-eaa3410a7b27)


3.First Product Bought by Each Customer:
Identify the first product purchased by each customer.

![image](https://github.com/user-attachments/assets/3c67ef6a-7e7f-4387-9c69-600c7f8010c9)

4.Most Purchased Item on the Menu:
Find the most purchased item on the menu.
![image](https://github.com/user-attachments/assets/4ee81a8c-e8f9-4a5d-bc83-6bd29c65a43d)

5.Most Popular Item for Each Customer:

Determine the most popular item for each customer.
![image](https://github.com/user-attachments/assets/799e7f09-9719-49aa-b253-6a3b0e1f9908)

6.Item Purchased After Becoming a Member:

Identify the first item purchased by a customer after becoming a Zomato Gold member.
![image](https://github.com/user-attachments/assets/6fdd81a0-3a5f-4c37-a2af-bc9d359adb88)

7.Item Purchased Before Becoming a Member:

Identify the last item purchased by a customer before becoming a Zomato Gold member.
![image](https://github.com/user-attachments/assets/5096a292-6552-4a0b-9018-c831101f007b)

8.Total Orders and Amount Spent Before Membership:

Calculate the total orders and amount spent by each customer before becoming a Zomato Gold member.
![image](https://github.com/user-attachments/assets/06a25eae-90be-4b03-b6c1-e20ac04f1310)

9.Points Earned by Customers:

a)Calculate the points collected by each customer.
sql
Copy code
SELECT userid, SUM(Pointss) AS Points_Earned 
FROM (
    SELECT e.*, Total_Amount / Points AS Pointss 
    FROM (
        SELECT d.*, CASE 
            WHEN product_id = 1 THEN 5 
            WHEN product_id = 2 THEN 2 
            WHEN product_id = 3 THEN 5 
            ELSE 0 
        END AS Points 
        FROM (
            SELECT c.userid, c.product_id, SUM(price) AS Total_Amount 
            FROM (
                SELECT s.*, p.price 
                FROM sale s
                INNER JOIN product p ON s.product_id = p.product_id
            ) c
            GROUP BY c.userid, c.product_id
        ) d
    ) e
) f
GROUP BY userid;
![image](https://github.com/user-attachments/assets/80c0f335-b927-4bd5-9c0e-a71089ab3b07)

b)identify the product that has given the most points till now
SELECT * FROM (
    SELECT *, RANK() OVER (ORDER BY Points_Earned DESC) AS Rnk 
    FROM (
        SELECT product_id, SUM(Pointss) AS Points_Earned 
        FROM (
            SELECT e.*, Total_Amount / Points AS Pointss 
            FROM (
                SELECT d.*, CASE 
                    WHEN product_id = 1 THEN 5 
                    WHEN product_id = 2 THEN 2 
                    WHEN product_id = 3 THEN 5 
                    ELSE 0 
                END AS Points 
                FROM (
                    SELECT c.userid, c.product_id, SUM(price) AS Total_Amount 
                    FROM (
                        SELECT s.*, p.price 
                        FROM sale s
                        INNER JOIN product p ON s.product_id = p.product_id
                    ) c
                    GROUP BY c.userid, c.product_id
                ) d
            ) e
        ) f
        GROUP BY product_id
    ) g
) h
WHERE h.Rnk = 1;
![image](https://github.com/user-attachments/assets/c2f4c57a-e97c-4528-b48d-d1fe8af3095b)


10.Points Earnings in the First Year of Membership:

Calculate the points earned by customers in their first year after joining the Zomato Gold program.
sql
Copy code
SELECT c.*, p.price * 0.5 AS Total_Points_Earned 
FROM (
    SELECT s.userid, s.created_date, s.product_id, g.gold_signup_date
    FROM sale s
    INNER JOIN goldusers_signup g ON s.userid = g.userid
    AND s.created_date >= g.gold_signup_date AND created_date <= DATEADD(year, 1, g.gold_signup_date)
) c
INNER JOIN product p ON c.product_id = p.product_id;

![image](https://github.com/user-attachments/assets/720da4a4-06d3-4076-bbd7-a4e3ee2aa84e)

11.Ranking All Transactions:

Rank all transactions of the customers.
sql
Copy code
SELECT *,
RANK() OVER (PARTITION BY userid ORDER BY created_date ASC) rnk 
FROM sale;

![image](https://github.com/user-attachments/assets/e555a914-c26b-4d5d-99e9-52ec6ef42639)


12.Ranking Transactions for Gold Members:

Rank all transactions for each customer whenever they are a Zomato Gold member, marking non-member transactions as "N/A".
![image](https://github.com/user-attachments/assets/8a34d572-0dfc-4249-89c1-81f06fb78122)
