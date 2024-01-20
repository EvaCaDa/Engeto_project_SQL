/* 
 * OTÁZKA 3
 * Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
 * 
 * Zdrojová data:
 * t_eva_cajzlova_project_SQL_primary_final
 */

SELECT *
FROM t_eva_cajzlova_project_sql_primary_final;

CREATE OR REPLACE VIEW v_eva_cajzlova_question3_price_year_avg AS
	SELECT
		category_code,
		category_name,
		price_value_unit,
		price_year,
		round(avg(price_value), 2) AS price_avg
	FROM t_eva_cajzlova_project_sql_primary_final
	GROUP BY
		category_code,
		price_year
	ORDER BY
		category_code,
		price_year;

CREATE OR REPLACE VIEW v_eva_cajzlova_question3_interannual_difference_percent AS
	SELECT
		tab1.*,
		tab2.price_avg AS last_year_price_avg,
		round(((tab1.price_avg / tab2.price_avg * 100) - 100), 2) AS interannual_difference_percent
	FROM v_eva_cajzlova_question3_price_year_avg tab1
	JOIN v_eva_cajzlova_question3_price_year_avg tab2
		ON tab1.price_year = tab2.price_year + 1
		AND tab1.category_code = tab2.category_code;

CREATE OR REPLACE TABLE t_eva_cajzlova_project_sql_question3_final
	SELECT
		category_code,
		category_name,
		price_value_unit,
		sum(interannual_difference_percent) AS total_price_growth_percent,
		round(avg(interannual_difference_percent), 2) AS price_growth_percent_avg
	FROM v_eva_cajzlova_question3_interannual_difference_percent
	GROUP BY
		category_code
	ORDER BY
		price_growth_percent_avg ASC;