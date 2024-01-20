/* 
 * OTÁZKA 5
 * Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, 
 * projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?
 * 
 * Zdrojová data:
 * v_eva_cajzlova_question3_interannual_difference_percent
 * v_eva_cajzlova_question4_payroll_difference_percent
 * t_eva_cajzlova_project_sql_secondary_final
 */

CREATE OR REPLACE VIEW v_eva_cajzlova_question5_GDP_difference_percent AS 
	SELECT
		tab1.country,
		tab1.`year`,
		round(tab1.GDP, 2) AS GDP,
		round(tab2.GDP, 2) AS last_year_GDP,
		round(((tab1.GDP / tab2.GDP * 100) - 100), 2) AS GDP_ia_diff_percent
	FROM t_eva_cajzlova_project_sql_secondary_final tab1
	JOIN t_eva_cajzlova_project_sql_secondary_final tab2
		ON tab1.`year` = tab2.`year` + 1
		AND tab1.country = tab2.country
	WHERE
		tab1.country = 'Czech Republic';

CREATE OR REPLACE VIEW v_eva_cajzlova_question5_gdp_pri_pay AS 
	SELECT
		gdp.`year`,
		gdp.GDP_ia_diff_percent,
		pri.price_ia_diff_percent_avg,
		pri2.price_ia_diff_percent_avg AS price_ia_diff_percent_avg_next_year,
		pay.payroll_ia_diff_percent_avg,
		pay2.payroll_ia_diff_percent_avg AS payroll_ia_diff_percent_avg_next_year
	FROM v_eva_cajzlova_question5_GDP_difference_percent gdp
	JOIN v_eva_cajzlova_question4_price_dif_percent_avg pri
		ON gdp.`year` = pri.price_year
	LEFT JOIN v_eva_cajzlova_question4_price_dif_percent_avg pri2
		ON gdp.`year` = pri2.price_year - 1
	JOIN v_eva_cajzlova_question4_payroll_dif_percent_avg pay
		ON gdp.`year` = pay.payroll_year
	LEFT JOIN v_eva_cajzlova_question4_payroll_dif_percent_avg pay2
		ON gdp.`year` = pay2.payroll_year - 1;

SELECT
	*,
	round((median(GDP_ia_diff_percent) OVER ()), 2) AS GDP_median
FROM v_eva_cajzlova_question5_gdp_pri_pay;
-- Medián GDP ve srovnatelném období (2.49) vezmu jako hranici pro výraznější růst.

CREATE OR REPLACE VIEW v_eva_cajzlova_question5_sig_changes AS 
	SELECT
		`year`,
		GDP_ia_diff_percent,
		CASE
			WHEN GDP_ia_diff_percent >= 2.49 THEN 1
			ELSE 0
		END AS GDP_sig_growth,
		price_ia_diff_percent_avg,
		price_ia_diff_percent_avg_next_year,
		CASE
			WHEN price_ia_diff_percent_avg >= 2.49 OR price_ia_diff_percent_avg_next_year >= 2.49 THEN 1
			ELSE 0
		END AS price_sig_growth,
		payroll_ia_diff_percent_avg,
		payroll_ia_diff_percent_avg_next_year,
		CASE
			WHEN payroll_ia_diff_percent_avg >= 2.49 OR payroll_ia_diff_percent_avg_next_year >= 2.49 THEN 1
			ELSE 0
		END AS payroll_sig_growth
	FROM v_eva_cajzlova_question5_gdp_pri_pay;

CREATE OR REPLACE TABLE t_eva_cajzlova_project_sql_question5_final AS 
	SELECT 
		`year`,
		GDP_ia_diff_percent,
		price_ia_diff_percent_avg,
		payroll_ia_diff_percent_avg,
		CASE
			WHEN GDP_sig_growth = 1 AND (price_sig_growth = 1 OR payroll_sig_growth = 1) THEN 1
			WHEN GDP_sig_growth = 0 THEN 2
			ELSE 0
		END AS effect_on_price_payroll,
		CASE
			WHEN GDP_sig_growth = 1 AND price_sig_growth = 1 THEN 1
			WHEN GDP_sig_growth = 0 THEN 2
			WHEN GDP_sig_growth = 1 AND payroll_sig_growth = 1 THEN 3
			ELSE 0
		END AS effect_on_price,
		CASE
			WHEN GDP_sig_growth = 1 AND payroll_sig_growth = 1 THEN 1
			WHEN GDP_sig_growth = 0 THEN 2
			WHEN GDP_sig_growth = 1 AND price_sig_growth = 1 THEN 3
			ELSE 0
		END AS effect_on_payroll
	FROM v_eva_cajzlova_question5_sig_changes;