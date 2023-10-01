/*Q1. Write a query to display customer_id, customer full name with their title (Mr/Ms), 
 both first name and last name are in upper case, customer_email,  customer_creation_year 
 and display customer’s category after applying below categorization rules:
 i. if CUSTOMER_CREATION_DATE year <2005 then category A
 ii. if CUSTOMER_CREATION_DATE year >=2005 and <2011 then category B 
 iii. if CUSTOMER_CREATION_DATE year>= 2011 then category C
 Expected 52 rows in final output.
 [Note: TABLE to be used - ONLINE_CUSTOMER TABLE] 
Hint:Use CASE statement. create customer_creation_year column with the help of customer_creation_date,
 no permanent change in the table is required. (Here don’t UPDATE or DELETE the columns in the table nor CREATE new tables
 for your representation. A new column name can be used as an alias for your manipulation in case if you are going to use a CASE statement.) 
*/

show databases;
use orders;

## Answer 1.

select case 
		when CUSTOMER_GENDER = 'F' then 'Ms' 
		when CUSTOMER_GENDER = 'M' then 'Mr' 
		end TITLE,
	concat (upper(CUSTOMER_FNAME),' ',upper(CUSTOMER_LNAME)) as CUSTOMER_FULL_NAME,
    CUSTOMER_EMAIL, CUSTOMER_CREATION_DATE, 
    case when CUSTOMER_CREATION_DATE < '2005-01-01' then 'A'
		 when CUSTOMER_CREATION_DATE >= '2005-01-01' and CUSTOMER_CREATION_DATE < '2011-01-01' then 'B'
         when CUSTOMER_CREATION_DATE >= '2011-01-01' then 'C'
         end CUSTOMER_CATEGORY
from online_customer;

/* Q2. Write a query to display the following information for the products which
 have not been sold: product_id, product_desc, product_quantity_avail, product_price,
 inventory values (product_quantity_avail * product_price), New_Price after applying discount
 as per below criteria. Sort the output with respect to decreasing value of Inventory_Value. 
i) If Product Price > 20,000 then apply 20% discount 
ii) If Product Price > 10,000 then apply 15% discount 
iii) if Product Price =< 10,000 then apply 10% discount 
Expected 13 rows in final output.
[NOTE: TABLES to be used - PRODUCT, ORDER_ITEMS TABLE]
Hint: Use CASE statement, no permanent change in table required. 
(Here don’t UPDATE or DELETE the columns in the table nor CREATE new tables for your representation.
 A new column name can be used as an alias for your manipulation in case if you are going to use a CASE statement.)
*/
## Answer 2.


select 
p.PRODUCT_ID, p.PRODUCT_DESC, p.PRODUCT_QUANTITY_AVAIL, p.PRODUCT_PRICE, 
p.PRODUCT_QUANTITY_AVAIL * p.PRODUCT_PRICE as INVENTORY_VALUE,
case 
when p.PRODUCT_PRICE > '200000' then p.PRODUCT_PRICE*0.80
when p.PRODUCT_PRICE > '100000' and p.PRODUCT_PRICE <= '200000' then p.PRODUCT_PRICE*0.85
when p.PRODUCT_PRICE <= '100000' then p.PRODUCT_PRICE*0.90
end as NEW_PRICE
from product as p
LEFT JOIN order_items as o_i on p.PRODUCT_ID = o_i.PRODUCT_ID
where o_i.PRODUCT_ID is null
ORDER BY INVENTORY_VALUE DESC ;


/*Q3. Write a query to display Product_class_code, Product_class_desc, Count of Product type in each product class, 
Inventory Value (p.product_quantity_avail*p.product_price). Information should be displayed for only those
 product_class_code which have more than 1,00,000 Inventory Value. Sort the output with respect to decreasing value of Inventory_Value. 
Expected 9 rows in final output.
[NOTE: TABLES to be used - PRODUCT, PRODUCT_CLASS]
Hint: 'count of product type in each product class' is the count of product_id based on product_class_code.
*/

