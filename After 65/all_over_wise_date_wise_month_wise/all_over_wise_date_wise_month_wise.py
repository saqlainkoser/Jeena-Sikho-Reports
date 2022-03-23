# Copyright (c) 2013, Frappe Technologies Pvt. Ltd. and contributors
# For license information, please see license.txt

from __future__ import unicode_literals
import frappe
from frappe import _, scrub
from frappe.utils import getdate, flt, add_to_date, add_days
from six import iteritems
from erpnext.accounts.utils import get_fiscal_year

def execute(filters=None):
	return Analytics(filters).run()

class Analytics(object):
	def __init__(self, filters=None):
		
		self.filters = frappe._dict(filters or {})
		self.date_field = 'transaction_date'
		self.months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
		self.get_period_date_ranges() # yaha date range deside kar li ki kitni dynamic fields laani h like 01-02-2022 se 28-02-2022 to 28 columns dikhenge date wali

	def get_period_date_ranges(self):
		from dateutil.relativedelta import relativedelta, MO     #The relativedelta type is designed to be applied to an existing datetime and can replace specific components of that datetime, or represents an interval of time.
		from_date, to_date = getdate(self.filters.from_date), getdate(self.filters.to_date) # i think taking date - interval from here

		increment = {
			"Monthly": 1,
			"Quarterly": 3,
			"Half-Yearly": 6,
			"Yearly": 12
		}.get(self.filters.range, 1)

		if self.filters.range in ['Monthly', 'Quarterly']:
			from_date = from_date.replace(day=1) # If it using Monthly or Qurterly the it will take first day of the month
		elif self.filters.range == "Yearly":
			from_date = get_fiscal_year(from_date)[1]  # jo bhi fiscal year system me hoga vo lega
		else:
			from_date = from_date  # daily ka case

		self.periodic_daterange = []
		for dummy in range(0, 365):
			if self.filters.range == "Daily":
				period_start_date = from_date
			else:
				period_start_date = add_to_date(from_date, months=increment, days=-1)

			if period_start_date > to_date:
				period_start_date = to_date

			self.periodic_daterange.append(period_start_date)

			from_date = add_days(period_start_date, 1)
			if period_start_date == to_date:
				break

	def run(self):
		self.get_columns()
		self.get_data()
		self.get_chart_data()

		# Skipping total row for tree-view reports
		skip_total_row = 0

		# if self.filters.tree_type in ["Supplier Group", "Item Group", "Customer Group", "Territory"]:
		# 	skip_total_row = 1

		return self.columns, self.data, None, self.chart, None, skip_total_row

	def get_columns(self):
		self.columns = [{
				"label": _("Count of "),
				"fieldname": "entity", # yaha pr entity column se data aaega
				"fieldtype":"Data",
				"width": 250
			}]
		for end_date in self.periodic_daterange:   # maan lete h ki 1st feb se last day feb
			period = self.get_period(end_date)    # string fromat me 28 feb ki date pass hogi
			# frappe.throw(_(period))    # end_date starting date h
			self.columns.append({
				"label": _(period),
				"fieldname": scrub(period), #Returns sluggified string. e.g. `Sales Order` becomes `sales_order`      
				"fieldtype": "Data",
				"width": 89
			})

		self.columns.append({
			"label": _("Total"),
			"fieldname": "total",
			"fieldtype": "Data",
			"width": 120
		})

	def get_data(self):
			self.get_query_data()
			self.get_rows_by_group()

	def get_query_data(self):
		if getdate(self.filters.from_date) < getdate(self.filters.to_date):
			value_field = "s.name"
			

			# self.entries = frappe.db .sql(""" select "Daily Order" as entity, {value_field} as value_field, s.{date_field}
			# 	from `tabSales Order` s where  s.company = %s and s.{date_field} between %s and %s
			# 	and ifnull(s.name, '') != '' group by s.name order by s.name
											
			# """
			self.entries = frappe.db .sql(""" select * from 
												(select "Daily Order" as entity, count({value_field}) as value_field, s.{date_field},s.company
												from `tabSales Order` s group by {date_field}
												union all
												select "Daily Delivery" as entity, count(case when s.status="To Deliver and Bill" then 1 end)  as value_field,  s.{date_field},s.company
												from `tabSales Order` s group by {date_field} )s
												where  s.company = %s and s.{date_field} between %s and %s
											
											
			"""
			.format(date_field=self.date_field, value_field=value_field),
			(self.filters.company, self.filters.from_date, self.filters.to_date), as_dict=1)

			self.get_teams()
		else : frappe.throw(_("To-Date Cannot be less than From-Date"))

	def get_rows(self):
		self.data = []
		self.get_periodic_data()

		for entity, period_data in iteritems(self.entity_periodic_data):
			row = {
				"entity": entity,
				"entity_name": self.entity_names.get(entity)
			}
			total = 0
			for end_date in self.periodic_daterange:
				period = self.get_period(end_date)
				amount = flt(period_data.get(period, 0.0))
				row[scrub(period)] = amount
				total += amount

			row["total"] = total

			if self.filters.tree_type == "Item":
				row["stock_uom"] = period_data.get("stock_uom")

			self.data.append(row)

	def get_rows_by_group(self):
		self.get_periodic_data()
		out = []

		for d in reversed(self.group_entries):
			row = {
				"entity": d.name,
				"indent": self.depth_map.get(d.name)
			}
			total = 0
			for end_date in self.periodic_daterange:
				period = self.get_period(end_date)
				amount = flt(self.entity_periodic_data.get(d.name, {}).get(period, 0.0))
				row[scrub(period)] = amount
				if d.parent and ( d.parent == "Data type"):
					self.entity_periodic_data.setdefault(d.parent, frappe._dict()).setdefault(period, 0.0)
					self.entity_periodic_data[d.parent][period] += amount
				total += amount

			row["total"] = total
			out = [row] + out

		self.data = out

	def get_periodic_data(self):
		self.entity_periodic_data = frappe._dict()

		for d in self.entries:
			period = self.get_period(d.get(self.date_field))
			self.entity_periodic_data.setdefault(d.entity, frappe._dict()).setdefault(period, 0.0)
			self.entity_periodic_data[d.entity][period] += flt(d.value_field)
			
	def get_period(self, posting_date):
		# if self.filters.range == 'Daily':
		# 	period = "Week " + str(posting_date.isocalendar()[1]) + " " + str(posting_date.year)
		if self.filters.range == 'Daily':  # it returns the string version of object
			period = str(posting_date.strftime("%d %b %Y"))  # strftime() is python a function treturns date funtion
		elif self.filters.range == 'Monthly': 
			period = str(self.months[posting_date.month - 1]) + " " + str(posting_date.year) 
		elif self.filters.range == 'Quarterly':
			period = "Quarter " + str(((posting_date.month - 1) // 3) + 1) + " " + str(posting_date.year)
		else:
			year = get_fiscal_year(posting_date, company=self.filters.company)
			period = str(year[0])
		return period

	def get_teams(self):
		self.depth_map = frappe._dict() # ye rowss 

		self.group_entries = frappe.db.sql("""select * from ( 
			  /*select "Data type"      as name, 0 as lft,2 as rgt, '' as parent 
                union 
                select "Daily Order"    as name, 1 as lft, 2 as rgt, "Data type" as parent 
                union 
                select "Daily Delivery" as name, 1 as lft, 1 as rgt, "Daily Order" as parent ) as b */
                
                select "Daily Order"    as name, 0 as lft, 2 as rgt, '' as parent 
                union 
                select "Daily Delivery" as name, 1 as lft, 2 as rgt, '' as parent ) as b"""
		, as_dict=1)

		for d in self.group_entries:
			if d.parent:
				self.depth_map.setdefault(d.name, self.depth_map.get(d.parent) + 1)
			else:
				self.depth_map.setdefault(d.name, 0)

	def get_chart_data(self):
		length = len(self.columns)
		labels = [d.get("label") for d in self.columns[1:length - 1]]
		self.chart = {
			"data": {
				'labels': labels,
				'datasets': []
			},
			"type": "line"
		}
