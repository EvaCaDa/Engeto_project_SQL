/* 
 * OTÁZKA 1
 * Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
 * 
 * Zdrojová data:
 * t_eva_cajzlova_project_SQL_primary_final
 */

CREATE OR REPLACE VIEW v_eva_cajzlova_question1_payroll_year_avg AS
	SELECT
		industry_branch_code,
		branch_code_name,
		payroll_year,
		round(avg(payroll_value), 2) AS average_payroll
	FROM t_eva_cajzlova_project_SQL_primary_final
	GROUP BY
		industry_branch_code,
		payroll_year
	ORDER BY
		industry_branch_code,
		payroll_year;

CREATE OR REPLACE TABLE t_eva_cajzlova_project_sql_question1_final AS
	SELECT
		tab1.*,
		tab2.average_payroll AS last_year_average_payroll,
		tab1.average_payroll - tab2.average_payroll AS interannual_difference,
		CASE
			WHEN tab1.average_payroll > tab2.average_payroll THEN 1
			ELSE 0
		END AS average_payroll_growth
	FROM v_eva_cajzlova_question1_payroll_year_avg tab1
	JOIN v_eva_cajzlova_question1_payroll_year_avg tab2
		ON tab1.payroll_year = tab2.payroll_year + 1
		AND tab1.industry_branch_code = tab2.industry_branch_code;

CREATE OR REPLACE TABLE t_eva_cajzlova_project_sql_question1_payroll_decrease AS
	SELECT *
	FROM t_eva_cajzlova_project_sql_question1_final
	WHERE average_payroll_growth = 0;


SELECT *
FROM t_eva_cajzlova_project_sql_question1_final
ORDER BY
	interannual_difference DESC;

SELECT
	round(avg(interannual_difference), 2) AS average_interannual_difference
FROM t_eva_cajzlova_project_sql_question1_final
ORDER BY
	interannual_difference DESC;