## Answer 3.


select p.PRODUCT_CLASS_CODE, pc.PRODUCT_CLASS_DESC, count(pc.PRODUCT_CLASS_CODE) as PRODUCT_COUNT,
sum(p.PRODUCT_QUANTITY_AVAIL * p.PRODUCT_PRICE) as INVENTORY_VALUE
from product as p
LEFT JOIN PRODUCT_CLASS as pc ON  p.PRODUCT_CLASS_CODE =  pc.PRODUCT_CLASS_CODE
group by p.PRODUCT_CLASS_CODE having INVENTORY_VALUE > 100000
order by INVENTORY_VALUE DESC;


/* Q4. Write a query to display customer_id, full name, customer_email, customer_phone and
 country of customers who have cancelled all the orders placed by them.
Expected 1 row in the final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ADDRESSS, OREDER_HEADER]
Hint: USE SUBQUERY
*/
 
## Answer 4.

select oh.CUSTOMER_ID, concat(upper(oc.CUSTOMER_FNAME),' ',upper(oc.CUSTOMER_LNAME)) as CUSTOMER_FULL_NAME , oc.CUSTOMER_EMAIL, oc.CUSTOMER_PHONE,a.COUNTRY
from order_header as oh
LEFT JOIN online_customer as oc on oh.CUSTOMER_ID = oc.CUSTOMER_ID
LEFT JOIN address as a on oc.ADDRESS_ID = a.ADDRESS_ID
where oh.customer_id in  (select customer_id from order_header where order_status='Cancelled')
group by oh.CUSTOMER_ID having count(distinct oh.ORDER_STATUS) = 1;


/*Q5. Write a query to display Shipper name, City to which it is catering, num of customer catered by the shipper in the city ,
 number of consignment delivered to that city for Shipper DHL 
Expected 9 rows in the final output
[NOTE: TABLES to be used - SHIPPER, ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]
Hint: The answer should only be based on Shipper_Name -- DHL. The main intent is to find the number
 of customers and the consignments catered by DHL in each city.
 */

## Answer 5.  

select S.SHIPPER_NAME,  ad.CITY, count(distinct(oh.CUSTOMER_ID)) as CUSTOMER_CATERED, count(ad.CITY) as CONSIGNMENTS_DELIVERED  from  shipper as S
left join order_header as oh on S.SHIPPER_ID = oh.SHIPPER_ID
left join online_customer as oc on oh.CUSTOMER_ID=oc.CUSTOMER_ID
left join address as ad on oc.ADDRESS_ID = ad.ADDRESS_ID
where S.SHIPPER_NAME = 'DHL'
group by ad.CITY;

/*Q6. Write a query to display product_id, product_desc, product_quantity_avail, quantity sold and 
show inventory Status of products as per below condition: 

a. For Electronics and Computer categories, 
if sales till date is Zero then show  'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 10% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 50% of quantity sold, show 'Medium inventory, need to add some inventory',
if inventory quantity is more or equal to 50% of quantity sold, show 'Sufficient inventory' 

b. For Mobiles and Watches categories, 
if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 20% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 60% of quantity sold, show 'Medium inventory, need to add some inventory', 
if inventory quantity is more or equal to 60% of quantity sold, show 'Sufficient inventory' 

c. Rest of the categories, 
if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 30% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 70% of quantity sold, show 'Medium inventory, need to add some inventory',
if inventory quantity is more or equal to 70% of quantity sold, show 'Sufficient inventory'
Expected 60 rows in final output
[NOTE: (USE CASE statement) ; TABLES to be used - PRODUCT, PRODUCT_CLASS, ORDER_ITEMS]
Hint:  quantity sold here is product_quantity in order_items table. 
You may use multiple case statements to show inventory status (Low stock, In stock, and Enough stock)
 that meets both the conditions i.e. on products as well as on quantity.
The meaning of the rest of the categories, means products apart from electronics, computers, mobiles, and watches.
*/

## Answer 6.


