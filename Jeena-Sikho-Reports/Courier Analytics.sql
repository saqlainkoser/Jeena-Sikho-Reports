select 
so.courier as 'Courier Name',
count(case when so.status = 'New Order' then 1 end) as 'New Order',
count(case when so.status = 'Draft' then 1 end) as 'Draft',
count(case when so.status = "Cancelled" then 1 end) as 'Cancelled',
count(case when so.status = "Completed" then 1 end) as 'Completed',
count(case when so.status = "Dispatch Pending" then 1 end) as 'Dispatch Pending',
count(case when so.status = 'Pick List Created' then 1 end) as 'Pick List Created',
count(case when so.status ="Shipped" then 1 end) as 'Shipped',
count(case when so.status = 'RTO' then 1 end) as 'RTO',
count(case when so.status ="To Deliver" then 1 end) as 'To Deliver',
count(case when so.status ="To Deliver and Bill" then 1 end) as 'To Deliver and Bill',

count(case when so.status !="Cancelled" 
            and so.status !="Completed" 
            and so.status !="Delivered" 
            and so.status !="Dispatch Pending" 
            and so.status !="Draft"
            and so.status !="New Order" 
            and so.status !="Pick List Created" 
            and so.status !="RTO" 
            and so.status !="Shipped"           
            and so.status !="To Deliver" 
            and so.status !="To Deliver and Bill" then 1 end) as "Others",
count(case when so.status = 'Delivered' then 1 end) as 'Delivered',            
count(case when so.status = "Cancelled" then 1 end)+
count(case when so.status = "Completed" then 1 end)+
count(case when so.status = 'Delivered' then 1 end)+
count(case when so.status = "Dispatch Pending" then 1 end)+
count(case when so.status = 'Draft' then 1 end)+
count(case when so.status = 'New Order' then 1 end)+
count(case when so.status = 'Pick List Created' then 1 end)+
count(case when so.status = 'RTO' then 1 end)+
count(case when so.status ="Shipped" then 1 end)+
count(case when so.status ="To Deliver" then 1 end)+
count(case when so.status ="To Deliver and Bill" then 1 end)+
count(case when so.status !="Cancelled" 
            and so.status !="Completed" 
            and so.status !="Delivered" 
            and so.status !="Dispatch Pending" 
            and so.status !="Draft"
            and so.status !="New Order" 
            and so.status !="Pick List Created" 
            and so.status !="RTO" 
            and so.status !="Shipped"           
            and so.status !="To Deliver" 
            and so.status !="To Deliver and Bill" then 1 end) as 'Grand Total',

concat(round((count(case when so.status = 'Delivered' then 1 end) * 100) / count(so.status),0),"%%") as 'Delivered%%'
from
(select courier,status,name,awb_no,call_center,ccm_code,dispatch_date from  `tabSales Order`)so

 
group by 
so.courier
