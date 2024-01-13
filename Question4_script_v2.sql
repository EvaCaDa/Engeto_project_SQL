/* 
 * OTÁZKA 4
 * Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
 * 
 * Zdrojová data:
 * v_eva_cajzlova_question3_interannual_difference_percent
 * v_eva_cajzlova_question1_payroll_year_avg
 */

CREATE OR REPLACE VIEW v_eva_cajzlova_question4_price_dif_percent_avg AS
	SELECT
		price_year,
		round(avg(interannual_difference_percent), 2) AS price_ia_diff_percent_avg
	FROM v_eva_cajzlova_question3_interannual_difference_percent
	GROUP BY
		price_year;

CREATE OR REPLACE VIEW v_eva_cajzlova_question4_payroll_difference_percent AS 
	SELECT
		tab1.*,
		tab2.average_payroll AS last_year_average_payroll,
		round(((tab1.average_payroll / tab2.average_payroll * 100) - 100), 2) AS interannual_difference_percent
	FROM v_eva_cajzlova_question1_payroll_year_avg tab1
	JOIN v_eva_cajzlova_question1_payroll_year_avg tab2
		ON tab1.payroll_year = tab2.payroll_year + 1
		AND tab1.industry_branch_code = tab2.industry_branch_code;

CREATE OR REPLACE VIEW v_eva_cajzlova_question4_payroll_dif_percent_avg AS
	SELECT
		payroll_year,
		round(avg(interannual_difference_percent), 2) AS payroll_ia_diff_percent_avg
	FROM v_eva_cajzlova_question4_payroll_difference_percent
	GROUP BY
		payroll_year;

CREATE OR REPLACE TABLE t_eva_cajzlova_project_sql_question4_final AS 
	SELECT
		pay.payroll_year AS `year`,
		pay.payroll_ia_diff_percent_avg,
		pri.price_ia_diff_percent_avg,
		(pri.price_ia_diff_percent_avg - pay.payroll_ia_diff_percent_avg) AS growth_difference
	FROM v_eva_cajzlova_question4_payroll_dif_percent_avg pay
	JOIN v_eva_cajzlova_question4_price_dif_percent_avg pri
		ON pay.payroll_year = pri.price_year
	ORDER BY
		growth_difference;

CREATE OR REPLACE TABLE t_eva_cajzlova_project_sql_question4_all_branches_categories AS 
	SELECT
		pay.payroll_year AS `year`,
		pay.industry_branch_code,
		pay.branch_code_name,
		pay.interannual_difference_percent AS payroll_ia_diff_percent,
		pri.category_code,
		pri.category_name,
		pri.price_value_unit,
		pri.interannual_difference_percent AS rice_ia_diff_percent,
		(pri.interannual_difference_percent - pay.interannual_difference_percent) AS growth_difference
	FROM v_eva_cajzlova_question4_payroll_difference_percent pay
	JOIN v_eva_cajzlova_question3_interannual_difference_percent pri
		ON pay.payroll_year = pri.price_year
	HAVING
		growth_difference > 10;

SELECT
	DISTINCT(`year`)
FROM t_eva_cajzlova_project_sql_question4_all_branches_categories
ORDER BY
	`year`;

SELECT *
FROM t_eva_cajzlova_project_sql_question4_all_branches_categories
ORDER BY
	growth_difference DESC;