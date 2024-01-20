/* 
 * OTÁZKA 2
 * Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
 * 
 * Zdrojová data:
 * t_eva_cajzlova_project_SQL_primary_final
 */

CREATE OR REPLACE VIEW v_eva_cajzlova_question2_years AS
	SELECT
		industry_branch_code,
		branch_code_name,
		payroll_year,
		round(avg(payroll_value), 2) AS payroll_avg,
		category_code,
		category_name,
		price_value_unit,
		round(avg(price_value), 2) AS price_avg
	FROM t_eva_cajzlova_project_sql_primary_final
	WHERE
		(category_code = 114201 AND price_year = 2006)
		OR (category_code = 111301 AND price_year = 2006)
		OR (category_code = 114201 AND price_year = 2018)
		OR (category_code = 111301 AND price_year = 2018)
	GROUP BY
		category_code,
		industry_branch_code,
		payroll_year;

CREATE OR REPLACE VIEW v_eva_cajzlova_question2_years_all_branches AS 
	SELECT
		payroll_year,
		industry_branch_code,
		branch_code_name,
		category_code,
		category_name,
		round((payroll_avg / price_avg), 2) AS affordable_amount
	FROM v_eva_cajzlova_question2_years
	ORDER BY
		category_code ASC,
		payroll_year ASC,
		industry_branch_code ASC;

CREATE OR REPLACE TABLE t_eva_cajzlova_project_sql_question2_years_final AS 
	SELECT
		payroll_year,
		category_code,
		category_name,
		round(avg(affordable_amount), 2) AS affordable_amount_avg
	FROM v_eva_cajzlova_question2_years_all_branches
	GROUP BY
		payroll_year,
		category_code
	ORDER BY
		payroll_year ASC;