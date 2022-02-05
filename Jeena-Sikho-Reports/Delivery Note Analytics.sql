select 
so.delivery_note as 'Delivery Note',
count(case when so.workflow_state ='Draft' then 1 end) as 'Draft',
count(case when so.workflow_state ="Dispatch" then 1 end) as 'Dispatch',
count(case when so.workflow_state ="Out for Pickup" then 1 end) as 'Out for Pickup',
count(case when so.workflow_state ="Address Verification" then 1 end) as 'Address Verification',
count(case when so.workflow_state ='Shipped' then 1 end) as 'Shipped',
count(case when so.workflow_state ="Cancelled" then 1 end) as 'Cancelled',
count(case when so.workflow_state ="Pick List Created" then 1 end) as 'Pick List Created',
count(case when so.workflow_state ="Pending For Payment" then 1 end) as 'Pending For Payment',

count(case when so.workflow_state !="Draft" 
            and so.workflow_state !="Dispatch" 
            and so.workflow_state !="Out for Pickup" 
            and so.workflow_state !="Address Verification" 
            and so.workflow_state !="Shipped"
            and so.workflow_state !="Delivered" 
            and so.workflow_state !="Cancelled" 
            and so.workflow_state !="Pick List Created"         
            and so.workflow_state !="Pending For Payment"  then 1 end) as "Others",
            
count(case when so.workflow_state ='Delivered' then 1 end) as 'Delivered',  
count(case when so.workflow_state ="Draft" then 1 end)+          
count(case when so.workflow_state ="Dispatch" then 1 end)+
count(case when so.workflow_state ="Out for Pickup" then 1 end)+
count(case when so.workflow_state ='Address Verification' then 1 end)+
count(case when so.workflow_state ="Shipped" then 1 end)+
count(case when so.workflow_state ='Delivered' then 1 end)+
count(case when so.workflow_state ='Cancelled' then 1 end)+
count(case when so.workflow_state ='Pick List Created' then 1 end)+
count(case when so.workflow_state ='Pending For Payment' then 1 end)+

count(case when so.workflow_state !="Draft" 
            and so.workflow_state !="Dispatch" 
            and so.workflow_state !="Out for Pickup" 
            and so.workflow_state !="Address Verification" 
            and so.workflow_state !="Shipped"
            and so.workflow_state !="Delivered" 
            and so.workflow_state !="Cancelled" 
            and so.workflow_state !="Pick List Created" 
            and so.workflow_state !="Pending For Payment" then 1 end) as 'Grand Total',

concat(round((count(case when so.workflow_state = 'Delivered' then 1 end) * 100) / count(so.workflow_state),0),"%%") as 'Delivered%%'
from
(select delivery_note,courier,workflow_state,name,awb_no,call_center,ccm_code,dispatch_date from  `tabSales Order`)so

 
group by 
so.delivery_note
