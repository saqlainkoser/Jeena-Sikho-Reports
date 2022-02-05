select 
clinics.clinic_name as "Clinic Name::200",
clinics.doctor_name as "Doctor Name",
clinics.contact_mobile as "Clinic Mobile No.",
concat(monthname(so.creation)," ","|"," ",Year(so.creation)) as "Month | Year",
count(case when so.order_type="Retail Sales" then 1 end) as "Retail Count",
round(SUM(case when so.order_type = "Retail Sales" then rounded_total else 0 end),0) as "Retail Sales:Currency",
count(case when so.order_type="Sales" then 1 end) as "COD Count",
SUM(case when so.order_type = "Sales" then rounded_total else 0 end) as "COD SALES:Currency",
count(case when so.order_type="Retail Sales" then 1 end)+count(case when so.order_type="Sales" then 1 end) as "Total Orders",
SUM(case when so.order_type = "Retail Sales" then rounded_total else 0 end) + SUM(case when so.order_type = "Sales" then rounded_total else 0 end) as "Total Amount:Currency"
from  `tabClinics` as clinics
LEFT JOIN `tabSales Order` so ON so.company=clinics.company_name

where so.doctor_name is not null 
      and monthname(so.creation)=%(from_month)s 
      and Year(so.creation)=%(year)s 
    and (select case when %(company)s = '__ALL__'  then 1=1 else clinics.clinic_name=%(company)s end ) 
    and (  select case when %(dr)s      = '__ALL__'  then 1=1 else clinics.doctor_name=%(dr)s  end )


group by clinics.clinic_name,clinics.doctor_name,Year(so.creation),Year(so.creation),month(so.creation)
/*need to add filter month,clinic,dr.name */
/* after pushing need to add dr.name filter*/
/* select Shuddhi Clinic By Acharya Manish and month - september and year 2021*/