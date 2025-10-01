create database nike;
use nike;
select * from nikesales;
describe nikesales;

-- Converting column Order datae from string to Date Format
update nikesales set Order_Date = STR_TO_DATE(Order_Date, '%d-%b-%Y');
    
-- 1)List all unique product lines sold.
select distinct Product_Name from nikesales;

-- 2)Find total units sold for each region.
select region,sum(Units_Sold) as TotalUnitsSold from nikesales group by region;

-- 3)What is the average selling price (MRP) for each product line?
select Product_Line,avg(MRP) as AVG_selling_price from nikesales group by Product_Line;

-- 4)Count the number of orders placed in each sales channel (Online vs Retail).
select Sales_Channel,count(*) as No_of_orders from nikesales group by Sales_Channel;

-- 5)Show all products sold to the 'Kids' category.
select Product_Line,Product_Name,Sales_Channel,Units_Sold from nikesales where Gender_Category="Kids";

-- 6)Which product name had the highest total revenue?
select Product_Name,sum(Units_Sold*MRP) as highest_total_revenue from nikesales group by Product_Name order by highest_total_revenue
desc limit 1;

-- 7)Find the top 5 regions by total profit.
select region,sum(profit)as total_profit from nikesales group by region order by total_profit desc limit 5;

-- 8)What is the average discount applied for each gender category
select Gender_Category,avg(Discount_Applied) as avg_discount from nikesales group by Gender_Category;

-- 9)Show the monthly trend of total revenue (group by month in Order_Date).
select year(Order_Date) as order_year, month(Order_Date) as order_month, sum(revenue) as total_revenue from nikesales
group by year(Order_Date), month(Order_Date) order by order_year, order_month;

-- 10)Compare units sold across different size segments for each product line
select product_line,size_segment,sum(units_sold) as total_units_sold from nikesales 
group by product_line, size_segment order by product_line, total_units_sold desc;

-- 11)What are the top 3 products by average profit per order?
select product_name,avg(profit) as avg_profit_per_order from nikesales group by product_name order by avg_profit_per_order desc limit 3;

-- 12)Find the gender category that contributed the most to overall profit in each region.
select region, gender_category, total_profit from (select region,gender_category,sum(profit) as total_profit,rank() over (partition by region
order by sum(profit) desc) as rnk from nikesales group by region, gender_category) ranked where rnk = 1;

-- 13)Which product line has the highest average discount but still maintains positive profit?
select product_line,avg(discount_applied) as avg_discount,sum(profit) as total_profit from nikesales group by product_line
having sum(profit) > 0 order by avg_discount desc limit 1;

-- 14)Identify orders where revenue is negative
select product_line,units_sold,MRP,discount_applied,(MRP - discount_applied) * units_sold as revenue from nikesales
where (MRP - discount_applied) * units_sold < 0;

-- 15)List orders where the profit margin (Profit/MRP) is below -10%, segmented by region and sales channel.
select region,sales_channel,mrp,profit,round((profit / mrp) * 100, 2) as profit_margin_percent from nikesales where (profit / mrp) < -0.10
order by region, sales_channel, profit_margin_percent;

-- 16)Calculate the correlation between discount applied and profit for each product line.
select product_line,((avg(discount_applied * profit) - avg(discount_applied) * avg(profit))/(stddev(discount_applied) * stddev(profit)))
as corr_discount_profit from nikesales group by product_line;

-- 17)How many orders were placed per sales channel
select sales_channel,count(distinct product_line) as total_orders from nikesales group by sales_channel order by total_orders desc;

-- 18)For each region, which gender category contributed the most to total profit?
select region, gender_category, total_profit from (select region,gender_category,sum(profit) as total_profit,rank() over 
(partition by region order by sum(profit) desc) as rnk from nikesales group by region, gender_category) ranked where rnk = 1;

-- 19)Identification of underperforming products or categories for strategic action.
select product_name,sum(units_sold) as total_units,sum(revenue) as total_revenue,SUM(profit) as total_profit from nikesales
group by product_name having sum(profit) <= 0 or sum(revenue) < (select avg(total_revenue) from (select sum(revenue) as total_revenue
from nikesales group by product_name) t) order by total_profit asc, total_revenue asc;

-- 20)Impact of discount strategies on profit and sales volume.
select case when discount_applied = 0 then 'No Discount' when discount_applied between 0.01 and 0.10 then '0-10%'
when discount_applied between 0.11 and 0.20 then '11-20%' when discount_applied between 0.21 and 0.30 then '21-30%' else '30%+' end as
discount_band,count(distinct product_name) as total_orders, sum(units_sold) as total_units, sum((MRP - discount_applied) * units_sold)
as total_revenue, sum(profit) as total_profit, round(sum(profit) / nullif(sum((MRP - discount_applied) * units_sold),0) * 100, 2)
as profit_margin_pct from nikesales group by discount_band order by discount_band;

-- 21)Regional sales hotspots and weak zones.
select region,sum(revenue) as total_revenue,sum(profit) as total_profit,count(distinct product_name) as total_orders,
round(avg(profit / nullif(revenue,0)) * 100, 2) as avg_profit_margin_pct from nikesales group by region order by total_revenue desc;