select p.PRODUCT_ID, p.PRODUCT_DESC, sum(p.PRODUCT_QUANTITY_AVAIL) as PRODUCT_QUANTITY_AVAIL, sum(ifnull(oi.PRODUCT_QUANTITY,0)) as QUANTITY_SOLD, 
sum(p.PRODUCT_QUANTITY_AVAIL) - sum(ifnull(oi.PRODUCT_QUANTITY,0)) as AVAILABLE_QUANTITY,
case when sum(ifnull(oi.PRODUCT_QUANTITY,0))  = 0 then 'No Sales in past, give discount to reduce inventory'
when pc.product_class_desc = 'Electronics' or pc.product_class_desc = 'Computer' then 
	case when  (sum(p.PRODUCT_QUANTITY_AVAIL) - sum(ifnull(oi.PRODUCT_QUANTITY,0))) < 0.1 * sum(ifnull(oi.PRODUCT_QUANTITY,0))  then 'Low inventory, need to add inventory'
		when (sum(p.PRODUCT_QUANTITY_AVAIL) - sum(ifnull(oi.PRODUCT_QUANTITY,0))) < 0.5 * sum(ifnull(oi.PRODUCT_QUANTITY,0)) then 'Medium inventory, need to add some inventory'
        when (sum(p.PRODUCT_QUANTITY_AVAIL) - sum(ifnull(oi.PRODUCT_QUANTITY,0))) >= 0.5 * sum(ifnull(oi.PRODUCT_QUANTITY,0)) then 'Sufficient inventory'
        end 
when pc.product_class_desc = 'Mobiles' or pc.product_class_desc = 'Watches' then 
	case  when  (sum(p.PRODUCT_QUANTITY_AVAIL) - sum(ifnull(oi.PRODUCT_QUANTITY,0))) < 0.2 * sum(ifnull(oi.PRODUCT_QUANTITY,0))  then 'Low inventory, need to add inventory'
		when (sum(p.PRODUCT_QUANTITY_AVAIL) - sum(ifnull(oi.PRODUCT_QUANTITY,0))) < 0.6 * sum(ifnull(oi.PRODUCT_QUANTITY,0)) then 'Medium inventory, need to add some inventory'
        when (sum(p.PRODUCT_QUANTITY_AVAIL) - sum(ifnull(oi.PRODUCT_QUANTITY,0))) >= 0.6 * sum(ifnull(oi.PRODUCT_QUANTITY,0)) then 'Sufficient inventory'
        end 
when pc.product_class_desc != 'Mobiles' or pc.product_class_desc = !'Watches' or pc.product_class_desc != 'Electronics' or pc.product_class_desc != 'Computer' then 
	case  when  (sum(p.PRODUCT_QUANTITY_AVAIL) - sum(ifnull(oi.PRODUCT_QUANTITY,0))) < 0.3 * sum(ifnull(oi.PRODUCT_QUANTITY,0))  then 'Low inventory, need to add inventory'
		when (sum(p.PRODUCT_QUANTITY_AVAIL) - sum(ifnull(oi.PRODUCT_QUANTITY,0))) < 0.7 * sum(ifnull(oi.PRODUCT_QUANTITY,0)) then 'Medium inventory, need to add some inventory'
        when (sum(p.PRODUCT_QUANTITY_AVAIL) - sum(ifnull(oi.PRODUCT_QUANTITY,0))) >= 0.7 * sum(ifnull(oi.PRODUCT_QUANTITY,0)) then 'Sufficient inventory'
        end 
	end as INVENTORY_STATUS
from  product as p
left join product_class as pc on p.product_class_code = pc.product_class_code
left join order_items as oi on p.product_id = oi.product_id
group by p.product_id
order by PRODUCT_ID asc;


/* Q7. Write a query to display order_id and volume of the biggest order (in terms of volume) that can fit in carton id 10 .
Expected 1 row in final output
[NOTE: TABLES to be used - CARTON, ORDER_ITEMS, PRODUCT]
Hint: First find the volume of carton id 10 and then find the order id with products having total volume less than the volume of carton id 10
 */

