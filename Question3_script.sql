/* 
 * OTÁZKA 3
 * Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
 * 
 * Zdrojová data:
 * t_eva_cajzlova_project_SQL_primary_final
 */

SELECT *
FROM t_eva_cajzlova_project_sql_primary_final;

CREATE VIEW v_eva_cajzlova_question3_avg_price_year AS
	SELECT
		category_code,
		category_name,
		price_value_unit,
		price_year,
		round(avg(price_avg_value), 2) AS average_price
	FROM t_eva_cajzlova_project_sql_primary_final
	GROUP BY
		category_code,
		price_year
	ORDER BY
		category_code,
		price_year;

CREATE VIEW v_eva_cajzlova_question3_interannual_difference_percent AS
	SELECT
		tab1.*,
		tab2.average_price AS last_year_average_price,
		round(((tab1.average_price / tab2.average_price * 100) - 100), 2) AS interannual_difference_percent
	FROM v_eva_cajzlova_question3_avg_price_year tab1
	JOIN v_eva_cajzlova_question3_avg_price_year tab2
		ON tab1.price_year = tab2.price_year + 1
		AND tab1.category_code = tab2.category_code;

CREATE OR REPLACE TABLE t_eva_cajzlova_project_sql_question3_final
	SELECT
		category_code,
		category_name,
		price_value_unit,
		sum(interannual_difference_percent) AS total_price_growth_percent
	FROM v_eva_cajzlova_question3_interannual_difference_percent
	GROUP BY
		category_code
	ORDER BY
		total_price_growth_percent ASC;