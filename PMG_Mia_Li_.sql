Create Database If Not Exists PMG_OA;
USE PMG_OA;
Create Table store_revenue (id int not null primary key auto_increment, 
	date datetime, 
	brand_id int, 
	store_location varchar(250), 
	revenue float
);
INSERT INTO store_revenue (date, brand_id, store_location, revenue) 
Values
("2016-01-01","1","United States-CA","100"),
("2016-01-01","1","United States-TX","420"),
("2016-01-01","1","United States-NY","142"),
("2016-01-02","1","United States-CA","231"),
("2016-01-02","1","United States-TX","2342"),
("2016-01-02","1","United States-NY","232"),
("2016-01-03","1","United States-CA","100"),
("2016-01-03","1","United States-TX","420"),
("2016-01-03","1","United States-NY","3245"),
("2016-01-04","1","United States-CA","34"),
("2016-01-04","1","United States-TX","3"),
("2016-01-04","1","United States-NY","54"),
("2016-01-05","1","United States-CA","45"),
("2016-01-05","1","United States-TX","423"),
("2016-01-05","1","United States-NY","234"),
("2016-01-01","2","United States-CA","234"),
("2016-01-01","2","United States-TX","234"),
("2016-01-01","2","United States-NY","142"),
("2016-01-02","2","United States-CA","234"),
("2016-01-02","2","United States-TX","3423"),
("2016-01-02","2","United States-NY","2342"),
("2016-01-03","2","United States-CA","234234"),
("2016-01-06","3","United States-TX","3"),
("2016-01-03","2","United States-TX","3"),
("2016-01-03","2","United States-NY","234"),
("2016-01-04","2","United States-CA","2"),
("2016-01-04","2","United States-TX","2354"),
("2016-01-04","2","United States-NY","45235"),
("2016-01-05","2","United States-CA","23"),
("2016-01-05","2","United States-TX","4"),
("2016-01-05","2","United States-NY","124");

Create Table marketing_data (id int not null primary key auto_increment, 
	date datetime, 
	geo varchar(2), 
	impressions float, 
	clicks float
);
INSERT INTO marketing_data (date, geo, impressions, clicks)
Values 
("2016-01-01","TX","2532","45"),
("2016-01-01","CA","3425","63"),
("2016-01-01","NY","3532","25"),
("2016-01-01","MN","1342","784"),
("2016-01-02","TX","3643","23"),
("2016-01-02","CA","1354","53"),
("2016-01-02","NY","4643","85"),
("2016-01-02","MN","2366","85"),
("2016-01-03","TX","2353","57"),
("2016-01-03","CA","5258","36"),
("2016-01-03","NY","4735","63"),
("2016-01-03","MN","5783","87"),
("2016-01-04","TX","5783","47"),
("2016-01-04","CA","7854","85"),
("2016-01-04","NY","4754","36"),
("2016-01-04","MN","9345","24"),
("2016-01-05","TX","2535","63"),
("2016-01-05","CA","4678","73"),
("2016-01-05","NY","2364","33"),
("2016-01-05","MN","3452","25");


-- Question #1 Generate a query to get the sum of the clicks of the marketing data​
Select SUM(clicks)
From marketing_data;
-- Question #2 Generate a query to gather the sum of revenue by geo from the store_revenue table​
Select store_location as geo,
	   SUM(revenue)
From store_revenue
Group by store_location;

-- Question #3 Merge these two datasets so we can see impressions, clicks, and revenue together by date and geo. Please ensure all records from each table are accounted for.​
Update store_revenue
Set store_location = Replace(store_location, 'United States-', '');

Create View combined_table AS
Select date, store_location
From store_revenue
Union
Select date,geo
From marketing_data;

Create View temp3 AS
Select c.date, c.store_location, s.revenue, m.impressions, m.clicks
From combined_table c
Left join store_revenue s On c.date = s.date AND c.store_location = s.store_location
Left Join marketing_data m On c.date = m.date AND c.store_location = m.geo; -- right(s.store_location,2) = m.geo

Select temp4.date, temp4.geo, m.impressions, m.clicks, temp4.sum_revenue as revenue
From (Select temp3.date, temp3.store_location as geo, SUM(revenue) as sum_revenue
From temp3 Group by temp3.date, temp3.store_location) as temp4
Left Join marketing_data m On m.date = temp4.date AND m.geo = temp4.geo;


-- Question #4 In your opinion, what is the most efficient store and why?​

-- Method: The approach is to calculate click through rate (CTR) and revenue per click (RPC) by states and compare with revenue to 
-- see which store is the most efficient one. Since we don't know the cost and conversion, revenue is not enough to define the efficency of stores.

Create View Question_3 AS
Select temp4.date, temp4.geo, m.impressions, m.clicks, temp4.sum_revenue as revenue
From (Select temp3.date, temp3.store_location as geo, SUM(revenue) as sum_revenue
From temp3 Group by temp3.date, temp3.store_location) as temp4
Left Join marketing_data m On m.date = temp4.date AND m.geo = temp4.geo;

Select geo, SUM(revenue), SUM(clicks)/SUM(impressions) * 100 as CTR, SUM(revenue)/SUM(clicks) as RPC
From Question_3
Group By geo;

-- Through running the query above we can know that stores in CA generate the highest revenue and 1.37 CTR. 
-- Although stores in TX has 0.2% higher CTR than stores in CA, their total revenue is much lower.

Select brand_id, store_location, revenue
From store_revenue
Order by revenue desc;

-- Answer: Based on the calculation of click through rate (CTR) by state, revenue per click (RPC) by state and total revenue by store,  store with brand_id 2 in CA is the most efficient one.
-- However, the CTR of stores in MN is around four times of other stores -- If we can get the total revenue of stores in MN maybe we can further confirm that stores in MN have higher efficency than stores in CA.


-- Question #5 (Challenge) Generate a query to rank in order the top 10 revenue producing states​
Select 
store_location
,total_revenue
From (
Select 
store_location
,total_revenue
,dense_rank()over(order by total_revenue desc) as rw_no 
From(
Select 
store_location
,SUM(revenue) total_revenue
From store_revenue
Group by store_location
) t
) t1
Where t1.rw_no <= 10;