## Answer 7.

select oi.order_id, sum(oi.product_quantity * p.len * p.width * p.height) as PRODUCT_VOLUME
from order_items as oi
left join product as p on oi.product_id = p.product_id
group by  order_id  having PRODUCT_VOLUME < (select len * width * height as CARTON_VOLUME from carton where carton_id = 10) 
order by product_volume desc
limit 1;

/*Q8. Write a query to display customer id, customer full name, total quantity and total value (quantity*price) 
shipped where mode of payment is Cash and customer last name starts with 'G'
Expected 2 rows in final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_ITEMS, PRODUCT, ORDER_HEADER]
*/

## Answer 8.


select oc.customer_id, concat(oc.customer_fname,' ',oc.customer_lname) as CUSTOMER_FULL_NAME, sum(oi.product_quantity) as TOTAL_QUANTITY, sum(oi.product_quantity*p.product_price) as TOTAL_VALUE
from online_customer as oc
left join order_header as oh on oc.customer_id = oh.customer_id
left join order_items as oi on oh.order_id = oi.order_id
left join product as p on oi.product_id = p.product_id
where oh.payment_mode = 'Cash' and oc.customer_lname LIKE 'G%'
group by CUSTOMER_FULL_NAME ; 

/*Q9. Write a query to display product_id, product_desc and total quantity of products which are sold together 
with product id 201 and are not shipped to city Bangalore and New Delhi. 
[NOTE: TABLES to be used - ORDER_ITEMS, PRODUCT, ORDER_HEADER, ONLINE_CUSTOMER, ADDRESS]
Hint: Display the output in descending order with respect to the sum of product_quantity. 
(USE SUB-QUERY) In final output show only those products , 
 product_id’s which are sold with 201 product_id (201 should not be there in output) and are shipped except Bangalore and New Delhi
 */

## Answer 9.

SELECT S.PRODUCT_ID
, S.PRODUCT_DESC
, S.TOT_QTY
FROM (
SELECT OI.ORDER_ID
, P.PRODUCT_ID
, P.PRODUCT_DESC
, SUM(PRODUCT_QUANTITY) AS TOT_QTY
FROM ORDER_ITEMS OI
INNER JOIN PRODUCT P
WHERE OI.PRODUCT_ID = P.PRODUCT_ID
AND ORDER_ID IN (
SELECT OI.ORDER_ID
FROM ORDER_ITEMS OI
JOIN ORDER_HEADER OH ON OI.ORDER_ID =
OH.ORDER_ID
JOIN ONLINE_CUSTOMER OC ON OH.CUSTOMER_ID =
OC.CUSTOMER_ID
JOIN ADDRESS A ON OC.ADDRESS_ID = A.ADDRESS_ID
WHERE OI.PRODUCT_ID = 201
AND OH.ORDER_STATUS = 'SHIPPED'
AND A.CITY NOT IN (
'BANGALORE'
, 'NEW DELHI'
)
)
AND P.PRODUCT_ID != 201
GROUP BY P.PRODUCT_ID
, PRODUCT_DESC
) S
ORDER BY TOT_QTY DESC;


/* Q10. Write a query to display the order_id, customer_id and customer fullname, 
total quantity of products shipped for order ids which are even and shipped to address where pincode is not starting with "5" 
Expected 15 rows in final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_HEADER, ORDER_ITEMS, ADDRESS]	
 */

## Answer 10.

select oh.order_id, oc.customer_id, concat(oc.customer_fname,' ',oc.customer_lname) as CUSTOMER_FULL_NAME, sum(oi.product_quantity) as TOTAL_QUANTITY
from online_customer as oc
left join order_header as oh on oc.customer_id = oh.customer_id
left join order_items as oi on oh.order_id = oi.order_id
left join address as a on oc.address_id = a.address_id
where oh.order_id % 2 = 0 and a.pincode not like '5%' and oi.product_quantity is not null
group by oc.customer_id;