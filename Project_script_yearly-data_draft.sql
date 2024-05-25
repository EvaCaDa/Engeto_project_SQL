/* 
 * DATA PRO MZDY - PŘÍPRAVA
 * 
 * Zdrojová data:
 * czechia_payroll – Informace o mzdách v různých odvětvích za několikaleté období. Datová sada pochází z Portálu otevřených dat ČR.
 * czechia_payroll_calculation – Číselník kalkulací v tabulce mezd.
 * czechia_payroll_industry_branch – Číselník odvětví v tabulce mezd.
 * czechia_payroll_unit – Číselník jednotek hodnot v tabulce mezd.
 * czechia_payroll_value_type – Číselník typů hodnot v tabulce mezd.
 */

CREATE OR REPLACE TABLE t_eva_cajzlova_czechia_payroll_year_avg AS 
	WITH pay AS (
		SELECT
			industry_branch_code,
			payroll_year,
			round(avg(value), 2) AS payroll_value,
			unit_code
		FROM czechia_payroll cp
		WHERE 1=1
			AND value_type_code = 5958 -- prumerna hruba mzda zamestnance
			AND calculation_code = 100 -- fyzicky plat
			AND industry_branch_code IS NOT NULL -- -- NULL hodnoty v industry_branch_code - nedokazu zjistit, co je to za data, do primarni tabulky nedavam
		GROUP BY
			industry_branch_code,
			payroll_year
	)
	SELECT
		pay.industry_branch_code,
		cpib.name AS branch_code_name,
		pay.payroll_year,
		pay.payroll_value
	FROM pay
	LEFT JOIN czechia_payroll_industry_branch cpib
		ON pay.industry_branch_code = cpib.code
	WHERE
		payroll_year BETWEEN 2006 AND 2018;


/* 
 * DATA PRO CENY - PŘÍPRAVA
 * 
 * Zdrojová data:
 * czechia_price – Informace o cenách vybraných potravin za několikaleté období. Datová sada pochází z Portálu otevřených dat ČR.
 * czechia_price_category – Číselník kategorií potravin, které se vyskytují v našem přehledu.
 */

CREATE OR REPLACE TABLE t_eva_cajzlova_czechia_price_year_avg AS 
	WITH pri AS (
		SELECT
			category_code,
			YEAR(date_from) AS price_year,
			round(avg(value), 2) AS price_value
		FROM czechia_price cp
		WHERE 1=1
			AND region_code IS NULL -- data pro celou ČR
		GROUP BY
			category_code,
			price_year
	)
	SELECT
		pri.category_code,
		cpc.name AS category_name,
		concat(cpc.price_value, ' ', cpc.price_unit) AS price_value_unit,
		pri.price_year,
		pri.price_value
	FROM pri
	LEFT JOIN czechia_price_category cpc
		ON pri.category_code = cpc.code
	WHERE
		price_year BETWEEN 2006 AND 2018;


/* 
 * VYTVOŘENÍ PRIMÁRNÍ TABULKY - SPOJENÍ DAT CEN A MEZD
 */

CREATE OR REPLACE TABLE t_eva_cajzlova_czechia_primary_table_year_avg AS
	SELECT
		pay.payroll_year AS 'year',
		pay.industry_branch_code,
		pay.branch_code_name,
		pay.payroll_value,
		pri.category_code,
		pri.category_name,
		pri.price_value,
		pri.price_value_unit
	FROM t_eva_cajzlova_czechia_payroll_year_avg pay
	JOIN t_eva_cajzlova_czechia_price_year_avg pri
		ON pay.payroll_year = pri.price_year
	WHERE
		pri.price_year BETWEEN 2006 AND 2018;
	

/* 
 * OTÁZKA 1
 * Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
 * 
 * Zdrojová data:
 * t_eva_cajzlova_czechia_payroll_year_final
 */

CREATE OR REPLACE TABLE t_eva_cajzlova_project_sql_question1_year_avg AS 
	WITH growth AS (
		SELECT
			*,
			LAG(payroll_value) OVER (PARTITION BY industry_branch_code ORDER BY payroll_year) AS prev_payroll_value,
			CASE
				WHEN LAG(payroll_value) OVER (PARTITION BY industry_branch_code ORDER BY payroll_year) IS NULL THEN NULL
				WHEN payroll_value > LAG(payroll_value) OVER (PARTITION BY industry_branch_code ORDER BY payroll_year) THEN 1
				WHEN payroll_value = LAG(payroll_value) OVER (PARTITION BY industry_branch_code ORDER BY payroll_year) THEN 100
				ELSE 0
			END AS ia_growth
		FROM t_eva_cajzlova_czechia_payroll_year_avg
	)
	SELECT
		industry_branch_code,
		branch_code_name,
		count(ia_growth) AS cases,
		sum(ia_growth) AS growth_sum
	FROM growth
	GROUP BY
		industry_branch_code;
