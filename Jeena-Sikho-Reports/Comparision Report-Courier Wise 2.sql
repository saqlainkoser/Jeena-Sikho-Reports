select
so.name "SALES ORDER:Link/Sales Order:100",
so.ccm_code as "CCM::170",
so.ccm_name as "CCM Name::110",
Day(so.creation) as "Upto Day of month",
monthname(so.creation) as "Month",
concat(year(so.creation),"|",monthname(so.creation)) as "Year",
/* using concat because , this column suming the years below */
count(case when so.order_type = "Retail Sales" then so.name end) as "Retails",
count(case when so.order_type = "Retail Sales" and so.status = 'Delivered' then so.name end) as "Total Retail Delivered",
concat((count(case when so.order_type = "Retail Sales" and so.status = 'Delivered' then so.name end)/count(case when so.order_type = "Retail Sales" then so.name end))*100,'0%%') as "Total Retail Delivered %%", 
sum(case when so.order_type = "Retail Sales" then so.total end)as "Total Retail Amt:Currency",
count(case when so.lead_type ='Fresh Order' and so.order_type = "Retail Sales" then  so.name  end) as "New Retail Orders",
count(case when so.lead_type ='Fresh Order' and so.order_type = "Retail Sales" and so.status = 'Delivered' then  so.name  end) as "New Retail Delivered",
concat((count(case when so.lead_type ='Fresh Order' and so.order_type = "Retail Sales" and so.status = 'Delivered' then  so.name  end)/count(case when so.lead_type ='Fresh Order' and so.order_type = "Retail Sales" then  so.name  end))*100,'0%%') as "New Retail Delivered %%",
sum(case when so.lead_type ='Fresh Order' and so.order_type = "Retail Sales" then so.total end) as "Total New Retail Order  Amt:Currency",
count(case when so.lead_type = 'Existing Customer Order' and so.order_type = "Retail Sales" then  so.name  end)  as "Repeat Retail Order",
count(case when so.lead_type = 'Existing Customer Order' and so.order_type = "Retail Sales" and so.status = 'Delivered' then  so.name  end) as "Delivered",
concat((count(case when so.lead_type = 'Existing Customer Order' and so.order_type = "Retail Sales" and so.status = 'Delivered' then  so.name  end)/count(case when so.lead_type = 'Existing Customer Order' and so.order_type = "Retail Sales" then  so.name  end))*100,'0%%')  as "Repeat Retail Delivered %%",
sum(case when so.lead_type = 'Existing Customer Order' and so.order_type = "Retail Sales" then so.total end)as "Total Repeat Retail Order Amt:Currency",
count(case when so.order_type = "Sales" then  so.name  end) as "COD",
count(case when so.order_type = "Sales" and so.status = 'Delivered' then  so.name  end) as "Total COD Delivered",
concat((count(case when so.order_type = "Sales" and so.status = 'Delivered' then  so.name  end)/count(case when so.order_type = "Sales" then  so.name  end))*100,'0%%') as "Total COD Delivered %%",
sum(case when so.order_type = "Sales"  then so.total end)as "Total COD Amt:Currency",
count(case when  so.lead_type ='Fresh Order' and so.order_type = "Sales" then  so.name  end) as "New COD Order",
count(case when so.lead_type ='Fresh Order' and so.order_type = "Sales" and so.status = 'Delivered' then  so.name  end) as "New COD Delivered",
concat((count(case when so.lead_type ='Fresh Order' and so.order_type = "Sales" and so.status = 'Delivered' then  so.name  end)/count(case when  so.lead_type ='Fresh Order' and so.order_type = "Sales" then  so.name  end))*100,'0%%') AS "New COD Delivered %%",
sum(case when so.order_type = "Sales" and so.lead_type ='Fresh Order' then so.total end) as "Total New COD Order Amt:Currency",
count(case when so.lead_type = 'Existing Customer Order' and so.order_type = "Sales" then  so.name  end)  as "Repeat COD Order",
count(case when so.lead_type = 'Existing Customer Order' and so.order_type = "Sales" and so.status = 'Delivered' then  so.name  end) as "Repeat COD Delivered",
concat((count(case when so.lead_type = 'Existing Customer Order' and so.order_type = "Sales" and so.status = 'Delivered' then  so.name  end)/count(case when so.lead_type = 'Existing Customer Order' and so.order_type = "Sales" then  so.name  end))*100,'0%%') as "Repeat COD Delivery %%",
sum(case when so.order_type = "Sales" and so.lead_type ='Existing Customer Order' then so.total end)as "Total COD OLD Order Amt:Currency",
count(so.name) as "Total Sales Order",
count(case when so.status = 'Delivered' then  so.name  end) as "Total Delivered",
concat((count(case when so.status = 'Delivered' then  so.name  end)/count(so.name))*100,'%%') AS "Total Delivered %%",
sum(so.total) as "Total Amt:Currency"
from (select ccm_code,ccm_name,creation,name,status,order_type,lead_type,total from `tabSales Order`) so 
where Day(so.creation)between 1 and %(day)s and so.ccm_code = %(ccm)s and date(so.creation) between %(from)s and %(to)s
  /* Need to add date filter fromdate to todate */     
  group by /*day(so.creation),*/so.ccm_code, month(so.creation),year(so.creation)
  order by date(so.creation) desc
  /* change the name of the filter to Upto Days */ /*add year filter*/
  /* where Day(so.creation) = 1 between %%(No.of_days)ss  and  so.ccm_code = %%(ccm)ss  and */