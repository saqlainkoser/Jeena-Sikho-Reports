// Copyright (c) 2016, Jeena and contributors
// For license information, please see license.txt
/* eslint-disable */

frappe.query_reports["Courier Comparision daily order daily delivery"] = {
	"filters": [
		{
			fieldname: "from_date",
			label: __("From Date"),
			fieldtype: "Date",
			default: "2021-12-01",//frappe.defaults.get_user_default("year_start_date"),
			reqd: 1
		},
		{
			fieldname:"to_date",
			label: __("To Date"),
			fieldtype: "Date",
			default: "2022-03-22",//frappe.defaults.get_user_default("year_end_date"),
			reqd: 1
		},
		{
			fieldname: "company",
			label: __("Company"),
			fieldtype: "Link",
			options: "Company",
			default: "Jeena Sikho Lifecare Limited",//frappe.defaults.get_user_default("Company"),
			reqd: 1
		},
		{
			fieldname: "range",
			label: __("Range"),
			fieldtype: "Select",
			options: [
				{ "value": "Daily", "label": __("Daily") },
				{ "value": "Monthly", "label": __("Monthly") },
				{ "value": "Quarterly", "label": __("Quarterly") },
				{ "value": "Yearly", "label": __("Yearly") }
			],
			default: "Daily",
			reqd: 1
		}
	],

	}
